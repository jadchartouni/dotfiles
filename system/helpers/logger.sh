LOG_LEVEL=1

# Parse command line arguments
while getopts "qvo:" opt; do
    case ${opt} in
        q)
            LOG_LEVEL=1
            ;;
        v)
            LOG_LEVEL=2
            ;;
        o)
            LOG_FILE=$OPTARG
            LOG_LEVEL=3
            ;;
        \?)
            echo "Invalid option -$OPTARG" >&2
            exit 1
            ;;
    esac
done

# Function to handle logging
log() {
    if [[ $LOG_LEVEL -eq 1 ]]; then
        echo "$@"
    elif [[ $LOG_LEVEL -eq 3 ]]; then
        echo "$@" >> $LOG_FILE
    fi
}

