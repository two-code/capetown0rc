function c0rc_docs_unlock() {
    c0rc_gocfs_unlock "$C0RC_WS_DOCS_ENC_SECRET_NAME" "$C0RC_WS_DOCS_ENC_DIR" "$C0RC_WS_DOCS_DIR"
    if [ $? -ne 0 ]; then
        return 1
    fi

    return 0
}

function c0rc_docs_lock() {
    c0rc_gocfs_lock "$C0RC_WS_DOCS_DIR"
    if [ $? -ne 0 ]; then
        return 1
    fi

    return 0
}

function c0rc_videss_unlock() {
    c0rc_gocfs_unlock "$C0RC_WS_VIDESS_ENC_SECRET_NAME" "$C0RC_WS_VIDESS_ENC_DIR" "$C0RC_WS_VIDESS_DIR"
    if [ $? -ne 0 ]; then
        return 1
    fi

    return 0
}

function c0rc_videss_lock() {
    c0rc_gocfs_lock "$C0RC_WS_VIDESS_DIR"
    if [ $? -ne 0 ]; then
        return 1
    fi

    return 0
}
