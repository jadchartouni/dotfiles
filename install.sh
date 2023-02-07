#!/usr/bin/env bash

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
echo "Configuring ZSH"
rm -rf $HOME/.zshrc
ln -s $DOTFILES/zsh/zshrc $HOME/.zshrc

# NeoVim
echo "Configuring Neovim"
rm -rf $HOME/.config/nvim
ln -s $DOTFILES/nvim $HOME/.config/nvim

# Vim
echo "Configuring Vim"
rm -rf $HOME/.vimrc
ln -s $DOTFILES/vim/vimrc $HOME/.vimrc

# Git
echo "Configuring git..."
rm -rf $HOME/.gitignore_global
ln -s $DOTFILES/git/gitignore $HOME/.gitignore_global

# Scripts
echo "Configuring scripts..."
mkdir -p $HOME/.local/bin
rm -rf $HOME/.local/bin/start-tmux
ln -s $DOTFILES/scripts/start-tmux $HOME/.local/bin/start-tmux

# Composer
echo "Installing composer..."

# Laravel
echo "Installing Laravel..."
