function c0rc_docs_unlock() {
    if ! command -v gocryptfs &>/dev/null; then
        c0rc_err "no command '${TXT_COLOR_YELLOW}gocryptfs${TXT_COLOR_NONE}' available; possibly, you need to install it"
        return 1
    fi
    if ! command -v fusermount &>/dev/null; then
        c0rc_err "no command '${TXT_COLOR_YELLOW}fusermount${TXT_COLOR_NONE}' available; possibly, you need to install it"
        return 1
    fi

    c0rc_info "unlocking '${TXT_COLOR_YELLOW}$C0RC_WS_DOCS_DIR${TXT_COLOR_NONE}' directory: $C0RC_OP_PROGRESS"
    gocryptfs -rw -extpass "$C0RC_SCRIPT_DIR/docs-askpass.sh" "$C0RC_WS_DOCS_ENC_DIR" "$C0RC_WS_DOCS_DIR" >/dev/null
    if [ $? -ne 0 ]; then
        c0rc_err "unlocking '${TXT_COLOR_YELLOW}$C0RC_WS_DOCS_DIR${TXT_COLOR_NONE}' directory: $C0RC_OP_FAIL"
        return 1
    else
        c0rc_info "unlocking '${TXT_COLOR_YELLOW}$C0RC_WS_DOCS_DIR${TXT_COLOR_NONE}' directory: $C0RC_OP_OK"
        return 0
    fi
}

function c0rc_docs_lock() {
    if ! command -v fusermount &>/dev/null; then
        c0rc_err "no command '${TXT_COLOR_YELLOW}fusermount${TXT_COLOR_NONE}' available; possibly, you need to install it"
        return 1
    fi

    c0rc_info "locking '${TXT_COLOR_YELLOW}$C0RC_WS_DOCS_DIR${TXT_COLOR_NONE}' directory: $C0RC_OP_PROGRESS"
    fusermount -u "$C0RC_WS_DOCS_DIR" >/dev/null
    if [ $? -ne 0 ]; then
        c0rc_err "locking '${TXT_COLOR_YELLOW}$C0RC_WS_DOCS_DIR${TXT_COLOR_NONE}' directory: $C0RC_OP_FAIL"
        return 1
    else
        c0rc_info "locking '${TXT_COLOR_YELLOW}$C0RC_WS_DOCS_DIR${TXT_COLOR_NONE}' directory: $C0RC_OP_OK"
        return 0
    fi
}
