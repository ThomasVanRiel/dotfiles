return {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
  },
  keys = {
    { "<c-h>",  "<cmd>TmuxNavigateLeft<cr>",     silent = true, desc = "navigate left"  },
    { "<c-j>",  "<cmd>TmuxNavigateDown<cr>",     silent = true, desc = "navigate down"  },
    { "<c-k>",  "<cmd>TmuxNavigateUp<cr>",       silent = true, desc = "navigate up"    },
    { "<c-l>",  "<cmd>TmuxNavigateRight<cr>",    silent = true, desc = "navigate right" },
    { "<c-\\>", "<cmd>TmuxNavigatePrevious<cr>", silent = true, desc = "navigate prev"  },
  },
}
