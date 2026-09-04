alias dc="sudo docker compose"
alias dcrt="dc down;dc up -d"
alias doc="sudo docker"

command -v docker &>/dev/null || return

function dbmlin() {
    local target_prefix="$1"
    local image_id="$2"
    local dockerfile="$3"
    local context="$4"
    local cache="$5"
    local image_full_path="$target_prefix-docker.pkg.dev/mowx-301015/$image_id"
    local build_cmd=(docker build --platform=linux/amd64)
    if [[ -z "$cache" || "$cache" == "nocache" ]]; then
        build_cmd+=(--no-cache)
    fi
    build_cmd+=(-t "$image_full_path" -f "$dockerfile" "$context")
    "${build_cmd[@]}"
    if [[ $? -ne 0 ]]; then
        echo "Build failed. Aborting."
        return 1
    fi
    printf "Do you want to push the image: {{ %s }}? (y/N): " "$image_full_path"
    local user_input
    read -r user_input
    if [[ "$user_input" == [Yy]* ]]; then
        echo "Great, proceeding..."
        docker push "$image_full_path"
    else
        echo "Cool, not pushing..."
    fi
}
