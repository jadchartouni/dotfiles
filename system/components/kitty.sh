##################################################################
# Setup kitty
##################################################################
function lets_kitty()
{
    echo -e " ${C_FG_BLACK}${C_BG_BLUE} Kitty ${C_OFF}"

    start_process "Removing ${C_FG_YELLOW}${HOME}/.config/kitty${C_OFF}"
    rm -rf $HOME/.config/kitty
    end_process

    start_process "Linking ${C_FG_YELLOW}${DOTFILES}/kitty${C_OFF} to ${C_FG_YELLOW}${HOME}/.config/kitty${C_OFF}"
    ln -s $DOTFILES/kitty $HOME/.config/kitty
    end_process
}

