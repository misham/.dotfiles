# Claude Code Configuration

This directory contains configuration for [Claude Code](https://claude.ai/code), Anthropic's CLI tool.

## Development Workflow

Follow TDD (red/green/refactor) methodology for all implementations. Write failing tests first, then implement the minimum code to make them pass.

## Debugging

When asked to investigate a bug or discrepancy, start fresh with the current state of data. Do not carry over stale IDs, assumptions, or prior hypotheses from earlier in the conversation without re-verifying them.

## Communication

When asked a clarifying question, answer the specific question being asked. Do not assume a broader or different interpretation. If unsure, ask for clarification rather than guessing.

## Code Editing

When editing files, verify you are editing the file that is actually used in the running application, not a similarly-named unused or deprecated file. Check imports and routes to confirm.

## Compact Instructions

When compacting, always preserve:

- All file modifications with exact paths
- Decisions made and user-stated criteria/requirements
- Configuration details (API keys, account info, IDs)
- Current task state, blockers, and next steps
- Anything the user explicitly asked to remember

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

<!--# BEGIN SNYK GLOBAL RULE -->
---
alwaysApply: true
always_on: true
trigger: always_on
applyTo: "**"
description: Snyk Security At Inception
---

# Project security best practices

- Always run snyk_code_scan tool for new first party code that is generated in a Snyk-supported language.
- If any security issues are found based on newly introduced or modified code or dependencies, attempt to fix the issues using the results context from Snyk.
- Rescan the code after fixing the issues to ensure that the issues were fixed and that there are no newly introduced issues.
- Repeat this process until no new issues are found.
<!--# END SNYK GLOBAL RULE -->
