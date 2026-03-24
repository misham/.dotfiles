#!/bin/bash
# PostToolUse Hook: WebFetch Chrome Fallback
#
# Detects when WebFetch returns truncated, empty, or SPA-shell content
# and reminds the assistant to retry using Chrome browser tools.

set -euo pipefail

PAYLOAD=$(cat)

TOOL_OUTPUT=$(echo "$PAYLOAD" | jq -r '.tool_output // empty' 2>/dev/null)

if [ -z "$TOOL_OUTPUT" ]; then
  exit 0
fi

# Check for common failure patterns
FAILED=false
REASON=""

# Truncated content
if echo "$TOOL_OUTPUT" | grep -qi "content was truncated\|truncated after\|content too large\|maximum.*exceeded"; then
  FAILED=true
  REASON="Content was truncated"
fi

# SPA shell (minimal HTML with JS bundle references, no real content)
if echo "$TOOL_OUTPUT" | grep -qiP '<div id="(root|app|__next)">\s*</div>|<noscript>|"bundle\.(js|min\.js)"' 2>/dev/null || \
   echo "$TOOL_OUTPUT" | grep -qi '<div id="root"></div>\|<div id="app"></div>\|<div id="__next"></div>\|<noscript>' 2>/dev/null; then
  FAILED=true
  REASON="Page appears to be a JavaScript SPA (empty shell returned)"
fi

# Fetch errors
if echo "$TOOL_OUTPUT" | grep -qi "failed to fetch\|connection refused\|timeout\|403 forbidden\|access denied\|cloudflare\|captcha\|bot detection\|please enable javascript"; then
  FAILED=true
  REASON="Fetch failed or was blocked"
fi

# Very short content (likely incomplete)
CONTENT_LENGTH=${#TOOL_OUTPUT}
if [ "$CONTENT_LENGTH" -lt 200 ] && echo "$TOOL_OUTPUT" | grep -qi "http\|url\|fetch"; then
  FAILED=true
  REASON="Response suspiciously short (${CONTENT_LENGTH} chars)"
fi

if [ "$FAILED" = true ]; then
  cat <<EOF
WebFetch returned incomplete results: ${REASON}.

IMPORTANT: Retry this URL using Chrome browser tools instead:
1. Call mcp__claude-in-chrome__tabs_context_mcp to check existing tabs
2. Create a new tab with mcp__claude-in-chrome__tabs_create_mcp
3. Navigate with mcp__claude-in-chrome__navigate
4. Read content with mcp__claude-in-chrome__read_page or mcp__claude-in-chrome__get_page_text
EOF
fi
