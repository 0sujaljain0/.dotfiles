# Filesystem
alias ltr="ls -latr"
alias lz="eza -l --icons --context --total-size"
alias lt="eza --tree"
alias cat="bat --theme base16"
alias ex="yazi"
alias uc="sort | uniq -c"

# Build tools
alias m="make"
alias v="nvim"

# Shell utils
alias grep="grep --color"
alias dss="diff --side-by-side"

# Config
alias gstc="vim ~/.dotfiles/ghostty/config"
alias zshc="vim ~/.zshrc"
alias zshs="source ~/.zshrc"

# Tmux
alias tmux="tmux -u"
alias toff="tmux kill-session -t"
alias toffex="tmux kill-session -a -t"
alias tscl="tmux switch-client -t"

# Terraform
function tf() { terraform "$@" }

# Python
alias py="python"
alias spy=". venv/bin/activate"
alias pyi="pip install -r requirements.txt"

# OTP (depends on clp from 20-functions.zsh)
alias otp="oathtool -b --totp 4XE4WAU22ZULPQRV | clp"
