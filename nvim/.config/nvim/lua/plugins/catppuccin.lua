return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      custom_highlights = function(c)
        return {
          -- Match lualine's uniform base background so %* resets in trouble
          -- statusline segments don't flash a darker mantle rectangle
          StatusLine   = { fg = c.text, bg = c.mantle },
          StatusLineNC = { fg = c.overlay0, bg = c.mantle },
        }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-nvim",
    },
  },
  {
    "akinsho/bufferline.nvim",
    opts = function(_, opts)
      if (vim.g.colors_name or ""):find("catppuccin") then
        local get_theme = require("catppuccin.special.bufferline").get_theme()
        opts.highlights = function()
          local C = require("catppuccin.palettes").get_palette()
          local h = get_theme()
          -- Replace crust (fill) and mantle (inactive) with base for a
          -- uniform background that matches lualine and the tmux bar
          for _, entry in pairs(h) do
            if entry.bg == C.crust or entry.bg == C.mantle then
              entry.bg = C.mantle
            end
          end
          return h
        end
      end
    end,
  },
}
