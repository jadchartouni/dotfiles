##################################################################
# Setup vim
##################################################################
function lets_vim()
{
    # Title
    echo -e " ${C_FG_BLACK}${C_BG_BLUE} Vim ${C_OFF}"

    # Create symlink
    symlink $DOTFILES/vim/vimrc $HOME/.vimrc
}

