# Cursor — bar in shell, reset after every prompt (survives returning from nvim/tmux)
# printf '\e[6 q'
# add-zsh-hook precmd _set_bar_cursor
# _set_bar_cursor() { printf '\e[6 q' }

# Tmux
bindkey -s '^y' 'tmux-sessionizer\n'
bindkey -s '^v' 'vim .\n'

# Git
bindkey -s '^gc' 'git commit -m ""\C-b'

# FZF history search (overrides fzf's default ^R with a custom widget)
fzf-history-widget() {
    local selected_command=$(fc -rln 1 | awk ' !seen[$0]++ ' | fzf --height 40% --tiebreak=index --reverse --query="$LBUFFER")
    if [ -n "$selected_command" ]; then
        LBUFFER="$selected_command"
    fi
    zle reset-prompt
}

zle -N fzf-history-widget
bindkey '^R' fzf-history-widget
