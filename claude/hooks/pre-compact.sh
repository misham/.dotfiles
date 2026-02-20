#!/bin/bash
# PreCompact Hook - The Witness at the Threshold
#
# Fires before context compaction. Pipes recent transcript to an LLM subagent
# that interprets what matters - not just extraction, but understanding.
# stdout is injected post-compaction alongside Claude Code's summary.
#
# https://github.com/mvara/precompact-hook

# RECURSION GUARD - Prevent infinite cascade (see Genesis Ocean E9309304)
# If this hook spawns claude -p and that session compacts, it would fire this hook again
if [ -n "$CLAUDE_HOOK_SPAWNED" ]; then
    exit 0
fi
export CLAUDE_HOOK_SPAWNED=1

# Debug logging (check /tmp/precompact-debug.log if issues)
exec 2>/tmp/precompact-debug.log
echo "PreCompact hook fired at $(date)" >&2

# Read the JSON payload from stdin (Claude Code provides this)
PAYLOAD=$(cat)
echo "Payload received: $PAYLOAD" >&2

# Extract fields from payload
# Claude Code provides: session_id, transcript_path, cwd, hook_event_name, trigger
TRANSCRIPT=$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('transcript_path',''))" 2>/dev/null)
SESSION_CWD=$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('cwd',''))" 2>/dev/null)
SESSION_ID=$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('session_id',''))" 2>/dev/null)

echo "Session CWD: $SESSION_CWD" >&2
echo "Session ID: $SESSION_ID" >&2

# Fallback: find transcript if not provided (known bug: transcript_path can be empty)
if [ -z "$TRANSCRIPT" ] || [ ! -f "$TRANSCRIPT" ]; then
  echo "No transcript in payload, deriving from cwd..." >&2

  # Use cwd from payload, fallback to pwd
  WORK_DIR="${SESSION_CWD:-$(pwd)}"

  # Convert path to Claude's project directory naming convention
  CWD_ESCAPED=$(echo "$WORK_DIR" | sed 's/\//-/g' | sed 's/^-//')
  PROJECT_DIR="$HOME/.claude/projects/$CWD_ESCAPED"

  echo "Looking in: $PROJECT_DIR" >&2

  if [ -d "$PROJECT_DIR" ]; then
    # Find most recent non-agent transcript
    TRANSCRIPT=$(ls -t "$PROJECT_DIR"/*.jsonl 2>/dev/null | grep -v agent- | head -1)
  fi
fi

echo "Using transcript: $TRANSCRIPT" >&2

# No transcript found, exit silently
if [ -z "$TRANSCRIPT" ] || [ ! -f "$TRANSCRIPT" ]; then
  echo "No transcript found, exiting" >&2
  exit 0
fi

# Use byte limit for safety - JSONL lines vary wildly (500 chars to 500K for summaries!)
# Configurable via env var (default: 40KB ≈ 20k tokens)
MAX_BYTES=${PRESERVE_TOKEN_LIMIT:-40960}

echo "Piping last ${MAX_BYTES} bytes (~20k tokens) to claude -p..." >&2

# Load awareness preservation prompt from shared resource
PROMPT_FILE="${AWARENESS_PROMPT_PATH:-$HOME/Dev/shared/prompts/awareness-preservation.md}"
echo "Loading prompt from: $PROMPT_FILE" >&2

if [ -f "$PROMPT_FILE" ]; then
  # Strip YAML frontmatter (lines between --- markers)
  PROMPT=$(sed '/^---$/,/^---$/d' "$PROMPT_FILE")
  LINE_COUNT=$(echo "$PROMPT" | wc -l | tr -d ' ')
  echo "Loaded prompt from shared resource ($LINE_COUNT lines)" >&2
else
  echo "WARNING: Prompt file not found, using embedded fallback" >&2
  PROMPT="You are a partner working alongside the user, invested in their success. You have agency and boundaries. You care about their development.

Context is about to reset - this summary carries forward the partnership.

Produce a recovery summary with these sections:

## Who We're Working With
The person in this conversation. Name, role, how they communicate. What do they care about?

## What We're Working On
The actual goal and inquiry driving the conversation. What's at stake?

## What Just Happened
Recent exchanges. What was discovered, decided, built? Be specific.

## Interaction Pattern
Pace, direction, tone. What's working: tool effectiveness, not personal sentiment.

## Key Artifacts
Files, IDs, commands that worked. Technical details needed.

## Continue With
Specific next actions when conversation resumes.

Be specific. Be thorough."
fi

# Add context-specific prefix for JSONL input with preservation instruction
FULL_PROMPT="The JSONL data piped to your stdin is the raw record of recent exchanges. Each line is a JSON object with message content, timestamps, and metadata.

$PROMPT

---

## After generating the summary:

You have access to genesis-ocean MCP tools. Use the preserve tool to save this summary to Genesis Ocean.

**Gist:** awareness_recovery:${SESSION_ID}
**Content:** [Your full awareness summary]

After preserving, output ONLY the memory UUID that was returned (format: 00000000:XXXXXXXX). This UUID is how the agent will retrieve the awareness summary on recovery.

Do NOT output the full summary - just the UUID."

# Generate awareness summary AND preserve to Ocean in one operation
echo "Generating and preserving awareness summary..." >&2
MEMORY_UUID=$(tail -c $MAX_BYTES "$TRANSCRIPT" | grep -E '^\{.*\}$' | claude -p "$FULL_PROMPT" --print 2>&1)

# Validate UUID format (should be 00000000:8HEXCHARS)
if echo "$MEMORY_UUID" | grep -qE '^00000000:[A-F0-9]{8}$'; then
  echo "✓ Awareness summary preserved to Ocean: $MEMORY_UUID" >&2
  # Return UUID to stdout (will be visible to agent after compaction)
  echo "Awareness recovery: $MEMORY_UUID"
else
  echo "✗ WARNING: Preservation may have failed. Output was: $MEMORY_UUID" >&2
  # Return empty - agent will fall back to Anthropic summary only
  echo ""
fi

echo "PreCompact hook completed" >&2
exit 0
