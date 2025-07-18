-- OSC52 copy function
local function copy_to_osc52(lines, regtype)
  local text = table.concat(lines, "\n")
  if regtype == "V" then
    text = text .. "\n" -- Ensure linewise yanks include a newline
  end
  local osc52 = string.format("\027]52;c;%s\007", vim.base64.encode(text))
  -- Write to stderr to avoid tmux interception
  io.stderr:write(osc52)
  -- Debug notification
  -- vim.notify("Sent to OSC52 clipboard: " .. text:sub(1, 20) .. "...", vim.log.levels.INFO)
end

-- Fallback paste function
local function paste()
  return vim.fn.getreg("+")
end

-- Custom clipboard provider
vim.g.clipboard = {
  name = "osc52",
  copy = {
    ["+"] = copy_to_osc52,
    ["*"] = copy_to_osc52,
  },
  paste = {
    ["+"] = paste,
    ["*"] = paste,
  },
}

-- Trigger OSC52 on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("Osc52Yank", { clear = true }),
  callback = function()
    if vim.v.event.regname == "+" or vim.v.event.regname == "" then
      copy_to_osc52(vim.v.event.regcontents, vim.v.event.regtype)
    end
  end,
})

-- Enable system clipboard
vim.opt.clipboard:append("unnamedplus")

-- Optional: Map yank/paste in terminal mode
vim.keymap.set("t", "<C-c>", [[<C-\><C-n>"+y]], { desc = "Copy in terminal" })
vim.keymap.set("t", "<C-v>", [[<C-\><C-n>"+p]], { desc = "Paste in terminal" })

return {
  -- No external dependencies
}
