#!/bin/env bash

export C0RC_DIR="${C0RC_DIR:-"${HOME}/.capetown0rc"}"
export C0RC_SCRIPT_DIR="${C0RC_SCRIPT_DIR:-"${C0RC_DIR}/lib/script"}"
export C0RC_BIN_DIR="${C0RC_BIN_DIR:-"${C0RC_DIR}/bin"}"
export C0RC_TMP_DIR="${C0RC_BIN_DIR:-"${C0RC_DIR}/tmp"}"
export C0RC_GO_DIR="${C0RC_BIN_DIR:-"${C0RC_DIR}/go"}"

. $C0RC_SCRIPT_DIR/consts.sh
. $C0RC_SCRIPT_DIR/msg.sh
. $C0RC_SCRIPT_DIR/aliases.sh
. $C0RC_SCRIPT_DIR/func.sh

mkdir -p "${C0RC_BIN_DIR}"
if [ $? -ne 0 ]; then
    c0rc_warn "error while created dir $C0RC_BIN_DIR"
fi

PATH="${C0RC_BIN_DIR}:${HOME}/go/bin:${PATH}"

c0rc_sshgpg
