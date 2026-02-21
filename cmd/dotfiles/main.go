package main

import (
	"flag"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
)

// ANSI color codes
const (
	colorReset  = "\033[0m"
	colorRed    = "\033[31m"
	colorGreen  = "\033[32m"
	colorYellow = "\033[33m"
	colorBlue   = "\033[34m"
)

// Config holds the installation configuration
type Config struct {
	DotfilesDir string
	HomeDir     string
	DryRun      bool
	Verbose     bool
}

// SymlinkSpec defines a symlink to be created
type SymlinkSpec struct {
	Source string // relative to dotfiles dir
	Target string // relative to home dir
}

// Module represents a group of related configurations
type Module struct {
	Name     string
	Symlinks []SymlinkSpec
	PreHook  func(cfg *Config) error
	PostHook func(cfg *Config) error
}

func main() {
	cfg := &Config{}

	// Parse flags
	flag.BoolVar(&cfg.DryRun, "dry-run", false, "Show what would be done without making changes")
	flag.BoolVar(&cfg.Verbose, "verbose", false, "Enable verbose output")
	flag.Parse()

	// Determine directories
	homeDir, err := os.UserHomeDir()
	if err != nil {
		logError("Failed to get home directory: %v", err)
		os.Exit(1)
	}
	cfg.HomeDir = homeDir
	cfg.DotfilesDir = filepath.Join(homeDir, ".dotfiles")

	// Verify dotfiles directory exists
	if _, err := os.Stat(cfg.DotfilesDir); os.IsNotExist(err) {
		logError("Dotfiles directory not found: %s", cfg.DotfilesDir)
		os.Exit(1)
	}

	logInfo("Installing dotfiles...")
	logInfo("Detected OS: %s/%s", runtime.GOOS, runtime.GOARCH)
	fmt.Println()

	// Define modules
	modules := []Module{
		bashModule(),
		zshModule(),
		gitModule(),
		vimModule(),
		neovimModule(),
		rubyModule(),
		jstsModule(),
		claudeModule(),
	}

	// Install each module
	for _, mod := range modules {
		if err := installModule(cfg, mod); err != nil {
			logError("Failed to install %s: %v", mod.Name, err)
		}
	}

	fmt.Println()
	logSuccess("Done! Some changes may require a new shell session.")
	if runtime.GOOS == "darwin" {
		logInfo("Run 'make macos' to apply macOS-specific settings (Finder, Touch ID for sudo, etc.)")
	}
}

func bashModule() Module {
	return Module{
		Name: "bash",
		Symlinks: []SymlinkSpec{
			{"bash/bash_profile", ".bash_profile"},
			{"bash/bashrc", ".bashrc"},
			{"bash/tmux.conf", ".tmux.conf"},
			{"bash/starship.toml", ".config/starship.toml"},
		},
		PreHook: func(cfg *Config) error {
			// Ensure .config directory exists
			configDir := filepath.Join(cfg.HomeDir, ".config")
			return os.MkdirAll(configDir, 0755)
		},
	}
}

func zshModule() Module {
	return Module{
		Name: "zsh",
		Symlinks: []SymlinkSpec{
			{"zsh/zshrc", ".zshrc"},
			{"zsh/zprofile", ".zprofile"},
		},
		PostHook: func(cfg *Config) error {
			if !commandExists("zsh") {
				logWarning("zsh not installed — skipping zsh post-setup")
				return nil
			}
			// Generate gh completion for zsh
			if commandExists("gh") {
				ghCompletion := filepath.Join(cfg.HomeDir, ".zsh_completions", "_gh")
				if err := os.MkdirAll(filepath.Dir(ghCompletion), 0755); err == nil {
					out, err := exec.Command("gh", "completion", "-s", "zsh").Output()
					if err == nil {
						if err := os.WriteFile(ghCompletion, out, 0644); err == nil {
							logSuccess("Generated gh zsh completion")
						}
					}
				}
			}
			logInfo("Run: bun completions >> ~/.zsh_completions/_bun  (if using bun)")
			logInfo("To switch default shell: chsh -s /bin/zsh")
			logInfo("Install oh-my-zsh: https://ohmyz.sh/#install")
			return nil
		},
	}
}

func gitModule() Module {
	return Module{
		Name: "git",
		Symlinks: []SymlinkSpec{
			{"git/gitconfig", ".gitconfig"},
			{"git/gitignore", ".gitignore"},
			{"git/git_template", ".git_template"},
			{"git/gitattributes", ".gitattributes"},
		},
		PostHook: func(cfg *Config) error {
			// Check for git-secrets
			if !commandExists("git-secrets") {
				logWarning("git-secrets not installed - pre-commit hooks may not work")
				logInfo("Install with: brew install git-secrets")
			}
			// Check for ctags
			if !commandExists("ctags") {
				logWarning("ctags not installed - post-commit tag generation will not work")
				logInfo("Install with: brew install ctags")
			}
			logInfo("Set your email: git config --global user.email \"your@email.com\"")
			return nil
		},
	}
}

func vimModule() Module {
	return Module{
		Name: "vim",
		Symlinks: []SymlinkSpec{
			{"vim/vimrc", ".vimrc"},
			{"vim/vim", ".vim"},
			{"vim/ctags", ".ctags"},
		},
		PostHook: func(cfg *Config) error {
			// Bootstrap Vundle if not present
			vundleDir := filepath.Join(cfg.HomeDir, ".vim", "bundle", "Vundle.vim")
			if _, err := os.Stat(vundleDir); os.IsNotExist(err) {
				if commandExists("git") {
					logInfo("Installing Vundle plugin manager...")
					cmd := exec.Command("git", "clone",
						"https://github.com/VundleVim/Vundle.vim.git", vundleDir)
					if err := cmd.Run(); err != nil {
						logWarning("Failed to clone Vundle: %v", err)
					} else {
						logSuccess("Vundle installed")
						logInfo("Run :PluginInstall in vim to install plugins")
					}
				} else {
					logWarning("Git not found - cannot install Vundle automatically")
				}
			} else {
				logInfo("Vundle already installed")
			}
			return nil
		},
	}
}

func neovimModule() Module {
	return Module{
		Name: "neovim",
		Symlinks: []SymlinkSpec{
			{"nvim", ".config/nvim"},
		},
		PreHook: func(cfg *Config) error {
			// Ensure .config directory exists
			configDir := filepath.Join(cfg.HomeDir, ".config")
			return os.MkdirAll(configDir, 0755)
		},
		PostHook: func(cfg *Config) error {
			if !commandExists("nvim") {
				logWarning("Neovim not installed")
				logInfo("Install with: brew install neovim")
				return nil
			}
			logInfo("Run 'nvim' to install plugins via lazy.nvim")
			logInfo("LSP servers will be installed automatically via Mason")
			return nil
		},
	}
}

func rubyModule() Module {
	return Module{
		Name: "ruby",
		Symlinks: []SymlinkSpec{
			{"ruby/rvmrc", ".rvmrc"},
			{"ruby/gemrc", ".gemrc"},
			{"ruby/irbrc", ".irbrc"},
		},
	}
}

func jstsModule() Module {
	return Module{
		Name: "js-ts",
		Symlinks: []SymlinkSpec{
			{"js-ts/npmrc", ".npmrc"},
		},
	}
}

func claudeModule() Module {
	return Module{
		Name: "claude",
		Symlinks: []SymlinkSpec{
			{"claude/settings.json", ".claude/settings.json"},
			{"claude/CLAUDE.md", ".claude/CLAUDE.md"},
			{"claude/agents", ".claude/agents"},
			{"claude/commands", ".claude/commands"},
			{"claude/hooks", ".claude/hooks"},
			{"claude/summarize-session.sh", ".local/bin/summarize-session.sh"},
		},
		PreHook: func(cfg *Config) error {
			// Ensure .claude directory exists
			claudeDir := filepath.Join(cfg.HomeDir, ".claude")
			if err := os.MkdirAll(claudeDir, 0755); err != nil {
				return err
			}
			// Ensure .local/bin directory exists
			localBinDir := filepath.Join(cfg.HomeDir, ".local", "bin")
			return os.MkdirAll(localBinDir, 0755)
		},
	}
}

func installModule(cfg *Config, mod Module) error {
	fmt.Printf("--- Setting up %s ---\n", mod.Name)

	// Run pre-hook if defined
	if mod.PreHook != nil {
		if err := mod.PreHook(cfg); err != nil {
			return fmt.Errorf("pre-hook failed: %w", err)
		}
	}

	// Create symlinks
	for _, spec := range mod.Symlinks {
		source := filepath.Join(cfg.DotfilesDir, spec.Source)
		target := filepath.Join(cfg.HomeDir, spec.Target)

		if err := safeSymlink(cfg, source, target); err != nil {
			logError("Failed to link %s: %v", filepath.Base(target), err)
		}
	}

	// Run post-hook if defined
	if mod.PostHook != nil {
		if err := mod.PostHook(cfg); err != nil {
			return fmt.Errorf("post-hook failed: %w", err)
		}
	}

	fmt.Println()
	return nil
}

func safeSymlink(cfg *Config, source, target string) error {
	targetName := filepath.Base(target)

	// Validate source exists
	if _, err := os.Stat(source); os.IsNotExist(err) {
		return fmt.Errorf("source does not exist: %s", source)
	}

	// Ensure parent directory exists
	targetDir := filepath.Dir(target)
	if err := os.MkdirAll(targetDir, 0755); err != nil {
		return fmt.Errorf("failed to create parent directory: %w", err)
	}

	// Check if target exists
	info, err := os.Lstat(target)
	if err == nil {
		if info.Mode()&os.ModeSymlink != 0 {
			// It's a symlink, remove it
			if !cfg.DryRun {
				if err := os.Remove(target); err != nil {
					return fmt.Errorf("failed to remove existing symlink: %w", err)
				}
			}
		} else {
			// It's a regular file/directory, back it up
			backupPath := target + ".orig"
			logInfo("%s exists, backing up to %s.orig", targetName, targetName)
			if !cfg.DryRun {
				if err := os.Rename(target, backupPath); err != nil {
					return fmt.Errorf("failed to backup: %w", err)
				}
			}
		}
	}

	// Create symlink
	if cfg.DryRun {
		logInfo("[DRY-RUN] Would link %s -> %s", targetName, source)
	} else {
		if err := os.Symlink(source, target); err != nil {
			return fmt.Errorf("failed to create symlink: %w", err)
		}
		logSuccess("Linked %s", targetName)
	}

	return nil
}

func commandExists(cmd string) bool {
	_, err := exec.LookPath(cmd)
	return err == nil
}

// Logging functions
func logInfo(format string, args ...interface{}) {
	fmt.Printf("%s[INFO]%s %s\n", colorBlue, colorReset, fmt.Sprintf(format, args...))
}

func logSuccess(format string, args ...interface{}) {
	fmt.Printf("%s[OK]%s %s\n", colorGreen, colorReset, fmt.Sprintf(format, args...))
}

func logWarning(format string, args ...interface{}) {
	fmt.Printf("%s[WARN]%s %s\n", colorYellow, colorReset, fmt.Sprintf(format, args...))
}

func logError(format string, args ...interface{}) {
	fmt.Fprintf(os.Stderr, "%s[ERROR]%s %s\n", colorRed, colorReset, fmt.Sprintf(format, args...))
}
