function c0rc_dir_unseal() {
    if [ $# -ne 1 ]; then
        c0rc_err "one argument specifying dir expected"
        return 1
    fi

    local dir="$1"
    local msg_prologue="unsealing dir '${TXT_COLOR_YELLOW}$dir${TXT_COLOR_NONE}':"

    c0rc_info "$msg_prologue $C0RC_OP_PROGRESS"

    sudo chattr -i -R "$dir"
    if [ $? -ne 0 ]; then
        c0rc_err "error while unsetting imuutability attribute"
        c0rc_err "$msg_prologue $C0RC_OP_FAIL"
        return 1
    fi

    sudo chmod ug+rwx -R "$dir"
    if [ $? -ne 0 ]; then
        c0rc_err "error while unsetting permissions"
        c0rc_err "$msg_prologue $C0RC_OP_FAIL"
        return 1
    fi

    sudo chown "$(id -un)":"$(id -gn)" -R "$dir"
    if [ $? -ne 0 ]; then
        c0rc_err "error while setting owner"
        c0rc_err "$msg_prologue $C0RC_OP_FAIL"
        return 1
    fi

    c0rc_info "$msg_prologue $C0RC_OP_OK"

    return 0
}

function c0rc_dir_seal() {
    if [ $# -ne 1 ]; then
        c0rc_err "one argument specifying dir expected"
        return 1
    fi

    local dir="$1"
    local msg_prologue="sealing dir '${TXT_COLOR_YELLOW}$dir${TXT_COLOR_NONE}':"

    c0rc_info "$msg_prologue $C0RC_OP_PROGRESS"

    sudo chattr -i -R "$dir"
    if [ $? -ne 0 ]; then
        c0rc_err "error while unsetting imuutability attribute"
        c0rc_err "$msg_prologue $C0RC_OP_FAIL"
        return 1
    fi

    sudo chown "$(id -un)":"$(id -gn)" -R "$dir"
    if [ $? -ne 0 ]; then
        c0rc_err "error while setting owner"
        c0rc_err "$msg_prologue $C0RC_OP_FAIL"
        return 1
    fi

    sudo chmod a-rwx -R "$dir"
    if [ $? -ne 0 ]; then
        c0rc_err "error while unsetting permissions"
        c0rc_err "$msg_prologue $C0RC_OP_FAIL"
        return 1
    fi

    sudo chmod u+rx -R "$dir"
    if [ $? -ne 0 ]; then
        c0rc_err "error while setting user read+exec permissions"
        c0rc_err "$msg_prologue $C0RC_OP_FAIL"
        return 1
    fi

    sudo chattr +i -R "$dir"
    if [ $? -ne 0 ]; then
        c0rc_err "error while setting imuutability attribute"
        c0rc_err "$msg_prologue $C0RC_OP_FAIL"
        return 1
    fi

    c0rc_info "$msg_prologue $C0RC_OP_OK"

    return 0
}

function c0rc_secrets_2fa_dir_seal() {
    c0rc_dir_seal "$C0RC_SECRETS_DIR"
    c0rc_dir_seal "$C0RC_2FA_DIR"

    return 0
}

function c0rc_secrets_dir_seal() {
    c0rc_dir_seal "$C0RC_SECRETS_DIR"
    if [ $# -ne 0 ]; then
        return 1
    fi

    return 0
}

function c0rc_secrets_dir_unseal() {
    c0rc_dir_unseal "$C0RC_SECRETS_DIR"
    if [ $# -ne 0 ]; then
        return 1
    fi

    return 0
}

function c0rc_otp_material() {
    if [ $# -ne 1 ]; then
        c0rc_err "one argument specifying otp name expected"
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
        c0rc_err "one argument specifying otp name expected"
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

    sha256 <<<$1 | xxd -p -c 32 | head -c 12
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
            c0rc_err "no command '${TXT_COLOR_YELLOW}xsel${TXT_COLOR_NONE}' available; possibly, you need to install it"
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
        c0rc_err "no command '${TXT_COLOR_YELLOW}kwrite${TXT_COLOR_NONE}' available; possibly, you need to install it"
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
    c0rc_secrets_dir_unseal
    c0rc_gpg_encrypt_to "$secret_in_file" "$secret_out_file"
    if [ $? -ne 0 ]; then
        c0rc_err "error while encrypting secret"
        rm -f $secret_in_file
        return 1
    fi
    c0rc_secrets_dir_seal

    rm -f $secret_in_file
    c0rc_ok

    return 0
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
    for secret_file in $(find "$C0RC_SECRETS_DIR" -maxdepth 1 -iname "*$C0RC_PLAIN_TEXT_SECRET_FILE_NAME_EXT" -type f | LC_ALL=C sort); do
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

function c0rc_secv_legacy_open() {
    local mount_point="$C0RC_WS_SECV_LEGACY_DIR"
    local loop_device="/dev/loop3000"
    local loop_img="$C0RC_SECV_LEGACY_IMG"
    local mapper_name="secv-legacy"
    local mapper_name_full="/dev/mapper/$mapper_name"
    local last_up_mark_file="$mount_point/.last-up.txt"
    local encryption_key="$C0RC_SECRETS_DIR/secv-legacy-key.gpg"

    # mount point(s) {{{
    sudo mkdir -p "$mount_point" &&
        sudo chown "$(id -un)":"$(id -gn)" "$mount_point"
    if [ $? -ne 0 ]; then
        c0rc_err "error while creating and tuning mount point '${TXT_COLOR_YELLOW}$mount_point${TXT_COLOR_NONE}'"
        return 1
    fi
    # }}}

    # loop device {{{
    sudo losetup $loop_device $loop_img
    if [ $? -ne 0 ]; then
        c0rc_err "error while setup loop device"
        return 1
    fi
    # }}}

    # luks device {{{
    c0rc_gpg_decrypt "$encryption_key" |
        sudo cryptsetup --key-file=- --key-slot=$C0RC_LUKS_DEFAULT_KEYSLOT --perf-no_read_workqueue --perf-no_write_workqueue --persistent luksOpen $loop_device $mapper_name
    if [ $? -ne 0 ]; then
        c0rc_err "error while opening luks device"
        c0rc_secv_legacy_close
        return 1
    fi
    # }}}

    # mount {{{
    sudo mount $mapper_name_full "$mount_point"
    if [ $? -ne 0 ]; then
        c0rc_err "error while mounting luks device"
        c0rc_secv_legacy_close
        return 1
    fi

    sudo chown "$(id -un)":"$(id -gn)" "$mount_point"
    if [ $? -ne 0 ]; then
        c0rc_err "error while tuning permissions/ownership for luks device's file system root"
        c0rc_secv_legacy_close
        return 1
    fi
    # }}}

    # output info {{{
    c0rc_info "previous up '${TXT_COLOR_YELLOW}$(sudo cat "$last_up_mark_file" || echo -n '<no data>')'${TXT_COLOR_NONE}"
    date '+%Y-%m-%dT%H:%M:%S%z, %A %b %d, %s' | sudo tee $last_up_mark_file >/dev/null
    if [ $? -ne 0 ]; then
        c0rc_warn "error while writing out mark of device up"
    fi

    local luks_device_uuid_loc=$(lsblk -dn -o UUID $mapper_name_full)
    if [ $? -ne 0 ]; then
        c0rc_err "error while getting luks device uuid"
        c0rc_secv_legacy_close
        return 1
    fi

    c0rc_info "luks device uuid '${TXT_COLOR_YELLOW}$luks_device_uuid_loc${TXT_COLOR_NONE}'"
    c0rc_info "mount point '${TXT_COLOR_YELLOW}$mount_point${TXT_COLOR_NONE}'"
    # }}}

    c0rc_ok

    return 0
}

function c0rc_secv_legacy_close() {
    local mount_point="$C0RC_WS_SECV_LEGACY_DIR"
    local loop_device="/dev/loop3000"
    local mapper_name="secv-legacy"

    # unmount {{{
    sudo sync -f
    if [ $? -ne 0 ]; then
        c0rc_warn "error while syncing fs"
    fi

    sudo umount "$mount_point"
    if [ $? -ne 0 ]; then
        c0rc_warn "error while unmounting luks device"
    fi
    # }}}

    # luks device {{{
    sudo cryptsetup close $mapper_name
    if [ $? -ne 0 ]; then
        c0rc_warn "error while closing luks device"
    fi
    # }}}

    # loop device {{{
    sudo losetup -d $loop_device
    if [ $? -ne 0 ]; then
        c0rc_warn "error while closing loop device"
    fi
    # }}}

    c0rc_ok

    return 0
}
# container_uuid_out
function c0rc_luks_init_params() {
    while :; do
        case $1 in
        --mount_point=?*)
            mount_point=${1#*=}
            ;;
        --container_name=?*)
            container_name=${1#*=}
            ;;
        --container_uuid_out=?*)
            container_uuid_out=${1#*=}
            ;;
        --)
            shift
            break
            ;;
        -?*)
            c0rc_err "unknown parameter '${TXT_COLOR_YELLOW}$1${TXT_COLOR_NONE}'"
            return 1
            ;;
        *)
            break
            ;;
        esac
        shift
    done

    if [ -z "$container_name" ]; then
        c0rc_err "no container name specified; use '${TXT_COLOR_YELLOW}--container_name${TXT_COLOR_NONE}' parameter"
        return 1
    fi

    if [ -z "$mount_point" ]; then
        mount_point="/mnt/$container_name"
    fi

    ramfs_mount_point="/mnt/ramfs_$(c0rc_hash_default "${C0RC_SHELL_SALT}_$container_name")"
    if [ $? -ne 0 ]; then
        c0rc_err "error while generating ram-fs mount point"
        return 1
    fi

    integrity_key="${C0RC_SECRETS_DIR}/${container_name}-ikey.gpg"
    integrity_key_raw="${ramfs_mount_point}/${container_name}-ikey"
    integrity_mapper_name="${container_name}_int"
    integrity_mapper_full="/dev/mapper/${integrity_mapper_name}"

    encryption_key="${C0RC_SECRETS_DIR}/${container_name}-key.gpg"
    encryption_key_raw="${ramfs_mount_point}/${container_name}-key"
    encryption_mapper_name="${container_name}_enc"
    encryption_mapper_full="/dev/mapper/${encryption_mapper_name}"

    header="${C0RC_SECRETS_DIR}/${container_name}-header.gpg"
    header_raw="${ramfs_mount_point}/${container_name}-header"

    partition_label="${container_name}-vault"
    local backend_device_rel=$(readlink "/dev/disk/by-partlabel/$partition_label")
    if [ $? -ne 0 ]; then
        c0rc_err "error while resolving disk by partition label '${TXT_COLOR_YELLOW}$partition_label${TXT_COLOR_NONE}'"
        return 1
    elif [ -z "$backend_device_rel" ]; then
        c0rc_err "partition label '${TXT_COLOR_YELLOW}$partition_label${TXT_COLOR_NONE}' resolved to empty disk path"
        return 1
    fi
    backend_device="/dev/$(basename $backend_device_rel)"
    if [ $? -ne 0 ]; then
        c0rc_err "error while resolving disk by partition label '${TXT_COLOR_YELLOW}${partition_label}${TXT_COLOR_NONE}'"
        return 1
    fi

    last_up_mark_file="${mount_point}/.last-up.txt"

    if [ "$C0RC_LUKS_OUTPUT_INIT_PARAMS" = "y" ]; then
        c0rc_info "luks container params:"
        echo -e "\tbackend_device_rel: ${TXT_COLOR_YELLOW}${backend_device_rel}${TXT_COLOR_NONE}"
        echo -e "\tbackend_device: ${TXT_COLOR_YELLOW}${backend_device}${TXT_COLOR_NONE}"
        echo -e "\tcontainer_name: ${TXT_COLOR_YELLOW}${container_name}${TXT_COLOR_NONE}"
        echo -e "\tcontainer_uuid_out: ${TXT_COLOR_YELLOW}${container_uuid_out}${TXT_COLOR_NONE}"
        echo -e "\tencryption_key_raw: ${TXT_COLOR_YELLOW}${encryption_key_raw}${TXT_COLOR_NONE}"
        echo -e "\tencryption_key: ${TXT_COLOR_YELLOW}${encryption_key}${TXT_COLOR_NONE}"
        echo -e "\tencryption_mapper_full: ${TXT_COLOR_YELLOW}${encryption_mapper_full}${TXT_COLOR_NONE}"
        echo -e "\tencryption_mapper_name: ${TXT_COLOR_YELLOW}${encryption_mapper_name}${TXT_COLOR_NONE}"
        echo -e "\theader_raw: ${TXT_COLOR_YELLOW}${header_raw}${TXT_COLOR_NONE}"
        echo -e "\theader: ${TXT_COLOR_YELLOW}${header}${TXT_COLOR_NONE}"
        echo -e "\tintegrity_key_raw: ${TXT_COLOR_YELLOW}${integrity_key_raw}${TXT_COLOR_NONE}"
        echo -e "\tintegrity_key: ${TXT_COLOR_YELLOW}${integrity_key}${TXT_COLOR_NONE}"
        echo -e "\tintegrity_mapper_full: ${TXT_COLOR_YELLOW}${integrity_mapper_full}${TXT_COLOR_NONE}"
        echo -e "\tintegrity_mapper_name: ${TXT_COLOR_YELLOW}${integrity_mapper_name}${TXT_COLOR_NONE}"
        echo -e "\tlast_up_mark_file: ${TXT_COLOR_YELLOW}${last_up_mark_file}${TXT_COLOR_NONE}"
        echo -e "\tmount_point: ${TXT_COLOR_YELLOW}${mount_point}${TXT_COLOR_NONE}"
        echo -e "\tpartition_label: ${TXT_COLOR_YELLOW}${partition_label}${TXT_COLOR_NONE}"
        echo -e "\tramfs_mount_point: ${TXT_COLOR_YELLOW}${ramfs_mount_point}${TXT_COLOR_NONE}"
    fi

    return 0
}

function c0rc_luks_close() {
    # init params {{{
    local backend_device=""
    local container_name=""
    local container_uuid_out=""
    local encryption_key_raw=""
    local encryption_key=""
    local encryption_mapper_full=""
    local encryption_mapper_name=""
    local header_raw=""
    local header=""
    local integrity_key_raw=""
    local integrity_key=""
    local integrity_mapper_full=""
    local integrity_mapper_name=""
    local last_up_mark_file=""
    local mount_point=""
    local partition_label=""
    local ramfs_mount_point=""

    c0rc_luks_init_params "$@"
    if [ $? -ne 0 ]; then
        return 1
    fi
    # }}}

    # unmount device {{{
    c0rc_info "unmount '${TXT_COLOR_YELLOW}$mount_point${TXT_COLOR_NONE}': $C0RC_OP_PROGRESS"

    sudo sync -f
    if [ $? -ne 0 ]; then
        c0rc_warn "error while syncing fs"
    fi

    sudo umount "$mount_point"
    if [ $? -ne 0 ]; then
        c0rc_warn "error while unmounting '${TXT_COLOR_YELLOW}$mount_point${TXT_COLOR_NONE}'"
    else
        c0rc_info "unmount '${TXT_COLOR_YELLOW}$mount_point${TXT_COLOR_NONE}': $C0RC_OP_OK"
    fi
    # }}}

    # luks device {{{
    c0rc_info "close luks device: $C0RC_OP_PROGRESS"

    sudo cryptsetup close $encryption_mapper_name
    if [ $? -ne 0 ]; then
        c0rc_warn "error while closing luks device"
    else
        c0rc_info "close luks device: $C0RC_OP_OK"
    fi
    # }}}

    # integrity device {{{
    c0rc_info "close integrity device: $C0RC_OP_PROGRESS"

    sudo integritysetup close "$integrity_mapper_name"
    if [ $? -ne 0 ]; then
        c0rc_warn "error while closing integrity device"
    else
        c0rc_info "close integrity device: $C0RC_OP_OK"
    fi
    # }}}

    return 0

}

function c0rc_luks_open() {
    # init params {{{
    local backend_device=""
    local container_name=""
    local container_uuid_out=""
    local encryption_key_raw=""
    local encryption_key=""
    local encryption_mapper_full=""
    local encryption_mapper_name=""
    local header_raw=""
    local header=""
    local integrity_key_raw=""
    local integrity_key=""
    local integrity_mapper_full=""
    local integrity_mapper_name=""
    local last_up_mark_file=""
    local mount_point=""
    local partition_label=""
    local ramfs_mount_point=""

    c0rc_luks_init_params "$@"
    if [ $? -ne 0 ]; then
        return 1
    fi
    # }}}

    # mounts {{{
    sudo mkdir -p "$mount_point" &&
        sudo chown "$(id -un)":"$(id -gn)" "$mount_point" &&
        sudo mkdir -p "$ramfs_mount_point" &&
        sudo chown "$(id -un)":"$(id -gn)" "$ramfs_mount_point"
    if [ $? -ne 0 ]; then
        c0rc_err "error while creating and tuning mount points"
        sudo rm -fdr "$ramfs_mount_point"
        return 1
    fi

    sudo mount -t ramfs ramfs "$ramfs_mount_point" &&
        sudo chown "$(id -un)":"$(id -gn)" "$ramfs_mount_point" &&
        sudo chmod a-rwx "$ramfs_mount_point" &&
        sudo chmod u+rwx "$ramfs_mount_point"
    if [ $? -ne 0 ]; then
        c0rc_err "error while mounting ramfs"
        sudo rm -fdr "$ramfs_mount_point"
        return 1
    fi
    sudo df "$ramfs_mount_point" >/dev/null
    if [ $? -ne 0 ]; then
        c0rc_err "error while mounting ramfs: file system mount check failed"
        sudo rm -fdr "$ramfs_mount_point"
        return 1
    fi
    # }}}

    # integrity device {{{
    c0rc_info "open integrity device: $C0RC_OP_PROGRESS"

    c0rc_gpg_decrypt_to "$integrity_key" "$integrity_key_raw"
    if [ $? -ne 0 ]; then
        c0rc_err "error while decrypting integrity key"
        sudo umount -f "$ramfs_mount_point" &&
            sudo rm -fdr "$ramfs_mount_point"
        return 1
    fi

    sudo integritysetup \
        open "$backend_device" "$integrity_mapper_name" \
        --integrity=hmac-sha256 \
        --integrity-key-file="$integrity_key_raw" \
        --integrity-key-size=32
    if [ $? -ne 0 ]; then
        c0rc_err "error while opening integrity device"
        sudo umount -f "$ramfs_mount_point" &&
            sudo rm -fdr "$ramfs_mount_point"
        return 1
    fi

    c0rc_info "open integrity device: $C0RC_OP_OK"
    # }}}

    # luks device {{{
    c0rc_info "open luks device: $C0RC_OP_PROGRESS"

    c0rc_gpg_decrypt_to "$header" "$header_raw"
    if [ $? -ne 0 ]; then
        c0rc_err "error while decrypting luks device header"
        c0rc_luks_close --container_name="$container_name" --mount_point="$mount_point"
        return 1
    fi

    c0rc_gpg_decrypt "$encryption_key" |
        sudo cryptsetup \
            --key-file=- \
            --key-slot=$C0RC_LUKS_DEFAULT_KEYSLOT \
            --header="$header_raw" \
            --perf-no_read_workqueue \
            --perf-no_write_workqueue \
            --persistent \
            luksOpen $integrity_mapper_full $encryption_mapper_name
    if [ $? -ne 0 ]; then
        c0rc_err "error while opening luks device"
        c0rc_luks_close --container_name="$container_name" --mount_point="$mount_point"
        return 1
    fi

    c0rc_info "open luks device: $C0RC_OP_OK"
    # }}}

    # mount {{{
    c0rc_info "mount luks device to '${TXT_COLOR_YELLOW}$mount_point${TXT_COLOR_NONE}': $C0RC_OP_PROGRESS"

    sudo mount -t $C0RC_BCK_VOLUME_DEFAULT_FS "$encryption_mapper_full" "$mount_point"
    if [ $? -ne 0 ]; then
        c0rc_err "error while mounting luks device"
        c0rc_luks_close --container_name="$container_name" --mount_point="$mount_point"
        return 1
    fi

    sudo chown "$(id -un)":"$(id -gn)" "$mount_point"
    if [ $? -ne 0 ]; then
        c0rc_err "error while tuning permissions/ownership for luks device's file system root"
        c0rc_luks_close --container_name="$container_name" --mount_point="$mount_point"
        return 1
    fi

    c0rc_info "mount luks device: $C0RC_OP_OK"
    # }}}

    # unmount ramfs {{{
    sudo umount -f "$ramfs_mount_point" &&
        sudo rm -fdr "$ramfs_mount_point"
    if [ $? -ne 0 ]; then
        c0rc_warn "error while unmounting ramfs"
    fi
    # }}}

    # output info {{{
    c0rc_info "previous up '${TXT_COLOR_YELLOW}$(sudo cat "$last_up_mark_file" 2>/dev/null || echo -n '<no data>')'${TXT_COLOR_NONE}"
    date '+%Y-%m-%dT%H:%M:%S%z, %A %b %d, %s' | sudo tee $last_up_mark_file >/dev/null
    if [ $? -ne 0 ]; then
        c0rc_warn "error while writing out mark of device up"
    fi

    local luks_device_uuid_loc=$(lsblk -dn -o UUID "$encryption_mapper_full")
    if [ $? -ne 0 ]; then
        c0rc_err "error while getting luks device uuid"
        c0rc_luks_close --container_name="$container_name" --mount_point="$mount_point"
        return 1
    fi

    c0rc_info "luks device uuid '${TXT_COLOR_YELLOW}$luks_device_uuid_loc${TXT_COLOR_NONE}'"
    c0rc_info "mount point '${TXT_COLOR_YELLOW}$mount_point${TXT_COLOR_NONE}'"

    if [ ! -z "$container_uuid_out" ]; then
        eval "$container_uuid_out=$luks_device_uuid_loc"
    fi
    # }}}

    return 0
}

function c0rc_luks_init_fail_clean() {
    c0rc_warn "c0rc_luks_init_fail_clean: not implemented yet"
    return 0
}

function c0rc_luks_init() {
    # init params {{{
    local backend_device=""
    local container_name=""
    local container_uuid_out=""
    local encryption_key_raw=""
    local encryption_key=""
    local encryption_mapper_full=""
    local encryption_mapper_name=""
    local header_raw=""
    local header=""
    local integrity_key_raw=""
    local integrity_key=""
    local integrity_mapper_full=""
    local integrity_mapper_name=""
    local last_up_mark_file=""
    local mount_point=""
    local partition_label=""
    local ramfs_mount_point=""

    C0RC_LUKS_OUTPUT_INIT_PARAMS=y c0rc_luks_init_params "$@"
    if [ $? -ne 0 ]; then
        return 1
    fi
    # }}}

    # mounts {{{
    sudo mkdir -p "$mount_point" &&
        sudo chown "$(id -un)":"$(id -gn)" "$mount_point" &&
        sudo mkdir -p "$ramfs_mount_point" &&
        sudo chown "$(id -un)":"$(id -gn)" "$ramfs_mount_point"
    if [ $? -ne 0 ]; then
        c0rc_err "error while creating and tuning mount points"
        sudo rm -fdr "$ramfs_mount_point"
        return 1
    fi

    sudo mount -t ramfs ramfs "$ramfs_mount_point" &&
        sudo chown "$(id -un)":"$(id -gn)" "$ramfs_mount_point" &&
        sudo chmod a-rwx "$ramfs_mount_point" &&
        sudo chmod u+rwx "$ramfs_mount_point"
    if [ $? -ne 0 ]; then
        c0rc_err "error while mounting ramfs"
        sudo rm -fdr "$ramfs_mount_point"
        return 1
    fi
    sudo df "$ramfs_mount_point" >/dev/null
    if [ $? -ne 0 ]; then
        c0rc_err "error while mounting ramfs: file system mount check failed"
        sudo rm -fdr "$ramfs_mount_point"
        return 1
    fi
    # }}}

    # generate random data {{{
    sudo dd if=/dev/urandom bs=32 count=1 of=$integrity_key_raw
    if [ $? -ne 0 ]; then
        c0rc_err "error while generating integrity key"
        c0rc_luks_init_fail_clean
        return 1
    fi

    sudo dd if=/dev/urandom bs=512 count=1 of=$encryption_key_raw
    if [ $? -ne 0 ]; then
        c0rc_err "error while generating encryption key"
        c0rc_luks_init_fail_clean
        return 1
    fi

    sudo dd if=/dev/zero bs=16777216 count=1 of=$header_raw
    if [ $? -ne 0 ]; then
        c0rc_err "error while generating luks header"
        c0rc_luks_init_fail_clean
        return 1
    fi
    # }}}

    # integrity layer {{{
    sudo integritysetup \
        --debug \
        format \
        $backend_device \
        --tag-size=32 \
        --integrity=hmac-sha256 \
        --integrity-key-file=$integrity_key_raw \
        --integrity-key-size=32 \
        --sector-size=4096
    if [ $? -ne 0 ]; then
        c0rc_err "error while formatting integrity layer"
        c0rc_luks_init_fail_clean
        return 1
    fi

    sudo integritysetup \
        --debug open \
        $backend_device \
        $integrity_mapper_name \
        --integrity=hmac-sha256 \
        --integrity-key-file=$integrity_key_raw \
        --integrity-key-size=32
    if [ $? -ne 0 ]; then
        c0rc_err "error while opening integrity layer device"
        c0rc_luks_init_fail_clean
        return 1
    fi
    # }}}

    # luks layer {{{
    sudo cryptsetup \
        --debug \
        luksFormat \
        --cipher="capi:xts(twofish)-essiv:sha256" \
        --key-size=256 \
        --pbkdf=argon2id \
        --iter-time=16000 \
        --hash=sha512 \
        --label=$partition_label \
        --key-slot=$C0RC_LUKS_DEFAULT_KEYSLOT \
        --use-urandom \
        --key-file=$encryption_key_raw \
        --header=$header_raw \
        --sector-size=4096 \
        $integrity_mapper_full
    if [ $? -ne 0 ]; then
        c0rc_err "error while formatting luks layer"
        c0rc_luks_init_fail_clean
        return 1
    fi

    sudo cryptsetup \
        --debug \
        luksOpen \
        --key-slot=$C0RC_LUKS_DEFAULT_KEYSLOT \
        --key-file=$encryption_key_raw \
        --header=$header_raw \
        $integrity_mapper_full \
        $encryption_mapper_name
    if [ $? -ne 0 ]; then
        c0rc_err "error while opening luks layer device"
        c0rc_luks_init_fail_clean
        return 1
    fi
    # }}}

    # file system {{{
    sudo mkfs.$C0RC_LUKS_DEFAULT_FS -F -v $encryption_mapper_full
    if [ $? -ne 0 ]; then
        c0rc_err "error while making file system on luks layer"
        c0rc_luks_init_fail_clean
        return 1
    fi

    sudo mount -t $C0RC_LUKS_DEFAULT_FS $encryption_mapper_full $mount_point/
    if [ $? -ne 0 ]; then
        c0rc_err "error while mounting created file system"
        c0rc_luks_init_fail_clean
        return 1
    fi

    sudo sync -f
    if [ $? -ne 0 ]; then
        c0rc_err "error while syncing fs"
        c0rc_luks_init_fail_clean
        return 1
    fi
    # }}}

    # encrypt and store credentials {{{
    c0rc_secrets_dir_unseal

    c0rc_gpg_encrypt_to "$integrity_key_raw" "$integrity_key" &&
        c0rc_gpg_encrypt_to "$encryption_key_raw" "$encryption_key" &&
        c0rc_gpg_encrypt_to "$header_raw" "$header"
    if [ $? -ne 0 ]; then
        c0rc_err "error while storing credentials"
        c0rc_luks_init_fail_clean
        return 1
    fi

    c0rc_secrets_dir_seal
    # }}}

    # unmount ramfs {{{
    sudo umount -f "$ramfs_mount_point" &&
        sudo rm -fdr "$ramfs_mount_point"
    if [ $? -ne 0 ]; then
        c0rc_warn "error while unmounting ramfs"
    fi
    # }}}

    # close created container {{{
    c0rc_luks_close --container_name="$container_name" --mount_point="$mount_point"
    # }}}

    c0rc_ok

    return 0
}

function c0rc_secv_close() {
    c0rc_info "close luks container '${TXT_COLOR_YELLOW}$C0RC_SECV_LUKS_CONTAINER_NAME${TXT_COLOR_NONE}': $C0RC_OP_PROGRESS"
    c0rc_luks_close --container_name="$C0RC_SECV_LUKS_CONTAINER_NAME" --mount_point="$C0RC_WS_SECV_DIR"
    if [ $? -ne 0 ]; then
        c0rc_warn "error while closing container"
    else
        c0rc_info "close luks container '${TXT_COLOR_YELLOW}$C0RC_SECV_LUKS_CONTAINER_NAME${TXT_COLOR_NONE}': $C0RC_OP_OK"
    fi

    c0rc_info "detach loop device ('${TXT_COLOR_YELLOW}/dev/$C0RC_SECV_LOOP_NAME${TXT_COLOR_NONE}'): $C0RC_OP_PROGRESS"
    sudo losetup -v -d /dev/$C0RC_SECV_LOOP_NAME
    if [ $? -ne 0 ]; then
        c0rc_warn "error while detaching loop device"
    else
        c0rc_info "detach loop device ('${TXT_COLOR_YELLOW}/dev/$C0RC_SECV_LOOP_NAME${TXT_COLOR_NONE}'): $C0RC_OP_OK"
    fi

    return 0
}

function c0rc_secv_open() {
    c0rc_info "setup loop device '${TXT_COLOR_YELLOW}/dev/$C0RC_SECV_LOOP_NAME${TXT_COLOR_NONE}': $C0RC_OP_PROGRESS"
    sudo losetup --direct-io=on -P /dev/$C0RC_SECV_LOOP_NAME "$C0RC_SECV_IMG"
    if [ $? -ne 0 ]; then
        c0rc_err "error while setting up loop device"
        c0rc_secv_close
        return 1
    fi
    # c0rc_info "some pause needed (7 secs) $C0RC_OP_PROGRESS"
    # sleep 7
    # sudo partx -u - /dev/$C0RC_SECV_LOOP_NAME
    # if [ $? -ne 0 ]; then
    #     c0rc_err "error while setting up loop device"
    #     c0rc_secv_close
    #     return 1
    # fi
    sudo partprobe
    if [ $? -ne 0 ]; then
        c0rc_err "error while setting up loop device"
        c0rc_secv_close
        return 1
    fi
    c0rc_info "setup loop device: $C0RC_OP_OK"

    c0rc_info "open luks container '${TXT_COLOR_YELLOW}$C0RC_SECV_LUKS_CONTAINER_NAME${TXT_COLOR_NONE}': $C0RC_OP_PROGRESS"
    c0rc_luks_open --container_name="$C0RC_SECV_LUKS_CONTAINER_NAME" --mount_point="$C0RC_WS_SECV_DIR"
    if [ $? -ne 0 ]; then
        c0rc_err "error while opening container"
        c0rc_secv_close
        return 1
    fi
    c0rc_info "open luks container '${TXT_COLOR_YELLOW}$C0RC_SECV_LUKS_CONTAINER_NAME${TXT_COLOR_NONE}': $C0RC_OP_OK"

    return 0
}
