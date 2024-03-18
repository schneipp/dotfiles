-- init.lua
local neogit = require('neogit')
neogit.setup {} 


-- bind neogit to a keymap
vim.api.nvim_set_keymap('n', '<leader>gg', '<cmd>Neogit<CR>', { noremap = true, silent = true })
