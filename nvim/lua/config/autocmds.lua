-- Autocommands (ported from vimrc)

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- General settings group
local general = augroup("General", { clear = true })

-- Strip trailing whitespace on save
autocmd("BufWritePre", {
  group = general,
  pattern = "*",
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
  desc = "Strip trailing whitespace",
})

-- Remember last position in file
autocmd("BufReadPost", {
  group = general,
  pattern = "*",
  callback = function()
    local ft = vim.bo.filetype
    if ft:match("git") then return end
    local line = vim.fn.line("'\"")
    if line > 0 and line <= vim.fn.line("$") then
      vim.cmd('normal! g`"')
    end
  end,
  desc = "Return to last edit position",
})

-- Highlight on yank
autocmd("TextYankPost", {
  group = general,
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
  end,
  desc = "Highlight yanked text",
})

-- Resize splits when window is resized
autocmd("VimResized", {
  group = general,
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
  desc = "Resize splits on window resize",
})

-- Close some filetypes with q
autocmd("FileType", {
  group = general,
  pattern = { "help", "qf", "lspinfo", "man", "notify", "checkhealth" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<Cmd>close<CR>", { buffer = event.buf, silent = true })
  end,
  desc = "Close with q",
})

-- Filetype-specific settings
local filetypes = augroup("Filetypes", { clear = true })

-- Text files
autocmd("FileType", {
  group = filetypes,
  pattern = "text",
  callback = function()
    vim.opt_local.textwidth = 79
  end,
})

-- Python
autocmd("FileType", {
  group = filetypes,
  pattern = "python",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.textwidth = 88
    vim.opt_local.expandtab = true
  end,
})

-- Go
autocmd("FileType", {
  group = filetypes,
  pattern = "go",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = false
  end,
})

-- Makefile
autocmd("FileType", {
  group = filetypes,
  pattern = "make",
  callback = function()
    vim.opt_local.expandtab = false
  end,
})

-- JSON (don't conceal quotes)
autocmd("FileType", {
  group = filetypes,
  pattern = "json",
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- Markdown
autocmd("FileType", {
  group = filetypes,
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Packer files as JSON
autocmd({ "BufNewFile", "BufRead" }, {
  group = filetypes,
  pattern = "*.pkr.hcl",
  callback = function()
    vim.bo.filetype = "hcl"
  end,
})

-- Ansible playbooks
autocmd({ "BufRead", "BufNewFile" }, {
  group = filetypes,
  pattern = "*/playbooks/*.yml",
  callback = function()
    vim.bo.filetype = "yaml.ansible"
  end,
})

-- Terminal settings
autocmd("TermOpen", {
  group = general,
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
    vim.cmd("startinsert")
  end,
  desc = "Terminal settings",
})
