-- Send code cells to a REPL in a tmux pane (pairs with quarto-nvim for .qmd).
-- Usage: open an IPython pane (e.g. `.venv/bin/ipython`), then <C-c><C-c>
-- sends the current cell/selection to the last-active tmux pane.
return {
  "jpalardy/vim-slime",
  init = function()
    vim.g.slime_target = "tmux"
    vim.g.slime_default_config = { socket_name = "default", target_pane = "{last}" }
    vim.g.slime_bracketed_paste = 1
    -- treat ```{python} fences (qmd) as cell boundaries; <C-c><C-e> runs a cell
    vim.g.slime_cell_delimiter = "```"
  end,
}
