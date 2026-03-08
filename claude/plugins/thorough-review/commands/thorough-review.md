---
description: Run a thorough, structured code review with source-first analysis
model: opus
argument-hint: "[target: file, directory, --branch, or plan path]"
allowed-tools: Read, Grep, Glob, Bash, Task
---

Run a thorough code review using the thorough-review skill methodology.

## Step 1: Load Local Feedback

Read `.claude/thorough-review.local.md` if it exists. Also read `~/.claude/thorough-review.global.md` if it exists. These contain false-positive rules, calibrations, missed patterns, and project conventions to apply during the review.

## Step 2: Detect Review Target

Determine the review mode from the argument `$ARGUMENTS`:

- If argument is a file path ending in `.md` inside a plans directory → **plan review**
- If argument is `--branch` or empty and there are uncommitted/branch changes → **code review** of branch diff
- If argument is a file or directory path → **code review** of those specific files
- If ambiguous → ask the user

## Step 3: Gather Inputs

For **plan review:**
- Read the plan file
- Extract all file paths, line numbers, and code claims referenced in the plan

For **code review:**
- Run `git diff main...HEAD --stat` to scope changed files
- Run `git log main..HEAD --oneline` to list commits
- Run `git diff main...HEAD` for the full diff
- Read the project's CLAUDE.md for conventions

## Step 4: Dispatch Reviewer Agent

Launch the `thorough-reviewer` agent (via Task tool) with a prompt containing:
- The review mode (plan or code)
- All inputs gathered above
- Local and global feedback rules (false positives, calibrations, conventions)
- The output format from `${CLAUDE_PLUGIN_ROOT}/skills/thorough-review/references/output-format.md`

If `${CLAUDE_PLUGIN_ROOT}` is not set, locate the plugin directory via `~/.dotfiles/claude/plugins/thorough-review/` or by searching `~/.claude/plugins/`.

## Step 5: Present and Follow Up

Present the agent's findings to the user. Then offer next steps:
- "Want me to fix the critical/important issues?"
- "Any findings I should not have flagged? (saves to local feedback)"
- "Anything I missed?"

If the user provides feedback, append it to `.claude/thorough-review.local.md` using the Edit tool (or create the file with Write if it doesn't exist).