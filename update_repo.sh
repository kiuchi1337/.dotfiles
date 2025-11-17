#!/bin/bash
# update_repo.sh
# Copies current dotfiles back into the repo and pushes to GitHub

set -e  # exit on error

DOTFILES_DIR="$HOME/.dotfiles"
REMOTE_URL="git@github.com:kiuchi1337/.dotfiles.git"  # <- Adjust!

echo "Updating repo at $DOTFILES_DIR ..."

# .bashrc (local to repo)
cp -v "$HOME/.bashrc" "$DOTFILES_DIR/bash/"

# neovim (local to repo)
cp -rv "$HOME/.config/nvim/" "$DOTFILES_DIR/nvim/"

# btop (local to repo)
cp -rv "$HOME/.config/btop/" "$DOTFILES_DIR/btop/"

# fastfetch (local to repo)
cp -rv "$HOME/.config/fastfetch/" "$DOTFILES_DIR/fastfetch/"

# starship (local to repo)
cp -v "$HOME/.config/starship.toml" "$DOTFILES_DIR/starship/"

# Add more files here as needed:
# if directories are present, use cp -rv to copy recursively

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
