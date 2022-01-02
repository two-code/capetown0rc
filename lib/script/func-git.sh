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

function gg_msg() {
    local log_msg=$(git log -n 1 --format=%B)
    if [ $? -ne 0 ]; then
        return 1
    fi
    print $log_msg

    return 0
}

function gg_cmt_with_last_msg() {
    local log_msg="$(gg_msg)"
    if [ $? -ne 0 ]; then
        gg_err "error while comitting"
        return 1
    fi

    gg_cmt $1 "$log_msg"
    if [ $? -ne 0 ]; then
        return 1
    fi

    return 0
}
