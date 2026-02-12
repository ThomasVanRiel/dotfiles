# LazyVim Customization Guide

**Date:** February 12, 2026  
**Purpose:** Document findings and best practices for configuring and extending LazyVim

---

## Table of Contents

1. [Understanding LazyVim's Plugin Architecture](#understanding-lazyvims-plugin-architecture)
2. [Plugin Configuration Methods](#plugin-configuration-methods)
3. [Common Patterns & Solutions](#common-patterns--solutions)
4. [Troubleshooting Custom Configurations](#troubleshooting-custom-configurations)
5. [Real Example: Treesitter Swap Configuration](#real-example-treesitter-swap-configuration)
6. [Best Practices](#best-practices)

---

## Understanding LazyVim's Plugin Architecture

### LazyVim vs Lazy.nvim

**Lazy.nvim** = Plugin manager  
**LazyVim** = Distribution built on lazy.nvim with custom logic

**Key Insight:** LazyVim often has **custom `config` functions** that replace standard plugin setup. This means:
- Simply setting `opts` may not work as expected
- Need to understand LazyVim's specific implementation
- Sometimes need workarounds for non-standard features

### Where LazyVim Configs Live

```
~/.local/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/
├── coding.lua          # Autocompletion, snippets
├── editor.lua          # Navigation, search
├── formatting.lua      # conform.nvim
├── linting.lua         # nvim-lint
├── lsp/                # LSP configuration
├── treesitter.lua      # Tree-sitter and textobjects
└── ui.lua              # UI plugins
```

**Important:** These define LazyVim's default behavior. Your custom configs in `~/.config/nvim/lua/plugins/` can override them.

---

## Plugin Configuration Methods

### 1. Using `opts` (Simplest)

**When it works:**
- Plugin has standard `setup()` function
- LazyVim doesn't override with custom config
- You just want to add/override options

**Example:**
```lua
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    auto_install = false,  -- Disable auto-install
    ensure_installed = { "lua", "python" },  -- Add to LazyVim's list
  },
}
```

**How it merges:**
- Your `opts` are merged with LazyVim's defaults
- Use `opts_extend` for arrays that should be extended vs replaced

### 2. Using `opts` as Function (Advanced Merging)

**When to use:**
- Need access to LazyVim's default opts
- Want to conditionally modify options
- Need to extend complex nested tables

**Example:**
```lua
return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  opts = function(_, opts)
    -- opts contains LazyVim's defaults
    opts.swap = {
      enable = true,
      swap_next = {
        ["<leader>na"] = "@parameter.inner",
      },
    }
    return opts
  end,
}
```

**Problem:** This doesn't always work if LazyVim's `config` function ignores certain opts!

### 3. Using `config` (Full Control)

**When to use:**
- Need complete control over setup
- LazyVim's config doesn't support your feature
- Want to replace LazyVim's implementation entirely

**Example:**
```lua
return {
  "some-plugin",
  config = function()
    require("some-plugin").setup({
      -- Your complete configuration
    })
  end,
}
```

**Warning:** This completely replaces LazyVim's config. You lose LazyVim's defaults.

### 4. Using `init` (Pre-Setup)

**When to use:**
- Need to run code **before** plugin loads
- Setting up autocmds or keymaps
- Configuring global variables

**Example:**
```lua
return {
  "some-plugin",
  init = function()
    -- Runs before plugin is loaded
    vim.g.plugin_option = true
  end,
}
```

### 5. Using `keys` (Lazy-Loaded Keymaps)

**When to use:**
- Want lazy-loading triggered by keymap
- Global keymaps that don't need buffer-local behavior
- Simple one-line commands

**Example:**
```lua
return {
  "telescope.nvim",
  keys = {
    { "<leader>fp", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
  },
}
```

**Limitation:** Not suitable for buffer-local or filetype-specific keymaps.

---

## Common Patterns & Solutions

### Pattern 1: Adding Features LazyVim Doesn't Configure

**Problem:** LazyVim's config function doesn't set up all plugin features.

**Example:** nvim-treesitter-textobjects supports "swap" but LazyVim only configures "move".

**Solution:** Use `init` with autocmds for buffer-local setup:

```lua
return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  init = function()
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("my_treesitter_custom", { clear = true }),
      callback = function(event)
        local buf = event.buf
        if LazyVim.treesitter.have(vim.bo[buf].filetype, "textobjects") then
          -- Setup your custom feature
          vim.keymap.set("n", "<leader>sa", function()
            require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner")
          end, { buffer = buf, desc = "Swap Next Argument" })
        end
      end,
    })
  end,
}
```

### Pattern 2: Overriding LazyVim Keymaps

**Problem:** LazyVim sets keymaps you want to change.

**Solution 1:** Disable in `lua/config/keymaps.lua`:
```lua
vim.keymap.del("n", "<leader>ff")  -- Delete LazyVim's keymap
vim.keymap.set("n", "<leader>f", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })
```

**Solution 2:** Override in plugin spec:
```lua
return {
  "telescope.nvim",
  keys = {
    { "<leader>ff", false },  -- Disable LazyVim's keymap
    { "<leader>f", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
  },
}
```

### Pattern 3: Buffer-Local Keymaps Based on Filetype/Feature

**Problem:** Need keymaps only when certain conditions are met.

**Solution:** Use autocmd with feature detection:

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "lua", "javascript" },
  callback = function(event)
    -- Check if feature is available
    if LazyVim.has("some-plugin") then
      vim.keymap.set("n", "<leader>x", function()
        -- Your action
      end, { buffer = event.buf, desc = "Custom Action" })
    end
  end,
})
```

### Pattern 4: Conditional Plugin Loading

**Problem:** Only want plugin in certain conditions.

**Solution:** Use `cond`:

```lua
return {
  "plugin-name",
  cond = function()
    return vim.fn.executable("some-tool") == 1
  end,
}
```

Or `enabled`:
```lua
return {
  "plugin-name",
  enabled = vim.fn.has("nvim-0.10") == 1,
}
```

---

## Troubleshooting Custom Configurations

### Issue: My `opts` Are Being Ignored

**Symptoms:**
- You set `opts = { feature = true }` but it doesn't work
- Plugin loads but your settings aren't applied

**Diagnosis:**
1. Check if LazyVim has a custom `config` function:
   ```bash
   # Search LazyVim's source
   rg "plugin-name" ~/.local/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/
   ```

2. Look for custom config that might ignore your opts

**Solutions:**

**A) Use function form to debug:**
```lua
opts = function(_, opts)
  -- Debug: see what LazyVim provides
  vim.print(opts)
  
  -- Your modifications
  opts.your_setting = true
  return opts
end,
```

**B) Replace config entirely:**
```lua
config = function()
  require("plugin").setup({
    -- Your complete config
  })
end,
```

**C) Use init/autocmd workaround (like treesitter swap example)**

### Issue: Keymaps Not Working

**Symptoms:**
- Keymap defined but pressing it does nothing
- `which-key` doesn't show your keymap

**Diagnosis:**
1. Check if it's set: `:map <leader>x`
2. Check for conflicts: `:verbose map <leader>x`
3. Test manually: `:lua vim.keymap.set('n', '<leader>x', function() print('test') end)`

**Solutions:**

**A) Buffer-local keymaps need autocmd:**
```lua
-- Don't use global keymap for buffer-specific features
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function(event)
    vim.keymap.set("n", "<leader>x", action, { buffer = event.buf })
  end,
})
```

**B) Check loading order:**
```lua
-- Use init for early setup
init = function()
  -- Your keymaps
end,
```

**C) Use keys spec:**
```lua
keys = {
  { "<leader>x", function() ... end, desc = "Action" },
},
```

### Issue: Plugin Not Loading

**Diagnosis:**
```lua
-- Check if plugin is loaded
:Lazy

-- Try loading manually
:Lazy load plugin-name

-- Check for errors
:messages
```

**Common Causes:**
1. Wrong plugin name in spec
2. `lazy = true` without trigger (event, keys, cmd)
3. `enabled = false` or failing `cond`
4. Syntax error in config file

---

## Real Example: Treesitter Swap Configuration

### The Problem

Wanted to add argument swapping with nvim-treesitter-textobjects:

```lua
-- This DIDN'T work:
return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  opts = {
    swap = {
      enable = true,
      swap_next = { ["<leader>na"] = "@parameter.inner" },
    },
  },
}
```

**Why it failed:**
- LazyVim has custom `config` function for textobjects
- It only sets up `move` keymaps, ignores `swap` config
- Standard `opts` approach doesn't work

### The Solution

Use `init` with autocmd to set up keymaps manually:

```lua
return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  init = function()
    -- Setup after FileType detection
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter_swap_keymaps", { clear = true }),
      callback = function(event)
        local buf = event.buf
        local ft = vim.bo[buf].filetype
        
        -- Only for files with textobject support
        if LazyVim.treesitter.have(ft, "textobjects") then
          local swap = require("nvim-treesitter-textobjects.swap")
          
          -- Buffer-local keymaps
          vim.keymap.set("n", "<leader>na", function()
            swap.swap_next("@parameter.inner")
          end, { buffer = buf, desc = "Swap Next Parameter", silent = true })
          
          vim.keymap.set("n", "<leader>pa", function()
            swap.swap_previous("@parameter.inner")
          end, { buffer = buf, desc = "Swap Previous Parameter", silent = true })
        end
      end,
    })
  end,
}
```

### Key Learnings

1. **LazyVim's custom configs can override standard behavior**
2. **Use `init` for features LazyVim doesn't configure**
3. **FileType autocmds for buffer-local, conditional keymaps**
4. **`LazyVim.treesitter.have()` checks feature availability**
5. **Call plugin functions directly when config setup doesn't work**

---

## Best Practices

### 1. Start with `opts`, Escalate if Needed

**Hierarchy:**
1. Try `opts = { }` first (simplest)
2. If that doesn't work, try `opts = function(_, opts) ... end`
3. If still broken, check LazyVim's source
4. Use `init` for workarounds
5. Use `config` as last resort (loses LazyVim defaults)

### 2. Always Add Descriptions to Keymaps

```lua
-- Good
vim.keymap.set("n", "<leader>x", action, { desc = "Do Something" })

-- Bad
vim.keymap.set("n", "<leader>x", action)
```

**Why:** 
- Shows in which-key
- Self-documenting
- Easier to debug conflicts

### 3. Use LazyVim Utilities

LazyVim provides helpful functions:

```lua
-- Check if plugin is available
if LazyVim.has("telescope.nvim") then ... end

-- Check treesitter support
if LazyVim.treesitter.have(filetype, "query") then ... end

-- Format current buffer
LazyVim.format()

-- Error messages
LazyVim.error("Something went wrong")
LazyVim.warn("Warning message")
LazyVim.info("Info message")
```

### 4. Group Related Configs

```lua
-- lua/plugins/coding.lua - all coding-related plugins
-- lua/plugins/editor.lua - all editor-related plugins
-- lua/plugins/ui.lua - all UI plugins
```

### 5. Use Autocmd Groups

```lua
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("my_custom_feature", { clear = true }),
  --                                    ^^^^^^^^^^^^^^^^ unique name
  --                                                     ^^^^^^^^^^^^^ clear old autocmds
  callback = function(event) ... end,
})
```

**Why:**
- Prevents duplicate autocmds on reload
- Easy to manage and debug
- Can clear specific groups

### 6. Make Keymaps Buffer-Local When Appropriate

```lua
-- Global - available everywhere
vim.keymap.set("n", "<leader>x", action)

-- Buffer-local - only in current buffer
vim.keymap.set("n", "<leader>x", action, { buffer = buf })

-- Buffer-local + filetype-specific - best for language features
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function(event)
    vim.keymap.set("n", "<leader>x", action, { buffer = event.buf })
  end,
})
```

### 7. Test Incrementally

```lua
-- Add one feature at a time
return {
  "plugin",
  -- opts = { feature1 = true },  -- Test this first
  opts = { 
    feature1 = true,
    feature2 = true,  -- Then add this
  },
}
```

### 8. Read LazyVim's Source

When stuck, check how LazyVim configures the plugin:

```bash
# Find LazyVim's config for a plugin
rg -A 20 "plugin-name" ~/.local/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/

# Or use Telescope in Neovim
<leader>fp  # Find files in LazyVim installation
```

---

## Useful Commands for Development

### Debugging Plugin Loading

```vim
" See all loaded plugins
:Lazy

" See plugin load status
:Lazy profile

" Reload a specific plugin
:Lazy reload plugin-name

" Check health
:checkhealth
:checkhealth lazy

" See messages/errors
:messages

" View keymaps
:map <leader>
:verbose map <leader>x

" Check if command exists
:command MyCommand

" Check autocmds
:autocmd FileType
:autocmd my_group
```

### Testing Lua Code

```vim
" Execute Lua
:lua print(vim.inspect(LazyVim))

" Execute Lua file
:luafile %

" Source current file
:source %

" Reload config
:Lazy reload
```

---

## Common LazyVim Patterns

### Pattern: Override Default Keymap Prefix

```lua
-- In lua/plugins/telescope.lua
return {
  "nvim-telescope/telescope.nvim",
  keys = {
    -- Disable all LazyVim <leader>s* keymaps
    { "<leader>sf", false },
    { "<leader>sg", false },
    { "<leader>sh", false },
    
    -- Add your own with different prefix
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
  },
}
```

### Pattern: Add LSP Server

```lua
-- In lua/plugins/lsp.lua
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      -- Add new server (Mason will auto-install)
      gopls = {
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
          },
        },
      },
    },
  },
}
```

### Pattern: Modify Formatter

```lua
-- In lua/plugins/formatting.lua
return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "black", "isort" },
      javascript = { "prettier" },
    },
  },
}
```

### Pattern: Add Custom Command

```lua
return {
  "some-plugin",
  init = function()
    vim.api.nvim_create_user_command("MyCommand", function()
      -- Your command logic
      print("Hello from custom command!")
    end, {
      desc = "My custom command",
      nargs = 0,  -- Number of arguments
    })
  end,
}
```

---

## Checklist for Adding New Plugins

- [ ] Add plugin spec to `lua/plugins/plugin-name.lua`
- [ ] Decide on loading strategy (lazy, event, keys, cmd)
- [ ] Configure with `opts` first, escalate if needed
- [ ] Add keymaps with descriptions
- [ ] Test that plugin loads (`:Lazy`)
- [ ] Test functionality works as expected
- [ ] Document any custom keymaps in which-key groups
- [ ] Update `lazy-lock.json` (`:Lazy sync`)
- [ ] Commit changes

---

## Checklist for Debugging Issues

- [ ] Check `:messages` for errors
- [ ] Verify plugin is loaded (`:Lazy`)
- [ ] Check `:checkhealth` for issues
- [ ] Test Lua code directly (`:lua ...`)
- [ ] Check LazyVim's default config for the plugin
- [ ] Try minimal reproduction
- [ ] Check plugin's documentation
- [ ] Search LazyVim GitHub issues

---

## Resources

### Documentation
- [LazyVim Docs](https://lazyvim.org)
- [lazy.nvim Docs](https://github.com/folke/lazy.nvim)
- [Neovim Lua Guide](https://neovim.io/doc/user/lua-guide.html)

### Key Files
- LazyVim defaults: `~/.local/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/`
- Your configs: `~/.config/nvim/lua/plugins/`
- Keymaps: `~/.config/nvim/lua/config/keymaps.lua`
- Options: `~/.config/nvim/lua/config/options.lua`
- Autocmds: `~/.config/nvim/lua/config/autocmds.lua`

### Helpful Commands
```bash
# Search LazyVim source
rg "search-term" ~/.local/share/nvim/lazy/LazyVim/

# Find plugin files
fd plugin-name ~/.local/share/nvim/lazy/

# View lazy-lock.json
bat ~/.config/nvim/lazy-lock.json
```

---

## Final Thoughts

**Key Principle:** LazyVim is not just a plugin manager config - it's a distribution with custom logic. Understanding when and how LazyVim customizes plugins is crucial for successful configuration.

**When in doubt:**
1. Check LazyVim's source code
2. Use `init` for workarounds
3. Call plugin functions directly
4. Ask in LazyVim discussions on GitHub

**Remember:** Your configs in `~/.config/nvim/lua/plugins/` **override** LazyVim's defaults, but you need to use the right approach (opts vs config vs init) depending on how LazyVim implements each plugin.

---

*Last Updated: February 12, 2026*  
*Based on hands-on experience configuring nvim-treesitter-textobjects swap functionality*
