##################################################################
# Setup zsh
##################################################################
function lets_zsh()
{
    # Title
    echo -e " ${C_FG_BLACK}${C_BG_BLUE} Z shell ${C_OFF}"

    # Create symlink
    symlink $DOTFILES/zsh/zshrc $HOME/.zshrc

    # Install Oh my zsh
    # sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    # Install Powerlevel10k theme
    # git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

    # Link Powerlevel10k configuration
    symlink $DOTFILES/zsh/p10k.zsh $HOME/.p10k.zsh

    # Install zsh-autosuggestions
    # git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions > $OUTPUT 2>&1

    # Install syntax-highlighting
    # git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting > $OUTPUT 2>&1

    # Source configuration
    start_process "Sourcing ${C_FG_YELLOW}${HOME}/.zshrc${C_OFF}"
    source $HOME/.zshrc > $OUTPUT 2>&1
    end_process
}
