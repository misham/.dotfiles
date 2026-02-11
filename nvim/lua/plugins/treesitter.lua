-- Treesitter Configuration

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    version = false,
    build = ":TSUpdate",
    lazy = false,
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
      },
    },
    config = function()
      -- Install parsers
      require("nvim-treesitter").install({
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
      })

      -- Enable treesitter features per filetype
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local ok = pcall(vim.treesitter.start, args.buf)
          if ok then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      -- Disable treesitter indent for ruby (can be quirky)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "ruby" },
        callback = function(args)
          vim.bo[args.buf].indentexpr = ""
        end,
      })

      -- Additional regex highlighting for ruby and markdown
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "ruby", "markdown" },
        callback = function(args)
          vim.bo[args.buf].syntax = "ON"
        end,
      })

      -- Textobjects
      require("nvim-treesitter-textobjects").setup({
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
      })
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
