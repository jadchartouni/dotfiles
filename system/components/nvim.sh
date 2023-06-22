##################################################################
# Setup nvim
##################################################################
function lets_nvim()
{
    echo -e " ${C_FG_BLACK}${C_BG_BLUE} Neovim ${C_OFF}"

    start_process "Removing ${C_FG_YELLOW}${HOME}/.config/nvim${C_OFF}"
    rm -rf $HOME/.config/nvim
    end_process

    start_process "Linking ${C_FG_YELLOW}${DOTFILES}/nvim${C_OFF} to ${C_FG_YELLOW}${HOME}/.config/nvim${C_OFF}"
    ln -s $DOTFILES/nvim $HOME/.config/nvim
    end_process

    start_process "Calling ${C_FG_YELLOW}PackerSync${C_OFF}..."
    nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
    end_process
}

