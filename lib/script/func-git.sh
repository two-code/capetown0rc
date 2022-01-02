function gg_err() {
    c0rc_err "[git]: $1"
    return 0
}

function gg_info() {
    c0rc_info "[git]: $1"
    return 0
}

function gg_warn() {
    c0rc_warn "[git]: $1"
    return 0
}

function gg_ok() {
    gg_info "OK"
    return 0
}

function gg_cmt() {
    git add --all &&
        git commit -m "$2" --allow-empty &&
        git push origin HEAD:$1
    if [ $? -ne 0 ]; then
        gg_err "error while comitting"
        return 1
    fi

    gg_ok

    return 0
}
