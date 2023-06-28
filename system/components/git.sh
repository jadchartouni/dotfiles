##################################################################
# Setup Git
##################################################################
function lets_git()
{
    # Title
    echo -e " ${C_FG_BLACK}${C_BG_BLUE} Git ${C_OFF}"

    # Create symlink
    symlink $DOTFILES/git/gitignore_global $HOME/.gitignore_global
}
