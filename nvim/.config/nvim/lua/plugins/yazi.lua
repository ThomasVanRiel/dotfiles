---@type LazySpec
return {
  "mikavilpas/yazi.nvim",
  version = "*", -- stable releases only
  event = "VeryLazy",
  dependencies = {
    -- already in the tree via LazyVim, listed for correctness
    { "nvim-lua/plenary.nvim", lazy = true },
  },
  keys = {
    -- Upstream defaults; two of them shadow LazyVim keymaps:
    --   <leader>- was "Split Window Below" (<C-w>s still splits)
    --   <c-up> was "Increase Window Height" (<C-w>+ still resizes)
    { "<leader>-", "<cmd>Yazi<cr>", mode = { "n", "v" }, desc = "Open yazi at the current file" },
    { "<leader>cw", "<cmd>Yazi cwd<cr>", desc = "Open yazi in nvim's working directory" },
    { "<c-up>", "<cmd>Yazi toggle<cr>", desc = "Resume the last yazi session" },
  },
  ---@type YaziConfig | {}
  opts = {
    -- oil.nvim keeps hijacking directories, so netrw stays as-is and no
    -- init/loaded_netrwPlugin dance is needed
    open_for_directories = false,
    keymaps = {
      show_help = "<f1>",
    },
  },
}
