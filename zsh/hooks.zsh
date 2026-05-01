chpwd() {
    if [[ "$PWD" == "$HOME/projects/"* ]]; then
        if [[ -d ".git" ]]; then
            echo ""$COLOR_GREEN"[git tracked][$PWD]"
            echo ""$COLOR_GREEN"$(git remote -v)"$COLOR_RESET""
        else
            echo ""$COLOR_RED"[not git tracked][$PWD]"$COLOR_RESET""

            echo "Wanna git track it?? (y/N): "
            read -r ans

            if [[ "$ans" == "y" || "$ans" == "Y" ]]; then
                echo "enter git remote(format: context/repo_name): "
                read -r remote
                git init
                git remote add origin "git@github.com/$remote"

                echo "Does the remote exist or do you want me to create it(only github)? (y/N)"
                read -r ans
                if [[ "$ans" == "y" || "$ans" == "Y" ]]; then
                    echo "1. private\n2. public\n(1/[2])?"
                    read -r choice
                    flag="public"
                    if [[ "$choice" == "1" ]]; then
                        flag="private"
                    fi
                    gh repo create "--$flag" "$remote"
                    echo ""$COLOR_GREEN"[git tracked][$PWD]"
                    echo ""$COLOR_GREEN"$(git remote -v)"$COLOR_RESET""
                fi
            else
                echo "okie ... "$COLOR_RED"your loss :)$COLOR_RESET"
            fi
        fi
    fi
}
