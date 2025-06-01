function killport() { 
     sudo lsof -n -i :$1 | grep LISTEN | awk '{ print $2 }' | xargs kill -9
}
