--[[
lvim is the global options object

Linters should be
filled in as strings with either
a global executable or a path to
an executable
]]
-- THESE ARE EXAMPLE CONFIGS FEEL FREE TO CHANGE TO WHATEVER YOU WANT

-- general
lvim.log.level = "warn"
lvim.format_on_save.enabled = false
-- lvim.colorscheme = "OceanicNext"
lvim.colorscheme = "monokai_ristretto"
-- to disable icons and use a minimalist setup, uncomment the following
lvim.use_icons = true

-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"
-- add your own keymapping
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"

-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = true

-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = {
  "bash",
  "c",
  "javascript",
  "json",
  "lua",
  "python",
  "typescript",
  "tsx",
  "css",
  "rust",
  "java",
  "yaml",
}

lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enable = true


-- Additional Plugins
lvim.plugins = {
  {
    "akinsho/toggleterm.nvim",
    -- tag = '*',
    config = function()
      require("toggleterm").setup()
    end
  },
  { "natecraddock/workspaces.nvim" },
  { "mg979/vim-visual-multi" },
  { "eaxly/autumn.nvim" },
  { "YorickPeterse/Autumn.vim" },
  { "dempfi/ayu" },
  { "ThePrimeagen/harpoon" },
  {
    "romgrk/nvim-treesitter-context",
    config = function()
      require("treesitter-context").setup {
        enable = true,   -- Enable this plugin (Can be enabled/disabled later via commands)
        throttle = true, -- Throttles plugin updates (may improve performance)
        max_lines = 0,   -- How many lines the window should span. Values <= 0 mean no limit.
        patterns = {
                         -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
          -- For all filetypes
          -- Note that setting an entry here replaces all other patterns for this entry.
          -- By setting the 'default' entry below, you can control which nodes you want to
          -- appear in the context window.
          default = {
            'class',
            'function',
            'method',
          },
        },
      }
    end
  }, { "sonph/onehalf" },
  {
    "tpope/vim-fugitive",
    cmd = {
      "G",
      "Git",
      "Gdiffsplit",
      "Gread",
      "Gwrite",
      "Ggrep",
      "GMove",
      "GDelete",
      "GBrowse",
      "GRemove",
      "GRename",
      "Glgrep",
      "Gedit"
    },
    ft = { "fugitive" }
  }, { "mg979/vim-visual-multi" },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require('copilot').setup({
        panel = {
          enabled = true,
          auto_refresh = true,
          keymap = {
            jump_prev = "[[",
            jump_next = "]]",
            accept = "<CR>",
            refresh = "gr",
            open = "<M-CR>"
          },
          layout = {
            position = "right", -- | top | left | right
            ratio = 0.4
          },
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          debounce = 75,
          keymap = {
            accept = "<C-l>",
            accept_word = false,
            accept_line = false,
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
        filetypes = {
          yaml = false,
          markdown = false,
          help = false,
          gitcommit = false,
          gitrebase = false,
          hgcommit = false,
          svn = false,
          cvs = false,
          rust = true,
          php = true,
          ["."] = false,
        },
        copilot_node_command = 'node', -- Node.js version must be > 16.x
        server_opts_overrides = {},
      })
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    after = { "copilot.lua", "nvim-cmp" },
  },
  { 'mhartington/oceanic-next' },
  { 'tanvirtin/monokai.nvim' },
  { "ellisonleao/gruvbox.nvim", priority = 1000 },
  {
    'simrat39/rust-tools.nvim',
    ft = "rust",
    dependencies = "neovim/nvim-lspconfig",
    opts = function()
      return require "rust-tools"
    end,
    config = function(_, opts)
      require('rust-tools').setup(opts)
    end,
  },
  {
    "mfussenegger/nvim-dap",
    init = function()
      --      require("core.utils").load_mappings("dap")
    end
  },
  {
    "phaazon/hop.nvim",
    event = "BufRead",
    config = function()
      require("hop").setup()
      vim.api.nvim_set_keymap("n", "s", ":HopChar2<cr>", { silent = true })
      vim.api.nvim_set_keymap("n", "S", ":HopWord<cr>", { silent = true })
    end,
  },
  {
    "pwntester/octo.nvim",
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require("octo").setup()
    end,
  },
  {
    "nvim-neorg/neorg",
    build = ":Neorg sync-parsers",
    opts = {
      load = {
        ["core.defaults"] = {},               -- Loads default behaviour
        ["core.concealer"] = {},              -- Adds pretty icons to your documents
        ["core.integrations.telescope"] = {}, -- Adds Telscope support
        ["core.dirman"] = {                   -- Manages Neorg workspaces
          config = {
            workspaces = {
              notes = "~/notes",
            },
          },
        },
      },
    },
    dependencies = { { "nvim-lua/plenary.nvim" }, { "nvim-neorg/neorg-telescope" } },
  }
}

vim.opt.relativenumber = true

-- vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })
-- vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, { desc = 'Find Files' })

require("telescope").load_extension('workspaces')
vim.keymap.set('n', '<leader>fw', ":Telescope workspaces\n")
vim.opt.guicursor = ""
-- Autocommands (https://neovim.io/doc/user/autocmd.html)
-- vim.api.nvim_create_autocmd("BufEnter", {
--   pattern = { "*.json", "*.jsonc" },
--   -- enable wrap mode for json files only
--   command = "setlocal wrap",
-- })
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "zsh",
--   callback = function()
--     -- let treesitter use bash highlight for zsh files as well
--     require("nvim-treesitter.highlight").attach(0, "bash")
--   end,
-- })
--

require('toggleterm').setup {
  open_mapping = [[<C-t>]],
  direction = 'float',
  float_opts = {
    border = 'curved',
    width = 150,
    height = 50,
    highlights = {
      border = "#FF6600",
      background = "Normal"
    }
  }
}

require("workspaces").setup({
  hooks = {
    open = function()
      --            require("sessions").load(nil,{silent=true})
      require 'telescope.builtin'.find_files { hidden = true }
    end,
  }
})



-- now for some customizations
lvim.keys.visual_mode["<C-j>"] = ':m \'>+1<CR>gv=gv'
lvim.keys.visual_mode['<C-k>'] = ':m \'<-2<CR>gv=gv'
-- keep selection in visual mode when indenting
lvim.keys.visual_mode['<'] = '<gv'
lvim.keys.visual_mode['>'] = '>gv'
lvim.keys.normal_mode['Y'] = '0"*yg$'
-- center after page up and down
lvim.keys.normal_mode['<C-u>'] = '<C-u>zz'
lvim.keys.normal_mode['<C-d>'] = '<C-d>zz'
-- n jump to next match, and center the screen
-- forward and opposite dircection
lvim.keys.normal_mode['n'] = 'nzzzv'
lvim.keys.normal_mode['N'] = 'Nzzzv'
lvim.keys.normal_mode['<CR>'] = 'ciw'
lvim.keys.normal_mode['<S-CR>'] = 'ciw'
-- quick escape by pressing jk at the same time
-- lvim.keys.insert_mode[ 'jk'] = '<ESC>'
-- J Join lines, but keep cursor on same line
lvim.keys.normal_mode['J'] = 'mzJ`z'
-- Insane remapping of save to hammer
lvim.keys.normal_mode['<leader><leader>'] = ':w<CR>'
lvim.keys.insert_mode['<C-i>'] = '<'
lvim.keys.insert_mode['<C-o>'] = '>'
lvim.keys.normal_mode['<leader>j'] = require('harpoon.ui').nav_next
lvim.keys.normal_mode['<leader>k'] = require('harpoon.ui').nav_prev
lvim.keys.normal_mode['<C-j>'] = require('harpoon.ui').nav_next
lvim.keys.normal_mode['<C-k>'] = require('harpoon.ui').nav_prev
lvim.keys.normal_mode['<leader>hh'] = require('harpoon.ui').toggle_quick_menu
lvim.keys.normal_mode['<leader>ha'] = require('harpoon.mark').add_file
lvim.keys.normal_mode['<leader>nrn'] = ':Neorg workspace notes<CR>:Telescope neorg find_norg_files<CR>'
lvim.keys.normal_mode['<leader>ff'] = require('telescope.builtin').find_files
lvim.keys.normal_mode['<leader>f'] = false

lvim.builtin.cmp.formatting.source_names["copilot"] = "(Copilot)"

table.insert(lvim.builtin.cmp.sources, 1, { name = "copilot" })
-- table.insert(lvim.builtin.cmp.sources, 2, { name = "rust-analyzer" })

require("copilot.suggestion").toggle_auto_trigger()
