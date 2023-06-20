##################################################################
# Setup Laravel & co
##################################################################
function lets_laravel()
{
    output $C_FG_BLACK$C_BG_BLUE" Laravel "

    # Global Laravel installer
    output "Downloading and installing Laravel installer..."
    # composer global require laravel/installer > /dev/null 2>&1

    # Valet
    output "Downloading and installing Laravel valet..."
    # composer global require laravel/valet > /dev/null 2>&1
    # valet install > /dev/null 2>&1

    # Sites
    output "Setting up ~/Sites to serve..."
    # mkdir ~/Sites > /dev/null 2>&1
    # valet park > /dev/null 2>&1
}
