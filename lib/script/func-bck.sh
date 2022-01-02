function c0rc_bck_err() {
    c0rc_err "[bck]: $1"
    return 0
}

function c0rc_bck_info() {
    c0rc_info "[bck]: $1"
    return 0
}

function c0rc_bck_warn() {
    c0rc_warn "[bck]: $1"
    return 0
}

function c0rc_bck_ok() {
    c0rc_bck_info "OK"
    return 0
}

function c0rc_bck_init_params() {
    if [ $# -ne 1 ]; then
        c0rc_bck_err "one argument specifying backup name expected"
        return 1
    fi

    bck_name="$1"
    if [ -z $bck_name ]; then
        c0rc_bck_err "no backup name specified"
        return 1
    fi

    mnt_path="/mnt/$bck_name"

    ramfs_mnt_path="/mnt/ramfs_$(c0rc_hash_default "${C0RC_SHELL_SALT}_$bck_name")"
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while generating ram-fs mount point"
        return 1
    fi

    integrity_key="${C0RC_SECRETS_DIR}/${bck_name}-ikey.gpg"
    integrity_key_decrypted="${ramfs_mnt_path}/${bck_name}-ikey"
    integrity_mapper_name="${bck_name}_int"
    integrity_mapper_full="/dev/mapper/${integrity_mapper_name}"

    encryption_key="${C0RC_SECRETS_DIR}/${bck_name}-key.gpg"
    encryption_mapper_name="${bck_name}_enc"
    encryption_mapper_full="/dev/mapper/${encryption_mapper_name}"

    header="${C0RC_SECRETS_DIR}/${bck_name}-header.gpg"
    header_decrypted="${ramfs_mnt_path}/${bck_name}-header"

    partition_label="${bck_name}-vault"
    local backend_device_rel=$(readlink "/dev/disk/by-partlabel/${partition_label}")
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while resolving disk by backup partition label '${TXT_COLOR_YELLOW}${partition_label}${TXT_COLOR_NONE}'"
        return 1
    elif [ -z $backend_device_rel ]; then
        c0rc_bck_err "backup partition label '${TXT_COLOR_YELLOW}${partition_label}${TXT_COLOR_NONE}' resolved to empty disk path"
        return 1
    fi
    backend_device="/dev/$(basename $backend_device_rel)"
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while resolving disk by backup partition label '${TXT_COLOR_YELLOW}${partition_label}${TXT_COLOR_NONE}'"
        return 1
    fi

    last_up_mark_file="${mnt_path}/.last-up.txt"

    c0rc_bck_info "backup device params:"
    echo -e "\tbackend_device_rel: ${TXT_COLOR_YELLOW}${backend_device_rel}${TXT_COLOR_NONE}"
    echo -e "\tbackend_device: ${TXT_COLOR_YELLOW}${backend_device}${TXT_COLOR_NONE}"
    echo -e "\tbck_name: ${TXT_COLOR_YELLOW}${bck_name}${TXT_COLOR_NONE}"
    echo -e "\tencryption_key: ${TXT_COLOR_YELLOW}${encryption_key}${TXT_COLOR_NONE}"
    echo -e "\tencryption_mapper_full: ${TXT_COLOR_YELLOW}${encryption_mapper_full}${TXT_COLOR_NONE}"
    echo -e "\tencryption_mapper_name: ${TXT_COLOR_YELLOW}${encryption_mapper_name}${TXT_COLOR_NONE}"
    echo -e "\theader_decrypted: ${TXT_COLOR_YELLOW}${header_decrypted}${TXT_COLOR_NONE}"
    echo -e "\theader: ${TXT_COLOR_YELLOW}${header}${TXT_COLOR_NONE}"
    echo -e "\tintegrity_key_decrypted: ${TXT_COLOR_YELLOW}${integrity_key_decrypted}${TXT_COLOR_NONE}"
    echo -e "\tintegrity_key: ${TXT_COLOR_YELLOW}${integrity_key}${TXT_COLOR_NONE}"
    echo -e "\tintegrity_mapper_full: ${TXT_COLOR_YELLOW}${integrity_mapper_full}${TXT_COLOR_NONE}"
    echo -e "\tintegrity_mapper_name: ${TXT_COLOR_YELLOW}${integrity_mapper_name}${TXT_COLOR_NONE}"
    echo -e "\tlast_up_mark_file: ${TXT_COLOR_YELLOW}${last_up_mark_file}${TXT_COLOR_NONE}"
    echo -e "\tmnt_path: ${TXT_COLOR_YELLOW}${mnt_path}${TXT_COLOR_NONE}"
    echo -e "\tpartition_label: ${TXT_COLOR_YELLOW}${partition_label}${TXT_COLOR_NONE}"
    echo -e "\tramfs_mnt_path: ${TXT_COLOR_YELLOW}${ramfs_mnt_path}${TXT_COLOR_NONE}"

    return 0
}

function c0rc_bck_close() {
    c0rc_bck_info "request to close backup device"

    if [ $# -ne 1 ]; then
        c0rc_bck_err "one argument specifying backup name expected"
        return 1
    fi

    # init params {{{
    local backend_device=""
    local bck_name=""
    local encryption_key=""
    local encryption_mapper_full=""
    local encryption_mapper_name=""
    local header_decrypted=""
    local header=""
    local integrity_key_decrypted=""
    local integrity_key=""
    local integrity_mapper_full=""
    local integrity_mapper_name=""
    local last_up_mark_file=""
    local mnt_path=""
    local partition_label=""
    local ramfs_mnt_path=""
    c0rc_bck_init_params "$1"
    if [ $? -ne 0 ]; then
        return 1
    fi
    # }}}

    # unmount device {{{
    c0rc_bck_info "unmount luks device: ..."

    sudo sync -f
    if [ $? -ne 0 ]; then
        c0rc_bck_warn "error while syncing fs"
    fi

    sudo umount "$mnt_path"
    if [ $? -ne 0 ]; then
        c0rc_bck_warn "error while unmounting luks device"
    else
        c0rc_bck_info "unmount luks device: ${TXT_COLOR_GREEN}OK${TXT_COLOR_NONE}"
    fi
    # }}}

    # luks device {{{
    c0rc_bck_info "close luks device: ..."

    sudo cryptsetup close $encryption_mapper_name
    if [ $? -ne 0 ]; then
        c0rc_bck_warn "error while closing luks device"
    else
        c0rc_bck_info "close luks device: ${TXT_COLOR_GREEN}OK${TXT_COLOR_NONE}"
    fi
    # }}}

    # integrity device {{{
    c0rc_bck_info "close integrity device: ..."

    sudo integritysetup close "$integrity_mapper_name"
    if [ $? -ne 0 ]; then
        c0rc_bck_warn "error while closing integrity device"
    else
        c0rc_bck_info "close integrity device: ${TXT_COLOR_GREEN}OK${TXT_COLOR_NONE}"
    fi
    # }}}

    return 0
}

function c0rc_bck_open() {
    c0rc_bck_info "request to open backup device"

    if [ $# -ne 1 ]; then
        c0rc_bck_err "one argument specifying backup name expected"
        return 1
    fi

    # init params {{{
    local backend_device=""
    local bck_name=""
    local encryption_key=""
    local encryption_mapper_full=""
    local encryption_mapper_name=""
    local header_decrypted=""
    local header=""
    local integrity_key_decrypted=""
    local integrity_key=""
    local integrity_mapper_full=""
    local integrity_mapper_name=""
    local last_up_mark_file=""
    local mnt_path=""
    local partition_label=""
    local ramfs_mnt_path=""
    c0rc_bck_init_params "$1"
    if [ $? -ne 0 ]; then
        return 1
    fi
    # }}}

    sudo mkdir -p "$mnt_path" &&
        sudo chown vitalik:vitalik "$mnt_path" &&
        sudo mkdir -p "$ramfs_mnt_path" &&
        sudo chown vitalik:vitalik "$ramfs_mnt_path"
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while creating and tuning mount points"
        sudo rm -fdr "$ramfs_mnt_path"
        return 1
    fi

    # integrity device {{{
    c0rc_bck_info "open integrity device: ..."

    sudo mount -t ramfs ramfs "$ramfs_mnt_path" &&
        sudo chown vitalik:vitalik "$ramfs_mnt_path" &&
        sudo chmod a-rwx "$ramfs_mnt_path" &&
        sudo chmod u+rwx "$ramfs_mnt_path"

    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while mounting ramfs"
        sudo rm -fdr "$ramfs_mnt_path"
        return 1
    fi

    c0rc_gpg_decrypt_to "$integrity_key" "$integrity_key_decrypted"
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while decrypting integrity key"
        sudo umount -f "$ramfs_mnt_path" &&
            sudo rm -fdr "$ramfs_mnt_path"
        return 1
    fi

    sudo integritysetup open "$backend_device" "$integrity_mapper_name" --integrity=hmac-sha256 --integrity-key-file="$integrity_key_decrypted" --integrity-key-size=32
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while opening integrity device"
        sudo umount -f "$ramfs_mnt_path" &&
            sudo rm -fdr "$ramfs_mnt_path"
        return 1
    fi

    c0rc_bck_info "open integrity device: ${TXT_COLOR_GREEN}OK${TXT_COLOR_NONE}"
    # }}}

    # luks device {{{
    c0rc_bck_info "open luks device: ..."

    c0rc_gpg_decrypt_to "$header" "$header_decrypted"
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while decrypting luks device header"
        c0rc_bck_close "$bck_name"
        return 1
    fi

    c0rc_gpg_decrypt "$encryption_key" |
        sudo cryptsetup --key-file=- --key-slot=$C0RC_LUKS_DEFAULT_KEYSLOT --header="$header_decrypted" --perf-no_read_workqueue --perf-no_write_workqueue --persistent luksOpen $integrity_mapper_full $encryption_mapper_name
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while opening luks device"
        c0rc_bck_close "$bck_name"
        return 1
    fi

    c0rc_bck_info "open luks device: ${TXT_COLOR_GREEN}OK${TXT_COLOR_NONE}"
    # }}}

    # mount {{{
    c0rc_bck_info "mount luks device: ..."

    sudo mount -t $C0RC_BCK_VOLUME_DEFAULT_FS "$encryption_mapper_full" "$mnt_path"
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while mounting luks device"
        c0rc_bck_close "$bck_name"
        return 1
    fi

    sudo chown vitalik:vitalik "$mnt_path"
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while tuning permissions/ownership for luks device's file system root"
        c0rc_bck_close "$bck_name"
        return 1
    fi

    c0rc_bck_info "mount luks device: ${TXT_COLOR_GREEN}OK${TXT_COLOR_NONE}"
    # }}}

    c0rc_bck_info "previous up: ${TXT_COLOR_GREEN}$(sudo cat "$last_up_mark_file" || echo -n '<no data>')${TXT_COLOR_NONE}"
    date '+%Y-%m-%dT%H:%M:%S%z, %A %b %d, %s' | sudo tee $last_up_mark_file >/dev/null
    if [ $? -ne 0 ]; then
        c0rc_bck_warn "error while writing out mark of device up"
    fi

    # unmount ramfs {{{
    sudo umount -f "$ramfs_mnt_path" &&
        sudo rm -fdr "$ramfs_mnt_path"
    if [ $? -ne 0 ]; then
        c0rc_bck_warn "error while unmounting ramfs"
    fi
    # }}}

    return 0
}

function c0rc_bck_open_close() {
    if [ $# -ne 1 ]; then
        c0rc_bck_err "one argument specifying backup name expected"
        return 1
    fi

    c0rc_bck_open "$1" && c0rc_bck_close "$1"
    if [ $? -ne 0 ]; then
        return 1
    fi

    return 0
}
