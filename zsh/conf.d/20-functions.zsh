watchcmd () {
        local interval=3
        local clear_screen=false
        local cmd=""
        _watchcmd_help() {
                cat <<'EOF'
watchcmd — repeatedly run a command at a fixed interval.

USAGE
    watchcmd [-t|--time SECONDS] [-c|--clear] [-h|--help] <command>

OPTIONS
    -t, --time SECONDS   Interval between runs (default: 3).
    -c, --clear          Clear screen between runs.
    -h, --help           Show this help.

EXAMPLES
    watchcmd 'kubectl get pods'
    watchcmd -t 5 -c 'df -h'
EOF
        }
        while [[ $# -gt 0 ]]
        do
                case $1 in
                        (-t | --time) interval="$2"
                                shift 2 ;;
                        (-c | --clear) clear_screen=true
                                shift ;;
                        (-h | --help) _watchcmd_help; return 0 ;;
                        (*) cmd="$1"
                                shift ;;
                esac
        done
        if ! [[ "$interval" =~ ^[0-9]+(\.[0-9]+)?$ ]]
        then
                echo "Error: Interval must be a number"
                return 1
        fi
        while true
        do
                echo `date`
                if [ "$clear_screen" = true ]
                then
                        clear
                fi
                eval "$cmd"
                echo '=========================================='
                sleep "$interval"
        done
}

function clp() {
    local text="$*"
    if [ -z "$text" ]; then
        text=$(cat)
    fi
    if command -v pbcopy &>/dev/null; then
        echo -n "$text" | pbcopy
    elif command -v wl-copy &>/dev/null; then
        echo -n "$text" | wl-copy
    elif command -v xclip &>/dev/null; then
        echo -n "$text" | xclip -selection clipboard
    elif command -v xsel &>/dev/null; then
        echo -n "$text" | xsel --clipboard --input
    else
        echo "No clipboard tool found. Install one of: pbcopy, wl-copy, xclip, xsel." >&2
        return 1
    fi
    echo "Copied to clipboard..."
}

function ak() {
    awk '{ print \$$1 }'
}

function killport() {
    sudo lsof -n -i :$1 | grep LISTEN | awk '{ print $2 }' | xargs kill -9
}

function fproc() {
    ps aux | grep -E $1 | grep -v "grep"
}

function try() {
    if [ "$#" -eq 0 ]; then
        echo "Usage try <command> [args...]"
    fi
    until "$@"; do
        echo "Command failed with exit code $? - retrying..."
        sleep 1
    done
    echo "Command Successful"
}

function cnet() {
    sudo wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant.conf
    sudo dhclient wlan0 -v
}

function memmax() {
    PID=$1
    exec "touch mem.log"
    while kill -0 $PID 2>/dev/null; do
        ps -o rss= -p $PID >> "/temp/mem.log"
        sleep 0.5
    done
    exec "sort -nr mem.log | head -1"
    exec "rm -rf mem.log"
}


function c-pers() {
    CLAUDE_CONFIG_DIR=~/.claude-personal claude "$@"
}

function c-work() {
    CLAUDE_CONFIG_DIR=~/.claude-work claude "$@"
}
