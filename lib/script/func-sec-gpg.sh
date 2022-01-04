function c0rc_gpg() {
    if ! command -v gpg2 &>/dev/null; then
        c0rc_err "no command '${TXT_COLOR_YELLOW}gpg2${TXT_COLOR_NONE}' available; possibly, you need to install it"
        return 1
    fi

    gpg2 $(<<<$C0RC_GPG_CMD_OPTS) "$@"
    if [ $? -ne 0 ]; then
        return 1
    fi

    return 0
}

function c0rc_gpg_decrypt_to() {
    if [ $# -ne 2 ]; then
        c0rc_bck_err "two arguments specifying gpg material input and decryption output expected"
        return 1
    fi

    c0rc_gpg -u "${C0RC_GPG_KID}" -r "${C0RC_GPG_UID}" --output "$2" --decrypt "$1"
    if [ $? -ne 0 ]; then
        c0rc_err "error while executing gpg decryption"
        return 1
    fi

    return 0
}

function c0rc_gpg_decrypt() {
    if [ $# -ne 1 ]; then
        c0rc_bck_err "one argument specifying gpg material input expected"
        return 1
    fi

    c0rc_gpg -u "${C0RC_GPG_KID}" -r "${C0RC_GPG_UID}" --decrypt "$1"
    if [ $? -ne 0 ]; then
        c0rc_err "error while executing gpg decryption"
        return 1
    fi

    return 0
}

function c0rc_gpg_encrypt_to() {
    if [ $# -ne 2 ]; then
        c0rc_bck_err "two arguments specifying input and output expected"
        return 1
    fi

    c0rc_gpg -u "${C0RC_GPG_KID}" -r "${C0RC_GPG_UID}" --output "$2" --encrypt "$1"
    if [ $? -ne 0 ]; then
        c0rc_err "error while executing gpg encryption"
        return 1
    fi

    return 0
}

function c0rc_gpg_export_pri() {
    local file_name="$C0RC_SECRETS_GPG_DIR/pri_keys-$(hostname)-$(date '+%Y_%m_%dT%H_%M_%S%z')-$(c0rc_gen_hex32bit).asc"
    if [ $? -ne 0 ]; then
        c0rc_err "error while generating output file name"
    fi

    c0rc_gpg -a --export-secret-keys >"$file_name"
    if [ $? -ne 0 ]; then
        c0rc_err "expor gpg private keys ('${TXT_COLOR_YELLOW}$file_name${TXT_COLOR_NONE}'): $C0RC_OP_FAIL"
        return 1
    else
        c0rc_info "expor gpg private keys ('${TXT_COLOR_YELLOW}$file_name${TXT_COLOR_NONE}'): $C0RC_OP_OK"
        return 0
    fi
}

function c0rc_gpg_export_pub() {
    local file_name="$C0RC_SECRETS_GPG_DIR/pub_keys-$(hostname)-$(date '+%Y_%m_%dT%H_%M_%S%z')-$(c0rc_gen_hex32bit).asc"
    if [ $? -ne 0 ]; then
        c0rc_err "error while generating output file name"
    fi

    c0rc_gpg -a --export >"$file_name"
    if [ $? -ne 0 ]; then
        c0rc_err "expor gpg public keys ('${TXT_COLOR_YELLOW}$file_name${TXT_COLOR_NONE}'): $C0RC_OP_FAIL"
        return 1
    else
        c0rc_info "expor gpg public keys ('${TXT_COLOR_YELLOW}$file_name${TXT_COLOR_NONE}'): $C0RC_OP_OK"
        return 0
    fi
}
