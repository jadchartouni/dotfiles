##################################################################
# Setup vim
##################################################################
function lets_vim()
{
    output $C_FG_BLACK$C_BG_BLUE" Vim "

    output "Removing "$C_FG_YELLOW"$HOME/.vimrc"$C_OFF
    rm -rf $HOME/.vimrc

    output "Linking $C_FG_YELLOW$DOTFILES/vim/vimrc$C_OFF to $C_FG_YELLOW$HOME/.vimrc$C_OFF"
    ln -s $DOTFILES/vim/vimrc $HOME/.vimrc
}

