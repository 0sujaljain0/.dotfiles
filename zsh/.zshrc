ZSH_DOTFILES_PATH="$HOME/.dotfiles/zsh"
COLOR_RESET="\033[0m"
COLOR_GREEN="\033[32m"
COLOR_RED="\033[31m"

export WLR_DRM_DEVICES=/dev/dri/by-path/pci-0000:01:00.0-card:/dev/dri/by-path/pci-0000:05:00.0-card
ZSH_THEME="robbyrussell"
plugins=(git zsh-syntax-highlighting zsh-autosuggestions)

source <(fzf --zsh)
source ~/.oh-my-zsh/oh-my-zsh.sh

eval "$(starship init zsh)"
eval "$(kubectl completion zsh)"
eval "$(zoxide init zsh)"

source "$ZSH_DOTFILES_PATH"/hooks.zsh
source "$ZSH_DOTFILES_PATH"/histry.zsh
source "$ZSH_DOTFILES_PATH"/kubernetes.zsh
source "$ZSH_DOTFILES_PATH"/tmux.zsh
source "$ZSH_DOTFILES_PATH"/git.zsh
source "$ZSH_DOTFILES_PATH"/ssh.zsh
source "$ZSH_DOTFILES_PATH"/languages.zsh
source "$ZSH_DOTFILES_PATH"/keymaps.zsh
source "$ZSH_DOTFILES_PATH"/gcloud.zsh
source "$ZSH_DOTFILES_PATH"/sys-funcs.zsh
source "$ZSH_DOTFILES_PATH"/browser_actions.zsh
source "$ZSH_DOTFILES_PATH"/metrics.zsh
source "$ZSH_DOTFILES_PATH"/base_custom_aliases.zsh
source "$ZSH_DOTFILES_PATH"/terraform.zsh

export TERM="xterm-256color"

export MNET="$HOME/main/work/projects/mnet/"

export GOPATH=$HOME/go
export GOROOT=/usr/local/go
export GOBIN=$GOPATH/bin
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH":"$HOME/.local/scripts/"
export PATH=$PATH:$GOPATH
export PATH=$PATH:$GOROOT/bin
export PATH=$PATH:$GOPATH/bin
export PATH="$HOME/.rbenv/bin:$PATH"
export PATH=/opt/puppetlabs/bin:$PATH



alias tmux="tmux -u"

export NVM_DIR="$HOME/.nvm"

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/sujal.ja/repos/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/sujal.ja/repos/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/sujal.ja/repos/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/sujal.ja/repos/google-cloud-sdk/completion.zsh.inc'; fi

. /Users/sujal.ja/export-esp.sh
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
