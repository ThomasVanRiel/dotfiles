# Neovim Upgrade Notes

## 0.11 -> 0.12

### Catppuccin v2 colorscheme rename

Catppuccin v2 (released 2026-04-02) renamed the colorscheme from `catppuccin` to `catppuccin-nvim`.
Update `colorscheme` in your LazyVim config accordingly.

Also includes intentional treesitter color changes to align with the catppuccin style guide.

### render-markdown.nvim and Quarto

`render-markdown.nvim` does not include `quarto` in its default filetypes.
Add `quarto` to both `ft` and `opts.file_types` in the plugin spec.

### Quarto treesitter language registration

Snacks picker preview needs the `quarto -> markdown` treesitter mapping registered early (at startup),
not just in `ftplugin/quarto.lua` (which only runs when a quarto buffer is opened).
Add `vim.treesitter.language.register("markdown", "quarto")` in the plugin's `init` function.

### Treesitter parsers need forced reinstall

Upgrading nvim may invalidate compiled parser `.so` files due to ABI changes.
If you delete old parsers, the `.revision` files in `parser-info/` still exist,
so `:TSInstall` thinks they're installed and skips compilation.

Use `:TSInstall!` (with bang) to force recompilation.

### tree-sitter CLI glibc incompatibility (Ubuntu 22.04)

nvim-treesitter now uses the `tree-sitter` CLI to compile parsers.
Mason may install a prebuilt `tree-sitter` binary that requires a newer glibc than Ubuntu 22.04 provides (needs 2.39, has 2.35).

nvim resolves Mason's binary (`~/.local/share/nvim/mason/bin/tree-sitter`) before the cargo-installed one (`~/.cargo/bin/tree-sitter`).

Fix: remove the Mason binary so the cargo-built version (compiled against your system glibc) is used:

```bash
rm ~/.local/share/nvim/mason/bin/tree-sitter
```

### Picker preview colors differ from buffers

Snacks picker preview only uses treesitter highlighting, not LSP semantic tokens.
This is expected -- real buffers get richer colors from the LSP that the preview cannot replicate.
