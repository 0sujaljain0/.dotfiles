## Git Functions
alias gitc="cat ~/.gitconfig"
alias gs="git status"
alias gaM="gs --short | grep 'M' | awk '{ print \$2 }' | xargs git add"

bindkey -s '^gc' 'git commit -m ""\C-b'

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

    git fetch origin $target_to_sync:$target_to_sync
    git merge $target_to_sync
}

function gsyncpush() {
    branch=$(git branch --show-current)

    target_to_sync=$1

    git checkout $target_to_sync && git pull && git checkout $branch && git merge $target_to_sync && git push origin $branch
}

function gcpull() {
    branch=$1
    git checkout $branch && git pull
}

function parse_ssh_git_url() {
    local ssh_url="$1"
    
    # Reset globals in case of failure
    GIT_HOST=""
    GIT_PATH=""
    
    # Check if the URL is an SSH URL format (contains @ and :)
    if [[ "$ssh_url" =~ @.*: ]]; then
        
        # Use awk to split the string:
        # 1. First split by ':' (FS=":"), giving us the Host and the Path fields.
        # 2. Within the first field, split by '@' (FS="@"), giving us the Host.
        
        # Extract Host (Field 2 from the @ split, which is Field 1 from the : split)
        GIT_HOST=$(echo "$ssh_url" | awk -F: '{print $1}' | awk -F@ '{print $2}')
        
        # Extract Path (Field 2 from the : split) and strip the .git suffix
        local raw_path=$(echo "$ssh_url" | awk -F: '{print $2}')
        GIT_PATH="${raw_path%.git}"
        
        # Check if extraction was successful
        if [[ -z "$GIT_HOST" || -z "$GIT_PATH" ]]; then
            echo "Error: SSH URL matched, but awk extraction failed." >&2
            echo "URL: $ssh_url" >&2
            echo "Host: '$GIT_HOST', Path: '$GIT_PATH'" >&2
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
  # Use sed to replace common characters needed for URL encoding:
  # 1. Replace '/' with '%2F' (Essential for Git branch names)
  # 2. Replace ' ' with '%20' (Essential for spaces)
  # 3. Replace '%' with '%25' (For already existing percent signs)
  # 4. Handle other special characters like ':' and '@' if necessary
  
  # For maximum compatibility with common branch names, we focus on / and space.
  # If other characters are needed, they can be added.
  
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
  # 1. Get the current branch
  branch=$(git branch --show-current)

  # 2. Target branch is the first argument
  target="$1"

  # 3. Push current branch
  git push origin "$branch"

    # --- FIX IS HERE ---
    # 4. Call the function directly to set global variables GIT_HOST, GIT_PATH, etc.
  if ! parse_ssh_git_url "$(git config --get remote.origin.url)"; then
    echo "Could not parse remote URL. Check git config --get remote.origin.url" >&2
    return 1
  fi
    # -------------------

  # 5. Construct and open the comparison URL
  # Note: The function 'url_encode' returns the string via stdout, so you 
    # must capture its output using $(...).
  local target_encoded=$(url_encode "$target")
  local branch_encoded=$(url_encode "$branch")

    # Use 'xdg-open' for Linux or 'open' for macOS
    open_cmd=""
    case "$(uname -s)" in
        Linux*)     open_cmd="xdg-open";;
        Darwin*)    open_cmd="open";;
        *)          echo "Please manually open URL."; return 1;;
    esac

  "$open_cmd" "http://${GIT_HOST}/${GIT_PATH}/-/compare/${target_encoded}...${branch_encoded}"
}
