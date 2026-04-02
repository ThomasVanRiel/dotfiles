# Thomas' awesome niri setup

Apply configuration using [GNU Stow](https://www.gnu.org/software/stow/)

## Usage

```bash
cd ~/dotfiles

# Stow a single package (creates symlinks)
stow zsh

# This creates: ~/.zshrc -> ~/dotfiles/zsh/.zshrc

# Stow multiple packages
stow zsh vim git

# Stow everything
stow */

# Remove symlinks
stow -D zsh

# Restow (useful after editing)
stow -R zsh
```

## Cheatsheet

Keybind reference for niri, nvim, and tmux, plus tool usage for Quarto, ffmpeg, git, and Docker.

```bash
cd ~/dotfiles

# HTML (interactive, tabbed)
quarto render cheatsheet.qmd --to html
xdg-open cheatsheet.html

# PDF (for printing)
quarto render cheatsheet.qmd --to typst
```
