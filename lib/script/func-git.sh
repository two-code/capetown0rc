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
    gg_info "... ${TXT_COLOR_GREEN}OK${TXT_COLOR_NONE}"
    return 0
}

function gg_refname() {
    local ref_name="$(git rev-parse --abbrev-ref HEAD)"
    if [ $? -ne 0 ]; then
        return 1
    fi

    print $ref_name

    return 0
}

function gg_cmt() {
    local ref_name=""
    local commit_msg=""

    if [ $# -eq 2 ]; then
        ref_name="$1"
        commit_msg="$2"
    elif [ $# -eq 1 ]; then
        commit_msg="$1"

        ref_name="$(git rev-parse --abbrev-ref HEAD)"
        if [ $? -ne 0 ]; then
            gg_err "error while getting HEAD reference name"
            return 1
        fi
    else
        gg_err "one or two argument expected"
        return 1
    fi

    git add --all &&
        git commit -m "$commit_msg" --allow-empty &&
        git push origin HEAD:$ref_name
    if [ $? -ne 0 ]; then
        gg_err "error while comitting/pushing"
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

function gg_stat() {
    git status --long -b
    if [ $? -ne 0 ]; then
        return 1
    fi

    return 0
}

function gg_del_tag() {
    gg_info "delete tag matching grep pattern '$1'..."

    local tags=$(git tag -l | grep -E "$1" | tr '\n' ' ')

    for t in $(<<<$tags); do
        git tag -d $t
        if [ $? -ne 0 ]; then
            gg_warn "error while deleting tag '$t'"
        fi
    done

    for t in $(<<<$tags); do
        git push origin :refs/tags/$t
        if [ $? -ne 0 ]; then
            gg_warn "error while deleting tag '$t'"
        fi
    done

    gg_ok

    return 0
}

function gg_add_tag() {
    git tag -a "$1" -m "version $1" &&
        git push origin "$1"
    if [ $? -ne 0 ]; then
        gg_err "error while adding tag"
        return 1
    fi

    gg_ok

    return 0
}

function gg_ls_tag() {
    gg_info "list tags matching grep pattern '$1'..."

    git tag -l | sort | grep -E "$1"

    gg_ok

    return 0
}
