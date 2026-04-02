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

# Render both HTML and PDF
quarto render cheatsheet.qmd

xdg-open cheatsheet.html  # interactive, tabbed
xdg-open cheatsheet.pdf   # for printing
```
