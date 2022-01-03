function c0rc_otp_material() {
    if [ $# -ne 1 ]; then
        c0rc_bck_err "one argument specifying otp name expected"
        return 1
    fi

    echo "$(c0rc_gpg -u "${C0RC_GPG_KID}" -r "${C0RC_GPG_UID}" --decrypt "${C0RC_2FA_DIR}/$1")"
    if [ $? -ne 0 ]; then
        c0rc_err "error while gpg-decryption"
        return 1
    fi

    return 0
}

function c0rc_otp() {
    if [ $# -ne 1 ]; then
        c0rc_bck_err "one argument specifying otp name expected"
        return 1
    fi

    local descrypted_material="$(c0rc_otp_material $1)"
    if [ $? -ne 0 ]; then
        c0rc_err "error while decryption otp material"
        return 1
    fi

    local otp="$(oathtool -b --totp "$descrypted_material")"
    if [ $? -ne 0 ]; then
        c0rc_err "error evaluating otp"
        return 1
    fi

    c0rc_info $otp

    return 0
}

function c0rc_hash_default() {
    if [ $# -ne 1 ]; then
        c0rc_err "one argument specifying material to hash"
        return 1
    fi

    if ! command -v sha256 &>/dev/null; then
        c0rc_err "no command '${TXT_COLOR_YELLOW}sha256${TXT_COLOR_NONE}' available; possibly, you need to install it"
        return 1
    fi

    sha256 <<<$1 | xxd -p -c 32
    if [ $? -ne 0 ]; then
        c0rc_err "error while evaluating hash of specified string"
        return 1
    fi

    return 0
}
