##################################################################
# Setup homebrew
##################################################################
function lets_brew()
{
    output $C_FG_BLACK$C_BG_BLUE" Homebrew "
    
    which -s brew
    if [[ $? != 0 ]] ; then
        # Install Homebrew
        output "Downloading and installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" > /dev/null 2>&1
    else
        # Update Homebrew
        output "Downloading and updating Homebrew..."
        brew update > /dev/null 2>&1
    fi

    # Remove ~/Brewfile
    output "Removing "$C_FG_YELLOW"$HOME/Brewfile"$C_OFF
    rm -rf $HOME/Brewfile

    # Link ~/Brewfile
    output "Linking "$C_FG_YELLOW"$DOTFILES/brew/Brewfile"$C_OFF" to "$C_FG_YELLOW"$HOME/Brewfile"$C_OFF
    ln -s $DOTFILES/brew/Brewfile $HOME/Brewfile

    # Install brew bundle
    output "Installing "$C_FG_YELLOW"Brewfile"$C_OFF" bundle..."
    brew bundle --file=$HOME/Brewfile > /dev/null 2>&1
}
