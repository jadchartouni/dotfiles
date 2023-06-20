##################################################################
# Setup Git
##################################################################
function lets_git()
{
    output $C_FG_BLACK$C_BG_BLUE" Git "

    # Remove ~/.gitignore_global
    output "Removing "$C_FG_YELLOW"$HOME/.gitignore_global"$C_OFF
    rm -rf $HOME/.gitignore_global > /dev/null 2>&1

    # Link ~/.gitignore_global
    output "Linking $C_FG_YELLOW$DOTFILES/git/gitignore_global$C_OFF to $C_FG_YELLOW$HOME/.gitignore_global$C_OFF"
    ln -s $DOTFILES/git/gitignore_global $HOME/.gitignore_global > /dev/null 2>&1
}
