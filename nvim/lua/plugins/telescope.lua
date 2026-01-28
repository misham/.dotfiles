-- Telescope Configuration

return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    version = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
      "nvim-telescope/telescope-ui-select.nvim",
    },
    keys = {
      -- Files
      { "<leader>f", "<Cmd>Telescope find_files<CR>", desc = "Find files" },
      { "<leader>F", "<Cmd>Telescope find_files hidden=true<CR>", desc = "Find all files" },
      { "<leader>r", "<Cmd>Telescope oldfiles<CR>", desc = "Recent files" },

      -- Search
      { "<leader>g", "<Cmd>Telescope live_grep<CR>", desc = "Live grep" },
      { "<leader>G", "<Cmd>Telescope grep_string<CR>", desc = "Grep word under cursor" },
      { "<leader>/", "<Cmd>Telescope current_buffer_fuzzy_find<CR>", desc = "Search in buffer" },

      -- Buffers
      { "<leader>bb", "<Cmd>Telescope buffers<CR>", desc = "Buffers" },

      -- Git
      { "<leader>gc", "<Cmd>Telescope git_commits<CR>", desc = "Git commits" },
      { "<leader>gb", "<Cmd>Telescope git_branches<CR>", desc = "Git branches" },
      { "<leader>gs", "<Cmd>Telescope git_status<CR>", desc = "Git status" },

      -- LSP
      { "<leader>ls", "<Cmd>Telescope lsp_document_symbols<CR>", desc = "Document symbols" },
      { "<leader>lS", "<Cmd>Telescope lsp_workspace_symbols<CR>", desc = "Workspace symbols" },
      { "<leader>lr", "<Cmd>Telescope lsp_references<CR>", desc = "References" },
      { "<leader>ld", "<Cmd>Telescope diagnostics bufnr=0<CR>", desc = "Buffer diagnostics" },
      { "<leader>lD", "<Cmd>Telescope diagnostics<CR>", desc = "Workspace diagnostics" },

      -- Misc
      { "<leader>:", "<Cmd>Telescope command_history<CR>", desc = "Command history" },
      { "<leader>h", "<Cmd>Telescope help_tags<CR>", desc = "Help tags" },
      { "<leader>k", "<Cmd>Telescope keymaps<CR>", desc = "Keymaps" },
      { "<leader>m", "<Cmd>Telescope marks<CR>", desc = "Marks" },
      { "<leader>'", "<Cmd>Telescope registers<CR>", desc = "Registers" },
    },
    opts = function()
      local actions = require("telescope.actions")

      return {
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          path_display = { "truncate" },
          sorting_strategy = "ascending",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
            },
            vertical = {
              mirror = false,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-n>"] = actions.cycle_history_next,
              ["<C-p>"] = actions.cycle_history_prev,
              ["<C-c>"] = actions.close,
              ["<C-u>"] = actions.preview_scrolling_up,
              ["<C-d>"] = actions.preview_scrolling_down,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
            },
            n = {
              ["q"] = actions.close,
            },
          },
          file_ignore_patterns = {
            "node_modules",
            ".git/",
            "%.lock",
            "vendor/",
            "%.png",
            "%.jpg",
            "%.jpeg",
            "%.gif",
          },
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
            "--glob=!.git/",
          },
        },
        pickers = {
          find_files = {
            find_command = { "rg", "--files", "--hidden", "--glob", "!.git/*" },
          },
          buffers = {
            show_all_buffers = true,
            sort_lastused = true,
            mappings = {
              i = {
                ["<C-d>"] = actions.delete_buffer,
              },
            },
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
        },
      }
    end,
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)

      -- Load extensions
      pcall(telescope.load_extension, "fzf")
      pcall(telescope.load_extension, "ui-select")
    end,
  },
}
