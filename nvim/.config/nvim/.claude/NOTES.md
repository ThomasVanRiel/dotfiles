# Quick Notes & Findings

This file is for quick notes, findings, and reminders while developing/configuring this Neovim setup.

---

## Recent Changes

### 2026-02-12: Treesitter Swap Configuration

**Added:** Argument/parameter swapping with nvim-treesitter-textobjects

**Keymaps:**
- `<leader>na` - Swap next parameter
- `<leader>nm` - Swap next function  
- `<leader>pa` - Swap previous parameter
- `<leader>pm` - Swap previous function

**Learning:** LazyVim's custom config for textobjects doesn't support swap natively. Had to use `init` function with FileType autocmd to set up buffer-local keymaps manually.

**File:** `lua/plugins/treesitter.lua`

---

## Useful Patterns Discovered

### Buffer-Local Keymaps with Feature Detection

```lua
init = function()
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("unique_group_name", { clear = true }),
    callback = function(event)
      if LazyVim.treesitter.have(vim.bo[event.buf].filetype, "feature") then
        vim.keymap.set("n", "<key>", action, { 
          buffer = event.buf, 
          desc = "Description",
          silent = true 
        })
      end
    end,
  })
end
```

### Checking LazyVim's Default Config

```bash
# Find how LazyVim configures a plugin
rg "plugin-name" ~/.local/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/
```

---

## Common Issues & Solutions

### Issue: `opts` Being Ignored

**Cause:** LazyVim has custom `config` function that doesn't use certain opts

**Solution:** Use `init` for setup or call plugin functions directly in autocmds

### Issue: Keymaps Not Showing in which-key

**Cause:** Missing `desc` parameter

**Solution:** Always add `desc` to keymaps:
```lua
{ desc = "Action Description" }
```

---

## Plugins to Explore

- [ ] nvim-dap (debugging)
- [ ] oil.nvim (file explorer) - already installed
- [ ] More treesitter textobjects (select, goto)
- [ ] Custom snippets

---

## Reminders

- Use `:Lazy profile` to check plugin load times
- Run `:checkhealth` after major changes
- Check `:messages` for errors
- Test keymaps with `:map <leader>key`
- Use `<Space>` to explore available keybindings

---

## Custom Keybindings Summary

| Key | Action | Mode | Context |
|-----|--------|------|---------|
| `<leader>nl` | List notes | n | nvim-notediscovery |
| `<leader>ns` | Search notes | n | nvim-notediscovery |
| `<leader>nn` | New note | n | nvim-notediscovery |
| `<leader>no` | Open note | n | nvim-notediscovery |
| `<leader>nr` | Reload last note | n | nvim-notediscovery |
| `<leader>nq` | Quick note from selection | v | nvim-notediscovery |
| `<leader>ni` | Toggle images | n | nvim-notediscovery |
| `<leader>na` | Swap next parameter | n | treesitter (code files) |
| `<leader>nm` | Swap next function | n | treesitter (code files) |
| `<leader>pa` | Swap previous parameter | n | treesitter (code files) |
| `<leader>pm` | Swap previous function | n | treesitter (code files) |

---

## Configuration Files

- `lua/plugins/treesitter.lua` - Treesitter config with swap
- `lua/plugins/nvim-notediscovery.lua` - Note-taking integration
- `lua/config/keymaps.lua` - Custom global keymaps
- `lua/config/options.lua` - Custom vim options
- `lua/config/autocmds.lua` - Custom autocommands

---

## Notes

*This file is for quick reference and notes during development. For comprehensive documentation, see `.claude/LAZYVIM-CUSTOMIZATION.md`*
