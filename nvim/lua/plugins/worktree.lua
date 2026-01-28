-- Git Worktree Management

return {
  {
    "ThePrimeagen/git-worktree.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("git-worktree").setup({
        change_directory_command = "cd",
        update_on_change = true,
        update_on_change_command = "e .",
        clearjumps_on_change = true,
        autopush = false,
      })

      -- Load Telescope extension
      require("telescope").load_extension("git_worktree")

      -- Hooks for worktree operations
      local Worktree = require("git-worktree")

      Worktree.on_tree_change(function(op, metadata)
        if op == Worktree.Operations.Switch then
          print("Switched to worktree: " .. metadata.path)
        elseif op == Worktree.Operations.Create then
          print("Created worktree: " .. metadata.path)
        elseif op == Worktree.Operations.Delete then
          print("Deleted worktree: " .. metadata.path)
        end
      end)
    end,
    keys = {
      {
        "<leader>ww",
        function()
          require("telescope").extensions.git_worktree.git_worktrees()
        end,
        desc = "Switch worktree",
      },
      {
        "<leader>wc",
        function()
          require("telescope").extensions.git_worktree.create_git_worktree()
        end,
        desc = "Create worktree",
      },
      {
        "<leader>wd",
        function()
          -- Delete current worktree (prompts for confirmation)
          local worktree = require("git-worktree")
          local path = vim.fn.getcwd()
          vim.ui.input({ prompt = "Delete worktree at " .. path .. "? (y/n): " }, function(input)
            if input == "y" then
              worktree.delete_worktree(path)
            end
          end)
        end,
        desc = "Delete worktree",
      },
    },
  },
}
