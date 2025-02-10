-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- local map = LazyVim.safe_keymap_set
local map = vim.keymap.set
map("n", "<leader>fw", ":Telescope workspaces<CR>", { desc = "List Workspaces", remap = true })
