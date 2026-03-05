---
name: gemini-review
description: >
  Run a Gemini CLI session to get an independent review from a different model family.
  By default reviews the most recent plan from docs/ai/plans/. Can review
  any target: a plan, a branch diff, a file, a directory, or a custom prompt.
  Trigger phrases: "/gemini-review", "gemini review", "get a second opinion",
  "have gemini review this", "outside review".
version: 3.0.0
---

# Gemini Review

Shell out to Google Gemini CLI to get an independent review — a second pair of eyes from a different model family. Gemini has full disk read access in plan mode; pass it file paths and let it do the reading.

## Step 1: Determine the Review Target

Ask the user if unclear. Otherwise infer from context:

| Signal | Target |
|--------|--------|
| User specifies a file/dir/branch | That target |
| "review the plan" or no target given | Most recent plan in `docs/ai/plans/` (see below) |
| "review the branch" / "review the diff" | Branch diff (see base-branch resolution below) |
| "review this" mid-conversation | Current work — summarize the task + relevant file paths |

**Don't inline target contents into the prompt.** You may inspect files minimally to resolve paths and validate they exist, but let Gemini do the actual reading.

### Plan Discovery

Find the most recent plan:

```bash
plan=$(find docs/ai/plans -maxdepth 1 -name '*.md' -print0 2>/dev/null | xargs -0 ls -t 2>/dev/null | head -1)
```

If no plan is found, tell the user and ask them to specify a target.

## Step 2: Build the Prompt

Keep it short. Gemini shares no context with Claude Code, so the prompt must be self-contained — that means file paths and a clear ask, not inlined content.

**Use these prompts verbatim** (substituting only the bracketed placeholders). Do not embellish, add instructions, or reword.

**Plan review:**
```
Read the plan outlined in <absolute path to plan file> and provide structured, actionable feedback for improvement.
```

**Code/diff review:**
```
Review the changes on this branch against <base-branch>. Provide structured, actionable feedback.
```

**General review:**
```
Read <file paths> and <what you want reviewed>. Provide structured, actionable feedback.
```

If the target wouldn't make sense without context, add one sentence of project description. Nothing more.

## Step 3: Launch Gemini

`gemini -p` runs in non-interactive (headless) mode and prints the final response to **stdout**. Use `-o text` to ensure clean text output and redirect stdout to capture the result to a file.

**Important:** Use a Bash timeout of at least 300000ms (5 minutes) since Gemini reviews can take a while on large targets.

First, create a unique temp directory for this run:

```bash
review_dir=$(mktemp -d /tmp/gemini-review-XXXXXX)
output_file="$review_dir/review.md"
debug_log="$review_dir/debug.log"
```

Then launch:

```bash
(cd <working-directory> && gemini -p "<prompt>" --approval-mode plan -o text) >"$output_file" 2>"$debug_log"
```

**Check the exit code immediately.** If non-zero, read the debug log and surface a summary of what went wrong to the user. Do not proceed to Step 4.

**Flags:**
- `cd <dir>` — working directory via subshell (Gemini has no `-C` equivalent)
- `--approval-mode plan` — read-only mode; Gemini can read the filesystem but cannot write
- `-o text` — plain text output format (not to be confused with file output)
- `>"$file"` — redirect stdout to capture the final response to a file
- `2>"$file"` — redirect stderr to a debug log (check this file if something goes wrong)

### Follow-Up Reviews

Gemini tracks sessions per project directory. For follow-up reviews, resume the latest session using `--resume latest`.

If the user wants a follow-up review (e.g., after making changes based on feedback):

```bash
(cd <working-directory> && gemini --resume latest -p "<follow-up prompt>" --approval-mode plan -o text) >"$output_file" 2>"$debug_log"
```

To list available sessions and resume a specific one by index:

```bash
(cd <working-directory> && gemini --list-sessions)
(cd <working-directory> && gemini --resume <index> -p "<follow-up prompt>" --approval-mode plan -o text) >"$output_file" 2>"$debug_log"
```

The resumed session retains full context from the prior review.

**Follow-up prompts:**

Re-review after changes:
```
Re-review the plan/code against the feedback you gave previously. Note what has been addressed, what remains, and any new concerns.
```

Targeted follow-up:
```
<specific question or area to focus on, referencing prior feedback>
```

## Step 4: Present Feedback to User

Read the feedback from the output file. If the file doesn't exist or is empty, check the debug log for errors — see Troubleshooting.

**Present all feedback to the user.** Do not silently incorporate or skip suggestions. For each piece of feedback:

1. Summarize it clearly
2. Let the user decide whether to accept, modify, or skip it
3. If the user wants to discuss a suggestion, engage on it before acting

The user controls what gets incorporated. Your role is to present the feedback and execute the user's decisions.

## Troubleshooting

**Gemini fails to start:**
- Verify Gemini CLI is installed: `gemini --version`
- Check the debug log for details
- Verify flags against `gemini --help` — CLI flags change across versions
- Ensure Google authentication is configured (run `gemini` interactively to trigger OAuth if needed)

**Non-zero exit code:**
- Read the debug log and surface the relevant error to the user
- Common causes: network issues, invalid model configuration, expired OAuth tokens

**Output file is empty or missing:**
- Gemini may have timed out or hit an error. Check the debug log.
- Try running with a simpler prompt or smaller target to isolate the issue.

**Review takes too long:**
- Increase the Bash timeout beyond 300000ms if needed (max 600000ms for Bash tool)
- Consider reviewing a smaller scope (single file instead of full directory)

**`gemini --resume` fails:**
- Session may have expired or been cleaned up. Start a fresh review instead.
- Use `gemini --list-sessions` to see available sessions and specify the correct index.
- Sessions are scoped to the project directory — ensure you run from the correct directory.
