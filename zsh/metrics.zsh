function memmax() { 
    PID=$1
    exec "touch mem.log"
    while kill -0 $PID 2>/dev/null; do
        ps -o rss= -p $PID >> "/temp/mem.log"
        sleep 0.5
    done

    exec "sort -nr mem.log | head -1"
    exec "rm -rf mem.log"
}
