vim.opt.number = true
vim.opt.relativenumber = true
shiftwidth=4

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
	"git", "clone", "--filter=blob:none",
	"https://github.com/folke/lazy.nvim.git",
	"--branch=stable", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Setup plugins
require("lazy").setup({
    {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	config = function()
	    require("catppuccin").setup({
		flavour = "mocha", -- latte, frappe, macchiato, mocha
		background = { -- :h background
		    light = "latte",
		    dark = "mocha",
		},
		transparent_background = true, -- disables setting the background color.
		float = {
		    transparent = false, -- enable transparent floating windows
		    solid = false, -- use solid styling for floating windows, see |winborder|
		},
		show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
		term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
		dim_inactive = {
		    enabled = false, -- dims the background color of inactive window
		    shade = "dark",
		    percentage = 0.15, -- percentage of the shade to apply to the inactive window
		},
		no_italic = false, -- Force no italic
		no_bold = false, -- Force no bold
		no_underline = false, -- Force no underline
		styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
		    comments = { "italic" }, -- Change the style of comments
		    conditionals = { "italic" },
		    loops = {},
		    functions = {},
		    keywords = {},
		    strings = {},
		    variables = {},
		    numbers = {},
		    booleans = {},
		    properties = {},
		    types = {},
		    operators = {},
		    -- miscs = {}, -- Uncomment to turn off hard-coded styles
		},
		lsp_styles = { -- Handles the style of specific lsp hl groups (see `:h lsp-highlight`).
		    virtual_text = {
			errors = { "italic" },
			hints = { "italic" },
			warnings = { "italic" },
			information = { "italic" },
			ok = { "italic" },
		    },
		    underlines = {
			errors = { "underline" },
			hints = { "underline" },
			warnings = { "underline" },
			information = { "underline" },
			ok = { "underline" },
		    },
		    inlay_hints = {
			background = true,
		    },
		},
		color_overrides = {},
		custom_highlights = {},
		default_integrations = true,
		auto_integrations = false,
		integrations = {
		    cmp = true,
		    gitsigns = true,
		    nvimtree = true,
		    notify = false,
		    mini = {
			enabled = true,
			indentscope_color = "",
		    },
		    -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
		},
	    })
	    vim.cmd.colorscheme("catppuccin")
	end,
    },
    {
	'MeanderingProgrammer/render-markdown.nvim',
	dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },            -- if you use the mini.nvim suite
	-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },        -- if you use standalone mini plugins
	-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
	---@module 'render-markdown'
	---@type render.md.UserConfig
	opts = {},
    },
    {"https://github.com/Weyaaron/nvim-training", pin= true, opts = {}},
    {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
	    "nvim-lua/plenary.nvim",
	    "MunifTanjim/nui.nvim",
	    "nvim-tree/nvim-web-devicons", -- optional, but recommended
	},
	lazy = false, -- neo-tree will lazily load itself
    }
})
