# thorough-review

Source-first, verification-oriented code review with self-improving feedback loops.

## What It Does

This plugin implements a structured code review methodology based on three principles:

1. **Source-first** — read full source files for context, not just diffs
2. **Verification-oriented** — verify specific claims against actual code
3. **Concrete fixes** — every finding includes a specific remediation

It supports two review modes: **code review** (branch diffs, specific files) and **plan review** (implementation plans with verification tables).

All findings are confidence-scored (0-100) with only findings >= 75 reported, reducing noise and false positives.

## Installation

The plugin lives in the dotfiles repo at `claude/plugins/thorough-review/`. It is registered in `claude/plugins/installed_plugins.json` and available automatically when the dotfiles are installed.

## Usage

### `/thorough-review`

Run a thorough code review. Accepts a target argument:

```
/thorough-review --branch          # Review branch changes against main
/thorough-review src/api/          # Review specific directory
/thorough-review path/to/plan.md   # Review a plan document
/thorough-review                   # Auto-detect from context
```

### `/thorough-review-improve`

Promote accumulated feedback patterns into permanent rules:

```
/thorough-review-improve
```

This command reads feedback from all projects, identifies patterns appearing in 2+ projects, and proposes promotions to the global feedback file or the skill itself.

## Self-Improvement Loop

After each review, the plugin captures feedback:
- **False positives** — findings that were wrong get recorded to prevent recurrence
- **Missed patterns** — things the review should have caught get added as boosters
- **Calibrations** — severity adjustments for project-specific context

Feedback accumulates in `.claude/thorough-review.local.md` (per-project) and `~/.claude/thorough-review.global.md` (cross-project). Use `/thorough-review-improve` to promote stable patterns into permanent rules.

## Interaction with Other Tools

| Tool | Relationship |
|------|-------------|
| `code-review` plugin | Posts to GitHub PRs. This plugin does local reviews. Complementary. |
| `pr-review-toolkit` plugin | Different trigger phrases. No conflict. |
| `/gemini_review` | Cross-model validation. Can be used after this plugin for a second opinion. |