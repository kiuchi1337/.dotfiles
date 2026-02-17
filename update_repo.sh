#!/bin/bash
# update_repo.sh
# Copies current dotfiles back into the repo and pushes to GitHub

set -e  # exit on error

DOTFILES_DIR="$HOME/.dotfiles"
REMOTE_URL="git@github.com:kiuchi1337/.dotfiles.git"  # <- Adjust!

echo "Updating repo at $DOTFILES_DIR ..."

# .bashrc (local to repo)
mkdir -p "$DOTFILES_DIR/bash"
cp -v "$HOME/.bashrc" "$DOTFILES_DIR/bash/.bashrc"

# btop (local to repo)
mkdir -p "$DOTFILES_DIR/btop"
cp -v "$HOME/.config/btop/btop.conf" "$DOTFILES_DIR/btop/btop.conf"

# fastfetch (local to repo)
mkdir -p "$DOTFILES_DIR/fastfetch"
cp -v "$HOME/.config/fastfetch/config.jsonc" "$DOTFILES_DIR/fastfetch/config.jsonc"
cp -v "$HOME/.config/fastfetch/yorha.txt" "$DOTFILES_DIR/fastfetch/yorha.txt"

# ly (local to repo)
mkdir -p "$DOTFILES_DIR/ly"
cp -v "/etc/ly/config.ini" "$DOTFILES_DIR/ly/config.ini"

# neovim (local to repo)
mkdir -p "$DOTFILES_DIR/nvim"
cp -v "$HOME/.config/nvim/init.vim" "$DOTFILES_DIR/nvim/init.vim"

# starship (local to repo)
mkdir -p "$DOTFILES_DIR/starship"
cp -v "$HOME/.config/starship.toml" "$DOTFILES_DIR/starship/starship.toml"

cd "$DOTFILES_DIR"

# Initialize repo if not already done
if [ ! -d ".git" ]; then
  echo "Initializing Git repo..."
  git init
  git branch -M main
  git remote add origin "$REMOTE_URL"
fi

git add .
git commit -m "Update dotfiles"
git push -u origin main

echo "Repo successfully updated and pushed!"
