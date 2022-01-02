function c0rc_srch() {
    {
        tac ~/.zsh_history
        tac /root/.zsh_history
    } | uniq -iu | grep --color=always -E $1 | less -r

    return 0
}

function c0rc_srch_files() {
    grep -r -n -o -E $(echo $1) $2 2>/dev/null
    if [ $? -ne 0 ]; then
        return 1
    fi

    return 0
}
