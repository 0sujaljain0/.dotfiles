# Try both known SDK locations
if [ -f '/Users/sujal.ja/Downloads/google-cloud-sdk/path.zsh.inc' ]; then
    . '/Users/sujal.ja/Downloads/google-cloud-sdk/path.zsh.inc'
elif [ -f '/Users/sujal.ja/repos/google-cloud-sdk/path.zsh.inc' ]; then
    . '/Users/sujal.ja/repos/google-cloud-sdk/path.zsh.inc'
fi

if [ -f '/Users/sujal.ja/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then
    . '/Users/sujal.ja/Downloads/google-cloud-sdk/completion.zsh.inc'
elif [ -f '/Users/sujal.ja/repos/google-cloud-sdk/completion.zsh.inc' ]; then
    . '/Users/sujal.ja/repos/google-cloud-sdk/completion.zsh.inc'
fi

command -v gcloud &>/dev/null || return

function get_gke_creds() {
    gcloud container clusters list --format="value(name, location)" --project mowx-301015 | xargs -n 2 sh -c 'gcloud container clusters get-credentials "$0" --region "$1" --project mowx-301015'
}

function gip() {
    local zone="$1"
    local ZONE_NAME=""
    case "$zone" in
        "sg") ZONE_NAME="asia-southeast1-b";;
        "eu") ZONE_NAME="europe-west1-b";;
        "sc") ZONE_NAME="us-east1-d";;
        "or") ZONE_NAME="us-west1-b";;
        *)    echo "Unknown Region"; return;;
    esac
    gcloud compute instances describe $2 --zone $ZONE_NAME --format="table(
      networkInterfaces[].name,
      networkInterfaces[].networkIP,
      networkInterfaces[].accessConfigs[].natIP
    )"
}

function pig() {
    gcloud compute instances list \
      --filter="networkInterfaces.accessConfigs.natIP=('${1}')" \
      --format="value(name,zone)"
}


function gissh() {
    local resource="$1"
    entries=( ${(s:/:)resource} )
    project=$entries[1]
    zone=$entries[2]
    vm_name=$entries[3]

    gcloud compute ssh $vm_name --project=$project --zone=$zone --tunnel-through-iap --ssh-key-file=~/.ssh/fleet-health
}

function gcpstartup() {
    local resource="$1"
    entries=( ${(s:/:)resource} )
    project=$entries[1]
    zone=$entries[2]
    vm_name=$entries[3]

    gcloud compute ssh $vm_name --project=$project --zone=$zone --tunnel-through-iap --quiet --ssh-key-file=$HOME/.ssh/fleet-health --ssh-flag="-o BatchMode=yes" --ssh-flag="-o StrictHostKeyChecking=no" --command="sudo google_metadata_script_runner startup" 
}
