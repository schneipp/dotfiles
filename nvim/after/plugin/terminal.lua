local ui = require('vim.ui')

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

local Terminal  = require('toggleterm.terminal').Terminal
local lazygit = Terminal:new({ cmd = "lazygit", hidden = true })

function LazygitToggle()
  lazygit:toggle()
end

vim.api.nvim_set_keymap("n", "<C-g>", "<cmd>lua LazygitToggle()<CR>", {noremap = true, silent = true})
