# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# source ~/repos/powerlevel10k/powerlevel10k.zsh-theme
#
# Load the kubectl completion code for zsh[1] into the current shell
#source <(kubectl completion zsh)
# Set the kubectl completion code for zsh[1] to autoload on startup
#kubectl completion zsh > "${fpath[1]}/_kubectl"
#
#eval "neofetch --ascii_distro Ubuntu_small"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH":"$HOME/.local/scripts/"
#export PATH=$PATH:$(go env GOPATH)/bin
#export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export GOROOT=/usr/local/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOPATH
export PATH=$PATH:$GOROOT/bin
export PATH=$PATH:$GOPATH/bin
# add to ~/.zshrc
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$PATH:/opt/nvim/"

plugins=(... git)

# bun completions
[ -s "/home/sujal/.bun/_bun" ] && source "/home/sujal/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions

autoload -U compinit && compinit

bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
#set -o vi

declare -A pomo_options
pomo_options["work"]="45"
pomo_options["break"]="10"

pomodoro () {
  if [ -n "$1" -a -n "${pomo_options["$1"]}" ]; then
  val=$1
  echo $val | lolcat
  timer ${pomo_options["$val"]}m
  fi
}

alias wo="pomodoro 'work'"
alias br="pomodoro 'break'"

#alias ls='eza --icons=always'
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

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" 

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source <(fzf --zsh)
bindkey -s ^f "tmux-sessionizer\n"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

PATH=~/.console-ninja/.bin:$PATH
# source ~/repos/powerlevel10k/powerlevel10k.zsh-theme

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
source ~/.oh-my-zsh/oh-my-zsh.sh
