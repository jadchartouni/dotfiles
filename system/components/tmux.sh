##################################################################
# Setup tmux
##################################################################
function lets_tmux()
{
    output $C_FG_BLACK$C_BG_BLUE" Tmux "

    output "Removing "$C_FG_YELLOW"$HOME/.tmux.conf"$C_OFF
    rm -rf $HOME/.tmux.conf

    output "Linking $C_FG_YELLOW$DOTFILES/tmux/tmux.conf$C_OFF to $C_FG_YELLOW$HOME/.tmux.conf$C_OFF"
    ln -s $DOTFILES/tmux/tmux.conf $HOME/.tmux.conf

    # Start tmux script
    mkdir -p $HOME/.local/bin
    rm -rf $HOME/.local/bin/start-tmux
    ln -s $DOTFILES/scripts/start-tmux $HOME/.local/bin/start-tmux
}

