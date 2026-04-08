return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local mocha                       = require("catppuccin.palettes").get_palette("mocha")
      local bg                          = mocha.mantle

      -- Uniform dark background, all color in the foreground
      opts.options.theme                = {
        normal   = {
          a = { fg = mocha.green, bg = bg, gui = "bold" },
          b = { fg = mocha.subtext1, bg = bg },
          c = { fg = mocha.subtext0, bg = bg },
          x = { fg = mocha.subtext0, bg = bg },
          y = { fg = mocha.subtext1, bg = bg },
          z = { fg = mocha.blue, bg = bg },
        },
        insert   = { a = { fg = mocha.blue, bg = bg, gui = "bold" } },
        visual   = { a = { fg = mocha.mauve, bg = bg, gui = "bold" } },
        replace  = { a = { fg = mocha.red, bg = bg, gui = "bold" } },
        command  = { a = { fg = mocha.peach, bg = bg, gui = "bold" } },
        terminal = { a = { fg = mocha.teal, bg = bg, gui = "bold" } },
        inactive = {
          a = { fg = mocha.overlay0, bg = bg },
          b = { fg = mocha.overlay0, bg = bg },
          c = { fg = mocha.overlay0, bg = bg },
        },
      }

      -- One global statusline — prevents file explorers from hiding it
      opts.options.globalstatus         = true

      -- No section arrows, soft │ between components (mirrors tmux bar)
      opts.options.section_separators   = { left = "", right = "" }
      opts.options.component_separators = { left = "│", right = "│" }

      -- Remove the clock
      opts.sections.lualine_z           = {}

      return opts
    end,
  },
}
