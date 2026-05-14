function sw()  { ssh -i ~/.ssh/id_ecdsa_mnet_main_ssh sujal.ja@$1 }
function swa() { ssh -A -i ~/.ssh/id_ecdsa_mnet_main_ssh sujal.ja@$1 }
function shl() { ssh -i ~/.ssh/ecdsa_homelab_ecdsa $@ }

alias jump_server="sw jump"
