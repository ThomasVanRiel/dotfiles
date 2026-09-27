return {
  {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",

    config = function()
      local mc = require("multicursor-nvim")
      mc.setup()

      local map = vim.keymap.set

      -- Add cursor at next/previous occurrence of word or visual selection.
      map({ "n", "x" }, "<leader>mn", function()
        mc.matchAddCursor(1)
      end, { desc = "Multicursor: next match" })

      map({ "n", "x" }, "<leader>mN", function()
        mc.matchAddCursor(-1)
      end, { desc = "Multicursor: previous match" })

      -- Add cursors vertically.
      map({ "n", "x" }, "<leader>mj", function()
        mc.lineAddCursor(1)
      end, { desc = "Multicursor: line below" })

      map({ "n", "x" }, "<leader>mk", function()
        mc.lineAddCursor(-1)
      end, { desc = "Multicursor: line above" })

      -- Escape clears multicursors when they exist.
      mc.addKeymapLayer(function(layerSet)
        layerSet("n", "<esc>", function()
          if not mc.cursorsEnabled() then
            mc.enableCursors()
          else
            mc.clearCursors()
          end
        end)
      end)
    end,
  },
}
