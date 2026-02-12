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
      },
    },
  },
}
