-- plugins/quarto.lua
return {
  {
    "quarto-dev/quarto-nvim",
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    init = function()
      vim.treesitter.language.register("markdown", "quarto")
    end,
    opts = { -- <- this is what was missing
      lspFeatures = { languages = { "python" } },
      codeRunner = { enabled = true, default_method = "slime" },
    },
  },
  {
    "jpalardy/vim-slime",
    init = function()
      vim.g.slime_target = "tmux"
      vim.g.slime_bracketed_paste = 1 -- required, or ipython mangles indented blocks
      vim.g.slime_default_config = { socket_name = "default", target_pane = "{last}" }
      vim.g.slime_dont_ask_default = 1
    end,
  },
}
