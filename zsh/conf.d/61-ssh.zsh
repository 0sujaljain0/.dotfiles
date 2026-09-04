function sw()  { ssh -i ~/.ssh/id_ecdsa_mnet_main_ssh sujal.ja@$1 }
function swa() { ssh -A -i ~/.ssh/id_ecdsa_mnet_main_ssh sujal.ja@$1 }
function shl() { ssh -i /Users/sujal.ja/.ssh/ecdsa_homelab_ecdsa 'herdcontrarian@doesntmatter.local' }

alias jump_server="sw jump"
