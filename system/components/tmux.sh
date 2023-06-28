##################################################################
# Setup tmux
##################################################################
function lets_tmux()
{
    # Title
    echo -e " ${C_FG_BLACK}${C_BG_BLUE} Tmux ${C_OFF}"

    # Create symlink
    symlink $DOTFILES/tmux/tmux.conf $HOME/.tmux.conf

    # Start-tmux script
    start_process "Creating ${C_FG_YELLOW}start-tmux${C_OFF} script..."
    mkdir -p $HOME/.local/bin
    symlink $DOTFILES/scripts/start-tmux $HOME/.local/bin/start-tmux
    end_process
}
