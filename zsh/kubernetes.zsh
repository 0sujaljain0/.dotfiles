alias k="kubectl"
alias ktx="kubectx"
alias kns="kubens"
alias kgw="kubectl get pods -o wide --watch"
alias argo="argocd"

function kaf() {
    kubectl apply -f $1
}

function kl() {
    kubectl logs -f $1
}

function kgp() {
    kubectl get pods
}

function gpip() { 
    kubectl get pods -o wide | grep $1 | awk '{ print $1" "$3" "$6 }'
}

function ardash() {
    k argo rollouts dashboard -n $1
}

# BUG: This does not work.
function kall() {
    regions=("or","sg","eu","sc")


    for element in "${regions[@]}"; do
        eval "kubectx $element"
        # eval "kubectx $element; $1"
    done
}
