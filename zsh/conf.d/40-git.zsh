command -v git &>/dev/null || return

export GOPRIVATE="tree.mn/*"
export GONOSUMCHECK="tree.mn/*"
export GONOSUMDB="tree.mn/*"
export GOINSECURE="tree.mn/*"


alias gitc="cat ~/.gitconfig"
alias gs="git status"
alias gaM="gs --short | grep 'M' | awk '{ print \$2 }' | xargs git add"
alias gnew="git checkout -b"
alias gpf="git push -f"

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


# ============================================================
# GitLab CLI helpers (zsh) — Work instance
# ============================================================

# --- Config ---
export GITLAB_WORK_HOST="tree.mn"
export GITLAB_WORK_SCHEME="http"    # change to "https" if your GitLab uses TLS
export GITLAB_WORK_TOKEN_FILE="$HOME/.config/gitlab/work-token"

# --- Token retrieval ---
# Pick your storage method by uncommenting ONE block:

# Option A: Plain file with chmod 600
_gitlab_work_token() {
  if [[ ! -f "$GITLAB_WORK_TOKEN_FILE" ]]; then
    echo "Token file not found: $GITLAB_WORK_TOKEN_FILE" >&2
    return 1
  fi
  cat "$GITLAB_WORK_TOKEN_FILE"
}

# Option B (Linux keyring):
# _gitlab_work_token() { secret-tool lookup service gitlab-work user "$GITLAB_WORK_HOST"; }

# Option C (macOS Keychain):
# _gitlab_work_token() { security find-generic-password -a "$GITLAB_WORK_HOST" -s gitlab-work -w; }


# --- URL-encoder (uses jq; fallback to python3) ---
_urlencode() {
  if command -v jq >/dev/null 2>&1; then
    jq -rn --arg s "$1" '$s|@uri'
  elif command -v python3 >/dev/null 2>&1; then
    python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1], safe=''))" "$1"
  else
    echo "Need jq or python3 installed for URL encoding" >&2
    return 1
  fi
}


# --- Sanity check: verify the token works ---
glwhoami() {
  local token
  token=$(_gitlab_work_token) || return 1
  curl -sSk --header "PRIVATE-TOKEN: ${token}" \
    "${GITLAB_WORK_SCHEME}://${GITLAB_WORK_HOST}/api/v4/user" | jq '{id, username, name, email}'
}


# --- Fetch a single file ---
# Usage: glfetch <project_path> <branch> <file_path> [output_file]
# Example: glfetch sysad/mowx-ops master production/kyverno-notifier/src/main.go
glfetch() {
  if [[ $# -lt 3 ]]; then
    cat <<EOF
Usage: glfetch <project_path> <branch> <file_path> [output_file]

Example:
  glfetch sysad/mowx-ops master production/kyverno-notifier/src/main.go
  glfetch sysad/mowx-ops master production/kyverno-notifier/src/main.go ./out.go
EOF
    return 1
  fi

  local project="$1"
  local branch="$2"
  local filepath="$3"
  local outfile="${4:-$(basename "$filepath")}"

  local enc_project enc_file token url
  enc_project=$(_urlencode "$project")   || return 1
  enc_file=$(_urlencode "$filepath")     || return 1
  token=$(_gitlab_work_token)            || return 1

  url="${GITLAB_WORK_SCHEME}://${GITLAB_WORK_HOST}/api/v4/projects/${enc_project}/repository/files/${enc_file}/raw?ref=${branch}"

  echo "→ Fetching: $url"
  if curl -sSk --fail \
       --header "PRIVATE-TOKEN: ${token}" \
       "$url" -o "$outfile"; then
    echo "✓ Saved to $outfile"
  else
    echo "✗ Failed to fetch file"
    return 1
  fi
}


# --- List directory contents in a repo ---
# Usage: gltree <project_path> [branch] [path]
# Example: gltree sysad/mowx-ops master production/kyverno-notifier
gltree() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: gltree <project_path> [branch] [path]"
    return 1
  fi

  local project="$1"
  local branch="${2:-master}"
  local path="${3:-}"

  local enc_project enc_path token url
  enc_project=$(_urlencode "$project")   || return 1
  enc_path=$(_urlencode "$path")         || return 1
  token=$(_gitlab_work_token)            || return 1

  url="${GITLAB_WORK_SCHEME}://${GITLAB_WORK_HOST}/api/v4/projects/${enc_project}/repository/tree?ref=${branch}&path=${enc_path}&per_page=100"

  curl -sSk --header "PRIVATE-TOKEN: ${token}" "$url" \
    | jq -r '.[] | "\(.type)\t\(.path)"' \
    | column -t -s $'\t'
}


# --- Download an entire directory recursively ---
# Usage: glfetchdir <project_path> <branch> <remote_dir> [local_dir]
# Example: glfetchdir sysad/mowx-ops master production/kyverno-notifier ./kyverno-notifier
glfetchdir() {
  if [[ $# -lt 3 ]]; then
    echo "Usage: glfetchdir <project_path> <branch> <remote_dir> [local_dir]"
    return 1
  fi

  local project="$1"
  local branch="$2"
  local remote_dir="$3"
  local local_dir="${4:-$(basename "$remote_dir")}"

  local enc_project enc_path token url
  enc_project=$(_urlencode "$project")   || return 1
  token=$(_gitlab_work_token)            || return 1

  mkdir -p "$local_dir"

  # Recursive tree listing
  enc_path=$(_urlencode "$remote_dir")
  url="${GITLAB_WORK_SCHEME}://${GITLAB_WORK_HOST}/api/v4/projects/${enc_project}/repository/tree?ref=${branch}&path=${enc_path}&recursive=true&per_page=100"

  local files
  files=$(curl -sSk --header "PRIVATE-TOKEN: ${token}" "$url" \
    | jq -r '.[] | select(.type=="blob") | .path')

  if [[ -z "$files" ]]; then
    echo "✗ No files found at $remote_dir (or path invalid)"
    return 1
  fi

  local relpath outpath
  while IFS= read -r f; do
    relpath="${f#$remote_dir/}"
    outpath="$local_dir/$relpath"
    mkdir -p "$(dirname "$outpath")"
    echo "→ $f"
    glfetch "$project" "$branch" "$f" "$outpath" >/dev/null \
      && echo "  ✓ $outpath" \
      || echo "  ✗ failed: $f"
  done <<< "$files"
}
