#!/bin/env zsh

export TXT_COLOR_NONE="${TXT_COLOR_NONE:-\033[0m}"
export TXT_COLOR_RED="${TXT_COLOR_RED:-\033[1;31m}"

if [ $# -ne 1 ]; then
    echo -e "${TXT_COLOR_RED}[$(date +'%Y-%m-%dT%H:%M:%S%z')] ERR:${TXT_COLOR_NONE} argument specifying secret name is missing" >&2
    exit 1
fi

source "$(dirname "$0")/entry-point.sh"
if [ $? -ne 0 ]; then
    echo -e "${TXT_COLOR_RED}[$(date +'%Y-%m-%dT%H:%M:%S%z')] ERR:${TXT_COLOR_NONE} error while sourcing c0rc entry-point script" >&2
    exit 1
fi

c0rc_secret_get "$1" stdout
if [ $? -ne 0 ]; then
    c0rc_err "error while getting secret"
    exit 1
fi
