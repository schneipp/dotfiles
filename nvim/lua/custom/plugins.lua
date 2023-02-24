return function(use)
  use({
    "folke/which-key.nvim",
      config = function()
        require("which-key").setup({})
      end
  })
  use {"akinsho/toggleterm.nvim", tag = '*', config = function()
    require("toggleterm").setup()
  end}
  use "natecraddock/workspaces.nvim"
  use "mg979/vim-visual-multi"
  use {'nvim-orgmode/orgmode', config = function()
    require('orgmode').setup{}
  end
}
end

