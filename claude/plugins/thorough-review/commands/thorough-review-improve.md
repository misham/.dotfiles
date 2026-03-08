---
description: Promote review feedback patterns into permanent skill rules
allowed-tools: Read, Edit, Write, Grep, Glob
---

Analyze accumulated review feedback and promote stable patterns into permanent rules.

## Step 1: Gather Feedback

Read feedback files from all available sources:
- `.claude/thorough-review.local.md` in the current project
- `~/.claude/thorough-review.global.md` if it exists (includes project registry)

Use the project registry in global.md to locate other project directories with `thorough-review.local.md` files. If no registry exists, scan `~/.claude/projects/` as a fallback.

After gathering, update the project registry in global.md with the current project path and date.

## Step 2: Identify Promotable Patterns

Analyze the collected feedback for patterns that are stable enough to promote:

**To global feedback file** (`~/.claude/thorough-review.global.md`):
- False positives that appear in 2+ projects → promote to global false_positives
- Missed patterns that recur across 2+ projects → promote to global missed_patterns
- Set initial `confirmation_count` based on occurrences found

**To skill itself** (`${CLAUDE_PLUGIN_ROOT}/skills/thorough-review/references/confidence-rules.md`):
- Patterns that appear in 3+ projects AND have `confirmation_count >= 5` in global → promote to permanent skill rules

If `${CLAUDE_PLUGIN_ROOT}` is not set, locate the plugin directory via `~/.dotfiles/claude/plugins/thorough-review/` or by searching `~/.claude/plugins/`.

## Step 3: Present Proposals

Present each proposed promotion to the user with:
- The pattern being promoted
- Where it was found (which projects)
- Where it would be promoted to (global file or skill)
- The confirmation count (how many times the pattern was seen/confirmed)
- The rationale

Do not make changes without user approval.

## Step 4: Execute Approved Changes

For each approved promotion:
- Use Edit to add entries to the target file (global or skill references)
- Use Edit to remove promoted entries from the source local files
- Mark entries with `promoted_at` date, `promoted_from` project list, and `confirmation_count`
- Update the project registry in global.md