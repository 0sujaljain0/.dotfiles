<<<<<<< HEAD
ZSH_THEME="robbyrussell"
plugins=(git zsh-syntax-highlighting zsh-autosuggestions)

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source <(fzf --zsh)
source ~/.oh-my-zsh/oh-my-zsh.sh
source /Users/sujal.ja/.dotfiles/zsh/git.zsh
source /Users/sujal.ja/.dotfiles/zsh/base_custom_aliases.zsh
source /Users/sujal.ja/.dotfiles/zsh/kubernetes.zsh
source /Users/sujal.ja/.dotfiles/zsh/keymaps.zsh
source /Users/sujal.ja/.dotfiles/zsh/gcloud.zsh
source /Users/sujal.ja/.dotfiles/zsh/sys-funcs.zsh

eval "$(starship init zsh)"
eval "$(kubectl completion zsh)"

export TERM="xterm-256color"
=======
ZSH_THEME="robbyrussell" # set by `omz`

export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH":"$HOME/.local/scripts/"
>>>>>>> df6423d (debian hyprland setup update)

export GOPATH=$HOME/go
export GOROOT=/usr/local/go
export ZIGPATH=/usr/local/zig
export GOBIN=$GOPATH/bin
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH":"$HOME/.local/scripts/"
export PATH=$PATH:$GOPATH
export PATH=$PATH:$GOROOT/bin
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$ZIGPATH

<<<<<<< HEAD
alias tmux="env TERM=screen-256color tmux"


=======
plugins=(git zsh-syntax-highlighting zsh-autosuggestions)
alias tmux='tmux -u'
alias exercism='~/.local/bin/exercism'
alias vim="nvim"
alias bootdev="~/go/bin/bootdev"
alias bat="batcat"
alias gitc="cat ~/.gitconfig"
alias zshc="vim ~/.zshrc"
alias updt="sudo apt-get update && sudo apt-get upgrade"
alias grep="grep --color"
alias kbl="kubectl"
alias ls="ls --color"
alias gstc="vim ~/.dotfiles/ghostty/config"

bindkey -s ^y "tmux-sessionizer\n"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source <(fzf --zsh)

function csoft() {
	ln -s $HOME/$1 $HOME/$2
}
source ~/.oh-my-zsh/oh-my-zsh.sh

>>>>>>> df6423d (debian hyprland setup update)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
