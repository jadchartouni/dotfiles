function symlink()
{
    # Check if symlink exists
    if [ -L $2 ]; then
        # Check if symlink points to the right location
        start_process "Checking ${C_FG_YELLOW}$2${C_OFF}"
        if [ "$(readlink $2)" != "$1" ]; then
            end_process

            # Remove symlink
            start_process "Removing ${C_FG_YELLOW}$2${C_OFF}"
            rm -rf $2
            end_process

            # Create symlink
            start_process "Linking ${C_FG_YELLOW}$1${C_OFF} to ${C_FG_YELLOW}$2${C_OFF}"
            ln -s $1 $2 > /dev/null 2>&1
            end_process
        else
            end_process
        fi
    else
        # Create symlink
        start_process "Linking ${C_FG_YELLOW}$1${C_OFF} to ${C_FG_YELLOW}$2${C_OFF}"
        ln -s $1 $2 > /dev/null 2>&1
        end_process
    fi
}
