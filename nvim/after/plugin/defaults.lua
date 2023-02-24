vim.opt.relativenumber = true

vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, { desc = 'Find Files' })

require("telescope").load_extension('workspaces')
vim.keymap.set('n', '<leader>fw', ":Telescope workspaces\n")
vim.opt.guicursor = ""

