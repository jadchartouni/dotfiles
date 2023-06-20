##################################################################
# Setup nvim
##################################################################
function lets_nvim()
{
    output $C_FG_BLACK$C_BG_BLUE" Neovim "

    output "Removing "$C_FG_YELLOW"$HOME/.config/nvim"$C_OFF
    rm -rf $HOME/.config/nvim

    output "Linking $C_FG_YELLOW$DOTFILES/nvim$C_OFF to $C_FG_YELLOW$HOME/.config/nvim$C_OFF"
    ln -s $DOTFILES/nvim $HOME/.config/nvim

    nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
}

