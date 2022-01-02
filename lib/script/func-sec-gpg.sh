function c0rc_gpg() {
    gpg2 $(<<<$C0RC_GPG_CMD_OPTS) $*
    if [ $? -ne 0 ]; then
        return 1
    fi

    return 0
}

function c0rc_gpg_decrypt() {
    echo "$(c0rc_gpg -u "${C0RC_GPG_KID}" -r "${C0RC_GPG_UID}" --decrypt "${C0RC_2FA_DIR}/$1")"
    if [ $? -ne 0 ]; then
        c0rc_err "error while gpg-decryption"
        return 1
    fi

    return 0
}
