# Dotfiles

Personal configuration files for macOS and Linux.

## Quick Start

```bash
# Clone the repository
git clone https://github.com/misham/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Install (requires Go)
make install

# Or build and run manually
make build
./bin/dotfiles
```

## Migrating from Previous Version

If you have an older version of these dotfiles installed:

```bash
# Pull the latest changes
cd ~/.dotfiles
git pull

# Build the new Go installer
make build

# Preview what will change (recommended)
./bin/dotfiles -dry-run -verbose

# Run the installer
./bin/dotfiles
```

**What happens:**
- Existing symlinks are updated in place
- Regular files (not symlinks) are backed up to `*.orig`
- New configs (neovim, claude) are added
- Safe to run multiple times (idempotent)

**New additions to set up manually:**

```bash
# Neovim (optional, for new nvim config)
brew install neovim
nvim  # First launch installs plugins automatically

# Reload your shell
source ~/.bash_profile
```

## What's Included

| Directory | Description |
|-----------|-------------|
| `bash/` | Shell configuration (bashrc, aliases, functions, tmux) |
| `git/` | Git configuration (aliases, hooks, templates) |
| `vim/` | Vim configuration (legacy, with Vundle) |
| `nvim/` | **Neovim configuration** (modern, with lazy.nvim + LSP) |
| `ruby/` | Ruby environment (gemrc, irbrc, rvmrc) |
| `js-ts/` | JavaScript/TypeScript (npmrc) |
| `claude/` | Claude Code settings, agents, and commands |
| `macos/` | macOS-specific setup (Brewfile, defaults) |

## Installation

### Prerequisites

- Go 1.21+ (for the installer)
- Git

### Install Everything

```bash
make install
```

This creates symlinks for all configurations:

```
~/.bashrc        → ~/.dotfiles/bash/bashrc
~/.bash_profile  → ~/.dotfiles/bash/bash_profile
~/.tmux.conf     → ~/.dotfiles/bash/tmux.conf
~/.gitconfig     → ~/.dotfiles/git/gitconfig
~/.vimrc         → ~/.dotfiles/vim/vimrc
~/.config/nvim   → ~/.dotfiles/nvim
~/.npmrc         → ~/.dotfiles/js-ts/npmrc
~/.claude/       → ~/.dotfiles/claude/*
...
```

### Preview Changes (Dry Run)

```bash
make install-dry-run
```

### Install Specific Module

Edit and run the Go installer directly:

```bash
./bin/dotfiles -verbose
```

## Components

### Bash

Shell configuration with:
- Custom prompt via [Starship](https://starship.rs/)
- Useful aliases (`ll`, `la`, `..`, etc.)
- Functions (`extract`, `project`)
- Vi mode editing
- History management
- Completion scripts

**Local overrides:** Create `~/.bashrc.local` for machine-specific settings.

### Git

- Extensive aliases (`co`, `ci`, `st`, `hist`, etc.)
- Delta pager for better diffs
- Git hooks template (ctags, secrets scanning)
- Global gitignore

**Local overrides:** Create `~/.gitconfig.local` for user email, signing keys, etc.

```gitconfig
# ~/.gitconfig.local
[user]
    email = your@email.com
    signingkey = YOUR_GPG_KEY
```

### Neovim

Modern Neovim setup with:
- **lazy.nvim** plugin manager
- **LSP** support for Go, Ruby, TypeScript, Python, and more
- **Treesitter** for syntax highlighting
- **Telescope** for fuzzy finding
- **Claude AI** integration (avante.nvim + CLI)
- **Tmux** integration (seamless navigation)

See [nvim/README.md](nvim/README.md) for detailed documentation.

### Tmux

- Vi-mode copy/paste
- Vim-tmux-navigator integration (Ctrl+hjkl)
- Custom prefix: `Ctrl-j`
- Sensible splits and window management

### Claude Code

Custom agents and commands for Claude Code CLI:
- Planning workflows
- Codebase analysis
- Research tools

## Development

### Project Structure

```
.dotfiles/
├── cmd/dotfiles/        # Go installer source
│   ├── main.go
│   └── main_test.go
├── test/
│   └── Dockerfile       # Integration test container
├── .github/workflows/   # CI/CD
│   ├── ci.yml          # Tests on push
│   └── release.yml     # Binary releases
├── Makefile
└── [config directories]
```

### Commands

```bash
make help          # Show all commands
make build         # Build installer for current platform
make build-all     # Cross-compile for all platforms
make test          # Run integration tests in Docker
make install       # Build and install dotfiles
make clean         # Remove build artifacts
```

### Testing

Tests run in Docker to verify symlinks are created correctly:

```bash
make test
```

### CI/CD

- **On push:** Runs integration tests, validates configs
- **On tag:** Builds binaries for macOS/Linux (amd64/arm64)

## Customization

### Adding New Configurations

1. Create a directory for your tool (e.g., `mytool/`)
2. Add your config files
3. Update `cmd/dotfiles/main.go` to add a new module:

```go
func mytoolModule() Module {
    return Module{
        Name: "mytool",
        Symlinks: []SymlinkSpec{
            {"mytool/config", ".mytoolrc"},
        },
    }
}
```

4. Add to the modules list in `main()`
5. Run `make install`

### Local Machine Overrides

Most configs support local overrides that aren't tracked in git:

| Config | Local Override |
|--------|----------------|
| bashrc | `~/.bashrc.local` |
| gitconfig | `~/.gitconfig.local` |
| vimrc | `~/.vimrc.local` |

## Projects Workflow

The `project` function provides quick access to project directories:

```bash
# Set in bashrc
export PROJECT_DIR="Projects"

# Usage
project myapp    # cd ~/Projects/myapp && source .project.env
```

Create `.project.env` in project roots for project-specific environment variables.

## Credits

Inspired by and borrowed from:
- [dotfiles.org](http://dotfiles.org)
- [ryanb/dotfiles](https://github.com/ryanb/dotfiles)
- [rtomayko/dotfiles](https://github.com/rtomayko/dotfiles)
- [mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles)

## License

MIT
