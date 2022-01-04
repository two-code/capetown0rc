function c0rc_gocfs_unlock() {
    local unlock_secret_name=""
    local backend_dir=""
    local frontend_dir=""
    if [ $# -ne 3 ]; then
        c0rc_err "some args are missing; expected args are: secret_name backend_dir frontend_dir"
        return 1
    else
        unlock_secret_name="$1"
        backend_dir="$2"
        frontend_dir="$3"
    fi

    if ! command -v gocryptfs &>/dev/null; then
        c0rc_err "no command '${TXT_COLOR_YELLOW}gocryptfs${TXT_COLOR_NONE}' available; possibly, you need to install it"
        return 1
    fi
    if ! command -v fusermount &>/dev/null; then
        c0rc_err "no command '${TXT_COLOR_YELLOW}fusermount${TXT_COLOR_NONE}' available; possibly, you need to install it"
        return 1
    fi

    c0rc_info "unlocking '${TXT_COLOR_YELLOW}$frontend_dir${TXT_COLOR_NONE}' directory: $C0RC_OP_PROGRESS"

    mkdir -p "$frontend_dir"
    if [ $? -ne 0 ]; then
        c0rc_err "error while creating directory '${TXT_COLOR_YELLOW}$frontend_dir${TXT_COLOR_NONE}'"
        c0rc_err "unlocking '${TXT_COLOR_YELLOW}$frontend_dir${TXT_COLOR_NONE}' directory: $C0RC_OP_FAIL"
        return 1
    fi

    gocryptfs -fsck -extpass "$C0RC_SCRIPT_DIR/ask-secret.sh" -extpass "$unlock_secret_name" "$backend_dir" >/dev/null
    if [ $? -ne 0 ]; then
        c0rc_warn "file system consistency check: $C0RC_OP_FAIL"
        c0rc_err "unlocking '${TXT_COLOR_YELLOW}$frontend_dir${TXT_COLOR_NONE}' directory: $C0RC_OP_FAIL"
        return 1
    else
        c0rc_info "file system consistency check: $C0RC_OP_OK"
    fi

    gocryptfs -extpass "$C0RC_SCRIPT_DIR/ask-secret.sh" -extpass "$unlock_secret_name" "$backend_dir" "$frontend_dir" >/dev/null
    if [ $? -ne 0 ]; then
        c0rc_err "unlocking '${TXT_COLOR_YELLOW}$frontend_dir${TXT_COLOR_NONE}' directory: $C0RC_OP_FAIL"
        return 1
    else
        c0rc_info "unlocking '${TXT_COLOR_YELLOW}$frontend_dir${TXT_COLOR_NONE}' directory: $C0RC_OP_OK"
        return 0
    fi
}

function c0rc_gocfs_lock() {
    local frontend_dir=""
    if [ $# -ne 1 ]; then
        c0rc_err "some args are missing; expected args are: frontend_dir"
        return 1
    else
        frontend_dir="$1"
    fi

    if ! command -v fusermount &>/dev/null; then
        c0rc_err "no command '${TXT_COLOR_YELLOW}fusermount${TXT_COLOR_NONE}' available; possibly, you need to install it"
        return 1
    fi

    c0rc_info "locking '${TXT_COLOR_YELLOW}$frontend_dir${TXT_COLOR_NONE}' directory: $C0RC_OP_PROGRESS"
    fusermount -u "$frontend_dir" >/dev/null
    if [ $? -ne 0 ]; then
        c0rc_err "locking '${TXT_COLOR_YELLOW}$frontend_dir${TXT_COLOR_NONE}' directory: $C0RC_OP_FAIL"
        return 1
    else
        c0rc_info "locking '${TXT_COLOR_YELLOW}$frontend_dir${TXT_COLOR_NONE}' directory: $C0RC_OP_OK"
        return 0
    fi
}
