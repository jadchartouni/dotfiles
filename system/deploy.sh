#!/usr/bin/env bash

SYSTEM=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
DOTFILES=$(dirname $SYSTEM)

# Ask for the administrator password upfront
echo "This script requires sudo permissions."
sudo -v

##################################################################
# Import helpers
##################################################################
source $SYSTEM/helpers/functions.sh
source $SYSTEM/helpers/colors.sh

##################################################################
# Import components
##################################################################
source $SYSTEM/components/git.sh
source $SYSTEM/components/homebrew.sh
source $SYSTEM/components/iterm.sh
source $SYSTEM/components/kitty.sh
source $SYSTEM/components/laravel.sh
source $SYSTEM/components/nvim.sh
source $SYSTEM/components/tmux.sh
source $SYSTEM/components/vim.sh
source $SYSTEM/components/zsh.sh

##################################################################
# Let's start
##################################################################
clear
output

functions=(
    "lets_brew"
    "lets_git"
    "lets_iterm"
    "lets_kitty"
    "lets_nvim"
    "lets_vim"
    "lets_tmux"
    "lets_zsh"
    "lets_laravel"
)

for function in "${functions[@]}"
do
    $function
    output
done
