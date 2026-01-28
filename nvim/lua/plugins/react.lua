-- React/TypeScript Development
-- Provides VS Code-like experience for React development

return {
  -- Formatting with Prettier and ESLint
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = "",
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        graphql = { "prettier" },
      },
      format_on_save = function(bufnr)
        -- Disable for certain filetypes or large files
        local ignore_filetypes = { "sql", "java" }
        if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
          return
        end
        -- Disable for files larger than 500KB
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        if vim.fn.getfsize(bufname) > 500 * 1024 then
          return
        end
        return {
          timeout_ms = 2500,
          lsp_fallback = true,
        }
      end,
      formatters = {
        prettier = {
          prepend_args = { "--single-quote", "--jsx-single-quote" },
        },
      },
    },
    init = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },

  -- Auto-close and auto-rename HTML/JSX tags
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      opts = {
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = true,
      },
      per_filetype = {
        ["html"] = { enable_close = true },
        ["javascript"] = { enable_close = true },
        ["javascriptreact"] = { enable_close = true },
        ["typescript"] = { enable_close = true },
        ["typescriptreact"] = { enable_close = true },
        ["vue"] = { enable_close = true },
        ["svelte"] = { enable_close = true },
        ["xml"] = { enable_close = true },
      },
    },
  },

  -- Emmet for JSX
  {
    "mattn/emmet-vim",
    ft = { "html", "css", "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte" },
    init = function()
      vim.g.user_emmet_leader_key = "<C-y>"
      vim.g.user_emmet_settings = {
        javascript = { extends = "jsx" },
        javascriptreact = { extends = "jsx" },
        typescript = { extends = "tsx" },
        typescriptreact = { extends = "tsx" },
      }
      vim.g.user_emmet_mode = "a" -- Enable in all modes
    end,
  },

  -- Auto pairs for brackets (React-aware)
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true, -- Use treesitter for smart pairing
      ts_config = {
        lua = { "string" },
        javascript = { "template_string" },
        typescript = { "template_string" },
        javascriptreact = { "template_string", "jsx_element" },
        typescriptreact = { "template_string", "jsx_element" },
      },
      fast_wrap = {
        map = "<M-e>",
        chars = { "{", "[", "(", '"', "'" },
        pattern = [=[[%'%"%)%>%]%)%}%,]]=],
        end_key = "$",
        keys = "qwertyuiopzxcvbnmasdfghjkl",
      },
    },
    config = function(_, opts)
      local npairs = require("nvim-autopairs")
      npairs.setup(opts)
      -- Integrate with nvim-cmp
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  -- Better JSX commenting
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = true,
    opts = {
      enable_autocmd = false,
    },
    init = function()
      -- Override default get_option for Comment.nvim integration
      local get_option = vim.filetype.get_option
      vim.filetype.get_option = function(filetype, option)
        return option == "commentstring"
          and require("ts_context_commentstring.internal").calculate_commentstring()
          or get_option(filetype, option)
      end
    end,
  },

  -- Package.json dependency info
  {
    "vuki656/package-info.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    ft = { "json" },
    opts = {
      colors = {
        up_to_date = "#3C4048",
        outdated = "#d19a66",
      },
      icons = {
        enable = true,
        style = {
          up_to_date = "|  ",
          outdated = "|  ",
        },
      },
      autostart = true,
      hide_up_to_date = false,
      hide_unstable_versions = true,
    },
    keys = {
      { "<leader>ns", function() require("package-info").show() end, desc = "Show package versions" },
      { "<leader>nc", function() require("package-info").hide() end, desc = "Hide package versions" },
      { "<leader>nu", function() require("package-info").update() end, desc = "Update package" },
      { "<leader>nd", function() require("package-info").delete() end, desc = "Delete package" },
      { "<leader>ni", function() require("package-info").install() end, desc = "Install package" },
      { "<leader>np", function() require("package-info").change_version() end, desc = "Change package version" },
    },
  },
}
