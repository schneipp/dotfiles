vim.opt.relativenumber = true

vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, { desc = 'Find Files' })
vim.keymap.set('n', '<leader>j', require('harpoon.ui').nav_next       , { desc = 'Harpoon Next' })
vim.keymap.set('n', '<leader>k', require('harpoon.ui').nav_prev, { desc = 'Harpoon Prev' })
vim.keymap.set('n', '<leader>h', require('harpoon.ui').toggle_quick_menu, { desc = 'Harpoon Navigation' })
vim.keymap.set('n', '<leader>ha', require('harpoon.mark').add_file, { desc = 'Harpoon Add File' })

vim.keymap.set({'v'},'<S-j>',':m \'>+1<CR>gv=gv')
vim.keymap.set({'v'},'<S-k>',':m \'<-2<CR>gv=gv')
-- keep selection in visual mode when indenting
vim.keymap.set({'v'},'<','<gv')
vim.keymap.set({'v'},'>','>gv')
vim.keymap.set({'n'},'Y','0"*yg$')
-- n jump to next match, and center the screen
-- forward and opposite dircection
vim.keymap.set({'n'},'n','nzzzv')
vim.keymap.set({'n'},'N','Nzzzv')
-- J Join lines, but keep cursor on same line
vim.keymap.set({'n'},'J','mzJ`z')
vim.keymap.set({'n'},'<CR>','ciw')
-- Insane remapping of save to hammer
vim.keymap.set({'n'},'<leader><leader>',':w<CR>')
vim.keymap.set({'i'},'<C-j>',':m \'>+1<CR>gv=gv')
vim.cmd [[set clipboard=unnamedplus]]
require("telescope").load_extension('workspaces')
vim.keymap.set('n', '<leader>fw', ":Telescope workspaces\n")
vim.opt.guicursor = ""
vim.keymap.set('n', '<leader>db', ":lua require'dap'.toggle_breakpoint()<CR>", { desc = 'Toggle Breakpoint' })
vim.keymap.set('n', '<leader>dB', ":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint Condition: '))<CR>", { desc = 'Toggle Breakpoint' })
vim.keymap.set('n', '<leader>dr', ":RustDebuggables<CR>:lua require'dapui'.toggle()<CR>", { desc = 'Start Debugger' })
vim.keymap.set('n', '<leader>dR', ":lua require'dap'.repl.open()<CR>", { desc = 'Open REPL' })
vim.keymap.set('n', '<leader>dl', ":lua require'dap'.run_last()<CR>", { desc = 'Run Last' })
vim.keymap.set('n', '<leader>dd', ":lua require'dap'.continue()<CR>", { desc = 'Continue' })
vim.keymap.set('n', '<leader>dc', ":lua require'dap'.step_over()<CR>", { desc = 'Step Over' })
vim.keymap.set('n', '<leader>di', ":lua require'dap'.step_into()<CR>", { desc = 'Step Into' })
vim.keymap.set('n', '<leader>di', ":lua require'dap'.stop()<CR>", { desc = 'Stop'} )
vim.keymap.set('n', '<leader>ds', ":lua require'dap'.stop()<CR>:lua require'dapui'.toggle()<CR>", { desc = 'Stop and Close UI'} )
vim.keymap.set('n', '<leader>e', ":NeoTreeFocusToggle<CR>", { desc = 'NeoTree Explorer'} )
vim.keymap.set('n', '<C-h>', "<cmd> TmuxNavigateLeft<CR>", { desc = 'Window Left'} )
vim.keymap.set('n', '<C-l>', "<cmd> TmuxNavigateRight<CR>", { desc = 'Window Right'} )
vim.keymap.set('n', '<C-j>', "<cmd> TmuxNavigateDown<CR>", { desc = 'Window Down'} )
vim.keymap.set('n', '<C-k>', "<cmd> TmuxNavigateUp<CR>", { desc = 'Window Up'} )


require('dapui').setup()

require('neodev').setup({
  library = { plugins = { 'nvim-dap-ui' } }
})

