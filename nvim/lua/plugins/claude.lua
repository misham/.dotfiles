-- Claude Code Integration

return {
  -- Claude Code IDE integration (VS Code-like experience)
  {
    "coder/claudecode.nvim",
    dependencies = {
      "folke/snacks.nvim",
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown" },
          latex = { enabled = false },
        },
        ft = { "markdown" },
      },
    },
    opts = {
      auto_start = true,
      terminal = {
        split_side = "right",
        split_width_percentage = 0.35,
        provider = "snacks",
      },
    },
    keys = {
      { "<leader>cc", "<Cmd>ClaudeCode<CR>", desc = "Toggle Claude Code" },
      { "<leader>cf", "<Cmd>ClaudeCodeFocus<CR>", desc = "Focus Claude Code" },
      { "<leader>cr", "<Cmd>ClaudeCode --resume<CR>", desc = "Resume session" },
      { "<leader>ck", "<Cmd>ClaudeCode --continue<CR>", desc = "Continue session" },
      { "<leader>cs", "<Cmd>ClaudeCodeSend<CR>", mode = "v", desc = "Send to Claude" },
      { "<leader>cb", "<Cmd>ClaudeCodeAdd %<CR>", desc = "Add buffer to context" },
      { "<leader>ca", "<Cmd>ClaudeCodeDiffAccept<CR>", desc = "Accept diff" },
      { "<leader>cd", "<Cmd>ClaudeCodeDiffDeny<CR>", desc = "Deny diff" },
      { "<leader>cm", "<Cmd>ClaudeCodeSelectModel<CR>", desc = "Select model" },
      {
        "<leader>cs",
        "<Cmd>ClaudeCodeTreeAdd<CR>",
        desc = "Add file to context",
        ft = { "NvimTree", "neo-tree", "oil" },
      },
    },
  },

  -- Snacks.nvim (terminal provider for claudecode)
  {
    "folke/snacks.nvim",
    lazy = false,
    opts = {},
  },

  -- Lazygit terminal (standalone, no toggleterm needed)
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>cg", function() Snacks.terminal.toggle("lazygit", { win = { border = "rounded" } }) end, desc = "Lazygit" },
      { "<C-\\>", function() Snacks.terminal.toggle(nil, { win = { border = "rounded" } }) end, mode = { "n", "t" }, desc = "Toggle terminal" },
      { "<leader>tt", function() Snacks.terminal.toggle(nil, { win = { position = "float", border = "rounded" } }) end, desc = "Float terminal" },
      { "<leader>th", function() Snacks.terminal.toggle(nil, { win = { position = "bottom", height = 0.3 } }) end, desc = "Horizontal terminal" },
      { "<leader>t|", function() Snacks.terminal.toggle(nil, { win = { position = "right", width = 0.4 } }) end, desc = "Vertical terminal" },
    },
  },
}
