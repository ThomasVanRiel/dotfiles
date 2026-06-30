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

vim.keymap.set({ "n", "x" }, "<leader>fl", function()
  local path = vim.fn.expand("%:.")
  local ref
  if vim.fn.mode():match("[vV\22]") then
    -- visual mode: copy a line range (start-end)
    local s, e = vim.fn.line("v"), vim.fn.line(".")
    if s > e then
      s, e = e, s
    end
    ref = path .. ":" .. s .. (s ~= e and "-" .. e or "")
  else
    -- normal mode: copy the current line
    ref = path .. ":" .. vim.fn.line(".")
  end
  vim.fn.setreg("+", ref)
  vim.notify("Copied file ref: " .. ref)
end, { desc = "Copy file path with line(s)" })
