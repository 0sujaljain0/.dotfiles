# Tmux
bindkey -s '^y' 'tmux-sessionizer\n'
bindkey -s '^v' 'vim .\n'

# Git
bindkey -s '^gc' 'git commit -m ""\C-b'

# FZF history search (overrides fzf's default ^R with a custom widget)
fzf-history-widget() {
    local selected_command=$(history -n 1 | fzf --height 40% --reverse --query="$LBUFFER")
    if [ -n "$selected_command" ]; then
        LBUFFER="$selected_command"
    fi
    zle reset-prompt
}

zle -N fzf-history-widget
bindkey '^R' fzf-history-widget
