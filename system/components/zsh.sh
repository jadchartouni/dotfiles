##################################################################
# Setup zsh
##################################################################
function lets_zsh()
{
    echo -e " ${C_FG_BLACK}${C_BG_BLUE} Z shell ${C_OFF}"

    start_process "Removing ${C_FG_YELLOW}${HOME}/.zshrc${C_OFF}"
    rm -rf $HOME/.zshrc
    end_process

    start_process "Linking ${C_FG_YELLOW}${DOTFILES}/zsh/zshrc${C_OFF} to ${C_FG_YELLOW}${HOME}/.zshrc${C_OFF}"
    ln -s $DOTFILES/zsh/zshrc $HOME/.zshrc
    end_process

    # Install zsh-autosuggestions

    # Install powerlevel10k theme
}

