---
description: Compact a finished plan, import to kb, and clean up source files
model: opus
argument-hint: [path to plan file]
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(~/.claude/bin/kb:*), Bash(git:*), Bash(~/.claude/scripts/*), Agent
---

# Compact Plan to KB

Compact a finished or in-progress implementation plan, import it into the kb database, and clean up the source markdown files (both the plan and any referenced research documents).

## Step 1: Locate the Plan

1. **If `$ARGUMENTS` is provided**, use it as the path to the plan file.
2. **If `$ARGUMENTS` is empty**, find the most recent plan:
   ```bash
   find docs/ai/plans -maxdepth 1 -name '*.md' -print0 2>/dev/null | xargs -0 ls -t 2>/dev/null | head -1
   ```
   If no plan is found, ask the user to specify a path.

3. Read the plan file FULLY.

## Step 2: Compact the Plan

Update the plan content following these rules:

1. **Replace inline code examples with file references** — use `file:line` references to the actual codebase instead of duplicating code in the plan
2. **Update implementation notes** — reflect what was actually done vs. what was planned
3. **Mark completed phases** — check off success criteria that were met
4. **Remove redundant detail** — collapse verbose sections into concise summaries while preserving key decisions, discoveries, and file references
5. **Preserve the structure** — keep the plan template sections (Overview, Current State, Phases, Testing Strategy, etc.)
6. **Update frontmatter** — add `status: complete` (or `status: in-progress`) and `compacted: YYYY-MM-DD`

Write the compacted plan back to the same file path.

## Step 3: Identify Research Documents to Clean Up

Look inside the plan for referenced research documents:

1. Check the **Research documents** section at the top of the plan
2. Look for references to `docs/ai/research/*.md` files
3. Look for kb document IDs (e.g., `kb:42`) — these are already in kb and don't need re-importing, but the corresponding `docs/ai/research/*.md` files can be deleted

Collect all `docs/ai/research/*.md` file paths that are referenced by this plan.

## Step 4: Import and Clean Up

Use the safety script to import the compacted plan and delete source files:

```bash
~/.claude/scripts/kb_import_and_cleanup.sh plan <compacted_plan_file> [research_file_1] [research_file_2] ...
```

The script will:
1. Import the compacted plan into kb as type `plan`
2. Verify the import by retrieving the document and checking content length
3. Only delete files after successful verification
4. Print the new kb document ID

**IMPORTANT**: If the script fails or reports an error, do NOT manually delete any files. Report the error to the user.

## Step 5: Link Related KB Documents

If the plan referenced existing kb document IDs (from research documents already in kb):

```bash
~/.claude/bin/kb link <new_plan_id> <research_id> -r related --db kb.db --plain
```

## Step 6: Report

Present a summary to the user:

```
Plan compacted and imported to kb:

- **KB Document ID**: <id>
- **Type**: plan
- **Files deleted**: <list of deleted files>
- **Linked to**: <list of linked kb document IDs, if any>

The plan is now stored in the kb database. Use `kb get <id>` to retrieve it.
```

## Important Guidelines

- **Never delete files before verifying the kb import** — the script handles this
- **Always read the plan fully** before compacting
- **Preserve key decisions and discoveries** — compacting means removing verbosity, not losing information
- **Keep file:line references** — these are the most valuable part of a compacted plan
- If research files are not found on disk (already deleted or never created), skip them silently
- If the plan references kb IDs, link them but don't try to re-import them
