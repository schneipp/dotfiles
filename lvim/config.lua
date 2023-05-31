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
lvim.colorscheme = "gruvbox"
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
  { "sonph/onehalf" },
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
    "nvim-neorg/neorg",
    build = ":Neorg sync-parsers",
    opts = {
      load = {
        ["core.defaults"] = {},          -- Loads default behaviour
        ["core.concealer"] = {},         -- Adds pretty icons to your documents
        ["core.integrations.telescope"] = {},         -- Adds pretty icons to your documents
        ["core.dirman"] = {              -- Manages Neorg workspaces
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
vim.keymap.set({ 'v' }, '<C-j>', ':m \'>+1<CR>gv=gv')
vim.keymap.set({ 'v' }, '<C-k>', ':m \'<-2<CR>gv=gv')
-- keep selection in visual mode when indenting
vim.keymap.set({ 'v' }, '<', '<gv')
vim.keymap.set({ 'v' }, '>', '>gv')
vim.keymap.set({ 'n' }, 'Y', '0"*yg$')
-- n jump to next match, and center the screen
-- forward and opposite dircection
vim.keymap.set({ 'n' }, 'n', 'nzzzv')
vim.keymap.set({ 'n' }, 'N', 'Nzzzv')
-- J Join lines, but keep cursor on same line
vim.keymap.set({ 'n' }, 'J', 'mzJ`z')
-- Insane remapping of save to hammer
vim.keymap.set({ 'n' }, '<leader><leader>', ':w<CR>')
lvim.builtin.cmp.formatting.source_names["copilot"] = "(Copilot)"

vim.keymap.set('n', '<C-j>', require('harpoon.ui').nav_next, { desc = 'Harpoon Next' })
vim.keymap.set('n', '<C-k>', require('harpoon.ui').nav_prev, { desc = 'Harpoon Prev' })
vim.keymap.set('n', '<leader>h', require('harpoon.ui').toggle_quick_menu, { desc = 'Harpoon Navigation' })
vim.keymap.set('n', '<leader>ha', require('harpoon.mark').add_file, { desc = 'Harpoon Add File' })

vim.keymap.set('n', '<leader>nrn', ':Telescope neorg find_norg_files<CR>', { desc = 'Harpoon Add File' })

table.insert(lvim.builtin.cmp.sources, 1, { name = "copilot" })
-- table.insert(lvim.builtin.cmp.sources, 2, { name = "rust-analyzer" })

require("copilot.suggestion").toggle_auto_trigger()
