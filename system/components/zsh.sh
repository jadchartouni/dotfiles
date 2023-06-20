##################################################################
# Setup zsh
##################################################################
function lets_zsh()
{
    output $C_FG_BLACK$C_BG_BLUE" Z shell "

    output "Removing "$C_FG_YELLOW"$HOME/.zshrc"$C_OFF
    rm -rf $HOME/.zshrc

    output "Linking $C_FG_YELLOW$DOTFILES/zsh/zshrc$C_OFF to $C_FG_YELLOW$HOME/.zshrc$C_OFF"
    ln -s $DOTFILES/zsh/zshrc $HOME/.zshrc

    # Install zsh-autosuggestions

    # Install powerlevel10k theme
}

