#!/bin/bash
# PreCompact Hook
#
# Fires before context compaction. Extracts conversation messages from the
# transcript, sends them to a claude subagent for semantic summarization,
# and outputs the summary to stdout where it gets injected post-compaction.
#
# Based on: https://github.com/mvara-ai/precompact-hook

set -euo pipefail

# Recursion guard - prevent infinite cascade if subagent triggers compaction
if [ -n "${CLAUDE_HOOK_SPAWNED:-}" ]; then
  exit 0
fi
export CLAUDE_HOOK_SPAWNED=1

# Debug logging (check /tmp/precompact-debug.log if issues)
exec 2>/tmp/precompact-debug.log
echo "PreCompact hook fired at $(date)" >&2

# Read the JSON payload from stdin
PAYLOAD=$(cat)
echo "Payload received: $PAYLOAD" >&2

# Extract fields using jq
TRANSCRIPT=$(echo "$PAYLOAD" | jq -r '.transcript_path // empty')
SESSION_CWD=$(echo "$PAYLOAD" | jq -r '.cwd // empty')

echo "Transcript: $TRANSCRIPT" >&2
echo "CWD: $SESSION_CWD" >&2

# Fallback: derive transcript path from cwd if not provided
if [ -z "$TRANSCRIPT" ] || [ ! -f "$TRANSCRIPT" ]; then
  echo "No transcript in payload, deriving from cwd..." >&2
  WORK_DIR="${SESSION_CWD:-$(pwd)}"
  CWD_ESCAPED=$(echo "$WORK_DIR" | sed 's/\//-/g' | sed 's/^-//')
  PROJECT_DIR="$HOME/.claude/projects/$CWD_ESCAPED"

  if [ -d "$PROJECT_DIR" ]; then
    TRANSCRIPT=$(ls -t "$PROJECT_DIR"/*.jsonl 2>/dev/null | grep -v agent- | head -1)
  fi
fi

if [ -z "${TRANSCRIPT:-}" ] || [ ! -f "$TRANSCRIPT" ]; then
  echo "No transcript found, exiting" >&2
  exit 0
fi

echo "Using transcript: $TRANSCRIPT" >&2

# Extract conversation content from the FULL transcript.
# - Keep only user/assistant messages
# - For arrays: extract text blocks, truncate tool results, summarize tool_use
# - Skip thinking blocks (internal reasoning, not useful for recovery)
# - Tool result content is capped to avoid file dumps dominating
MAX_TOOL_RESULT_LEN=${PRECOMPACT_MAX_TOOL_RESULT_LEN:-200}

CONVERSATION=$(jq -c --argjson maxlen "$MAX_TOOL_RESULT_LEN" '
  select(.type == "user" or .type == "assistant")
  | .message.content as $content
  | {
      type,
      message: (
        if ($content | type) == "array" then
          [ $content[] |
            if .type == "text" then
              {text: .text}
            elif .type == "tool_result" then
              {tool_result: ((.content // "") | tostring | .[:$maxlen])}
            elif .type == "tool_use" then
              {tool: .name, input: (.input | tostring | .[:$maxlen])}
            else
              empty
            end
          ]
          | if length > 0 then . else empty end
        elif ($content | type) == "string" then
          $content
        else
          empty
        end
      )
    }
  | select(.message | . == null or . == "" or . == [] | not)
' "$TRANSCRIPT" 2>/dev/null)

MSG_COUNT=$(echo "$CONVERSATION" | wc -l | tr -d ' ')
BYTE_COUNT=$(echo "$CONVERSATION" | wc -c | tr -d ' ')
echo "Extracted $MSG_COUNT messages, ${BYTE_COUNT} bytes" >&2

if [ "$MSG_COUNT" -lt 2 ]; then
  echo "Too few messages to summarize, exiting" >&2
  exit 0
fi

# Cap input to stay within subagent context window.
# For long conversations, take the first 40% and last 60% of messages.
# The beginning has instructions/intent, the end has recent state.
MAX_MESSAGES=${PRECOMPACT_MAX_MESSAGES:-400}

if [ "$MSG_COUNT" -gt "$MAX_MESSAGES" ]; then
  HEAD_LINES=$(( MAX_MESSAGES * 40 / 100 ))
  TAIL_LINES=$(( MAX_MESSAGES * 60 / 100 ))
  OMITTED=$(( MSG_COUNT - MAX_MESSAGES ))
  TMPFILE=$(mktemp)
  echo "$CONVERSATION" > "$TMPFILE"
  HEAD_PART=$(head -n "$HEAD_LINES" "$TMPFILE")
  TAIL_PART=$(tail -n "$TAIL_LINES" "$TMPFILE")
  rm -f "$TMPFILE"
  CONVERSATION="${HEAD_PART}
{\"type\":\"system\",\"message\":\"--- ${OMITTED} MESSAGES OMITTED — early instructions and recent activity preserved ---\"}
${TAIL_PART}"
  echo "Trimmed: first ${HEAD_LINES} + last ${TAIL_LINES} messages (omitted ${OMITTED})" >&2
fi

# The prompt focuses on what built-in compaction loses: early-conversation
# instructions, decision rationale, failed approaches, and the full arc.
# Built-in compaction already handles recent activity well — this supplements it.
PROMPT='You are reading a conversation transcript that is about to be compacted. A separate built-in system will summarize recent exchanges. YOUR job is to preserve the context that recency-biased compaction typically LOSES — especially instructions, decisions, and intent from earlier in the conversation.

The input is one JSON object per line with {type: "user"|"assistant", message: <content>}.

Prioritize thoroughness over brevity. Reference files as path:line instead of copying code blocks — the code is on disk, your job is to preserve the context around it. Target 1500-2000 words.

IMPORTANT: If the transcript contains a prior "Supplementary Context" section from a previous compaction, carry forward any still-relevant information from it. Do not re-summarize it — preserve it directly and update only what has changed.

Produce a supplementary context document with these sections:

## User Instructions & Preferences
Directives the user gave about HOW to work. Examples: "follow TDD", "don'\''t mock the database", "use this pattern", "always run tests first", "check with me before committing". These are the first things lost in compaction and the most damaging to lose. Include exact quotes where possible.

## Intent & Goals
What the user is ultimately trying to achieve and WHY — not just the immediate task but the motivation behind it. Include scope boundaries: what was explicitly ruled in or out.

## Decisions & Rationale
Key decisions made during the conversation and WHY they were chosen. Include alternatives that were considered and rejected. This prevents the post-compaction agent from relitigating settled questions or revisiting rejected approaches.

## Learnings & Discoveries
Knowledge gained during the conversation that isn'\''t obvious from the code alone. Patterns discovered, root causes identified, API behaviors observed, gotchas encountered. Example: "the config file loads before env vars, so env overrides don'\''t apply to X" or "the API returns cursor-based pagination, not offset."

## Failed Approaches & Dead Ends
Things that were tried and did not work, with enough detail to avoid retrying them. Include error messages, why they failed, and what was done instead.

## Task Progress
Any todo lists, checklists, plans, or multi-step workflows in progress. For each item, note whether it is done, in progress, or not yet started. Preserve the full list, not just remaining items.

## Critical References
Documents, specs, plans, or external resources that are driving the current work. Distinguish these from files being modified — these are the INPUTS informing decisions. Specifically preserve:
- kb database IDs (e.g. "kb ID 3") — these are used to retrieve research/context via `kb show <id>`
- Plan documents in docs/ai/plans/ (full paths)
- Research documents in docs/ai/research/ (full paths)
- External URLs, API docs, or specs referenced during the conversation
Include both the reference and a brief note on what it contains or why it matters.

## Modified & Produced Artifacts
Files created or modified during this conversation, with path:line references and a brief note on what changed and why. This is the OUTPUT of the work.

## Corrections & Course Changes
Times the user corrected the assistant'\''s approach or changed direction. These indicate preferences that should persist. Example: "User said not to add error handling for internal functions" or "User redirected from refactoring to focus on the failing test."

Be precise. Use exact file paths, quote the user directly when capturing instructions, and include specific technical details. This document must stand alone as a recovery aid — assume the reader has no other context about this conversation.'

echo "Generating summary via claude subagent..." >&2

# Pipe extracted conversation to claude sonnet, with a 120s timeout
# Unset CLAUDECODE to allow nested claude -p calls from within a Claude Code session
SUMMARY=$(echo "$CONVERSATION" | CLAUDECODE= timeout 120 claude -p "$PROMPT" --model sonnet 2>/dev/null) || true

if [ -n "$SUMMARY" ]; then
  SUMMARY_LINES=$(echo "$SUMMARY" | wc -l | tr -d ' ')
  echo "Summary generated ($SUMMARY_LINES lines)" >&2
  # Output to stdout — this gets injected post-compaction
  echo "$SUMMARY"
else
  echo "Summary generation failed or empty" >&2
fi

echo "PreCompact hook completed" >&2
