watch() {
    command watch -- "zsh -ic '$*'"
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
