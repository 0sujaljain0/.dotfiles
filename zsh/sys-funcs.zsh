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
        echo "Command failed with exit code "$?" - retrying..."
        sleep 1
    done

    echo "Command Successful"
}
function cnet() {
    sudo wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant.conf
    sudo dhclient wlan0 -v
}

# 1. Define the function/widget
fzf-history-widget() {
  # LBUFFER is the current content of the command line to the left of the cursor
  # We pipe history to fzf, then use 'head -n 1' to ensure we only get one result
  local selected_command=$(history -n 1 | fzf --height 40% --reverse --query="$LBUFFER")

  # If we actually picked something (didn't hit ESC)
  if [ -n "$selected_command" ]; then
    LBUFFER="$selected_command"
  fi
  
  # Redraw the prompt
  zle reset-prompt
}

# 2. Register the function as a ZLE widget
zle -N fzf-history-widget

# 3. Bind Ctrl+R to your new widget
bindkey '^R' fzf-history-widget
