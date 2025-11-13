# FS
alias ltr="ls -latr"
alias lz="eza --icons"
alias lt="eza --tree"
alias cat="bat --theme base16"
alias ex="yazi"

# Sys/Build Tools
alias m="make"
alias vim="nvim"

# Other Tools
alias grep="grep --color"
alias dss="diff --side-by-side"

# Config Editing
alias gstc="vim ~/.dotfiles/ghostty/config"
alias zshc="vim ~/.zshrc"

# Config Sourcing
alias zshs="source ~/.zshrc"

function hatch() {
    watch zsh -ic "$*"
}

function clp() {
    local text="$*"
    
    # If no argument, read from stdin
    if [ -z "$text" ]; then
        text=$(cat)
    fi
    
    if command -v pbcopy &>/dev/null; then
        echo "Using pbcopy"
        echo -n "$text" | pbcopy
    elif command -v wl-copy &>/dev/null; then
        echo "Using wl-copy"
        echo -n "$text" | wl-copy
    elif command -v xclip &>/dev/null; then
        echo "Using xclip"
        echo -n "$text" | xclip -selection clipboard
    elif command -v xsel &>/dev/null; then
        echo "Using pbcopy"
        echo -n "$text" | xsel --clipboard --input
    else
        echo "❌ No clipboard tool found. Please install one of: pbcopy, wl-copy, xclip, or xsel." >&2
        return 1
    fi
    
    echo "Copied to clipboard..."
}

alias otp="oathtool -b --totp 4XE4WAU22ZULPQRV | clp"
