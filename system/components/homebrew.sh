#################################################################
# Setup homebrew
##################################################################
function lets_brew()
{
    # Title
    echo -e " ${C_FG_BLACK}${C_BG_BLUE} Homebrew ${C_OFF}"

    # Install or update/upgrade Homebrew
    which -s brew
    if [[ $? != 0 ]] ; then
        # Install Homebrew
        start_process "Downloading and installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" > $OUTPUT 2>&1
        end_process
    else
        # Update Homebrew
        start_process "Updating ${C_FG_YELLOW}Homebrew${C_OFF}..."
        brew update > $OUTPUT 2>&1
        end_process

        # Upgrade Homebrew
        start_process "Upgrading ${C_FG_YELLOW}Homebrew${C_OFF}..."
        brew upgrade > $OUTPUT 2>&1
        end_process
    fi

    # Create symlink
    symlink $DOTFILES/brew/Brewfile $HOME/Brewfile

    # Install brew bundle
    start_process "Installing ${C_FG_YELLOW}Brewfile${C_OFF} bundle..."
    brew bundle --file=$HOME/Brewfile > $OUTPUT 2>&1
    end_process
}
