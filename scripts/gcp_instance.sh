local cache_dir="${HOME}/.cache/gcp_instance"
local cache_ttl="${GCP_INSTANCE_TTL:-30000000}"
mkdir -p "$cache_dir"

_gcp_instance_help() {
    cat <<'EOF'
    gcp_instance — list GCP compute instances (GKE nodes excluded), with caching.

    USAGE
    gcp_instance [--name REGEX] [--label KEY=REGEX] [--zone REGEX]
    [--project PROJECT] [--refresh|-r] [--help|-h]

    OPTIONS
    --name REGEX        Filter by instance name (regex, jq test()).
    E.g. --name 'abc-vm'                (substring)
    --name '.*abc-vm.*'            (substring, explicit)
    --name '^prod-.*-vm$'          (anchored)
    --label KEY=REGEX   Filter by label; VALUE is a regex.
    E.g. --label app=billing            (substring)
    --label 'app=^billing$'        (exact match)
    --label 'app=.*abc.*'          (contains abc)
    --zone REGEX        Filter by zone basename (regex).
    E.g. --zone us-east1-d              (substring)
    --zone '^us-east1-[a-d]$'      (anchored)
    --project PROJECT   Use this project (defaults to active gcloud project).
    Each project has its own cache file.
    --refresh, -r       Bypass cache and re-fetch from gcloud.
    --help, -h          Show this help.

    OUTPUT COLUMNS
    NAME  ZONE  STATUS  EXTERNAL_IP  INTERNAL_IP  APP
    STATUS reflects the cache snapshot — use --refresh for live state.

    CACHING
    Cache file:   ~/.cache/gcp_instance/<project>.json
    Default TTL:  300 seconds
    Override TTL: export GCP_INSTANCE_TTL=600
    GKE nodes are excluded at fetch time (label goog-gke-node).

    EXAMPLES
    gcp_instance --name 'abc-vm'
    gcp_instance --name '.*aerospike.*' --zone us-west1-b
    gcp_instance --label 'app=billing' --name '^prod-'
    gcp_instance --refresh --name 'api'

    REQUIRES
    gcloud, jq, column
    EOF
}

local name_filter="" label_kv="" zone_filter="" project="" refresh=0
while [[ $# -gt 0 ]]; do
    case "$1" in
        --name)       name_filter="$2"; shift 2 ;;
        --label)      label_kv="$2";    shift 2 ;;
        --zone)       zone_filter="$2"; shift 2 ;;
        --project)    project="$2";     shift 2 ;;
        --refresh|-r) refresh=1;        shift ;;
        --help|-h)    _gcp_instance_help; return 0 ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Try: gcp_instance --help" >&2
            return 1
            ;;
    esac
done

local proj
proj="${project:-$(gcloud config get-value project 2>/dev/null)}"
local cache_file="${cache_dir}/${proj}.json"

local need_refresh=$refresh
if [[ ! -f "$cache_file" ]]; then
    need_refresh=1
else
    local mtime now
    mtime=$(stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file")
    now=$(date +%s)
    (( now - mtime > cache_ttl )) && need_refresh=1
fi

if (( need_refresh )); then
    echo "↻ refreshing cache for ${proj}..." >&2
    local proj_arg=()
    [[ -n "$project" ]] && proj_arg=(--project="$project")
    gcloud compute instances list "${proj_arg[@]}" \
        --filter='-labels.goog-gke-node:*' \
        --format=json > "$cache_file" || return 1
fi

local jq_query='.[]'
if [[ -n "$name_filter" ]]; then
    jq_query+=" | select(.name | test(\"$name_filter\"))"
fi
if [[ -n "$label_kv" ]]; then
    local k="${label_kv%%=*}" v="${label_kv#*=}"
    jq_query+=" | select(((.labels // {}).\"$k\" // \"\") | test(\"$v\"))"
fi
if [[ -n "$zone_filter" ]]; then
    jq_query+=" | select((.zone | split(\"/\") | last) | test(\"$zone_filter\"))"
fi

{
    printf 'NAME\tZONE\tSTATUS\tEXTERNAL_IP\tINTERNAL_IP\tAPP\n'
    jq -r "$jq_query | [
    .name,
    (.zone | split(\"/\") | last),
    (.status // \"-\"),
    (.networkInterfaces[0].accessConfigs[0].natIP // \"-\"),
    (.networkInterfaces[0].networkIP // \"-\"),
    ((.labels // {}).app // \"\")
    ] | @tsv" "$cache_file"
} | column -t -s $'\t'
