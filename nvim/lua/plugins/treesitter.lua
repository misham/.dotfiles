-- Treesitter Configuration

return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    opts = {
      ensure_installed = {
        -- Your languages
        "go",
        "gomod",
        "gosum",
        "ruby",
        "javascript",
        "typescript",
        "tsx",
        "python",
        "c",
        "swift",
        "bash",
        "hcl", -- Terraform
        "sql",

        -- Web
        "html",
        "css",
        "json",
        "jsonc",

        -- Config/Data
        "yaml",
        "toml",
        "xml",

        -- Documentation
        "markdown",
        "markdown_inline",
        "mermaid",

        -- Git
        "git_config",
        "gitcommit",
        "gitignore",
        "diff",

        -- Neovim
        "lua",
        "vim",
        "vimdoc",
        "query",

        -- Other
        "dockerfile",
        "make",
        "regex",
        "jinja",
      },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { "ruby", "markdown" },
      },
      indent = {
        enable = true,
        disable = { "ruby" }, -- Ruby indentation can be quirky
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]m"] = "@function.outer",
            ["]]"] = "@class.outer",
          },
          goto_next_end = {
            ["]M"] = "@function.outer",
            ["]["] = "@class.outer",
          },
          goto_previous_start = {
            ["[m"] = "@function.outer",
            ["[["] = "@class.outer",
          },
          goto_previous_end = {
            ["[M"] = "@function.outer",
            ["[]"] = "@class.outer",
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ["<leader>a"] = "@parameter.inner",
          },
          swap_previous = {
            ["<leader>A"] = "@parameter.inner",
          },
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  -- Show context at top of buffer
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      enable = true,
      max_lines = 3,
      trim_scope = "outer",
    },
  },
}
