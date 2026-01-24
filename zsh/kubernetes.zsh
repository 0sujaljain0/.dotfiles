function k() { kubectl "$@" }
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

function svcips() {
    kubectl get endpoints $1 -n $2 -o jsonpath='{.subsets[*].addresses[*].ip}' | tr ' ' '\n' | sort -u
}




BELGIUM_CONTEXT_ID="e"
OREGON_CONTEXT_ID="o"
OREGON_POC_CONTEXT_ID="p"
SINGAPORE_CONTEXT_ID="s"
CAROLINA_CONTEXT_ID="c"
function kc(){ ktx sc &> /dev/null; k "$@" }
function ks(){ ktx sg &> /dev/null; k "$@" }
function ko(){ ktx or &> /dev/null; k "$@" }
function ke(){ ktx eu &> /dev/null; k "$@" }
function kp(){ ktx or_poc &> /dev/null; k "$@" }
function kubectl_ops_handler() {
    context_id=$1
    op=$2
    cmd="k${context_id}"
    resource=$3
    entries=( ${(s:/:)resource} )
    namespace=$entries[1]
    resource_type=$entries[2]
    resource_id=$entries[3]

    $cmd $op "$resource_type" ${resource_id:+"$resource_id"} -n "$namespace" $( [[ "$op" == "get" ]] && echo "-o wide" )
}
alias kcg="kubectl_ops_handler $CAROLINA_CONTEXT_ID get"
alias ksg="kubectl_ops_handler $SINGAPORE_CONTEXT_ID get"
alias kog="kubectl_ops_handler $OREGON_CONTEXT_ID get"
alias keg="kubectl_ops_handler $BELGIUM_CONTEXT_ID get"
alias kpg="kubectl_ops_handler $OREGON_POC_CONTEXT_ID get"
alias kcd="kubectl_ops_handler $CAROLINA_CONTEXT_ID describe"
alias ksd="kubectl_ops_handler $SINGAPORE_CONTEXT_ID describe"
alias kod="kubectl_ops_handler $OREGON_CONTEXT_ID describe"
alias ked="kubectl_ops_handler $BELGIUM_CONTEXT_ID describe"
alias kpd="kubectl_ops_handler $OREGON_POC_CONTEXT_ID describe"
