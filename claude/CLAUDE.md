# Claude Code Configuration

This directory contains configuration for [Claude Code](https://claude.ai/code), Anthropic's CLI tool.

## Structure

```
claude/
├── settings.json    # Claude Code settings
├── CLAUDE.md        # This file (project instructions)
├── agents/          # Custom agent definitions
└── commands/        # Custom slash commands
```

## Installation

The dotfiles installer symlinks this directory to `~/.claude/`:

```bash
make install
```

This creates:
```
~/.claude/settings.json → ~/.dotfiles/claude/settings.json
~/.claude/CLAUDE.md     → ~/.dotfiles/claude/CLAUDE.md
~/.claude/agents/       → ~/.dotfiles/claude/agents/
~/.claude/commands/     → ~/.dotfiles/claude/commands/
```

## Settings

The `settings.json` configures Claude Code behavior:

- **Default mode:** Plan mode for thoughtful responses
- **Plugins:** Various integrations enabled
- **Notifications:** Terminal notifications on completion

## Custom Agents

Agents are specialized assistants for specific tasks. Located in `agents/`:

| Agent | Purpose |
|-------|---------|
| `codebase-analyzer` | Analyze codebase architecture |
| `codebase-locator` | Find specific code patterns |
| `codebase-pattern-finder` | Search for code patterns |
| `research-analyzer` | Analyze research findings |
| `research-locator` | Locate research materials |
| `web-search-researcher` | Web research assistant |

### Using Agents

```bash
# In Claude Code
/agent codebase-analyzer
```

### Creating New Agents

Create a markdown file in `agents/` with:

```markdown
# Agent Name

Description of what the agent does.

## Instructions

Detailed instructions for the agent's behavior.
```

## Custom Commands

Commands are slash commands for common workflows. Located in `commands/`:

| Command | Purpose |
|---------|---------|
| `/commit` | Create well-formatted commits |
| `/create_plan` | Create implementation plans |
| `/implement_plan` | Execute implementation plans |
| `/research_codebase` | Research codebase patterns |
| `/add-to-changelog` | Update changelog |

### Using Commands

```bash
# In Claude Code
/commit
/create_plan Add user authentication
```

### Creating New Commands

Create a markdown file in `commands/` with:

```markdown
# Command Name

Description of the command.

## Usage

How to use the command.

## Template

The template or instructions for execution.
```

## Integration with Neovim

The Neovim configuration includes Claude integration:

- **avante.nvim:** Cursor-like AI experience (`<leader>ca` to ask)
- **toggleterm:** Run Claude Code CLI (`<leader>cc`)

See [nvim/README.md](../nvim/README.md) for details.

## Environment Variables

Set your API key for direct API access (used by avante.nvim):

```bash
export ANTHROPIC_API_KEY="sk-ant-..."
```

Add to `~/.bashrc.local` for persistence.

## Tips

### Project-Specific Instructions

Create a `CLAUDE.md` in your project root with project-specific instructions that Claude Code will automatically read.

### Memory

Claude Code maintains conversation context. Use `/clear` to reset.

### Cost Management

- Use `/compact` for shorter responses
- Plan mode thinks before acting (more thorough but uses more tokens)
