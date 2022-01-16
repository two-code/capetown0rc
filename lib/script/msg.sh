function c0rc_print_cnt() {
    if (($C0RC_MSG_CNT < 100)); then
        echo -n "$(printf '%3d' $C0RC_MSG_CNT)"
    elif (($C0RC_MSG_CNT < 1000)); then
        echo -n "$(printf '%4d' $C0RC_MSG_CNT)"
    elif (($C0RC_MSG_CNT < 10000)); then
        echo -n "$(printf '%5d' $C0RC_MSG_CNT)"
    elif (($C0RC_MSG_CNT < 100000)); then
        echo -n "$(printf '%6d' $C0RC_MSG_CNT)"
    else
        echo -n "$(printf '%7d' $C0RC_MSG_CNT)"
    fi

    return 0
}

function c0rc_err() {
    ((C0RC_MSG_CNT++))
    echo -e "${TXT_COLOR_ERR}[${TXT_COLOR_WHITE}$(c0rc_print_cnt)${TXT_COLOR_ERR} $(date +'%Y-%m-%dT%H:%M:%S%z')] ERR:${TXT_COLOR_NONE} $*" >&2
}

function c0rc_warn() {
    ((C0RC_MSG_CNT++))
    echo -e "${TXT_COLOR_WARN}[${TXT_COLOR_WHITE}$(c0rc_print_cnt)${TXT_COLOR_WARN} $(date +'%Y-%m-%dT%H:%M:%S%z')] WRN:${TXT_COLOR_NONE} $*" >&2
}

function c0rc_info() {
    ((C0RC_MSG_CNT++))
    echo -e "${TXT_COLOR_CYAN}[${TXT_COLOR_WHITE}$(c0rc_print_cnt)${TXT_COLOR_CYAN} $(date +'%Y-%m-%dT%H:%M:%S%z')] INF:${TXT_COLOR_NONE} $*"
}

function c0rc_splitter() {
    echo -e "${TXT_SPLITTER_COLOR}$TXT_SPLITTER${TXT_SPLITTER_COLOR}"
}

function c0rc_ok() {
    c0rc_info "$C0RC_OP_OK"
}
