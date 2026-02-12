return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      -- Disable auto-install if you prefer system parsers
      auto_install = false,
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    init = function()
      -- Setup swap keymaps for buffers with treesitter support
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter_swap_keymaps", { clear = true }),
        callback = function(event)
          local buf = event.buf
          local ft = vim.bo[buf].filetype
          
          -- Only set keymaps if treesitter textobjects are available for this filetype
          if LazyVim.treesitter.have(ft, "textobjects") then
            local swap = require("nvim-treesitter-textobjects.swap")
            
            vim.keymap.set("n", "<leader>na", function()
              swap.swap_next("@parameter.inner")
            end, { buffer = buf, desc = "Swap Next Parameter", silent = true })
            
            vim.keymap.set("n", "<leader>nm", function()
              swap.swap_next("@function.outer")
            end, { buffer = buf, desc = "Swap Next Function", silent = true })
            
            vim.keymap.set("n", "<leader>pa", function()
              swap.swap_previous("@parameter.inner")
            end, { buffer = buf, desc = "Swap Previous Parameter", silent = true })
            
            vim.keymap.set("n", "<leader>pm", function()
              swap.swap_previous("@function.outer")
            end, { buffer = buf, desc = "Swap Previous Function", silent = true })
          end
        end,
      })
    end,
  },
}

