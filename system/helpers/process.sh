PROCESS_MSG=""
PROCESS_START_TIME=0

function start_process()
{
    PROCESS_MSG=$@
    PROCESS_START_TIME=$(date +%s)

    echo -en " ${PROCESS_MSG}"
}

function end_process()
{
    MSG=$(echo -e "$PROCESS_MSG" | sed "s/$(echo -e "\e")[^m]*m//g");
    COLS=`tput cols`
    PADDING=2
    PROCESS_TIME=$(($(date +%s) - $PROCESS_START_TIME))
    DOTS=$(($COLS - ${#MSG} - $PADDING - ${#PROCESS_TIME} - 10))

    for ((i=0; i<$DOTS; i++)); do echo -n "."; done

    echo " ${PROCESS_TIME}s [DONE]"

    PROCESS_MSG=""
    PROCESS_START_TIME=0
}
