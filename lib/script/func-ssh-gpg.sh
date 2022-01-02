function c0rc_sshgpg() {
    # assumption, that gpg-agen already running
    #

    local auth_socket="$(gpgconf --list-dirs agent-ssh-socket)"
    if [ $? -ne 0 ]; then
        c0rc_warn "error while getting gpg-agent socket dir"
        return 1
    fi

    unset SSH_AGENT_PID
    export SSH_AUTH_SOCK=$auth_socket
    export GPG_TTY=$(tty)

    gpg-connect-agent 'UPDATESTARTUPTTY' /bye 1>/dev/null
    if [ $? -ne 0 ]; then
        c0rc_warn "error while updating startup tty for gpg-agent"
        return 1
    fi

    return 0
}
