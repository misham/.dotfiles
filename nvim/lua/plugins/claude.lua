-- Claude AI Integration

return {
  -- Avante: Cursor-like AI experience
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    build = "make",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
      {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = { insert_mode = true },
          },
        },
      },
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = { file_types = { "markdown", "Avante" } },
        ft = { "markdown", "Avante" },
      },
    },
    opts = {
      provider = "claude",
      claude = {
        endpoint = "https://api.anthropic.com",
        model = "claude-sonnet-4-20250514",
        temperature = 0,
        max_tokens = 4096,
      },
      behaviour = {
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = true,
      },
      mappings = {
        ask = "<leader>ca",
        edit = "<leader>ce",
        refresh = "<leader>cr",
        diff = {
          ours = "co",
          theirs = "ct",
          both = "cb",
          next = "]x",
          prev = "[x",
        },
        jump = {
          next = "]]",
          prev = "[[",
        },
        submit = {
          normal = "<CR>",
          insert = "<C-s>",
        },
        toggle = {
          debug = "<leader>cd",
          hint = "<leader>ch",
        },
      },
      hints = { enabled = true },
      windows = {
        position = "right",
        width = 30,
        sidebar_header = {
          align = "center",
          rounded = true,
        },
      },
    },
    keys = {
      { "<leader>ca", mode = { "n", "v" }, "<Cmd>AvanteAsk<CR>", desc = "Avante: Ask" },
      { "<leader>ce", mode = "v", "<Cmd>AvanteEdit<CR>", desc = "Avante: Edit" },
      { "<leader>cr", "<Cmd>AvanteRefresh<CR>", desc = "Avante: Refresh" },
      { "<leader>ct", "<Cmd>AvanteToggle<CR>", desc = "Avante: Toggle" },
    },
  },

  -- Terminal for Claude Code CLI
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = { "ToggleTerm", "TermExec" },
    keys = {
      { "<C-\\>", "<Cmd>ToggleTerm<CR>", mode = { "n", "t" }, desc = "Toggle terminal" },
      { "<leader>tt", "<Cmd>ToggleTerm direction=float<CR>", desc = "Float terminal" },
      { "<leader>th", "<Cmd>ToggleTerm direction=horizontal<CR>", desc = "Horizontal terminal" },
      { "<leader>tv", "<Cmd>ToggleTerm direction=vertical size=80<CR>", desc = "Vertical terminal" },
      { "<leader>cc", function()
          local Terminal = require("toggleterm.terminal").Terminal
          local claude = Terminal:new({
            cmd = "claude",
            direction = "float",
            float_opts = {
              border = "curved",
              width = function() return math.floor(vim.o.columns * 0.9) end,
              height = function() return math.floor(vim.o.lines * 0.9) end,
            },
            on_open = function(term)
              vim.cmd("startinsert!")
              vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<Cmd>close<CR>", { noremap = true, silent = true })
            end,
          })
          claude:toggle()
        end,
        desc = "Claude Code"
      },
      { "<leader>cg", function()
          local Terminal = require("toggleterm.terminal").Terminal
          local lazygit = Terminal:new({
            cmd = "lazygit",
            direction = "float",
            float_opts = { border = "curved" },
          })
          lazygit:toggle()
        end,
        desc = "Lazygit"
      },
    },
    opts = {
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
      open_mapping = [[<C-\>]],
      hide_numbers = true,
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      terminal_mappings = true,
      persist_size = true,
      direction = "float",
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = "curved",
        winblend = 0,
      },
    },
  },
}
