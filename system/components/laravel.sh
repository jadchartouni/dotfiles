##################################################################
# Setup Laravel & co
##################################################################
function lets_laravel()
{
    # Title
    echo -e " ${C_FG_BLACK}${C_BG_BLUE} Laravel ${C_OFF}"

    # Global Laravel installer
    start_process "Downloading and installing ${C_FG_YELLOW}Laravel installer${C_OFF}..."
    # composer global require laravel/installer > $OUTPUT 2>&1
    end_process

    # Valet
    start_process "Downloading and installing ${C_FG_YELLOW}Laravel valet${C_OFF}..."
    # composer global require laravel/valet > $OUTPUT 2>&1
    # valet install > $OUTPUT 2>&1
    end_process

    # Sites
    start_process "Setting up ${C_FG_YELLOW}~/Sites${C_OFF} to serve..."
    # mkdir ~/Sites > $OUTPUT 2>&1
    # valet park > $OUTPUT 2>&1
    end_process
}
