function Update_config()
	os.execute("cd ~/.config/nvim && git pull origin master")
end
-- Automatically call update_config when Neovim starts
vim.api.nvim_create_autocmd("VimEnter", { callback = Update_config })
local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
local is_bootstrap = false
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	is_bootstrap = true
	vim.fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
	vim.cmd([[packadd packer.nvim]])
end
require("packer").startup(function(use)
	-- Package manager
	use("wbthomason/packer.nvim")
	use("andweeb/presence.nvim")
	use("GustavoPrietoP/doom-themes.nvim")
	-- Remote-nvim
	use("MunifTanjim/nui.nvim")
	use({ "nvim-neotest/nvim-nio" })
	use("mfussenegger/nvim-dap")
	use({
		"amitds1997/remote-nvim.nvim",
		config = function()
			require("remote-nvim").setup({
				ssh_config = {
					ssh_binary = "ssh", -- Binary to use for running SSH command
					scp_binary = "scp", -- Binary to use for running SSH copy commands
					ssh_config_file_paths = { "$HOME/.ssh/config" }, -- Which files should be considered to contain the ssh host configurations. NOTE: `Include` is respected in the provided files.

					-- These are useful for password-based SSH authentication.
					-- It provides parsing pattern for the plugin to detect that an input is requested.
					-- Each element contains the following attributes:
					-- match - The string to match (plain matching is done)
					-- type - Supports two values "plain"|"secret". Secret means when you provide the value, it should not be stored in the completion history of Neovim.
					-- value - Default value for the prompt
					-- value_type - "static"|"dynamic". For things like password, it would be needed for each new connection that the plugin initiates which could be obtrusive.
					-- So, we save the value (only for current session's interval) to ease the process. If set to "dynamic", we do not save the value even for the session. You have to provide a fresh value each time.
					ssh_prompts = {
						{
							match = "password:",
							type = "secret",
							value_type = "static",
							value = "",
						},
						{
							match = "continue connecting (yes/no/[fingerprint])?",
							type = "plain",
							value_type = "static",
							value = "",
						},
						-- There are other values here which can be checked in lua/remote-nvim/init.lua
					},
				},
				progress_view = {
					type = "popup",
				},
			})
		end,
	})
	use({
		"alexghergh/nvim-tmux-navigation",
		config = function()
			require("nvim-tmux-navigation").setup({
				disable_when_zoomed = true, -- defaults to false
				keybindings = {
					left = "<C-h>",
					down = "<C-j>",
					up = "<C-k>",
					right = "<C-l>",
					-- last_active = "<C-\\>",
					-- next = "<C-Space>",
				},
			})
		end,
	})
	-- templ treesitter
	use({
		"vrischmann/tree-sitter-templ",
		config = function()
			require("nvim-treesitter.parsers").get_parser_configs().templ = {
				filetype = "templ",
			}
		end,
	})
	-- folke/noice.nvim
	use({
		"folke/noice.nvim",
		config = function()
			require("noice").setup({
				lsp = {
					-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
					override = {
						["vim.lsp.util.convert_input_to_markdown_lines"] = true,
						["vim.lsp.util.stylize_markdown"] = true,
						["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
					},
				},
				-- you can enable a preset for easier configuration
				presets = {
					bottom_search = true, -- use a classic bottom cmdline for search
					command_palette = true, -- position the cmdline and popupmenu together
					long_message_to_split = true, -- long messages will be sent to a split
					inc_rename = false, -- enables an input dialog for inc-rename.nvim
					lsp_doc_border = true, -- add a border to hover docs and signature help
				},
			})
		end,
	})
	use({ "lvimuser/lsp-inlayhints.nvim" })
	use({ "folke/flash.nvim" })
	-- Treesitter playground
	use({
		"nvim-treesitter/playground",
		setup = function()
			vim.cmd([[
      nnoremap <leader>tp :TSPlaygroundToggle<CR>
    ]])
		end,
	})
	use({ -- LSP Configuration & Plugins
		"neovim/nvim-lspconfig",
		requires = {
			-- Automatically install LSPs to stdpath for neovim
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",

			-- Useful status updates for LSP
			-- 'j-hui/fidget.nvim',
		},
	})
	use({
		"epwalsh/obsidian.nvim",
		requires = {
			-- Required.
			"nvim-lua/plenary.nvim",

			-- see below for full list of optional dependencies 👇
		},
		config = function()
			require("obsidian").setup({
				workspaces = {
					{
						name = "personal",
						path = "~/Documents/allthethings",
					},
				},

				-- see below for full list of options 👇
			})
		end,
	})
	use({
		"NTBBloodbath/doom-one.nvim",
		setup = function()
			vim.g.doom_one_cursor_coloring = false
			vim.g.doom_one_terminal_colors = true
			vim.g.doom_one_italic_comments = false
			vim.g.doom_one_enable_treesitter = true
			vim.g.doom_one_diagnostics_text_color = false
			vim.g.doom_one_transparent_background = false
			vim.g.doom_one_pumblend_enable = false
			vim.g.doom_one_pumblend_transparency = 20
			vim.g.doom_one_plugin_neorg = true
			vim.g.doom_one_plugin_barbar = false
			vim.g.doom_one_plugin_telescope = true
			vim.g.doom_one_plugin_neogit = true
			vim.g.doom_one_plugin_nvim_tree = true
			vim.g.doom_one_plugin_dashboard = true
			vim.g.doom_one_plugin_startify = true
			vim.g.doom_one_plugin_whichkey = true
			vim.g.doom_one_plugin_indent_blankline = true
			vim.g.doom_one_plugin_vim_illuminate = true
			vim.g.doom_one_plugin_lspsaga = false
		end,
		config = function()
			--      vim.cmd("colorscheme doom-one")
		end,
	})
	use({ -- Autocompletion
		"hrsh7th/nvim-cmp",
		requires = { "hrsh7th/cmp-nvim-lsp", "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip" },
	})
	use("rafamadriz/friendly-snippets")
	use({ "ellisonleao/gruvbox.nvim" })
	use({ -- Highlight, edit, and navigate code
		"nvim-treesitter/nvim-treesitter",
		run = function()
			pcall(require("nvim-treesitter.install").update({ with_sync = true }))
		end,
	})
	use("nvim-treesitter/nvim-treesitter-context")
	use({ -- Additional text objects via treesitter
		"nvim-treesitter/nvim-treesitter-textobjects",
		after = "nvim-treesitter",
	})
	use({
		"max397574/better-escape.nvim",
		config = function()
			require("better_escape").setup()
		end,
	})
	-- Git related plugins
	use("tpope/vim-rhubarb")
	use("lewis6991/gitsigns.nvim")
	use("christoomey/vim-tmux-navigator")
	use("RishabhRD/popfix")
	use("RishabhRD/nvim-cheat.sh")
	use("navarasu/onedark.nvim") -- Theme inspired by Atom
	use("nvim-lualine/lualine.nvim") -- Fancier statusline
	use("lukas-reineke/indent-blankline.nvim") -- Add indentation guides even on blank lines
	use("numToStr/Comment.nvim") -- "gc" to comment visual regions/lines
	use("tpope/vim-sleuth") -- Detect tabstop and shiftwidth automatically
	-- neogit
	use({ "TimUntersberger/neogit", requires = "nvim-lua/plenary.nvim" })
	use({
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v2.x",
		requires = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
		},
	})
	-- Fuzzy Finder (files, lsp, etc)
	use({ "nvim-telescope/telescope.nvim", branch = "0.1.x", requires = { "nvim-lua/plenary.nvim" } })

	-- Fuzzy Finder Algorithm which requires local dependencies to be built. Only load if `make` is available
	use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make", cond = vim.fn.executable("make") == 1 })

	-- use { 'github/copilot.vim' }
	use({ "zbirenbaum/copilot.lua" })
	use({ "mhartington/oceanic-next" })
	--  use { 'tanvirtin/monokai.nvim' }
	use({
		"loctvl842/monokai-pro.nvim",
		config = function()
			require("monokai-pro").setup()
		end,
	})
	use({ "tpope/vim-fugitive" })
	use({ "pwntester/octo.nvim" })
	-- use { 'xiyaowong/nvim-transparent' }
	use({ "nvim-telescope/telescope-ui-select.nvim" })
	use({ "MunifTanjim/nui.nvim" })

	-- use({
	--   "jackMort/ChatGPT.nvim",
	--   config = function()
	--     require("chatgpt").setup({
	--       async_api_key_cmd = "pass show chatgpt/key",
	--     })
	--   end,
	--   requires = {
	--     "MunifTanjim/nui.nvim",
	--     "nvim-lua/plenary.nvim",
	--     "nvim-telescope/telescope.nvim"
	--   }
	-- })
	use({
		"kylechui/nvim-surround",
		tag = "*", -- Use for stability; omit to use `main` branch for the latest features
		config = function()
			require("nvim-surround").setup({
				-- Configuration here, or leave empty to use defaults
			})
		end,
	})
	-- Debugging
	use("nvim-lua/plenary.nvim")
	use({
		"folke/which-key.nvim",
		config = function()
			require("which-key").setup({})
		end,
	})
	use({
		"akinsho/toggleterm.nvim",
		tag = "*",
		config = function()
			require("toggleterm").setup()
		end,
	})
	use("natecraddock/workspaces.nvim")
	use("mg979/vim-visual-multi")
	use("ThePrimeagen/harpoon")
	-- use 'mfussenegger/nvim-dap'
	-- use "folke/neodev.nvim"
	-- use "theHamsta/nvim-dap-virtual-text"
	-- use {
	--   'chipsenkbeil/distant.nvim',
	--   branch = 'v0.3',
	--   config = function()
	--     require('distant'):setup()
	--   end
	-- }
	-- use "nvim-telescope/telescope-dap.nvim"
	-- use { "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } }
	use({ "catppuccin/nvim", as = "catppuccin" })
	use("simrat39/rust-tools.nvim")
	-- Add custom plugins to packer from ~/.config/nvim/lua/custom/plugins.lua
	local has_plugins, plugins = pcall(require, "custom.plugins")
	if has_plugins then
		plugins(use)
	end

	if is_bootstrap then
		require("packer").sync()
	end
end)

-- When we are bootstrapping a configuration, it doesn't
-- make sense to execute the rest of the init.lua.
--
-- You'll need to restart nvim, and then it will work.
if is_bootstrap then
	print("==================================")
	print("    Plugins are being installed")
	print("    Wait until Packer completes,")
	print("       then restart nvim")
	print("==================================")
	return
end

-- Automatically source and re-compile packer whenever you save this init.lua
local packer_group = vim.api.nvim_create_augroup("Packer", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
	command = "source <afile> | PackerCompile",
	group = packer_group,
	pattern = vim.fn.expand("$MYVIMRC"),
})

-- [[ Setting options ]]
-- See `:help vim.o`
-- Set highlight on search
vim.o.hlsearch = false
-- Make line numbers default
vim.wo.number = true
-- Enable mouse mode
vim.o.mouse = "a"
-- Enable break indent
vim.o.breakindent = true
-- Save undo history
vim.o.undofile = true
-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true
-- Decrease update time
vim.o.updatetime = 250
vim.wo.signcolumn = "yes"
-- Set colorscheme
vim.o.termguicolors = true
-- vim.cmd [[colorscheme catppuccin-mocha]]
vim.cmd([[colorscheme monokai-pro-classic]])
-- vim.cmd [[colorscheme monokai-pro-spectrum]]
-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noselect"
vim.g.mapleader = " "
vim.g.mapocalleader = " "
-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = "*",
})

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)

-- Make runtime files discoverable to the server
local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

-- nvim-cmp setup
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},

	mapping = cmp.mapping.preset.insert({
		["<C-d>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<CR>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		}),
	}),
	sources = {
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
	},
})
vim.o.background = "dark"
vim.o.conceallevel = 2

-- The line beneath this is called `modeline`. See `:help modeline`
--
-- Configure netrw to be less annoying
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3 -- Tree view
-- vim.g.netrw_browse_split = 4 -- Open in previous window
-- vim.g.netrw_altv = 1 -- Open splits to the right
-- vim.g.netrw_winsize = 25 -- Size of netrw window
vim.g.netrw_localrmdir = "rm -r" -- Delete recursively
vim.g.netrw_keepdir = 0 -- Delete empty directories
vim.g.netrw_sizestyle = "H" -- Human-readable file sizes
vim.g.netrw_list_hide = ".*.swp$" -- Hide swap files
vim.g.netrw_list_hide = ".git$" -- Hide git files
vim.g.netrw_list_hide = ".gitignore$" -- Hide git files
vim.g.netrw_list_hide = ".gitmodules$" -- Hide git files
vim.g.netrw_list_hide = ".DS_Store$" -- Hide git files
vim.g.netrw_list_hide = ".gitkeep$" -- Hide git files
vim.g.netrw_list_hide = ".gitconfig$" -- Hide git files
vim.g.netrw_list_hide = ".gitattributes$" -- Hide git files

if vim.g.neovide then
	vim.o.guifont = "JetBrainsMonoNL Nerd Font:h15"
end
