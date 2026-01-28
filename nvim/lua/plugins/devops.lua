-- DevOps Tooling: Terraform, AWS, GitHub
-- Enhanced support for infrastructure and cloud development

return {
  -- Terraform enhancements
  {
    "hashivim/vim-terraform",
    ft = { "terraform", "tf", "terraform-vars", "hcl" },
    init = function()
      vim.g.terraform_fmt_on_save = 1
      vim.g.terraform_align = 1
      vim.g.terraform_fold_sections = 0
    end,
  },

  -- Terraform state explorer and CLI integration
  {
    "Allaman/tf.nvim",
    ft = { "terraform", "tf", "hcl" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      -- Custom terraform binary path (optional)
      -- terraform_binary = "terraform",
    },
    keys = {
      { "<leader>ti", "<cmd>TerraformInit<cr>", desc = "Terraform init" },
      { "<leader>tv", "<cmd>TerraformValidate<cr>", desc = "Terraform validate" },
      { "<leader>tp", "<cmd>TerraformPlan<cr>", desc = "Terraform plan" },
      { "<leader>ta", "<cmd>TerraformApply<cr>", desc = "Terraform apply" },
      { "<leader>ts", "<cmd>TerraformState<cr>", desc = "Terraform state" },
      { "<leader>to", "<cmd>TerraformOutput<cr>", desc = "Terraform output" },
    },
  },

  -- Terraform documentation browser
  {
    "ANGkeith/telescope-terraform-doc.nvim",
    ft = { "terraform", "tf", "hcl" },
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("telescope").load_extension("terraform_doc")
    end,
    keys = {
      { "<leader>td", "<cmd>Telescope terraform_doc<cr>", desc = "Terraform docs" },
      { "<leader>tD", "<cmd>Telescope terraform_doc full_name=hashicorp/aws<cr>", desc = "AWS provider docs" },
    },
  },

  -- GitHub integration (Issues, PRs, Reviews)
  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      enable_builtin = true,
      default_to_projects_v2 = true,
      suppress_missing_scope = {
        projects_v2 = true,
      },
      picker = "telescope",
      mappings = {
        issue = {
          close_issue = { lhs = "<leader>ic", desc = "Close issue" },
          reopen_issue = { lhs = "<leader>io", desc = "Reopen issue" },
          list_issues = { lhs = "<leader>il", desc = "List issues" },
          copy_url = { lhs = "<C-y>", desc = "Copy issue URL" },
        },
        pull_request = {
          checkout_pr = { lhs = "<leader>po", desc = "Checkout PR" },
          merge_pr = { lhs = "<leader>pm", desc = "Merge PR" },
          list_commits = { lhs = "<leader>pc", desc = "List commits" },
          list_changed_files = { lhs = "<leader>pf", desc = "List changed files" },
          diff_changes = { lhs = "<leader>pd", desc = "Diff changes" },
        },
        review_thread = {
          add_comment = { lhs = "<leader>ca", desc = "Add comment" },
          add_suggestion = { lhs = "<leader>sa", desc = "Add suggestion" },
        },
      },
    },
    keys = {
      -- Issues
      { "<leader>oi", "<cmd>Octo issue list<cr>", desc = "List issues" },
      { "<leader>oI", "<cmd>Octo issue create<cr>", desc = "Create issue" },
      { "<leader>os", "<cmd>Octo issue search<cr>", desc = "Search issues" },

      -- Pull Requests
      { "<leader>op", "<cmd>Octo pr list<cr>", desc = "List PRs" },
      { "<leader>oP", "<cmd>Octo pr create<cr>", desc = "Create PR" },
      { "<leader>oc", "<cmd>Octo pr checkout<cr>", desc = "Checkout PR" },

      -- Reviews
      { "<leader>or", "<cmd>Octo review start<cr>", desc = "Start review" },
      { "<leader>oR", "<cmd>Octo review submit<cr>", desc = "Submit review" },

      -- Actions
      { "<leader>oa", "<cmd>Octo actions<cr>", desc = "GitHub actions" },

      -- Repo
      { "<leader>ob", "<cmd>Octo repo browser<cr>", desc = "Open in browser" },
    },
  },

  -- Git signs and blame (complements octo.nvim)
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "│" },
        change = { text = "│" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
      current_line_blame = false, -- Toggle with :Gitsigns toggle_current_line_blame
      current_line_blame_opts = {
        delay = 500,
        virt_text_pos = "eol",
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end

        -- Navigation
        map("n", "]h", gs.next_hunk, "Next hunk")
        map("n", "[h", gs.prev_hunk, "Prev hunk")

        -- Actions
        map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
        map("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage hunk")
        map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset hunk")
        map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")
        map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")
        map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
        map("n", "<leader>hB", gs.toggle_current_line_blame, "Toggle line blame")
        map("n", "<leader>hd", gs.diffthis, "Diff this")
        map("n", "<leader>hD", function() gs.diffthis("~") end, "Diff this ~")

        -- Text object
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select hunk")
      end,
    },
  },

  -- Diffview for better diffs (works with octo.nvim)
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      enhanced_diff_hl = true,
      view = {
        merge_tool = {
          layout = "diff3_mixed",
        },
      },
    },
    keys = {
      { "<leader>hv", "<cmd>DiffviewOpen<cr>", desc = "Open diffview" },
      { "<leader>hf", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
      { "<leader>hF", "<cmd>DiffviewFileHistory<cr>", desc = "Branch history" },
      { "<leader>hx", "<cmd>DiffviewClose<cr>", desc = "Close diffview" },
    },
  },

  -- Git conflict resolution (inline markers)
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    event = "BufReadPre",
    opts = {
      default_mappings = true, -- Use default mappings
      default_commands = true,
      disable_diagnostics = false,
      list_opener = "copen", -- Use quickfix for conflict list
      highlights = {
        incoming = "DiffAdd",
        current = "DiffText",
      },
    },
    keys = {
      { "<leader>xo", "<cmd>GitConflictChooseOurs<cr>", desc = "Choose ours (current)" },
      { "<leader>xt", "<cmd>GitConflictChooseTheirs<cr>", desc = "Choose theirs (incoming)" },
      { "<leader>xb", "<cmd>GitConflictChooseBoth<cr>", desc = "Choose both" },
      { "<leader>xn", "<cmd>GitConflictChooseNone<cr>", desc = "Choose none" },
      { "<leader>xq", "<cmd>GitConflictListQf<cr>", desc = "List conflicts in quickfix" },
      { "]x", "<cmd>GitConflictNextConflict<cr>", desc = "Next conflict" },
      { "[x", "<cmd>GitConflictPrevConflict<cr>", desc = "Prev conflict" },
    },
  },

  -- YAML/JSON schema support for AWS CloudFormation, K8s, etc.
  {
    "b0o/schemastore.nvim",
    lazy = true,
  },
}
