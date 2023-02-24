require("workspaces").setup({
    hooks = {
        open = function()
--            require("sessions").load(nil,{silent=true})
            require'telescope.builtin'.find_files{ hidden = true }
        end,
    }
})
