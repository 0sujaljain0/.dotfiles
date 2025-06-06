ZSH_THEME="robbyrussell"
plugins=(git zsh-syntax-highlighting zsh-autosuggestions)

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source <(fzf --zsh)
source ~/.oh-my-zsh/oh-my-zsh.sh
source $HOME/.dotfiles/zsh/git.zsh
source $HOME/.dotfiles/zsh/base_custom_aliases.zsh
source $HOME/.dotfiles/zsh/kubernetes.zsh
source $HOME/.dotfiles/zsh/keymaps.zsh
source $HOME/.dotfiles/zsh/gcloud.zsh
source $HOME/.dotfiles/zsh/sys-funcs.zsh

eval "$(starship init zsh)"
eval "$(kubectl completion zsh)"

export TERM="xterm-256color"

export GOPATH=$HOME/go
export GOROOT=/usr/local/go
export GOBIN=$GOPATH/bin
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH":"$HOME/.local/scripts/"
export PATH=$PATH:$GOPATH
export PATH=$PATH:$GOROOT/bin
export PATH=$PATH:$GOPATH/bin

alias tmux="tmux -u"


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
