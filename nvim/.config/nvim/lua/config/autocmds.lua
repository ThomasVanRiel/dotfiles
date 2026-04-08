-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")


-- Start Godot Neovim server (cleans up stale socket)
vim.api.nvim_create_user_command("GodotServer", function()
  local sock = "/tmp/godot-nvim.sock"
  os.remove(sock)
  vim.fn.serverstart(sock)
  vim.notify("Listening on " .. sock)
end, {})
