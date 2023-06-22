#################################################################
# Setup homebrew
##################################################################
function lets_brew()
{
    echo -e " ${C_FG_BLACK}${C_BG_BLUE} Homebrew ${C_OFF}"

    which -s brew
    if [[ $? != 0 ]] ; then
        # Install Homebrew
        start_process "Downloading and installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" > /dev/null 2>&1
        end_process
    else
        # Update Homebrew
        start_process "Updating ${C_FG_YELLOW}Homebrew${C_OFF}..."
        brew update > /dev/null 2>&1
        end_process

        # Upgrade Homebrew
        start_process "Upgrading ${C_FG_YELLOW}Homebrew${C_OFF}..."
        brew upgrade > /dev/null 2>&1
        end_process
    fi

    # Remove ~/Brewfile
    start_process "Removing ${C_FG_YELLOW}${HOME}/Brewfile$C_OFF"
    rm -rf $HOME/Brewfile
    end_process

    # Link ~/Brewfile
    start_process "Linking ${C_FG_YELLOW}${DOTFILES}/brew/Brewfile${C_OFF} to ${C_FG_YELLOW}${HOME}/Brewfile${C_OFF}"
    ln -s $DOTFILES/brew/Brewfile $HOME/Brewfile
    end_process

    # Install brew bundle
    start_process "Installing ${C_FG_YELLOW}Brewfile${C_OFF} bundle..."
    brew bundle --file=$HOME/Brewfile > /dev/null 2>&1
    end_process
}
