#!/bin/bash
# copies dotfiles from ~/.dotfiles into their respective directories

set -e  # exit on error

DOTFILES_DIR="$HOME/.dotfiles"

echo "Deploying dotfiles from $DOTFILES_DIR ..."

# .bashrc (repo to local)
cp -v "$DOTFILES_DIR/bash/.bashrc" "$HOME/.bashrc"

# btop (repo to local)
mkdir -p "$HOME/.config/btop"
cp -v "$DOTFILES_DIR/btop/btop.conf" "$HOME/.config/btop/btop.conf"

# fastfetch (repo to local)
mkdir -p "$HOME/.config/fastfetch"
cp -v "$DOTFILES_DIR/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
cp -v "$DOTFILES_DIR/fastfetch/yorha.txt" "$HOME/.config/fastfetch/yorha.txt"

# ly (repo to local)
mkdir -p "/etc/ly"
cp -v "$DOTFILES_DIR/ly/config.ini" "/etc/ly/config.ini"

# neovim (repo to local)
mkdir -p "$HOME/.config/nvim"
cp -v "$DOTFILES_DIR/nvim/init.lua" "$HOME/.config/nvim/init.lua"
cp -v "$DOTFILES_DIR/nvim/lua/core/options.lua" "$HOME/.config/nvim/lua/core/options.lua"

# starship (repo to local)
mkdir -p "$HOME/.config"
cp -v "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"

echo "Deployment finished!"
