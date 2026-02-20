---
description: Setup the rich multi-line statusline for Claude Code
---

# Setup Statusline

You are tasked with installing the rich multi-line statusline for Claude Code.

## Steps:

1. **Write the statusline script** to `~/.claude/statusline.ts` using the Write tool. The script content is the TypeScript file at `~/.claude/statusline.ts` — read it to verify it exists, or write it fresh from the template below.

2. **Update `~/.claude/settings.json`** to set the `statusLine` field to:
   ```json
   "statusLine": {
     "type": "command",
     "command": "bun run $HOME/.claude/statusline.ts"
   }
   ```

3. **Verify** by running:
   ```bash
   echo '{"model":{"display_name":"Opus 4.6"},"context_window":{"context_window_size":200000,"current_usage":{"input_tokens":45000,"cache_creation_input_tokens":5000,"cache_read_input_tokens":10000}}}' | bun run ~/.claude/statusline.ts
   ```

4. **Tell the user** to restart Claude Code to see the new statusline.

## Important:
- Use `$HOME` in the settings command, never hardcode the username
- The script requires `bun` to be installed
- The statusline reads Claude Code's stdin JSON and renders a rich multi-line display showing model, context usage, API usage limits, tool activity, and agent status
