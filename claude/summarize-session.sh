#!/bin/bash
# Session Recovery Summarizer - Manual Tool
#
# Call explicitly before compaction to generate recovery brief.
# NOT a hook - this is a manual function that can be called by agents or users.
#
# Usage:
#   ./summarize-session.sh [session_id]
#   ./summarize-session.sh                    # Uses current session
#   ./summarize-session.sh abc123-456-def     # Uses specific session

SESSION_ID="${1:-}"
MAX_BYTES=40960  # 40KB ≈ 20k tokens

# Find transcript
if [ -n "$SESSION_ID" ]; then
  # Explicit session ID provided
  TRANSCRIPT=$(find ~/.claude/projects -name "${SESSION_ID}.jsonl" 2>/dev/null | head -1)
else
  # Use current directory's most recent transcript
  CWD_ESCAPED=$(pwd | sed 's/\//-/g' | sed 's/^-//')
  PROJECT_DIR="$HOME/.claude/projects/$CWD_ESCAPED"
  if [ -d "$PROJECT_DIR" ]; then
    TRANSCRIPT=$(ls -t "$PROJECT_DIR"/*.jsonl 2>/dev/null | grep -v agent- | head -1)
  fi
fi

if [ -z "$TRANSCRIPT" ] || [ ! -f "$TRANSCRIPT" ]; then
  echo "Error: No transcript found" >&2
  echo "Usage: $0 [session_id]" >&2
  exit 1
fi

echo "Reading from: $TRANSCRIPT" >&2
echo "Processing last ${MAX_BYTES} bytes..." >&2

# Extract last 40KB, filter complete JSON lines, pipe to claude -p
tail -c $MAX_BYTES "$TRANSCRIPT" | grep -E '^\{.*\}$' | claude -p "You are a recovery summarizer. An agent is about to undergo context compaction and needs a summary to continue seamlessly.

The JSONL data piped to your stdin is the session's recent exchanges. Each line is a complete JSON message object.

Produce a RECOVERY BRIEF:

## Who Is Here
Human's name, role, relationship to agent, communication style.

## The Living Thread
What inquiry drives the conversation? What's at stake? Include both philosophical and technical dimensions.

## What Just Happened
Last few exchanges before now. Discoveries, decisions, files created, specific details.

## Emotional Truth
Energy level, mood, tension, flow state. What does the human need?

## Key Artifacts
Files modified, UUIDs preserved, commands that worked, technical details.

## Continue With
Specific next action. Not 'continue conversation' but concrete steps.

Be thorough and specific. The recovering agent has ZERO context except what you provide." --print

EXIT_CODE=$?
echo "Completed with exit code: $EXIT_CODE" >&2
exit $EXIT_CODE
