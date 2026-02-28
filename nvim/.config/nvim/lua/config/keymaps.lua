-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Zellij navigation (overrides LazyVim's default <C-h/j/k/l> window nav)
vim.keymap.set("n", "<C-h>", "<cmd>ZellijNavigateLeft<cr>",  { silent = true })
vim.keymap.set("n", "<C-j>", "<cmd>ZellijNavigateDown<cr>",  { silent = true })
vim.keymap.set("n", "<C-k>", "<cmd>ZellijNavigateUp<cr>",    { silent = true })
vim.keymap.set("n", "<C-l>", "<cmd>ZellijNavigateRight<cr>", { silent = true })
