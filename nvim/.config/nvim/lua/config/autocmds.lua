-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "markdown",
--   callback = function(ev)
--     -- Disable auto-show so completions only appear on manual trigger (<C-Space>)
--     vim.b[ev.buf].blink_cmp_trigger_show_on_insert = false
--   end,
-- })
--
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.mdx",
  callback = function()
    vim.b.completion = false
  end,
})
