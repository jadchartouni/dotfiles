function output()
{
    COLOR=${2:-$C_FG_WHITE}
    echo -e " " $COLOR$@$C_OFF
}
