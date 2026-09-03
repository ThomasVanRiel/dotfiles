return {
  {
    "saghen/blink.cmp",
    keys = {
      {
        "<leader>uq",
        function()
          vim.g.blink_enabled = vim.g.blink_enabled == false
          vim.notify("blink.cmp " .. (vim.g.blink_enabled == false and "disabled" or "enabled"))
        end,
        desc = "Toggle blink.cmp",
      },
    },
    opts = {
      enabled = function()
        return vim.g.blink_enabled ~= false
      end,
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
