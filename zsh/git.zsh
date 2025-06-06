## Git Functions
alias gitc="cat ~/.gitconfig"
alias gs="git status"
function gco() {
    git checkout $1
}
function gaa() {
    git add .
}
function gc() {
    git commit
}

function gp() {
    git push $1 $2
}

function gdel() {
    git branch -D $1
}
