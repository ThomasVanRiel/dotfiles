return {
  "https://github.com/fresh2dev/zellij.vim",
  -- Pin version to avoid breaking changes.
  -- tag = '0.3.*',
  lazy = false,
  init = function()
    vim.g.zellij_navigator_no_default_mappings = 1
  end,
}
