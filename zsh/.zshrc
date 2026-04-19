ZSH_THEME="robbyrussell"
plugins=(git zsh-syntax-highlighting zsh-autosuggestions)

source <(fzf --zsh)
source ~/.oh-my-zsh/oh-my-zsh.sh

eval "$(starship init zsh)"
eval "$(kubectl completion zsh)"
eval "$(zoxide init zsh)"

source $HOME/.dotfiles/zsh/kubernetes.zsh
source $HOME/.dotfiles/zsh/tmux.zsh
source $HOME/.dotfiles/zsh/git.zsh
source $HOME/.dotfiles/zsh/ssh.zsh
source $HOME/.dotfiles/zsh/languages.zsh
source $HOME/.dotfiles/zsh/keymaps.zsh
source $HOME/.dotfiles/zsh/gcloud.zsh
source $HOME/.dotfiles/zsh/sys-funcs.zsh
source $HOME/.dotfiles/zsh/browser_actions.zsh
source $HOME/.dotfiles/zsh/metrics.zsh
source $HOME/.dotfiles/zsh/base_custom_aliases.zsh
source $HOME/.dotfiles/zsh/terraform.zsh

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

# Lazy load nvm
nvm() {
    unfunction "$0"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    $0 "$@"
}

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/sujal.ja/repos/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/sujal.ja/repos/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/sujal.ja/repos/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/sujal.ja/repos/google-cloud-sdk/completion.zsh.inc'; fi

. /Users/sujal.ja/export-esp.sh
