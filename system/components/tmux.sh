##################################################################
# Setup tmux
##################################################################
function lets_tmux()
{
    echo -e " ${C_FG_BLACK}${C_BG_BLUE} Tmux ${C_OFF}"

    start_process "Removing ${C_FG_YELLOW}${HOME}/.tmux.conf${C_OFF}"
    rm -rf $HOME/.tmux.conf
    end_process

    start_process "Linking ${C_FG_YELLOW}${DOTFILES}/tmux/tmux.conf${C_OFF} to ${C_FG_YELLOW}${HOME}/.tmux.conf${C_OFF}"
    ln -s $DOTFILES/tmux/tmux.conf $HOME/.tmux.conf
    end_process

    # Start-tmux script
    start_process "Creating ${C_FG_YELLOW}start-tmux${C_OFF} script..."
    mkdir -p $HOME/.local/bin
    rm -rf $HOME/.local/bin/start-tmux
    ln -s $DOTFILES/scripts/start-tmux $HOME/.local/bin/start-tmux
    end_process
}

