#!/usr/bin/env bash

# brew: done
# git: done
# iterm: done
# kitty
# nvim
# nvm
# scripts
# tmux: done
# vim: done
# wallpapers
# zsh

DOTFILES=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

# Configure macOS
echo "Configuring macOS..."
touch ~/.hushlogin

# Brew 


# Kitty
echo "Configuring kitty..."
rm -rf $HOME/.config/kitty
ln -s $DOTFILES/kitty $HOME/.config/kitty

# Tmux
echo "Configuring tmux..."
rm -rf $HOME/.tmux.conf
ln -s $DOTFILES/tmux/tmux.conf $HOME/.tmux.conf

# ZSH


# NeoVim
echo "Configuring Neovim"
rm -rf $HOME/.config/nvim
ln -s $DOTFILES/nvim $HOME/.config/nvim

# Git
echo "Configuring git..."
ln -s $DOTFILES/git/gitignore $HOME/.gitignore_global

# Scripts
echo "Configuring scripts..."
mkdir -p $HOME/.local/bin
rm -rf $HOME/.local/bin/start-tmux
ln -s $DOTFILES/scripts/start-tmux $HOME/.local/bin/start-tmux

# Composer


# Laravel
