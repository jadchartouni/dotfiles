#!/usr/bin/env bash

DOTFILES=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

# Ask for the administrator password upfront
echo "This script requires sudo permissions."
sudo -v

# Setup macOS
function setup_macos()
{
    echo "Configuring macOS..."
    touch ~/.hushlogin
}

# Setup Ubuntu
function setup_ubuntu()
{

}

# Setup Kitty
function setup_kitty()
{
    echo "Configuring kitty..."
    rm -rf $HOME/.config/kitty
    ln -s $DOTFILES/kitty $HOME/.config/kitty
}

# Setup Tmux
function setup_tmux()
{
    echo "Configuring tmux..."
    rm -rf $HOME/.tmux.conf
    ln -s $DOTFILES/tmux/tmux.conf $HOME/.tmux.conf
}

# Setup ZSH
function setup_zsh()
{
    echo "Configuring ZSH"
    rm -rf $HOME/.zshrc
    ln -s $DOTFILES/zsh/zshrc $HOME/.zshrc

    // Install zsh-autosuggestions

    // Install powerlevel10k theme
}

# Setup NeoVim
function setup_neovim()
{
    echo "Configuring Neovim"
    rm -rf $HOME/.config/nvim
    ln -s $DOTFILES/nvim $HOME/.config/nvim
}

# Setup Vim
function setup_vim()
{
    echo "Configuring Vim"
    rm -rf $HOME/.vimrc
    ln -s $DOTFILES/vim/vimrc $HOME/.vimrc
}

# Setup Git
function setup_git()
{
    echo "Configuring git..."
    rm -rf $HOME/.gitignore_global
    ln -s $DOTFILES/git/gitignore $HOME/.gitignore_global
}

# Setup Scripts
function setup_scripts()
{
    echo "Configuring scripts..."
    mkdir -p $HOME/.local/bin
    rm -rf $HOME/.local/bin/start-tmux
    ln -s $DOTFILES/scripts/start-tmux $HOME/.local/bin/start-tmux
}

# Setup Composer
function setup_composer()
{
    echo "Installing composer..."
}

# Setup Laravel
function setup_laravel()
{
    echo "Installing Laravel..."
}

