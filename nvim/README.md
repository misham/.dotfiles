# Neovim Configuration

Modern Neovim setup with lazy.nvim, LSP, and Claude AI integration.

## Installation

```bash
# From dotfiles root
make install

# Or manually
ln -s ~/.dotfiles/nvim ~/.config/nvim
```

On first launch, lazy.nvim will automatically:
1. Bootstrap itself
2. Install all plugins
3. Install LSP servers via Mason

## Structure

```
nvim/
├── init.lua                 # Entry point, lazy.nvim bootstrap
├── lua/
│   ├── config/
│   │   ├── options.lua      # Vim options (tabs, search, etc.)
│   │   ├── keymaps.lua      # Key bindings
│   │   └── autocmds.lua     # Auto commands (format on save, etc.)
│   └── plugins/
│       ├── lsp.lua          # LSP, completion, snippets
│       ├── treesitter.lua   # Syntax highlighting
│       ├── telescope.lua    # Fuzzy finder
│       ├── editor.lua       # Git, comments, surround
│       ├── ui.lua           # Theme, statusline, file tree
│       ├── claude.lua       # AI integration
│       └── tmux.lua         # Tmux integration
```

## Key Bindings

Leader key: `\` (backslash)

### General

| Key | Action |
|-----|--------|
| `jj` | Escape (insert mode) |
| `<CR>` | Clear search highlight |
| `<leader>W` | Strip trailing whitespace |
| `gcu` / `gcl` | Uppercase / lowercase word |

### File Navigation

| Key | Action |
|-----|--------|
| `<leader>f` | Find files |
| `<leader>F` | Find all files (including hidden) |
| `<leader>r` | Recent files |
| `<leader>g` | Live grep (search in files) |
| `<leader>G` | Grep word under cursor |
| `<leader>/` | Search in current buffer |
| `<leader>n` | Toggle file tree |
| `<leader>N` | Find current file in tree |

### Buffers & Tabs

| Key | Action |
|-----|--------|
| `<S-h>` / `<S-l>` | Previous / next buffer |
| `<leader>bb` | List buffers |
| `<leader>bo` | Close other buffers |
| `,tn` | New tab |
| `,tc` | Close tab |
| `,t[` / `,t]` | Previous / next tab |

### LSP

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | Find references |
| `gi` | Go to implementation |
| `K` | Hover documentation |
| `<C-k>` | Signature help |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>D` | Type definition |
| `<leader>lf` | Format file |
| `<leader>ls` | Document symbols |
| `<leader>lS` | Workspace symbols |
| `<leader>ld` | Buffer diagnostics |
| `[d` / `]d` | Previous / next diagnostic |

### Git

| Key | Action |
|-----|--------|
| `<leader>gf` | Git fugitive (status) |
| `<leader>gB` | Git blame |
| `<leader>gd` | Git diff |
| `<leader>gl` | Git log |
| `<leader>gc` | Git commits (telescope) |
| `<leader>gb` | Git branches (telescope) |
| `<leader>gs` | Git status (telescope) |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hp` | Preview hunk |
| `<leader>hb` | Blame line |
| `[c` / `]c` | Previous / next hunk |

### Claude AI

| Key | Action |
|-----|--------|
| `<leader>ca` | Avante: Ask Claude (normal/visual) |
| `<leader>ce` | Avante: Edit selection (visual) |
| `<leader>cr` | Avante: Refresh |
| `<leader>ct` | Avante: Toggle sidebar |
| `<leader>cc` | Open Claude Code CLI |
| `<leader>cg` | Open Lazygit |

### Terminal

| Key | Action |
|-----|--------|
| `<C-\>` | Toggle terminal |
| `<leader>tt` | Float terminal |
| `<leader>th` | Horizontal terminal |
| `<leader>tv` | Vertical terminal |

### Tmux Integration

| Key | Action |
|-----|--------|
| `<C-h/j/k/l>` | Navigate vim/tmux panes seamlessly |
| `<leader>vp` | Vimux: Prompt command |
| `<leader>vl` | Vimux: Run last command |
| `<leader>vi` | Vimux: Inspect runner |
| `<leader>vc` | Vimux: Close runner |

### Motions (Flash)

| Key | Action |
|-----|--------|
| `s` | Flash jump |
| `S` | Flash treesitter |

### Text Objects

| Key | Action |
|-----|--------|
| `af` / `if` | Around / inside function |
| `ac` / `ic` | Around / inside class |
| `aa` / `ia` | Around / inside argument |
| `ih` | Inside git hunk |

## LSP Servers

Mason automatically installs these LSP servers:

| Language | Server |
|----------|--------|
| Go | gopls |
| Ruby | ruby-lsp, solargraph |
| JavaScript/TypeScript | ts_ls, eslint |
| Python | pyright |
| C/C++ | clangd |
| Bash | bashls |
| Terraform | terraformls, tflint |
| YAML | yamlls |
| JSON | jsonls |
| Lua | lua_ls |
| HTML/CSS | html, cssls |
| Docker | dockerls |
| SQL | sqlls |

### Adding LSP Servers

Edit `lua/plugins/lsp.lua`:

```lua
-- In mason-lspconfig opts.ensure_installed, add:
"your_server_name",

-- In the servers table, add configuration:
your_server_name = {
  settings = {
    -- server-specific settings
  },
},
```

Then run `:Mason` to install, or restart Neovim.

## Claude AI Setup

### Avante (API-based)

Set your Anthropic API key:

```bash
export ANTHROPIC_API_KEY="your-api-key"
```

Add to your `~/.bashrc.local` or `~/.bashrc`:

```bash
export ANTHROPIC_API_KEY="sk-ant-..."
```

Usage:
- Select code and press `<leader>ca` to ask questions
- Use `<leader>ce` in visual mode to request edits
- Chat appears in sidebar

### Claude Code CLI

Press `<leader>cc` to open Claude Code in a floating terminal.
This uses your existing Claude Code authentication.

## Treesitter

Syntax highlighting and code navigation for all your languages.

### Adding Languages

Edit `lua/plugins/treesitter.lua`:

```lua
ensure_installed = {
  -- add your language
  "your_language",
},
```

Then run `:TSInstall your_language` or restart Neovim.

## Database (Dadbod)

Connect to PostgreSQL, MySQL, DynamoDB, etc.

```vim
:DBUI                    " Open database UI
:DBUIAddConnection       " Add new connection
```

Connection string format:
```
postgresql://user:pass@localhost:5432/dbname
mysql://user:pass@localhost:3306/dbname
```

## Customization

### Local Overrides

Create `~/.config/nvim/lua/config/local.lua` for machine-specific settings:

```lua
-- Example: different theme on work machine
vim.cmd.colorscheme("tokyonight")
```

Then add to `init.lua`:
```lua
pcall(require, "config.local")
```

### Adding Plugins

Create a new file in `lua/plugins/` or add to existing:

```lua
-- lua/plugins/my-plugin.lua
return {
  {
    "author/plugin-name",
    event = "VeryLazy",  -- lazy load
    opts = {
      -- plugin options
    },
  },
}
```

### Changing Theme

Edit `lua/plugins/ui.lua`:

```lua
-- Replace gruvbox with your preferred theme
{
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd.colorscheme("tokyonight")
  end,
},
```

### Filetype Settings

Edit `lua/config/autocmds.lua`:

```lua
autocmd("FileType", {
  group = filetypes,
  pattern = "your_filetype",
  callback = function()
    vim.opt_local.tabstop = 4
    -- other settings
  end,
})
```

## Commands

| Command | Action |
|---------|--------|
| `:Lazy` | Plugin manager UI |
| `:Mason` | LSP server manager |
| `:LspInfo` | Show LSP status |
| `:TSInstall <lang>` | Install treesitter parser |
| `:checkhealth` | Diagnose issues |
| `:Telescope` | Fuzzy finder |

## Troubleshooting

### Plugins not loading

```vim
:Lazy sync       " Update all plugins
:Lazy clean      " Remove unused plugins
```

### LSP not working

```vim
:LspInfo         " Check LSP status
:LspLog          " View LSP logs
:Mason           " Check server installation
```

### Treesitter errors

```vim
:TSUpdate        " Update all parsers
:TSInstall! <lang>  " Reinstall parser
```

### Reset everything

```bash
rm -rf ~/.local/share/nvim   # Plugin data
rm -rf ~/.local/state/nvim   # State
rm -rf ~/.cache/nvim         # Cache
nvim                         # Fresh start
```

## Performance

Startup time should be ~50-100ms thanks to lazy loading.

Check with:
```vim
:Lazy profile
```

## Updates

```vim
:Lazy update     " Update plugins
:MasonUpdate     " Update LSP servers
:TSUpdate        " Update treesitter parsers
```
