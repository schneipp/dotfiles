vim.opt.relativenumber = true

vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, { desc = 'Find Files' })
vim.keymap.set('n', '<leader>j', require('harpoon.ui').nav_next       , { desc = 'Harpoon Next' })
vim.keymap.set('n', '<leader>k', require('harpoon.ui').nav_prev, { desc = 'Harpoon Prev' })
vim.keymap.set('n', '<leader>h', require('harpoon.ui').toggle_quick_menu, { desc = 'Harpoon Navigation' })
vim.keymap.set('n', '<leader>ha', require('harpoon.mark').add_file, { desc = 'Harpoon Add File' })

vim.keymap.set({'v'},'<C-j>',':m \'>+1<CR>gv=gv')
vim.keymap.set({'v'},'<C-k>',':m \'<-2<CR>gv=gv')
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
-- Insane remapping of save to hammer
vim.keymap.set({'n'},'<leader><leader>',':w<CR>')
--nnoremap <leader>ps :lua require('telescope.builtin').grep_string( { search = vim.fn.input("Grep for > ") } )<cr>
--nnoremap <leader>ff :lua require'telescope.builtin'.find_files{ hidden = true }<cr> vim.keymap.set('n', '<leader>ps', require('telescope.builtin').live_grep())
vim.keymap.set({'i'},'<C-j>',':m \'>+1<CR>gv=gv')
vim.cmd [[set clipboard=unnamedplus]]
require("telescope").load_extension('workspaces')
vim.keymap.set('n', '<leader>fw', ":Telescope workspaces\n")
vim.opt.guicursor = ""
vim.keymap.set({'i'},'<M-j>','[', { noremap = true })
vim.keymap.set({'i'},'<M-k>',']' , { noremap = true })	      
vim.keymap.set({'i'},'<C-k>','}')
vim.keymap.set({'i'},'<C-j>','{')

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
 

-- vim.keymap.set({'i'},'§','<')
-- vim.keymap.set({'i'},'°','>')
--[=====[ 
local dap = require('dap')
dap.adapters.lldb= {
  type = 'executable',
  command = '/usr/bin/lldb-vscode', -- adjust as needed
  name = "lldb"
}
dap.configurations.rust = {
  {
    name = "Launch file",
    type = "lldb",
    request = "launch",
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    initCommands = function()
      -- Find out where to look for the pretty printer Python module
      local rustc_sysroot = vim.fn.trim(vim.fn.system('rustc --print sysroot'))

      local script_import = 'command script import "' .. rustc_sysroot .. '/lib/rustlib/etc/lldb_lookup.py"'
      local commands_file = rustc_sysroot .. '/lib/rustlib/etc/lldb_commands'

      local commands = {}
      local file = io.open(commands_file, 'r')
      if file then
        for line in file:lines() do
          table.insert(commands, line)
        end
        file:close()
      end
      table.insert(commands, 1, script_import)

      return commands
    end,
  },
  {
     name = "Attach to process",
      type = 'lldb',  -- Adjust this to match your adapter name (`dap.adapters.<name>`)
      request = 'attach',
      pid = require('dap.utils').pick_process,
      args = {},
  }
}
-- ]=====] 
-- Update this path
local extension_path = vim.env.HOME .. '/.vscode/extensions/vadimcn.vscode-lldb-1.9.1/'
local codelldb_path = extension_path .. 'adapter/codelldb'
local liblldb_path = extension_path .. 'lldb/lib/liblldb'
local this_os = vim.loop.os_uname().sysname;
-- The path in windows is different
if this_os:find "Windows" then
  codelldb_path = package_path .. "adapter\\codelldb.exe"
  liblldb_path = package_path .. "lldb\\bin\\liblldb.dll"
else
  -- The liblldb extension is .so for linux and .dylib for macOS
  liblldb_path = liblldb_path .. (this_os == "Linux" and ".so" or ".dylib")
end

local opts = {
    -- ... other configs
    dap = {
        adapter = require('rust-tools.dap').get_codelldb_adapter(
            codelldb_path, liblldb_path)
    }
}

require('dapui').setup()

require('neodev').setup({
  library = { plugins = { 'nvim-dap-ui' } }
})

--[=====[ 
local rt = require("rust-tools")

rt.setup({
  server = {
    on_attach = function(_, bufnr)
      -- Hover actions
      vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
      -- Code action groups
      vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
    end,
  }
})
-- ]=====]
