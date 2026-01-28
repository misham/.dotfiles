-- Go Development Enhancements
-- Additional tooling beyond gopls LSP

return {
  -- go.nvim: Feature-rich Go development plugin
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua", -- Float term, UI
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
      -- DAP for debugging (optional)
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
    },
    ft = { "go", "gomod", "gowork", "gotmpl" },
    build = ':lua require("go.install").update_all_sync()',
    opts = {
      -- Disable features handled by gopls
      lsp_cfg = false, -- We configure gopls separately
      lsp_gofumpt = false, -- gopls handles this
      lsp_keymaps = false, -- We set our own keymaps

      -- Enable go.nvim features
      tag_transform = false,
      tag_options = "json=omitempty",
      icons = { breakpoint = "🔴", currentpos = "👉" },
      verbose = false,

      -- Test configuration
      test_runner = "go",
      run_in_floaterm = true,
      floaterm = {
        position = "bottom",
        width = 0.98,
        height = 0.4,
      },

      -- Coverage
      test_coverage_signs = true,

      -- Diagnostics
      trouble = false, -- Set to true if you use trouble.nvim
      luasnip = true, -- Enable luasnip for snippets
    },
    config = function(_, opts)
      require("go").setup(opts)

      -- Format and organize imports on save (handled by gopls, but this is a fallback)
      local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.go",
        callback = function()
          require("go.format").goimports()
        end,
        group = format_sync_grp,
      })
    end,
    keys = {
      -- Testing
      { "<leader>gt", "<cmd>GoTest<cr>", desc = "Run Go tests" },
      { "<leader>gT", "<cmd>GoTestFile<cr>", desc = "Run Go file tests" },
      { "<leader>gf", "<cmd>GoTestFunc<cr>", desc = "Run Go test function" },
      { "<leader>gc", "<cmd>GoCoverage<cr>", desc = "Go test coverage" },
      { "<leader>gC", "<cmd>GoCoverageToggle<cr>", desc = "Toggle coverage signs" },

      -- Code generation
      { "<leader>ga", "<cmd>GoAddTag<cr>", desc = "Add struct tags" },
      { "<leader>gA", "<cmd>GoRmTag<cr>", desc = "Remove struct tags" },
      { "<leader>gi", "<cmd>GoImpl<cr>", desc = "Implement interface" },
      { "<leader>gF", "<cmd>GoFillStruct<cr>", desc = "Fill struct" },
      { "<leader>ge", "<cmd>GoIfErr<cr>", desc = "Add if err != nil" },

      -- Generate
      { "<leader>gg", "<cmd>GoGenerate<cr>", desc = "Go generate" },
      { "<leader>gm", "<cmd>GoMod tidy<cr>", desc = "Go mod tidy" },

      -- Debug
      { "<leader>gd", "<cmd>GoDebug<cr>", desc = "Start debugger" },
      { "<leader>gD", "<cmd>GoDbgStop<cr>", desc = "Stop debugger" },
      { "<leader>gb", "<cmd>GoBreakToggle<cr>", desc = "Toggle breakpoint" },

      -- Misc
      { "<leader>gv", "<cmd>GoVet<cr>", desc = "Go vet" },
      { "<leader>gl", "<cmd>GoLint<cr>", desc = "Go lint" },
      { "<leader>gr", "<cmd>GoRun<cr>", desc = "Go run" },
      { "<leader>gp", "<cmd>GoDoc<cr>", desc = "Go doc popup" },
    },
  },

  -- Gopher.nvim: Alternative/complementary Go tools
  {
    "olexsmir/gopher.nvim",
    ft = "go",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    build = function()
      vim.cmd([[silent! GoInstallDeps]])
    end,
    opts = {},
  },
}
