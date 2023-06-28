##################################################################
# Setup kitty
##################################################################
function lets_kitty()
{
    # Title
    echo -e " ${C_FG_BLACK}${C_BG_BLUE} Kitty ${C_OFF}"

    # Create symlink
    symlink $DOTFILES/kitty $HOME/.config/kitty
}

