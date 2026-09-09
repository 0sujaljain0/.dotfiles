ZSH_THEME="robbyrussell"
plugins=(git zsh-syntax-highlighting zsh-autosuggestions)
DISABLE_MAGIC_FUNCTIONS=true   # skip slow bracketed-paste init
ZSH_DISABLE_COMPFIX=true       # skip compaudit on every start
source ~/.oh-my-zsh/oh-my-zsh.sh

source <(fzf --zsh)
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
for f in $HOME/.dotfiles/zsh/conf.d/*.zsh(N); do source "$f"; done
