-- Options (ported from vimrc)

local opt = vim.opt

-- General
opt.compatible = false
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.undofile = true
opt.undodir = vim.fn.expand("~/.config/nvim/undo")
opt.swapfile = false
opt.backup = false
opt.shell = "bash"

-- UI
opt.number = true
opt.relativenumber = true
opt.ruler = true
opt.cursorline = true
opt.showmatch = true
opt.showcmd = true
opt.wildmenu = true
opt.wildmode = { "longest", "list", "full" }
opt.laststatus = 2
opt.scrolloff = 5
opt.signcolumn = "yes"
opt.colorcolumn = "100"
opt.termguicolors = true
opt.background = "dark"
opt.foldcolumn = "1"

-- Bell
opt.errorbells = false
opt.visualbell = true

-- Encoding
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"

-- Whitespace
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.smartindent = true
opt.autoindent = true
opt.backspace = { "indent", "eol", "start" }

-- Display invisible characters
opt.list = true
opt.listchars = { tab = "▸ ", eol = "¬", trail = "⋅", nbsp = "⋅" }

-- Search
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- Splits
opt.splitbelow = true
opt.splitright = true

-- Completion
opt.completeopt = { "menu", "menuone", "noselect" }

-- Performance
opt.updatetime = 250
opt.timeoutlen = 300

-- Format options
opt.formatoptions:append("j")

-- Autosave on make
opt.autowrite = true

-- Use ag/rg for grep
if vim.fn.executable("rg") == 1 then
  opt.grepprg = "rg --vimgrep --smart-case"
  opt.grepformat = "%f:%l:%c:%m"
elseif vim.fn.executable("ag") == 1 then
  opt.grepprg = "ag --nogroup --nocolor"
end

-- Tags
opt.tags:prepend("./.git/tags;")

-- Include - in keyword for completion
opt.iskeyword:append("-")

-- Disable netrw (we use nvim-tree)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Create undo directory if it doesn't exist
vim.fn.mkdir(vim.fn.expand("~/.config/nvim/undo"), "p")
