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

function c0rc_secret_get() {
    if [ $# -ne 1 ]; then
        c0rc_err "one argument specifying secret name expected"
        return 1
    fi

    if ! command -v xsel &>/dev/null; then
        c0rc_bck_err "no command '${TXT_COLOR_YELLOW}xsel${TXT_COLOR_NONE}' available; possibly, you need to install it"
        return 1
    fi

    local secret_name="$1"
    local secret_file="$C0RC_SECRETS_DIR/$(basenc --base32hex <<<$secret_name)"
    if [ $? -ne 0 ]; then
        c0rc_err "error while encoding secret name"
        return 1
    elif [ ! -f $secret_file ]; then
        c0rc_err "no file for secret found"
        return 1
    fi

    local secret_decrypted="$(c0rc_gpg_decrypt "$secret_file")"
    if [ $? -ne 0 ]; then
        c0rc_err "error while decrypting secret"
        return 1
    fi

    xsel -ib <<<$secret_decrypted
    if [ $? -ne 0 ]; then
        c0rc_err "error while putting secret into clipboard"
        return 1
    else
        c0rc_info "secret put into clipboard"
        return 0
    fi
}

function c0rc_secret_set() {
    if [ $# -ne 1 ]; then
        c0rc_err "one argument specifying secret name expected"
        return 1
    fi

    if ! command -v kwrite &>/dev/null; then
        c0rc_bck_err "no command '${TXT_COLOR_YELLOW}kwrite${TXT_COLOR_NONE}' available; possibly, you need to install it"
        return 1
    fi

    local secret_name="$1"
    local secret_file="$C0RC_SECRETS_DIR/$(basenc --base32hex <<<$secret_name)"
    if [ $? -ne 0 ]; then
        c0rc_err "error while encoding secret name"
        return 1
    elif [ -e $secret_file ]; then
        c0rc_err "such secret name '${TXT_COLOR_YELLOW}$secret_name${TXT_COLOR_NONE}' already in use"
        return 1
    fi

    local secret_tmp_file=""
    trap [ ! -z $secret_tmp_file ] && [ -e $secret_tmp_file ] && rm -f $secret_tmp_file && c0rc_info "tmp file '${TXT_COLOR_YELLOW}$secret_tmp_file${TXT_COLOR_YELLOW}' removed" RETURN
    secret_tmp_file=$(mktemp)
    if [ $? -ne 0 ]; then
        c0rc_err "error while creating tmp file"
        return 1
    fi

    if [ ! kwrite "$secret_tmp_file" ] &>/dev/null; then
        c0rc_err "secret text editor has returned non-zero exit code"
        return 1
    elif [ $(stat --printf="%s" "$secret_tmp_file") -eq 0 ]; then
        c0rc_warn "secret temp file have zero length; nothing to save in secrets"
        return 0
    fi

    c0rc_gpg --encrypt --output "$secret_file" <$secret_tmp_file
    if [ $? -ne 0 ]; then
        c0rc_err "error while encrypting secret"
        return 1
    else
        c0rc_ok
        return 0
    fi
}
