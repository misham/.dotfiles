package main

import (
	"os"
	"path/filepath"
	"testing"
)

// TestInstallation runs the full installation and verifies symlinks
func TestInstallation(t *testing.T) {
	// Skip if not in integration test mode
	if os.Getenv("INTEGRATION_TEST") != "1" {
		t.Skip("Skipping integration test (set INTEGRATION_TEST=1 to run)")
	}

	homeDir, err := os.UserHomeDir()
	if err != nil {
		t.Fatalf("Failed to get home directory: %v", err)
	}

	dotfilesDir := filepath.Join(homeDir, ".dotfiles")

	// Create config and run installation
	cfg := &Config{
		HomeDir:     homeDir,
		DotfilesDir: dotfilesDir,
		DryRun:      false,
		Verbose:     true,
	}

	modules := []Module{
		bashModule(),
		gitModule(),
		vimModule(),
		neovimModule(),
		rubyModule(),
		jstsModule(),
		claudeModule(),
	}

	for _, mod := range modules {
		if err := installModule(cfg, mod); err != nil {
			t.Errorf("Failed to install %s: %v", mod.Name, err)
		}
	}

	// Verify symlinks
	tests := []struct {
		name   string
		target string
		source string
	}{
		// Bash
		{"bash_profile", ".bash_profile", "bash/bash_profile"},
		{"bashrc", ".bashrc", "bash/bashrc"},
		{"tmux.conf", ".tmux.conf", "bash/tmux.conf"},
		{"starship.toml", ".config/starship.toml", "bash/starship.toml"},
		// Git
		{"gitconfig", ".gitconfig", "git/gitconfig"},
		{"gitignore", ".gitignore", "git/gitignore"},
		{"git_template", ".git_template", "git/git_template"},
		{"gitattributes", ".gitattributes", "git/gitattributes"},
		// Vim
		{"vimrc", ".vimrc", "vim/vimrc"},
		{"vim", ".vim", "vim/vim"},
		{"ctags", ".ctags", "vim/ctags"},
		// Neovim
		{"nvim", ".config/nvim", "nvim"},
		// Ruby
		{"rvmrc", ".rvmrc", "ruby/rvmrc"},
		{"gemrc", ".gemrc", "ruby/gemrc"},
		{"irbrc", ".irbrc", "ruby/irbrc"},
		// JS/TS
		{"npmrc", ".npmrc", "js-ts/npmrc"},
		// Claude
		{"claude/settings.json", ".claude/settings.json", "claude/settings.json"},
		{"claude/CLAUDE.md", ".claude/CLAUDE.md", "claude/CLAUDE.md"},
		{"claude/agents", ".claude/agents", "claude/agents"},
		{"claude/commands", ".claude/commands", "claude/commands"},
		{"claude/statusline.ts", ".claude/statusline.ts", "claude/statusline.ts"},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			targetPath := filepath.Join(homeDir, tc.target)
			expectedSource := filepath.Join(dotfilesDir, tc.source)

			// Check if symlink exists
			info, err := os.Lstat(targetPath)
			if err != nil {
				t.Errorf("%s: symlink does not exist: %v", tc.name, err)
				return
			}

			if info.Mode()&os.ModeSymlink == 0 {
				t.Errorf("%s: not a symlink", tc.name)
				return
			}

			// Check symlink target
			actualTarget, err := os.Readlink(targetPath)
			if err != nil {
				t.Errorf("%s: failed to read symlink: %v", tc.name, err)
				return
			}

			if actualTarget != expectedSource {
				t.Errorf("%s: wrong target\n  got:  %s\n  want: %s", tc.name, actualTarget, expectedSource)
			}
		})
	}
}

// TestIdempotency verifies running install twice doesn't break anything
func TestIdempotency(t *testing.T) {
	if os.Getenv("INTEGRATION_TEST") != "1" {
		t.Skip("Skipping integration test (set INTEGRATION_TEST=1 to run)")
	}

	homeDir, err := os.UserHomeDir()
	if err != nil {
		t.Fatalf("Failed to get home directory: %v", err)
	}

	cfg := &Config{
		HomeDir:     homeDir,
		DotfilesDir: filepath.Join(homeDir, ".dotfiles"),
		DryRun:      false,
		Verbose:     false,
	}

	modules := []Module{
		bashModule(),
		gitModule(),
		vimModule(),
	}

	// Run twice
	for i := 0; i < 2; i++ {
		for _, mod := range modules {
			if err := installModule(cfg, mod); err != nil {
				t.Errorf("Run %d: Failed to install %s: %v", i+1, mod.Name, err)
			}
		}
	}

	// Verify key symlinks still work
	bashrc := filepath.Join(homeDir, ".bashrc")
	info, err := os.Lstat(bashrc)
	if err != nil {
		t.Fatalf("bashrc missing after second run: %v", err)
	}
	if info.Mode()&os.ModeSymlink == 0 {
		t.Error("bashrc is not a symlink after second run")
	}
}

// TestDryRun verifies dry-run mode doesn't create files
func TestDryRun(t *testing.T) {
	// Create temp directory for testing
	tmpHome, err := os.MkdirTemp("", "dotfiles-test-*")
	if err != nil {
		t.Fatalf("Failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(tmpHome)

	// Get actual dotfiles dir
	realHome, _ := os.UserHomeDir()
	dotfilesDir := filepath.Join(realHome, ".dotfiles")

	cfg := &Config{
		HomeDir:     tmpHome,
		DotfilesDir: dotfilesDir,
		DryRun:      true,
		Verbose:     false,
	}

	// Run bash module in dry-run
	if err := installModule(cfg, bashModule()); err != nil {
		t.Errorf("Dry run failed: %v", err)
	}

	// Verify no files were created
	bashrc := filepath.Join(tmpHome, ".bashrc")
	if _, err := os.Lstat(bashrc); !os.IsNotExist(err) {
		t.Error("Dry run created .bashrc when it shouldn't have")
	}
}
