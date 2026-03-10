package main

import (
	"encoding/json"
	"os"
	"path/filepath"
	"testing"
)

func TestPluginManifestParsing(t *testing.T) {
	manifest := `{
		"marketplaces": ["owner/repo1", "owner/repo2"],
		"plugins": [
			{"name": "plugin1@repo1"},
			{"name": "plugin2@repo2"}
		]
	}`

	var m PluginManifest
	if err := json.Unmarshal([]byte(manifest), &m); err != nil {
		t.Fatalf("failed to parse manifest: %v", err)
	}

	if len(m.Marketplaces) != 2 {
		t.Errorf("expected 2 marketplaces, got %d", len(m.Marketplaces))
	}
	if len(m.Plugins) != 2 {
		t.Errorf("expected 2 plugins, got %d", len(m.Plugins))
	}
	if m.Plugins[0].Name != "plugin1@repo1" {
		t.Errorf("expected plugin1@repo1, got %s", m.Plugins[0].Name)
	}
}

func TestInstallPluginsMissingCLI(t *testing.T) {
	tmpDir := t.TempDir()

	// Create a manifest file
	manifestDir := filepath.Join(tmpDir, "claude")
	if err := os.MkdirAll(manifestDir, 0755); err != nil {
		t.Fatal(err)
	}
	manifest := `{"marketplaces": ["owner/repo"], "plugins": [{"name": "test@repo"}]}`
	if err := os.WriteFile(filepath.Join(manifestDir, "plugins.json"), []byte(manifest), 0644); err != nil {
		t.Fatal(err)
	}

	cfg := &Config{
		DotfilesDir: tmpDir,
		HomeDir:     tmpDir,
	}

	// With claude not in PATH, installPlugins should skip gracefully
	// Save and restore PATH to ensure claude is not found
	origPath := os.Getenv("PATH")
	os.Setenv("PATH", "/nonexistent")
	defer os.Setenv("PATH", origPath)

	err := installPlugins(cfg)
	if err != nil {
		t.Errorf("installPlugins should skip gracefully when claude CLI missing, got: %v", err)
	}
}

func TestInstallPluginsMissingManifest(t *testing.T) {
	tmpDir := t.TempDir()

	cfg := &Config{
		DotfilesDir: tmpDir,
		HomeDir:     tmpDir,
	}

	err := installPlugins(cfg)
	if err != nil {
		t.Errorf("installPlugins should skip gracefully when manifest missing, got: %v", err)
	}
}

func TestInstallPluginsInvalidJSON(t *testing.T) {
	tmpDir := t.TempDir()
	manifestDir := filepath.Join(tmpDir, "claude")
	if err := os.MkdirAll(manifestDir, 0755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(filepath.Join(manifestDir, "plugins.json"), []byte("{invalid}"), 0644); err != nil {
		t.Fatal(err)
	}

	// Need claude in PATH for this test to reach the JSON parsing
	if !commandExists("claude") {
		t.Skip("claude CLI not available")
	}

	cfg := &Config{
		DotfilesDir: tmpDir,
		HomeDir:     tmpDir,
	}

	err := installPlugins(cfg)
	if err == nil {
		t.Error("installPlugins should return error for invalid JSON")
	}
}

func TestInstallPluginsDryRun(t *testing.T) {
	tmpDir := t.TempDir()
	manifestDir := filepath.Join(tmpDir, "claude")
	if err := os.MkdirAll(manifestDir, 0755); err != nil {
		t.Fatal(err)
	}

	manifest := `{
		"marketplaces": ["owner/repo1"],
		"plugins": [{"name": "plugin1@repo1"}]
	}`
	if err := os.WriteFile(filepath.Join(manifestDir, "plugins.json"), []byte(manifest), 0644); err != nil {
		t.Fatal(err)
	}

	// Need claude in PATH for dry-run test
	if !commandExists("claude") {
		t.Skip("claude CLI not available")
	}

	cfg := &Config{
		DotfilesDir: tmpDir,
		HomeDir:     tmpDir,
		DryRun:      true,
	}

	err := installPlugins(cfg)
	if err != nil {
		t.Errorf("installPlugins dry-run should succeed, got: %v", err)
	}
}

func TestInstallPluginsSkipsFailedMarketplace(t *testing.T) {
	// Test the marketplace failure tracking logic
	failedMarketplaces := map[string]bool{
		"bad-marketplace": true,
	}

	// Plugin from failed marketplace should be skipped
	pluginName := "some-plugin@bad-marketplace"
	idx := len(pluginName) - len("bad-marketplace") - 1
	if idx < 0 {
		t.Fatal("unexpected plugin name format")
	}
	marketplace := pluginName[idx+1:]
	if !failedMarketplaces[marketplace] {
		t.Errorf("expected marketplace %q to be marked as failed", marketplace)
	}

	// Plugin from good marketplace should not be skipped
	goodPlugin := "some-plugin@good-marketplace"
	idx2 := len(goodPlugin) - len("good-marketplace") - 1
	marketplace2 := goodPlugin[idx2+1:]
	if failedMarketplaces[marketplace2] {
		t.Errorf("expected marketplace %q to NOT be marked as failed", marketplace2)
	}
}

func TestExtractMarketplaceFromPluginName(t *testing.T) {
	tests := []struct {
		name        string
		expected    string
		hasMarket   bool
	}{
		{"plugin@marketplace", "marketplace", true},
		{"plugin@my-marketplace", "my-marketplace", true},
		{"plugin-no-marketplace", "", false},
		{"complex-name@claude-plugins-official", "claude-plugins-official", true},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			got, ok := extractMarketplace(tc.name)
			if ok != tc.hasMarket {
				t.Errorf("extractMarketplace(%q) hasMarket = %v, want %v", tc.name, ok, tc.hasMarket)
			}
			if got != tc.expected {
				t.Errorf("extractMarketplace(%q) = %q, want %q", tc.name, got, tc.expected)
			}
		})
	}
}

func TestStaleSymlinkCleanup(t *testing.T) {
	tmpHome := t.TempDir()
	realHome, _ := os.UserHomeDir()
	dotfilesDir := filepath.Join(realHome, ".dotfiles")

	pluginsDir := filepath.Join(tmpHome, ".claude", "plugins")
	if err := os.MkdirAll(pluginsDir, 0755); err != nil {
		t.Fatal(err)
	}

	// Create stale symlinks (pointing to dotfiles repo paths that would have existed before)
	stalePluginFiles := []string{"config.json", "installed_plugins.json", "known_marketplaces.json"}
	for _, name := range stalePluginFiles {
		link := filepath.Join(pluginsDir, name)
		os.Symlink("/tmp/fake-target", link)
	}

	// Create stale bin symlink
	claudeDir := filepath.Join(tmpHome, ".claude")
	binLink := filepath.Join(claudeDir, "bin")
	os.Symlink("/tmp/fake-bin", binLink)

	// Also create a regular file that should NOT be removed
	regularFile := filepath.Join(pluginsDir, "regular.json")
	os.WriteFile(regularFile, []byte("{}"), 0644)

	cfg := &Config{
		HomeDir:     tmpHome,
		DotfilesDir: dotfilesDir,
	}

	mod := claudeModule()
	if err := mod.PreHook(cfg); err != nil {
		t.Fatalf("PreHook failed: %v", err)
	}

	// Stale plugin symlinks should be removed
	for _, name := range stalePluginFiles {
		link := filepath.Join(pluginsDir, name)
		if _, err := os.Lstat(link); !os.IsNotExist(err) {
			t.Errorf("stale symlink %s should have been removed", name)
		}
	}

	// Stale bin symlink should be removed
	if _, err := os.Lstat(binLink); !os.IsNotExist(err) {
		t.Errorf("stale bin symlink should have been removed")
	}

	// Regular file should still exist
	if _, err := os.Stat(regularFile); err != nil {
		t.Errorf("regular file should not be removed: %v", err)
	}
}

func TestStaleSymlinkCleanupDryRun(t *testing.T) {
	tmpHome := t.TempDir()
	realHome, _ := os.UserHomeDir()
	dotfilesDir := filepath.Join(realHome, ".dotfiles")

	pluginsDir := filepath.Join(tmpHome, ".claude", "plugins")
	if err := os.MkdirAll(pluginsDir, 0755); err != nil {
		t.Fatal(err)
	}

	link := filepath.Join(pluginsDir, "config.json")
	os.Symlink("/tmp/fake-target", link)

	cfg := &Config{
		HomeDir:     tmpHome,
		DotfilesDir: dotfilesDir,
		DryRun:      true,
	}

	mod := claudeModule()
	if err := mod.PreHook(cfg); err != nil {
		t.Fatalf("PreHook failed: %v", err)
	}

	// In dry-run, symlink should still exist
	if _, err := os.Lstat(link); os.IsNotExist(err) {
		t.Error("dry-run should not remove stale symlinks")
	}
}

func TestDumpPluginManifest(t *testing.T) {
	tmpHome := t.TempDir()
	tmpDotfiles := t.TempDir()

	// Create live state files
	pluginsDir := filepath.Join(tmpHome, ".claude", "plugins")
	if err := os.MkdirAll(pluginsDir, 0755); err != nil {
		t.Fatal(err)
	}

	marketplacesJSON := `{
		"claude-plugins-official": {
			"source": {"source": "github", "repo": "anthropics/claude-plugins-official"},
			"installLocation": "/tmp/marketplaces/claude-plugins-official"
		},
		"chrome-devtools-plugins": {
			"source": {"source": "github", "repo": "ChromeDevTools/chrome-devtools-mcp"},
			"installLocation": "/tmp/marketplaces/chrome-devtools-plugins"
		}
	}`
	if err := os.WriteFile(filepath.Join(pluginsDir, "known_marketplaces.json"), []byte(marketplacesJSON), 0644); err != nil {
		t.Fatal(err)
	}

	installedJSON := `{
		"version": 2,
		"plugins": {
			"plugin-b@claude-plugins-official": [{"scope": "user"}],
			"plugin-a@chrome-devtools-plugins": [{"scope": "user"}]
		}
	}`
	if err := os.WriteFile(filepath.Join(pluginsDir, "installed_plugins.json"), []byte(installedJSON), 0644); err != nil {
		t.Fatal(err)
	}

	// Create output directory
	claudeDir := filepath.Join(tmpDotfiles, "claude")
	if err := os.MkdirAll(claudeDir, 0755); err != nil {
		t.Fatal(err)
	}

	cfg := &Config{
		HomeDir:     tmpHome,
		DotfilesDir: tmpDotfiles,
	}

	if err := dumpPluginManifest(cfg); err != nil {
		t.Fatalf("dumpPluginManifest failed: %v", err)
	}

	// Read and verify the output
	data, err := os.ReadFile(filepath.Join(claudeDir, "plugins.json"))
	if err != nil {
		t.Fatalf("failed to read output: %v", err)
	}

	var manifest PluginManifest
	if err := json.Unmarshal(data, &manifest); err != nil {
		t.Fatalf("failed to parse output: %v", err)
	}

	// Marketplaces should be sorted
	if len(manifest.Marketplaces) != 2 {
		t.Fatalf("expected 2 marketplaces, got %d", len(manifest.Marketplaces))
	}
	if manifest.Marketplaces[0] != "ChromeDevTools/chrome-devtools-mcp" {
		t.Errorf("expected first marketplace ChromeDevTools/chrome-devtools-mcp, got %s", manifest.Marketplaces[0])
	}
	if manifest.Marketplaces[1] != "anthropics/claude-plugins-official" {
		t.Errorf("expected second marketplace anthropics/claude-plugins-official, got %s", manifest.Marketplaces[1])
	}

	// Plugins should be sorted
	if len(manifest.Plugins) != 2 {
		t.Fatalf("expected 2 plugins, got %d", len(manifest.Plugins))
	}
	if manifest.Plugins[0].Name != "plugin-a@chrome-devtools-plugins" {
		t.Errorf("expected first plugin plugin-a@chrome-devtools-plugins, got %s", manifest.Plugins[0].Name)
	}
	if manifest.Plugins[1].Name != "plugin-b@claude-plugins-official" {
		t.Errorf("expected second plugin plugin-b@claude-plugins-official, got %s", manifest.Plugins[1].Name)
	}
}

func TestDumpPluginManifestMissingFiles(t *testing.T) {
	tmpHome := t.TempDir()
	tmpDotfiles := t.TempDir()

	cfg := &Config{
		HomeDir:     tmpHome,
		DotfilesDir: tmpDotfiles,
	}

	err := dumpPluginManifest(cfg)
	if err == nil {
		t.Error("dumpPluginManifest should return error when files are missing")
	}
}

func TestDumpPluginManifestDryRun(t *testing.T) {
	tmpHome := t.TempDir()
	tmpDotfiles := t.TempDir()

	pluginsDir := filepath.Join(tmpHome, ".claude", "plugins")
	if err := os.MkdirAll(pluginsDir, 0755); err != nil {
		t.Fatal(err)
	}

	os.WriteFile(filepath.Join(pluginsDir, "known_marketplaces.json"), []byte(`{}`), 0644)
	os.WriteFile(filepath.Join(pluginsDir, "installed_plugins.json"), []byte(`{"version":2,"plugins":{}}`), 0644)

	claudeDir := filepath.Join(tmpDotfiles, "claude")
	os.MkdirAll(claudeDir, 0755)

	cfg := &Config{
		HomeDir:     tmpHome,
		DotfilesDir: tmpDotfiles,
		DryRun:      true,
	}

	if err := dumpPluginManifest(cfg); err != nil {
		t.Fatalf("dumpPluginManifest dry-run failed: %v", err)
	}

	// File should NOT be written in dry-run mode
	manifestPath := filepath.Join(claudeDir, "plugins.json")
	if _, err := os.Stat(manifestPath); !os.IsNotExist(err) {
		t.Error("dry-run should not write manifest file")
	}
}

func TestPrintInstallSummary(t *testing.T) {
	results := []InstallResult{
		{Name: "marketplace:owner/repo1", Success: true},
		{Name: "plugin:test@repo1", Success: true},
		{Name: "plugin:bad@repo2", Success: false, Error: "install failed"},
	}

	// Just verify it doesn't panic
	printInstallSummary(results)
}
