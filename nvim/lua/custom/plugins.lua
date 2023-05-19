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
  use "ThePrimeagen/harpoon"
  use 'mfussenegger/nvim-dap'
  use "folke/neodev.nvim"
  use "theHamsta/nvim-dap-virtual-text"
  use "nvim-telescope/telescope-dap.nvim"
  use { "rcarriga/nvim-dap-ui", requires = {"mfussenegger/nvim-dap"} }
  use { "catppuccin/nvim", as = "catppuccin" }
  use 'simrat39/rust-tools.nvim'
end
