return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        ["<CR>"] = {},
        ["<Tab>"] = { "select_and_accept", "snippet_forward", "fallback" },
      },
      completion = {
        trigger = {
          show_on_insert_on_trigger_character = true,
        },
        menu = {
          auto_show = function()
            return not vim.tbl_contains({ "markdown", "markdown.mdx" }, vim.bo.filetype)
          end,
        },
        ghost_text = {
          enabled = function()
            return not vim.tbl_contains({ "markdown", "markdown.mdx" }, vim.bo.filetype)
          end,
        },
      },
    },
  },
}
