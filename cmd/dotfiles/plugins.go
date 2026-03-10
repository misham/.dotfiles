package main

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strings"
	"time"
)

const pluginCmdTimeout = 2 * time.Minute

// PluginManifest represents the claude/plugins.json file
type PluginManifest struct {
	Marketplaces []string      `json:"marketplaces"`
	Plugins      []PluginEntry `json:"plugins"`
}

// PluginEntry represents a single plugin in the manifest
type PluginEntry struct {
	Name string `json:"name"`
}

// InstallResult tracks the outcome of a single install operation
type InstallResult struct {
	Name    string
	Success bool
	Error   string
}

// extractMarketplace extracts the marketplace name from a "plugin@marketplace" string.
func extractMarketplace(pluginName string) (string, bool) {
	idx := strings.LastIndex(pluginName, "@")
	if idx < 0 {
		return "", false
	}
	return pluginName[idx+1:], true
}

// installPlugins reads the manifest and installs marketplaces and plugins via the claude CLI.
func installPlugins(cfg *Config) error {
	if !commandExists("claude") {
		logWarning("claude CLI not found, skipping plugin installation")
		return nil
	}

	manifestPath := filepath.Join(cfg.DotfilesDir, "claude", "plugins.json")
	data, err := os.ReadFile(manifestPath)
	if err != nil {
		if os.IsNotExist(err) {
			logWarning("No claude/plugins.json found, skipping plugin installation")
			return nil
		}
		return fmt.Errorf("reading plugin manifest: %w", err)
	}

	var manifest PluginManifest
	if err := json.Unmarshal(data, &manifest); err != nil {
		return fmt.Errorf("parsing plugin manifest: %w", err)
	}

	var results []InstallResult
	failedMarketplaces := make(map[string]bool)

	// Install marketplaces first
	for _, repo := range manifest.Marketplaces {
		result := InstallResult{Name: "marketplace:" + repo}
		if cfg.DryRun {
			logInfo("[DRY-RUN] Would add marketplace: %s", repo)
			result.Success = true
		} else {
			logInfo("Adding marketplace: %s", repo)
			ctx, cancel := context.WithTimeout(context.Background(), pluginCmdTimeout)
			cmd := exec.CommandContext(ctx, "claude", "plugin", "marketplace", "add", repo)
			output, err := cmd.CombinedOutput()
			cancel()
			if err != nil {
				result.Error = fmt.Sprintf("%v: %s", err, string(output))
				logWarning("Failed to add marketplace %s: %s", repo, result.Error)
				parts := strings.SplitN(repo, "/", 2)
				if len(parts) == 2 {
					failedMarketplaces[parts[1]] = true
				}
			} else {
				result.Success = true
				logSuccess("Added marketplace: %s", repo)
			}
		}
		results = append(results, result)
	}

	// Install plugins, skipping those from failed marketplaces
	for _, plugin := range manifest.Plugins {
		result := InstallResult{Name: "plugin:" + plugin.Name}

		if marketplace, ok := extractMarketplace(plugin.Name); ok {
			if failedMarketplaces[marketplace] {
				result.Error = fmt.Sprintf("skipped: marketplace %s failed to add", marketplace)
				logWarning("Skipping plugin %s: marketplace %s failed", plugin.Name, marketplace)
				results = append(results, result)
				continue
			}
		}

		if cfg.DryRun {
			logInfo("[DRY-RUN] Would install plugin: %s", plugin.Name)
			result.Success = true
		} else {
			logInfo("Installing plugin: %s", plugin.Name)
			ctx, cancel := context.WithTimeout(context.Background(), pluginCmdTimeout)
			cmd := exec.CommandContext(ctx, "claude", "plugin", "install", plugin.Name)
			output, err := cmd.CombinedOutput()
			cancel()
			if err != nil {
				result.Error = fmt.Sprintf("%v: %s", err, string(output))
				logWarning("Failed to install plugin %s: %s", plugin.Name, result.Error)
			} else {
				result.Success = true
				logSuccess("Installed plugin: %s", plugin.Name)
			}
		}
		results = append(results, result)
	}

	printInstallSummary(results)
	return nil
}

// knownMarketplacesFile represents the structure of ~/.claude/plugins/known_marketplaces.json
type knownMarketplacesFile map[string]struct {
	Source struct {
		Repo string `json:"repo"`
	} `json:"source"`
}

// installedPluginsFile represents the structure of ~/.claude/plugins/installed_plugins.json
type installedPluginsFile struct {
	Version int                        `json:"version"`
	Plugins map[string]json.RawMessage `json:"plugins"`
}

// dumpPluginManifest reads the live plugin state and writes claude/plugins.json
func dumpPluginManifest(cfg *Config) error {
	pluginsDir := filepath.Join(cfg.HomeDir, ".claude", "plugins")

	// Read marketplaces
	marketplacesData, err := os.ReadFile(filepath.Join(pluginsDir, "known_marketplaces.json"))
	if err != nil {
		return fmt.Errorf("reading known_marketplaces.json: %w", err)
	}

	var mFile knownMarketplacesFile
	if err := json.Unmarshal(marketplacesData, &mFile); err != nil {
		return fmt.Errorf("parsing known_marketplaces.json: %w", err)
	}

	var marketplaces []string
	for _, entry := range mFile {
		marketplaces = append(marketplaces, entry.Source.Repo)
	}
	sort.Strings(marketplaces)

	// Read installed plugins
	installedData, err := os.ReadFile(filepath.Join(pluginsDir, "installed_plugins.json"))
	if err != nil {
		return fmt.Errorf("reading installed_plugins.json: %w", err)
	}

	var iFile installedPluginsFile
	if err := json.Unmarshal(installedData, &iFile); err != nil {
		return fmt.Errorf("parsing installed_plugins.json: %w", err)
	}

	var pluginEntries []PluginEntry
	for key := range iFile.Plugins {
		pluginEntries = append(pluginEntries, PluginEntry{Name: key})
	}
	sort.Slice(pluginEntries, func(i, j int) bool {
		return pluginEntries[i].Name < pluginEntries[j].Name
	})

	manifest := PluginManifest{
		Marketplaces: marketplaces,
		Plugins:      pluginEntries,
	}

	output, err := json.MarshalIndent(manifest, "", "  ")
	if err != nil {
		return fmt.Errorf("marshaling manifest: %w", err)
	}
	output = append(output, '\n')

	manifestPath := filepath.Join(cfg.DotfilesDir, "claude", "plugins.json")
	if cfg.DryRun {
		logInfo("[DRY-RUN] Would write %s:", manifestPath)
		fmt.Println(string(output))
		return nil
	}

	if err := os.WriteFile(manifestPath, output, 0644); err != nil {
		return fmt.Errorf("writing plugin manifest: %w", err)
	}

	logSuccess("Plugin manifest written to %s", manifestPath)
	logInfo("Marketplaces: %d, Plugins: %d", len(marketplaces), len(pluginEntries))
	return nil
}

// printInstallSummary prints a summary of install results.
func printInstallSummary(results []InstallResult) {
	var succeeded, failed int
	var failures []InstallResult
	for _, r := range results {
		if r.Success {
			succeeded++
		} else {
			failed++
			failures = append(failures, r)
		}
	}

	fmt.Println()
	logInfo("Plugin install summary: %d succeeded, %d failed", succeeded, failed)
	for _, f := range failures {
		logError("  FAILED: %s — %s", f.Name, f.Error)
	}
}
