#!/bin/bash
# deploy_dotfiles.sh
# Copies dotfiles from ~/.dotfiles into their respective directories

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
cp -rv "$DOTFILES_DIR/fastfetch/" "$HOME/.config/fastfetch/"

# neovim (repo to local)
mkdir -p "$HOME/.config/nvim"
cp -rv "$DOTFILES_DIR/nvim/" "$HOME/.config/nvim/"

# starship (repo to local)
mkdir -p "$HOME/.config"
cp -v "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"

# Add more files here as needed:
# if directories are present, use cp -rv to copy recursively

echo "Deployment finished!"
