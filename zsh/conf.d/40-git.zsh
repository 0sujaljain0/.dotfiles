command -v git &>/dev/null || return

alias gitc="cat ~/.gitconfig"
alias gs="git status"
alias gaM="gs --short | grep 'M' | awk '{ print \$2 }' | xargs git add"
alias gnew="git checkout -b"

function gco() { git checkout $1 }
function gaa() { git add . }
function gc()  { git commit }
function gp()  { git push $1 $2 }
function gdel() { git branch -D $1 }

function gsync() {
    local branch=$(git branch --show-current)
    local target_to_sync=$1
    git fetch origin $target_to_sync:$target_to_sync
    git merge $target_to_sync
}

function gsyncpush() {
    local branch=$(git branch --show-current)
    local target_to_sync=$1
    git checkout $target_to_sync && git pull && git checkout $branch && git merge $target_to_sync && git push origin $branch
}

function gcpull() {
    local branch=$1
    git checkout $branch && git pull
}

function parse_ssh_git_url() {
    local ssh_url="$1"
    GIT_HOST=""
    GIT_PATH=""
    if [[ "$ssh_url" =~ @.*: ]]; then
        GIT_HOST=$(echo "$ssh_url" | awk -F: '{print $1}' | awk -F@ '{print $2}')
        local raw_path=$(echo "$ssh_url" | awk -F: '{print $2}')
        GIT_PATH="${raw_path%.git}"
        if [[ -z "$GIT_HOST" || -z "$GIT_PATH" ]]; then
            echo "Error: SSH URL matched, but awk extraction failed." >&2
            echo "URL: $ssh_url" >&2
            return 1
        fi
        return 0
    else
        echo "Error: URL does not match the expected SSH format (user@host:path)." >&2
        return 1
    fi
}

function url_encode() {
    local string="$1"
    local encoded_string
    encoded_string=$(echo "$string" | sed \
        -e 's/%/%25/g' \
        -e 's/\//%2F/g' \
        -e 's/ /%20/g' \
        -e 's/:/%3A/g' \
        -e 's/@/%40/g'
    )
    printf '%s' "$encoded_string"
}

function glmr() {
    local branch=$(git branch --show-current)
    local target="$1"
    git push origin "$branch"
    if ! parse_ssh_git_url "$(git config --get remote.origin.url)"; then
        echo "Could not parse remote URL. Check git config --get remote.origin.url" >&2
        return 1
    fi
    local target_encoded=$(url_encode "$target")
    local branch_encoded=$(url_encode "$branch")
    local open_cmd=""
    case "$(uname -s)" in
        Linux*)  open_cmd="xdg-open";;
        Darwin*) open_cmd="open";;
        *)       echo "Please manually open URL."; return 1;;
    esac
    "$open_cmd" "http://${GIT_HOST}/${GIT_PATH}/-/compare/${target_encoded}...${branch_encoded}"
}
