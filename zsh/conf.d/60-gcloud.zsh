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
