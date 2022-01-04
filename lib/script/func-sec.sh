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

function c0rc_secret_name_to_file_name() {
    if [ $# -ne 1 ]; then
        c0rc_err "one argument specifying secret name expected"
        return 1
    fi

    local secret_name="$1"
    local secret_file="$(basenc --base32hex <<<$secret_name)$C0RC_PLAIN_TEXT_SECRET_FILE_NAME_EXT"
    if [ $? -ne 0 ]; then
        c0rc_err "error while encoding secret name '${TXT_COLOR_YELLOW}$secret_name${TXT_COLOR_NONE}'"
        return 1
    fi

    echo -n "$secret_file"

    return 0
}

function c0rc_secret_file_name_to_name() {
    if [ $# -ne 1 ]; then
        c0rc_err "one argument specifying secret file name expected"
        return 1
    fi

    local secret_file="$1"
    local secret_file_no_ext="$(echo -n "$secret_file" | sed "s/${C0RC_PLAIN_TEXT_SECRET_FILE_NAME_EXT}$//")"
    if [ $? -ne 0 ]; then
        c0rc_err "error while decoding secret file name '${TXT_COLOR_YELLOW}$secret_file${TXT_COLOR_NONE}'"
        return 1
    fi

    local secret_name="$(basenc --decode --base32hex <<<$secret_file_no_ext)"
    if [ $? -ne 0 ]; then
        c0rc_err "error while decoding secret file name '${TXT_COLOR_YELLOW}$secret_file_no_ext${TXT_COLOR_NONE}'"
        return 1
    fi

    echo -n "$secret_name"

    return 0
}

function c0rc_secret_get() {
    local stdout="n"
    local secret_name=""
    if [ $# -lt 1 ]; then
        c0rc_err "one argument specifying secret name expected"
        return 1
    elif [ $# -eq 1 ]; then
        secret_name="$1"
    elif [ $# -eq 2 ]; then
        secret_name="$1"
        if [ "$2" = "y" ] || [ "$2" = "stdout" ]; then
            stdout="y"
        else
            c0rc_err "second argument specifying output method has invalid value; 'y' or 'stdout' expected"
            return 1
        fi
    else
        c0rc_err "too many args; one argument specifying secret name expected"
        return 1
    fi

    if [ ! "$stdout" = "y" ]; then
        if ! command -v xsel &>/dev/null; then
            c0rc_bck_err "no command '${TXT_COLOR_YELLOW}xsel${TXT_COLOR_NONE}' available; possibly, you need to install it"
            return 1
        fi
    fi

    local secret_file="$C0RC_SECRETS_DIR/$(c0rc_secret_name_to_file_name "$secret_name")"
    if [ $? -ne 0 ]; then
        return 1
    elif [ ! -f $secret_file ]; then
        c0rc_err "no file for secret found"
        return 1
    fi

    local secret_decrypted="$(c0rc_gpg_decrypt "$secret_file" | sed -z -r 's/\n$//g')"
    if [ $? -ne 0 ]; then
        c0rc_err "error while decrypting secret"
        return 1
    fi

    if [ "$stdout" = "y" ]; then
        echo -n $secret_decrypted
    else
        echo -n $secret_decrypted | xsel -ib
        if [ $? -ne 0 ]; then
            c0rc_err "error while putting secret into clipboard"
            return 1
        else
            c0rc_info "secret put into clipboard"
            return 0
        fi
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
    local secret_out_file="$C0RC_SECRETS_DIR/$(c0rc_secret_name_to_file_name "$secret_name")"
    if [ $? -ne 0 ]; then
        return 1
    elif [ -e $secret_out_file ]; then
        c0rc_err "such secret name '${TXT_COLOR_YELLOW}$secret_name${TXT_COLOR_NONE}' already in use; that secret stores in '${TXT_COLOR_YELLOW}$secret_out_file${TXT_COLOR_NONE}' file"
        return 1
    fi

    local secret_in_file=$(mktemp)
    if [ $? -ne 0 ]; then
        c0rc_err "error while creating tmp file"
        rm -f $secret_in_file
        return 1
    fi

    c0rc_info "edit your secret with text editor (kwrite)..."
    local secret_edit_status=1
    kwrite "$secret_in_file" &>/dev/null && secret_edit_status=$?

    if [ $secret_edit_status -ne 0 ]; then
        c0rc_err "secret text editor has returned non-zero exit code"
        rm -f $secret_in_file
        return 1
    elif [ $(stat --printf="%s" "$secret_in_file") -eq 0 ]; then
        c0rc_warn "secret content have zero length; nothing to save"
        rm -f $secret_in_file
        return 0
    fi

    c0rc_info "encrypt and writeout your secret to '${TXT_COLOR_YELLOW}$secret_out_file${TXT_COLOR_NONE}'"
    c0rc_gpg_encrypt_to "$secret_in_file" "$secret_out_file"
    if [ $? -ne 0 ]; then
        c0rc_err "error while encrypting secret"
        rm -f $secret_in_file
        return 1
    else
        c0rc_ok
        rm -f $secret_in_file
        return 0
    fi
}

function c0rc_secret_file_get() {
    if [ $# -ne 1 ]; then
        c0rc_err "one argument specifying secret name expected"
        return 1
    fi

    local secret_name="$1"
    local secret_file="$C0RC_SECRETS_DIR/$(c0rc_secret_name_to_file_name "$secret_name")"
    if [ $? -ne 0 ]; then
        return 1
    fi

    print "$secret_file"

    return 0
}

function c0rc_secret_ls() {
    for secret_file in $(find "$C0RC_SECRETS_DIR" -maxdepth 1 -iname "*$C0RC_PLAIN_TEXT_SECRET_FILE_NAME_EXT" -type f); do
        local secret_file_base_name=$(basename "$secret_file")

        local secret_name="$(c0rc_secret_file_name_to_name "$secret_file_base_name")"
        if [ $? -ne 0 ]; then
            c0rc_warn "can't decode secret file name '${TXT_COLOR_YELLOW}$secret_file_base_name${TXT_COLOR_NONE}' as secret name"
        else
            c0rc_info "'${TXT_COLOR_YELLOW}$secret_name${TXT_COLOR_NONE}' -> '${TXT_COLOR_YELLOW}$secret_file${TXT_COLOR_NONE}'"
        fi
    done

    return 0
}
