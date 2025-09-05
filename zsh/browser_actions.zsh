function ogdi() {
    open https://mowx-eagle-eye.srv.media.net/grafana/d/${1}
}
function otr() {
    open https://registry.terraform.io/
}
function lh() {
    open http://localhost:$1
}

function orem() {
    local remote="$1"
    local url
    url=$(git remote get-url "$remote" 2>/dev/null)

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to get URL for remote '$remote'" >&2
        return 1
    fi

    # DEBUG: print the URL
    # echo "URL: $url"

    # Match git@domain:path.git
    if [[ "$url" =~ ^git@([^:]+):(.+)\.git$ ]]; then
        local domain="${BASH_REMATCH[1]}"
        local path="${BASH_REMATCH[2]}"

        echo "Domain: $domain"
        echo "Path: $path"

        if [[ "$domain" == "tree.mn" ]]; then
            open "http://tree.mn/$path"
        elif [[ "$domain" == "github.com" ]]; then
            open "https://github.com/$path"
        fi
    else
        echo "Error: Could not parse the Git URL: $url" >&2
        return 1
    fi
}

function opm() {
    open https://mowx-${1}-pm.srv.media.net/
}

function opx() {
    open https://mowx-${1}-pm.srv.media.net/graph?g0.expr=${2}
}
