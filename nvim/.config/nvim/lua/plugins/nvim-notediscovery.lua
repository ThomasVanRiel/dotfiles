return {
  {
    "ThomasVanRiel/nvim-notediscovery",
    lazy = false,
    config = function()
      require("notediscovery").setup({
        url = "https://notes.thomasvanriel.com/api", -- Required!
        default_folder = "inbox", -- Optional
      })

      -- Optional: Set up keybindings
      local keymap = vim.keymap.set
      keymap("n", "<leader>nl", ":NoteList<CR>", { desc = "List notes" })
      keymap("n", "<leader>ns", ":NoteSearch<CR>", { desc = "Search notes" })
      keymap("n", "<leader>nn", ":NoteNew<CR>", { desc = "New note" })
      keymap("n", "<leader>no", ":NoteLoad<CR>", { desc = "Open note" })
      keymap("n", "<leader>nr", ":NoteLoadLast<CR>", { desc = "Reload last note" })
      keymap("v", "<leader>nq", '"+y:NoteQuick<CR>', { desc = "Quick note from selection" })
    end,
  },
}
