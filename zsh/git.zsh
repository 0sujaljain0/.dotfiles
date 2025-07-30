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

function gsync() { 
    branch=$(git branch --show-current)

    target_to_sync=$1

    git checkout $target_to_sync && git pull && git checkout $branch && git merge $target_to_sync
}
