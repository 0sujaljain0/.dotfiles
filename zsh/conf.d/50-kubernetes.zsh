command -v kubectl &>/dev/null || return

eval "$(kubectl completion zsh)"

function k() { kubectl "$@" }
alias ktx="kubectx"
alias kns="kubens"
alias kgw="kubectl get pods -o wide --watch"
alias argo="argocd --grpc-web"

function kaf() { kubectl apply -f $1 }
function kl()  { kubectl logs -f $1 }
function kgp() { kubectl get pods }

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

function kc() { ktx sc &>/dev/null; k "$@" }
function ks() { ktx sg &>/dev/null; k "$@" }
function ko() { ktx or &>/dev/null; k "$@" }
function ke() { ktx eu &>/dev/null; k "$@" }
function kp() { ktx or_poc &>/dev/null; k "$@" }

function kubectl_ops_handler() {
    context_id=$1
    op=$2
    cmd="k${context_id}"
    resource=$3
    entries=( ${(s:/:)resource} )
    namespace=$entries[1]
    resource_type=$entries[2]
    resource_id=$entries[3]

    if [[ "$op" = "get_containers" ]]; then
        if [[ "$resource_type" != "pod" && "$resource_type" != "pods" ]]; then
            echo "you can only get containers of a pod, you gave: '$resource_type'"
        fi
        $cmd get "$resource_type" ${resource_id:+"$resource_id"} -n "$namespace" -o json | jq '(.spec.containers[] | {type: "container", containerName: .name,containerImage: .image}), (.spec.initContainers[] | {type: "initContainer", containerName: .name,containerImage: .image})'
    fi

    if [[ "$op" = "get_svcs" ]]; then
        if [[ "$resource_type" != "pod" && "$resource_type" != "pods" ]]; then
            echo "you can only get containers of a pod, you gave: '$resource_type'"
        fi
        $cmd get endpointslices -o json -n "$namespace" | \
        jq -r --arg id "$resource_id" '.items[] | select(.endpoints[]?.targetRef?.name == $id) | .metadata.labels["kubernetes.io/service-name"]' | \
        sort -u
        return
    fi

    $cmd $op "$resource_type" ${resource_id:+"$resource_id"} -n "$namespace" $( [[ "$op" == "get" ]] && echo "-o wide --sort-by=.metadata.creationTimestamp" )
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

alias kcgcont="kubectl_ops_handler $CAROLINA_CONTEXT_ID get_containers"
alias ksgcont="kubectl_ops_handler $SINGAPORE_CONTEXT_ID get_containers"
alias kogcont="kubectl_ops_handler $OREGON_CONTEXT_ID get_containers"
alias kegcont="kubectl_ops_handler $BELGIUM_CONTEXT_ID get_containers"
alias kpgcont="kubectl_ops_handler $OREGON_POC_CONTEXT_ID get_containers"

alias kcgsvc="kubectl_ops_handler $CAROLINA_CONTEXT_ID get_svcs"
alias ksgsvc="kubectl_ops_handler $SINGAPORE_CONTEXT_ID get_svcs"
alias kogsvc="kubectl_ops_handler $OREGON_CONTEXT_ID get_svcs"
alias kegsvc="kubectl_ops_handler $BELGIUM_CONTEXT_ID get_svcs"
alias kpgsvc="kubectl_ops_handler $OREGON_POC_CONTEXT_ID get_svcs"

function kcpsecret() {
    local context_id=$1
    local src=$2
    local target=$3
    local srcSplited=( ${(s:/:)src} )
    local srcNamespace=$srcSplited[1]
    local srcSecret=$srcSplited[2]
    local targetSplited=( ${(s:/:)target} )
    local targetNamespace=$targetSplited[1]
    local targetSecret=$targetSplited[2]
    if [[ -z "$srcSecret" ]]; then
        print "Error: Source Secret name is missing (Format: namespace/secret)\nExiting"
        return 1
    fi
    if [[ -z "$targetSecret" ]]; then
        targetSecret=$srcSecret
    fi
    print "Processing: $srcNamespace/$srcSecret -> $targetNamespace/$targetSecret"
    kubectx $context_id && kubectl get secrets/${srcSecret} -o yaml -n ${srcNamespace} | \
    yq "select(. != null) | .metadata |= (del(.creationTimestamp, .uid, .resourceVersion, .managedFields) | .namespace = \"${targetNamespace}\" | .name = \"${targetSecret}\")" | k apply -f -
}
