-- Keymaps (ported from vimrc)

local map = vim.keymap.set

-- Remap F1 to Esc
map({ "n", "i", "v" }, "<F1>", "<Esc>", { desc = "Escape" })

-- Remap jj to Esc in insert mode
map("i", "jj", "<Esc>", { desc = "Escape" })

-- Save easier
map("i", "<Esc><Esc>", "<Cmd>w<CR>", { desc = "Save file" })

-- Clear search highlighting
map("n", "<CR>", "<Cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Search for visual selection
map("v", "//", 'y/<C-R>"<CR>', { desc = "Search for selection" })

-- Strip trailing whitespace
map("n", "<leader>W", [[:%s/\s\+$//<CR>:let @/=''<CR>]], { desc = "Strip trailing whitespace" })

-- Capitalize words
map("n", "gU", "gUe", { desc = "Uppercase word" })
map("n", "gu", "gue", { desc = "Lowercase word" })

-- Tab navigation
map("n", "<leader>tn", "<Cmd>tabnew<CR>", { desc = "New tab" })
map("n", "<leader>tc", "<Cmd>tabclose<CR>", { desc = "Close tab" })
map("n", "<leader>t[", "<Cmd>tabprevious<CR>", { desc = "Previous tab" })
map("n", "<leader>t]", "<Cmd>tabnext<CR>", { desc = "Next tab" })

-- Window navigation: use <C-w>h/j/k/l (Vim default) in normal mode
-- and <C-w> prefix in terminal mode (Neovim built-in)

-- Resize windows: use built-in C-w +/-/>/<  (prefix count for bigger steps, e.g. 5<C-w>>)

-- Move lines up and down
map("n", "<A-j>", "<Cmd>m .+1<CR>==", { desc = "Move line down" })
map("n", "<A-k>", "<Cmd>m .-2<CR>==", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Better indenting (stay in visual mode)
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- Quickfix navigation
map("n", "[q", "<Cmd>cprevious<CR>", { desc = "Previous quickfix" })
map("n", "]q", "<Cmd>cnext<CR>", { desc = "Next quickfix" })

-- Diagnostic navigation
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic" })
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })
