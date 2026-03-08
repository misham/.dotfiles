---
name: thorough-review
description: >
  This skill should be used when the user asks for a "thorough review",
  "source-first review", "deep code review", "thorough code review",
  "review with verification", "review the plan thoroughly", or explicitly
  invokes the thorough-review methodology. Provides a structured, source-first
  review methodology with confidence-based filtering and self-improving feedback
  loops. This skill is NOT triggered by generic phrases like "review code" or
  "code review" — those are handled by other review plugins.
version: 1.0.0
---

# Thorough Review Methodology

## Overview

This skill implements a three-principle code review methodology: source-first context, verification-oriented analysis, and concrete remediations. It differs from generic review tools by requiring full source file reads (not just diffs), verification tables for plan reviews, and confidence-scored findings with explicit thresholds.

## Review Modes

Two review modes, auto-detected from context:

| Mode | Input | When |
|------|-------|------|
| **Plan Review** | A plan/spec document | User references a plan file or asks to review a plan |
| **Code Review** | Branch diff or specific files | User asks to review code, changes, a branch, or specific files |

## Core Principles

1. **Read source files, not just diffs.** After getting the diff, read each changed file in full to understand surrounding context. Cross-reference between files when changes span multiple components.

2. **Verify claims against code.** For plan reviews: check every file path, line number, and code snippet the plan references. For code reviews: verify that the code does what the commit message/PR description says it does.

3. **Every finding has a concrete fix.** Not "this could be a problem" but "change line 45 of `src/api/handler.ts` from X to Y because Z."

## Context Triage Protocol

For large changesets (10+ files), apply context triage to manage the context window:

1. Read the full diff first to identify all changed files
2. Classify files by risk level:
   - **High-risk:** entry points, security-sensitive logic, core data models, API handlers, authentication/authorization code
   - **Low-risk:** test fixtures, CSS/styling, pure UI components, generated files, documentation
3. Read high-risk files in full first
4. Read low-risk files only if the diff is ambiguous or the changes interact with high-risk code
5. For files exceeding ~500 lines, use Grep to locate relevant definitions instead of reading the entire file

## Conflict Resolution

When a user asks for a "quick review" or "fast review", this skill does NOT activate — defer to simpler review tools. This skill activates only for requests that explicitly want depth: "thorough", "deep", "source-first", "with verification".

If another review agent is already active in the session, defer rather than duplicate work.

## Post-Review Protocol

After presenting findings, offer three next steps:
- "Want me to fix the critical/important issues?"
- "Any findings I should not have flagged? (saves to local feedback)"
- "Anything I missed?"

Capture user feedback by appending to `.claude/thorough-review.local.md` using the Edit tool. If the file does not exist, create it with the Write tool using the format documented in `${CLAUDE_PLUGIN_ROOT}/skills/thorough-review/references/self-improvement.md`.

## Plugin Root Resolution

If `${CLAUDE_PLUGIN_ROOT}` is not set (e.g., running outside plugin context), locate the plugin directory using these fallback paths in order:
1. `~/.dotfiles/claude/plugins/thorough-review/`
2. Search `~/.claude/plugins/` for a directory containing a `thorough-review` plugin

## Additional Resources

For detailed output format templates, see `${CLAUDE_PLUGIN_ROOT}/skills/thorough-review/references/output-format.md`.

For confidence scoring rules, penalties, and boosters, see `${CLAUDE_PLUGIN_ROOT}/skills/thorough-review/references/confidence-rules.md`.

For local feedback file format and self-improvement workflow, see `${CLAUDE_PLUGIN_ROOT}/skills/thorough-review/references/self-improvement.md`.

For project flavor identification before starting reviews, see `${CLAUDE_PLUGIN_ROOT}/skills/thorough-review/references/project-fingerprints.md`.