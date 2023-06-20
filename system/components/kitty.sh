##################################################################
# Setup kitty
##################################################################
function lets_kitty()
{
    output $C_FG_BLACK$C_BG_BLUE" Kitty "

    output "Removing "$C_FG_YELLOW"$HOME/.config/kitty"$C_OFF
    rm -rf $HOME/.config/kitty

    output "Linking $C_FG_YELLOW$DOTFILES/kitty$C_OFF to $C_FG_YELLOW$HOME/.config/kitty$C_OFF"
    ln -s $DOTFILES/kitty $HOME/.config/kitty
}

