function c0rc_gpg() {
    gpg2 $(<<<$C0RC_GPG_CMD_OPTS) $*
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
        c0rc_err "error while gpg secret decryption"
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
        c0rc_err "error while gpg secret decryption"
        return 1
    fi

    return 0
}
