##################################################################
# Setup Git
##################################################################
function lets_git()
{
    echo -e " ${C_FG_BLACK}${C_BG_BLUE} Git ${C_OFF}"

    # Remove ~/.gitignore_global
    start_process "Removing ${C_FG_YELLOW}${HOME}/.gitignore_global${C_OFF}"
    rm -rf $HOME/.gitignore_global > /dev/null 2>&1
    end_process

    # Link ~/.gitignore_global
    start_process "Linking ${C_FG_YELLOW}${DOTFILES}/git/gitignore_global${C_OFF} to ${C_FG_YELLOW}${HOME}/.gitignore_global${C_OFF}"
    ln -s $DOTFILES/git/gitignore_global $HOME/.gitignore_global > /dev/null 2>&1
    end_process
}
