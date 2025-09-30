function killport() { 
     sudo lsof -n -i :$1 | grep LISTEN | awk '{ print $2 }' | xargs kill -9
}

function fproc() {
    ps aux | grep -E $1 | grep -v "grep"
}


function try() { 
    if [ "$#" -eq 0 ]; then
        echo "Usage try <command> [args...]"
    fi

    until "$@"; do
        echo "Command failed with exit code "$?" - retrying..."
        sleep 1
    done

    echo "Command Successful"
}
