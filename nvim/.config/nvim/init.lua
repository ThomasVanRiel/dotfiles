-- vim: ts=2 sts=2 sw=2 et
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.shiftwidth = 4

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Setup plugins
require("lazy").setup({
    { "catppuccin/nvim", lazy = false, name = "catppuccin", priority=1000 },
    {
      "kylechui/nvim-surround",
      version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
        event = "VeryLazy",
      config = function()
        require("nvim-surround").setup({
            -- Configuration here, or leave empty to use defaults
            })
      end
    }
})

-- Re-add system parser paths that lazy.nvim strips from runtimepath
for _, p in ipairs({ "/usr/lib/x86_64-linux-gnu/nvim", "/usr/lib/nvim" }) do
  if vim.uv.fs_stat(p) then vim.opt.rtp:append(p) end
end
vim.cmd.colorscheme("catppuccin")
