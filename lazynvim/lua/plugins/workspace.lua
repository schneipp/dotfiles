return {
  "natecraddock/workspaces.nvim",
  opts = {
    hooks = {
      open = function()
        require("telescope.builtin").find_files({ hidden = true })
      end,
    },
  },
}
