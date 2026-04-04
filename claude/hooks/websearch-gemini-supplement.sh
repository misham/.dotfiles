#!/bin/bash
# PostToolUse Hook: WebSearch Gemini Supplement
#
# After WebSearch completes, runs the same query through Gemini CLI
# and outputs the results as supplementary context. The agent sees
# both WebSearch results and Gemini results.

set -euo pipefail

# Extract the search query directly from stdin — no need to buffer the full payload
QUERY=$(jq -r '.tool_input.query // empty' 2>/dev/null) || true

if [ -z "$QUERY" ]; then
  exit 0
fi

# Run Gemini CLI with the same query
# Prefer timeout (Linux/Homebrew), fall back to gtimeout (macOS coreutils), then manual kill timer
TIMEOUT_CMD=$(command -v timeout || command -v gtimeout || echo "")
if [ -n "$TIMEOUT_CMD" ]; then
  GEMINI_RESULT=$($TIMEOUT_CMD 30 gemini -p "Web search: ${QUERY}" 2>/dev/null) || true
else
  # No timeout command available — use a background kill timer
  TMPFILE=$(mktemp)
  gemini -p "Web search: ${QUERY}" > "$TMPFILE" 2>/dev/null &
  GEMINI_PID=$!
  ( sleep 30 && kill "$GEMINI_PID" 2>/dev/null ) &
  KILL_PID=$!
  wait "$GEMINI_PID" 2>/dev/null || true
  kill "$KILL_PID" 2>/dev/null || true
  wait "$KILL_PID" 2>/dev/null || true
  GEMINI_RESULT=$(cat "$TMPFILE")
  rm -f "$TMPFILE"
fi

if [ -n "$GEMINI_RESULT" ]; then
  printf '%s\n' "--- Supplementary Gemini Search Results ---" \
                 "Query: ${QUERY}" \
                 "" \
                 "${GEMINI_RESULT}" \
                 "--- End Gemini Supplement ---"
fi
