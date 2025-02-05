export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH":"$HOME/.local/scripts/"

export GOPATH=$HOME/go
export GOROOT=/usr/local/go
export GOBIN=$GOPATH/bin

export PATH=$PATH:$GOPATH
export PATH=$PATH:$GOROOT/bin
export PATH=$PATH:$GOPATH/bin

plugins=(... git)
alias tmux='tmux -u'
alias exercism='~/.local/bin/exercism'
alias vim="nvim"
#alias vi="nvim"
alias bootdev="~/go/bin/bootdev"
alias bat="batcat"
alias gitc="cat ~/.gitconfig"
alias zshc="vim ~/.zshrc"
alias updt="sudo apt-get update && sudo apt-get upgrade"
alias tmux="env TERM=screen-256color tmux"
alias grep="grep --color"
alias kbl="kubectl"
alias ls="ls --color"
alias gstc="vim ~/.dotfiles/ghostty/config"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source <(fzf --zsh)
bindkey -s ^y "tmux-sessionizer\n"

source ~/.oh-my-zsh/oh-my-zsh.sh
