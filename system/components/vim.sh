##################################################################
# Setup vim
##################################################################
function lets_vim()
{
    echo -e " ${C_FG_BLACK}${C_BG_BLUE} Vim ${C_OFF}"

    start_process "Removing ${C_FG_YELLOW}${HOME}/.vimrc${C_OFF}"
    rm -rf $HOME/.vimrc
    end_process

    start_process "Linking ${C_FG_YELLOW}${DOTFILES}/vim/vimrc${C_OFF} to ${C_FG_YELLOW}${HOME}/.vimrc${C_OFF}"
    ln -s $DOTFILES/vim/vimrc $HOME/.vimrc
    end_process
}

