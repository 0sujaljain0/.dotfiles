function killport() { 
     sudo lsof -n -i :$1 | grep LISTEN | awk '{ print $2 }' | xargs kill -9
}

function fproc() {
    ps aux | grep $1 | grep -v "grep"
}
