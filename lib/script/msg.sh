function c0rc_err() {
    echo -e "${TXT_COLOR_RED}[$(date +'%Y-%m-%dT%H:%M:%S%z')] ERR:${TXT_COLOR_NONE} $*" >&2~
}

function c0rc_warn() {
    echo -e "${TXT_COLOR_YELLOW}[$(date +'%Y-%m-%dT%H:%M:%S%z')] WARN:${TXT_COLOR_NONE} $*" >&2
}

function c0rc_info() {
    echo -e "${TXT_COLOR_CYAN}[$(date +'%Y-%m-%dT%H:%M:%S%z')] INFO:${TXT_COLOR_NONE} $*"
}

function c0rc_ok() {
    c0rc_info "OK"
}
