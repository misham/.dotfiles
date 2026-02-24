---
name: codex-review
description: >
  Run a Codex session to get an independent review from a different model family.
  By default reviews the most recent plan from docs/ai/plans/. Can review
  any target: a plan, a branch diff, a file, a directory, or a custom prompt.
  Trigger phrases: "/codex-review", "codex review", "get a second opinion",
  "have codex review this", "outside review".
version: 2.1.0
---

# Codex Review

Shell out to OpenAI Codex CLI to get an independent review — a second pair of eyes from a different model family. Codex has full disk read access; pass it file paths and let it do the reading.

## Step 1: Determine the Review Target

Ask the user if unclear. Otherwise infer from context:

| Signal | Target |
|--------|--------|
| User specifies a file/dir/branch | That target |
| "review the plan" or no target given | Most recent plan in `docs/ai/plans/` (see below) |
| "review the branch" / "review the diff" | Branch diff (see base-branch resolution below) |
| "review this" mid-conversation | Current work — summarize the task + relevant file paths |

**Don't inline target contents into the prompt.** You may inspect files minimally to resolve paths and validate they exist, but let Codex do the actual reading.

### Plan Discovery

Find the most recent plan:

```bash
plan=$(find docs/ai/plans -maxdepth 1 -name '*.md' -print0 2>/dev/null | xargs -0 ls -t 2>/dev/null | head -1)
```

If no plan is found, tell the user and ask them to specify a target.

## Step 2: Build the Prompt

Keep it short. Codex shares no context with Claude Code, so the prompt must be self-contained — that means file paths and a clear ask, not inlined content.

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

## Step 3: Launch Codex

`codex exec` streams session progress (thinking, tool calls) to **stderr** and prints only the **final agent message** to **stdout**. Use `-o` to capture the final message to a file for reliable reading.

**Important:** Use a Bash timeout of at least 300000ms (5 minutes) since Codex reviews can take a while on large targets.

First, create unique temp files for this run:

```bash
output_file=$(mktemp /tmp/codex-review-XXXXXX.md)
debug_log=$(mktemp /tmp/codex-review-debug-XXXXXX.log)
```

Then launch:

```bash
codex exec -C <working-directory> -s read-only -o "$output_file" "<prompt>" 2>"$debug_log"
```

**Check the exit code immediately.** If non-zero, read the debug log and surface a summary of what went wrong to the user. Do not proceed to Step 4.

**Flags:**
- `-C <dir>` — working directory (defaults to cwd)
- `-s read-only` — Codex can read the full filesystem but cannot write
- `-o <file>` — write the final agent message to a file for reliable capture
- `2><file>` — redirect stderr to a debug log (check this file if something goes wrong)

### Capture Session ID

Immediately after Codex finishes, capture the session ID for potential follow-ups:

```bash
basename "$(ls -t ~/.codex/sessions/*/*/*.jsonl 2>/dev/null | head -1)" .jsonl
```

**Remember this session ID for the rest of the conversation.** The capture is only reliable when done immediately after the run completes — if you delay, another Codex session could interleave.

### Follow-Up Reviews

If the user wants a follow-up review (e.g., after making changes based on feedback), resume the prior session using the captured session ID:

```bash
codex exec resume -s read-only -o "$output_file" <SESSION_ID> "<follow-up prompt>" 2>"$debug_log"
```

If the session ID is unavailable, fall back to `--last`:

```bash
codex exec resume --last -s read-only -o "$output_file" "<follow-up prompt>" 2>"$debug_log"
```

The resumed session retains full context from the prior review. After the follow-up finishes, capture the new session ID (same command as above) — each resumed run creates a new session.

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

**Codex fails to start:**
- Verify Codex is installed: `codex --version`
- Check the debug log for details
- Verify flags against `codex exec --help` — CLI flags change across versions

**Non-zero exit code:**
- Read the debug log and surface the relevant error to the user
- Common causes: network issues, invalid model configuration, authentication problems

**Output file is empty or missing:**
- Codex may have timed out or hit an error. Check the debug log.
- Try running with a simpler prompt or smaller target to isolate the issue.

**Review takes too long:**
- Increase the Bash timeout beyond 300000ms if needed (max 600000ms for Bash tool)
- Consider reviewing a smaller scope (single file instead of full directory)

**`codex exec resume` fails:**
- Session files may have been cleaned up. Start a fresh review instead.
- If using `--last` and it picks up the wrong session, specify the session ID explicitly.
