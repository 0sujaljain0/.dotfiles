export TERM="xterm-256color"
export MNET="$HOME/main/work/projects/mnet/"
export MANPAGER='nvim +Man!'

# Go
export GOPATH=$HOME/go
export GOROOT=/usr/local/go
export GOBIN=$GOPATH/bin

# PATH
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/.local/scripts/"
export PATH=$PATH:$GOPATH
export PATH=$PATH:$GOROOT/bin
export PATH=$PATH:$GOPATH/bin
export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="$PATH:/Users/sujal.ja/main/work/projects/mnet/MOWX_K8S/mowx-k8s/ingress-test/istio-1.30.0/bin"
export PATH=$HOME/.istioctl/bin:$PATH
export PATH=/opt/puppetlabs/bin:$PATH

# NVM — lazy loaded on first use of nvm/node/npm/npx
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
_load_nvm() {
    unset -f nvm node npm npx
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
}
nvm() { _load_nvm; nvm "$@" }
node() { _load_nvm; node "$@" }
npm()  { _load_nvm; npm "$@" }
npx()  { _load_nvm; npx "$@" }

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

# ESP-IDF
[ -f /Users/sujal.ja/export-esp.sh ] && . /Users/sujal.ja/export-esp.sh
