alias k="kubectl"
alias ktx="kubectx"
alias kns="kubens"
alias kgw="kubectl get pods -o wide --watch"

function kaf() {
    kubectl apply -f $1
}

function kl() {
    kubectl logs -f $1
}

function kgp() {
    kubectl get pods
}
