# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/sujal.ja/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/sujal.ja/Downloads/google-cloud-sdk/path.zsh.inc'; fi
# The next line enables shell command completion for gcloud.
if [ -f '/Users/sujal.ja/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/sujal.ja/Downloads/google-cloud-sdk/completion.zsh.inc'; fi


function gip() {
    zone="$1"  # Or set zone variable however you get it
    ZONE_NAME=""
    case "$zone" in
        "sg")
            ZONE_NAME="asia-southeast1-b"
            ;;
        "eu")
            ZONE_NAME="europe-west1-b"
            ;;
        "sc")
            ZONE_NAME="us-east1-d"
            ;;
        "or")
            ZONE_NAME="us-west1-b"
            ;;
        *)
            echo "Unknown Region"
            return
    esac

    gcloud compute instances describe $2 --zone=$ZONE_NAME --format="table(
      networkInterfaces[].name,
      networkInterfaces[].networkIP,
      networkInterfaces[].accessConfigs[].natIP
    )"

    return eval "gcloud compute instances describe INSTANCE_NAME --zone=ZONE_NAME --format='json(networkInterfaces)'"
}


function pig() {
    gcloud compute addresses list --filter="address=$1"
}
