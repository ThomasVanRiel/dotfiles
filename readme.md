# Thomas' awesome hyprland setup
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
