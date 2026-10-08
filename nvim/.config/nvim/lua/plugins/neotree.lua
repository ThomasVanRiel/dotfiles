return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      filtered_items = {
        visible = false,
        hide_dotfiles = true,
        hide_gitignored = true,
        never_show = { ".git" },
      },
      window = {
        mappings = {
          ["<M-h>"] = "toggle_hidden",
        },
      },
    },
  },
}
