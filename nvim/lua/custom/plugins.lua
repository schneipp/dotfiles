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
  end}
  use { 'https://codeberg.org/esensar/nvim-dev-container' }
  use {
  'chipsenkbeil/distant.nvim',
  tag = 'v0.2',
  config = function()
    require('distant').setup {
      -- Applies Chip's personal settings to every machine you connect to
      --
      -- 1. Ensures that distant servers terminate with no connections
      -- 2. Provides navigation bindings for remote directories
      -- 3. Provides keybinding to jump into a remote file's parent directory
      ['*'] = require('distant.settings').chip_default()
    }
  end
}
end

