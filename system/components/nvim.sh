##################################################################
# Setup nvim
##################################################################
function lets_nvim()
{
    # Title
    echo -e " ${C_FG_BLACK}${C_BG_BLUE} Neovim ${C_OFF}"

    # Create symlink
    symlink $DOTFILES/nvim $HOME/.config/nvim

    # Call PackerSync to install plugins
    start_process "Calling ${C_FG_YELLOW}PackerSync${C_OFF}..."
    nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
    end_process
}
