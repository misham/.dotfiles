package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"runtime"
)

// ExternalTool defines a tool to fetch from GitHub releases
type ExternalTool struct {
	Name       string // display name
	GitHubRepo string // owner/repo
	BinaryName string // binary name in release assets (without os/arch suffix)
	TargetDir  string // relative to dotfiles dir
}

var externalTools = []ExternalTool{
	{
		Name:       "kb",
		GitHubRepo: "misham/kb",
		BinaryName: "kb",
		TargetDir:  "claude/bin",
	},
}

type githubRelease struct {
	TagName string        `json:"tag_name"`
	Assets  []githubAsset `json:"assets"`
}

type githubAsset struct {
	Name               string `json:"name"`
	BrowserDownloadURL string `json:"browser_download_url"`
}

// assetName returns the expected release asset name for the current platform
func (t ExternalTool) assetName() string {
	arch := runtime.GOARCH
	return fmt.Sprintf("%s-%s-%s", t.BinaryName, runtime.GOOS, arch)
}

// fetchLatestRelease gets the latest release info from GitHub
func fetchLatestRelease(repo string) (*githubRelease, error) {
	url := fmt.Sprintf("https://api.github.com/repos/%s/releases/latest", repo)
	resp, err := http.Get(url)
	if err != nil {
		return nil, fmt.Errorf("failed to fetch release: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		return nil, fmt.Errorf("GitHub API returned %d", resp.StatusCode)
	}

	var release githubRelease
	if err := json.NewDecoder(resp.Body).Decode(&release); err != nil {
		return nil, fmt.Errorf("failed to parse release: %w", err)
	}
	return &release, nil
}

// downloadFile downloads a URL to a local file path atomically.
// It writes to a temp file first, then renames on success to avoid
// leaving corrupt partial files on disk.
func downloadFile(url, destPath string) error {
	resp, err := http.Get(url)
	if err != nil {
		return fmt.Errorf("download failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		return fmt.Errorf("download returned %d", resp.StatusCode)
	}

	tmp, err := os.CreateTemp(filepath.Dir(destPath), ".tmp-"+filepath.Base(destPath))
	if err != nil {
		return fmt.Errorf("failed to create temp file: %w", err)
	}
	tmpPath := tmp.Name()

	if _, err := io.Copy(tmp, resp.Body); err != nil {
		tmp.Close()
		os.Remove(tmpPath)
		return fmt.Errorf("failed to write file: %w", err)
	}

	if err := tmp.Close(); err != nil {
		os.Remove(tmpPath)
		return fmt.Errorf("failed to close temp file: %w", err)
	}

	if err := os.Chmod(tmpPath, 0755); err != nil {
		os.Remove(tmpPath)
		return fmt.Errorf("failed to set permissions: %w", err)
	}

	if err := os.Rename(tmpPath, destPath); err != nil {
		os.Remove(tmpPath)
		return fmt.Errorf("failed to move file into place: %w", err)
	}

	return nil
}

// fetchTool downloads the latest version of an external tool
func fetchTool(cfg *Config, tool ExternalTool, force bool) error {
	targetDir := filepath.Join(cfg.DotfilesDir, tool.TargetDir)
	targetPath := filepath.Join(targetDir, tool.BinaryName)

	// Skip if already present and not forcing update
	if !force {
		if _, err := os.Stat(targetPath); err == nil {
			logInfo("%s already installed", tool.Name)
			return nil
		}
	}

	if cfg.DryRun {
		logInfo("[DRY-RUN] Would fetch latest %s from github.com/%s", tool.Name, tool.GitHubRepo)
		return nil
	}

	logInfo("Fetching latest %s from github.com/%s...", tool.Name, tool.GitHubRepo)

	release, err := fetchLatestRelease(tool.GitHubRepo)
	if err != nil {
		return err
	}

	assetName := tool.assetName()
	var downloadURL string
	for _, asset := range release.Assets {
		if asset.Name == assetName {
			downloadURL = asset.BrowserDownloadURL
			break
		}
	}
	if downloadURL == "" {
		return fmt.Errorf("no release asset found for %s (looking for %s)", tool.Name, assetName)
	}

	if err := os.MkdirAll(targetDir, 0755); err != nil {
		return fmt.Errorf("failed to create directory: %w", err)
	}

	if err := downloadFile(downloadURL, targetPath); err != nil {
		return err
	}

	logSuccess("Installed %s %s", tool.Name, release.TagName)
	return nil
}

// fetchAllTools downloads all external tools, returning the first error encountered
func fetchAllTools(cfg *Config, force bool) error {
	var firstErr error
	for _, tool := range externalTools {
		if err := fetchTool(cfg, tool, force); err != nil {
			logWarning("Failed to fetch %s: %v", tool.Name, err)
			if firstErr == nil {
				firstErr = fmt.Errorf("failed to fetch %s: %w", tool.Name, err)
			}
		}
	}
	return firstErr
}
