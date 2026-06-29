-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Copy paths to the system clipboard
vim.keymap.set("n", "<leader>fy", function()
  local path = vim.fn.expand("%:.")
  vim.fn.setreg("+", path)
  vim.notify("Copied file path: " .. path)
end, { desc = "Copy file path" })

vim.keymap.set("n", "<leader>fY", function()
  local dir = vim.fn.getcwd()
  vim.fn.setreg("+", dir)
  vim.notify("Copied cwd: " .. dir)
end, { desc = "Copy working directory" })
