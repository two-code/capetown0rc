function c0rc_luks_init_params() {
    while [ $# -gt 0 ]; do
        case $1 in
        --mount_point=?*)
            mount_point="${1#*=}"
            ;;
        --container_name=?*)
            container_name="${1#*=}"
            ;;
        --sector_size=?*)
            sector_size="${1#*=}"
            ;;
        --container_uuid_out=?*)
            container_uuid_out="${1#*=}"
            ;;
        --)
            shift
            break
            ;;
        -*)
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

    if [ -z "$sector_size" ]; then
        sector_size="4096"
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
        echo -e "\tsector_size: ${TXT_COLOR_YELLOW}${sector_size}${TXT_COLOR_NONE}"
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
    local sector_size=""

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
    local sector_size=""

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
    local sector_size=""

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
        --sector-size=$sector_size
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
        --sector-size=$sector_size \
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
