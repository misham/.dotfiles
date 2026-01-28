-- Tmux Integration

return {
  -- Seamless navigation between tmux panes and vim splits
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<C-h>", "<Cmd>TmuxNavigateLeft<CR>", desc = "Navigate left" },
      { "<C-j>", "<Cmd>TmuxNavigateDown<CR>", desc = "Navigate down" },
      { "<C-k>", "<Cmd>TmuxNavigateUp<CR>", desc = "Navigate up" },
      { "<C-l>", "<Cmd>TmuxNavigateRight<CR>", desc = "Navigate right" },
      { "<C-\\>", "<Cmd>TmuxNavigatePrevious<CR>", desc = "Navigate previous" },
    },
    init = function()
      -- Disable default mappings, we set our own
      vim.g.tmux_navigator_no_mappings = 1
      -- Save on switch
      vim.g.tmux_navigator_save_on_switch = 2
      -- Disable when zoomed
      vim.g.tmux_navigator_disable_when_zoomed = 1
      -- Preserve zoom
      vim.g.tmux_navigator_preserve_zoom = 1
    end,
  },

  -- Send commands to tmux panes
  {
    "preservim/vimux",
    cmd = {
      "VimuxRunCommand",
      "VimuxRunLastCommand",
      "VimuxPromptCommand",
      "VimuxInspectRunner",
      "VimuxCloseRunner",
      "VimuxInterruptRunner",
      "VimuxZoomRunner",
    },
    keys = {
      { "<leader>vp", "<Cmd>VimuxPromptCommand<CR>", desc = "Vimux prompt" },
      { "<leader>vl", "<Cmd>VimuxRunLastCommand<CR>", desc = "Vimux run last" },
      { "<leader>vi", "<Cmd>VimuxInspectRunner<CR>", desc = "Vimux inspect" },
      { "<leader>vc", "<Cmd>VimuxCloseRunner<CR>", desc = "Vimux close" },
      { "<leader>vx", "<Cmd>VimuxInterruptRunner<CR>", desc = "Vimux interrupt" },
      { "<leader>vz", "<Cmd>VimuxZoomRunner<CR>", desc = "Vimux zoom" },
    },
    init = function()
      -- Use vertical split
      vim.g.VimuxOrientation = "v"
      -- Runner height percentage
      vim.g.VimuxHeight = "30"
    end,
  },
}
