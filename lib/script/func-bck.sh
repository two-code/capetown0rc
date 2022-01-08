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
    c0rc_bck_info "$C0RC_OP_OK"
    return 0
}

function c0rc_timeshift_mount_try_unmount() {
    sudo umount "/run/timeshift/backup"
    if [ $? -ne 0 ]; then
        c0rc_bck_warn "error while unmounting timeshift mount point ('${TXT_COLOR_YELLOW}/run/timeshift/backup${TXT_COLOR_NONE}')"
    fi

    return 0
}

function c0rc_bck_run_precond_check() {
    c0rc_check_hh_cookie
    if [ $? -ne 0 ]; then
        return 1
    fi

    if ! command -v timeshift &>/dev/null; then
        c0rc_bck_err "no command '${TXT_COLOR_YELLOW}timeshift${TXT_COLOR_NONE}' available; possibly, you need to install it"
        return 1
    fi

    local c0rc_cmd=$(command -v c0rc 2>/dev/null)
    if [ ! -n "$c0rc_cmd" ]; then
        c0rc_bck_err "no command '${TXT_COLOR_YELLOW}c0rc${TXT_COLOR_NONE}' available; possibly, you need to install using 'go install github.com/two-code/capetown0rc.git/go' (or using make, if you have cloned repository)"
        return 1
    fi

    sudo sync -f
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while syncing fs; backup target '${TXT_COLOR_YELLOW}$bck_target${TXT_COLOR_NONE}'"
        return 1
    fi

    if [ -d "$C0RC_WS_DOCS_DIR" ] && [ ! -z "$(ls -A "$C0RC_WS_DOCS_DIR")" ]; then
        c0rc_bck_err "directory '${TXT_COLOR_YELLOW}$C0RC_WS_DOCS_DIR${TXT_COLOR_NONE}' not empty"
        return 1
    fi

    if [ -d "$C0RC_WS_VIDESS_DIR" ] && [ ! -z "$(ls -A "$C0RC_WS_VIDESS_DIR")" ]; then
        c0rc_bck_err "directory '${TXT_COLOR_YELLOW}$C0RC_WS_VIDESS_DIR${TXT_COLOR_NONE}' not empty"
        return 1
    fi

    if [ -d "$C0RC_WS_SECV_LEGACY_DIR" ] && [ ! -z "$(ls -A "$C0RC_WS_SECV_LEGACY_DIR")" ]; then
        c0rc_bck_err "directory '${TXT_COLOR_YELLOW}$C0RC_WS_SECV_LEGACY_DIR${TXT_COLOR_NONE}' not empty"
        return 1
    fi

    if [ -d "$C0RC_WS_SECV_DIR" ] && [ ! -z "$(ls -A "$C0RC_WS_SECV_DIR")" ]; then
        c0rc_bck_err "directory '${TXT_COLOR_YELLOW}$C0RC_WS_SECV_DIR${TXT_COLOR_NONE}' not empty"
        return 1
    fi

    return 0
}

function c0rc_bck_init_params() {
    # need to be removed when c0rc_luks_open/c0rc_luks_close will be used
    #
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
    local backend_device_rel=$(readlink "/dev/disk/by-partlabel/$partition_label")
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while resolving disk by backup partition label '${TXT_COLOR_YELLOW}$partition_label${TXT_COLOR_NONE}'"
        return 1
    elif [ -z "$backend_device_rel" ]; then
        c0rc_bck_err "backup partition label '${TXT_COLOR_YELLOW}$partition_label${TXT_COLOR_NONE}' resolved to empty disk path"
        return 1
    fi
    backend_device="/dev/$(basename $backend_device_rel)"
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while resolving disk by backup partition label '${TXT_COLOR_YELLOW}${partition_label}${TXT_COLOR_NONE}'"
        return 1
    fi

    last_up_mark_file="${mnt_path}/.last-up.txt"

    if [ "$C0RC_BCK_OUTPUT_INIT_PARAMS" = "y" ]; then
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
    fi

    return 0
}

function c0rc_bck_close() {
    # use c0rc_luks_close
    #
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
    c0rc_bck_info "unmount luks device: $C0RC_OP_PROGRESS"

    sudo sync -f
    if [ $? -ne 0 ]; then
        c0rc_bck_warn "error while syncing fs"
    fi

    sudo umount "$mnt_path"
    if [ $? -ne 0 ]; then
        c0rc_bck_warn "error while unmounting luks device"
    else
        c0rc_bck_info "unmount luks device: $C0RC_OP_OK"
    fi
    # }}}

    # luks device {{{
    c0rc_bck_info "close luks device: $C0RC_OP_PROGRESS"

    sudo cryptsetup close $encryption_mapper_name
    if [ $? -ne 0 ]; then
        c0rc_bck_warn "error while closing luks device"
    else
        c0rc_bck_info "close luks device: $C0RC_OP_OK"
    fi
    # }}}

    # integrity device {{{
    c0rc_bck_info "close integrity device: $C0RC_OP_PROGRESS"

    sudo integritysetup close "$integrity_mapper_name"
    if [ $? -ne 0 ]; then
        c0rc_bck_warn "error while closing integrity device"
    else
        c0rc_bck_info "close integrity device: $C0RC_OP_OK"
    fi
    # }}}

    return 0
}

function c0rc_bck_open() {
    # use c0rc_luks_open
    #
    if [ $# -lt 1 ]; then
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
        sudo chown "$(id -un)":"$(id -gn)" "$mnt_path" &&
        sudo mkdir -p "$ramfs_mnt_path" &&
        sudo chown "$(id -un)":"$(id -gn)" "$ramfs_mnt_path"
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while creating and tuning mount points"
        sudo rm -fdr "$ramfs_mnt_path"
        return 1
    fi

    # integrity device {{{
    c0rc_bck_info "open integrity device: $C0RC_OP_PROGRESS"

    sudo mount -t ramfs ramfs "$ramfs_mnt_path" &&
        sudo chown "$(id -un)":"$(id -gn)" "$ramfs_mnt_path" &&
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

    c0rc_bck_info "open integrity device: $C0RC_OP_OK"
    # }}}

    # luks device {{{
    c0rc_bck_info "open luks device: $C0RC_OP_PROGRESS"

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

    c0rc_bck_info "open luks device: $C0RC_OP_OK"
    # }}}

    # mount {{{
    c0rc_bck_info "mount luks device: $C0RC_OP_PROGRESS"

    sudo mount -t $C0RC_BCK_VOLUME_DEFAULT_FS "$encryption_mapper_full" "$mnt_path"
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while mounting luks device"
        c0rc_bck_close "$bck_name"
        return 1
    fi
    sudo df "$mnt_path" >/dev/null
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while mounting luks device: file system mount check failed"
        c0rc_bck_close "$bck_name"
        return 1
    fi

    sudo chown "$(id -un)":"$(id -gn)" "$mnt_path"
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while tuning permissions/ownership for luks device's file system root"
        c0rc_bck_close "$bck_name"
        return 1
    fi

    c0rc_bck_info "mount luks device: $C0RC_OP_OK"
    # }}}

    # unmount ramfs {{{
    sudo umount -f "$ramfs_mnt_path" &&
        sudo rm -fdr "$ramfs_mnt_path"
    if [ $? -ne 0 ]; then
        c0rc_bck_warn "error while unmounting ramfs"
    fi
    # }}}

    # output info {{{
    c0rc_bck_info "previous up '${TXT_COLOR_YELLOW}$(sudo cat "$last_up_mark_file" || echo -n '<no data>')'${TXT_COLOR_NONE}"
    date '+%Y-%m-%dT%H:%M:%S%z, %A %b %d, %s' | sudo tee $last_up_mark_file >/dev/null
    if [ $? -ne 0 ]; then
        c0rc_bck_warn "error while writing out mark of device up"
    fi

    local luks_device_uuid_loc=$(lsblk -dn -o UUID "$encryption_mapper_full")
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while getting luks device uuid"
        c0rc_bck_close "$bck_name"
        return 1
    fi

    c0rc_bck_info "luks device uuid '${TXT_COLOR_YELLOW}$luks_device_uuid_loc${TXT_COLOR_NONE}'"
    c0rc_bck_info "mount point '${TXT_COLOR_YELLOW}$mnt_path${TXT_COLOR_NONE}'"
    c0rc_bck_info "stats for '${TXT_COLOR_YELLOW}$encryption_mapper_full${TXT_COLOR_NONE}':\n$(lsblk -ao SIZE,FSSIZE,FSTYPE,FSAVAIL,FSUSED,FSUSE% $encryption_mapper_full)"

    if [ $# -gt 1 ]; then
        eval "$2=$luks_device_uuid_loc"
    fi
    if [ $# -gt 2 ]; then
        eval "$3=$mnt_path"
    fi
    if [ $# -gt 3 ]; then
        eval "$4=$encryption_mapper_full"
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

function c0rc_bck_run_insensitive_to() {
    local target=""
    if [ $# -ne 1 ]; then
        c0rc_bck_err "one argument specifying target name expected"
        return 1
    elif [ -z "$1" ]; then
        c0rc_bck_err "target name can't be empty string"
        return 1
    else
        target="$1"
    fi

    c0rc_bck_run_precond_check
    if [ $? -ne 0 ]; then
        return 1
    fi

    local partition_label="$target$C0RC_BCK_INSENSITIVE_TARGET_POSTFIX"
    local backend_device_rel=$(readlink "/dev/disk/by-partlabel/$partition_label")
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while resolving disk by partition label '${TXT_COLOR_YELLOW}$partition_label${TXT_COLOR_NONE}'"
        return 1
    elif [ -z "$backend_device_rel" ]; then
        c0rc_bck_err "partition label '${TXT_COLOR_YELLOW}$partition_label${TXT_COLOR_NONE}' resolved to an empty disk path"
        return 1
    fi
    local backend_device="/dev/$(basename $backend_device_rel)"
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while resolving disk by partition label '${TXT_COLOR_YELLOW}${partition_label}${TXT_COLOR_NONE}'"
        return 1
    fi

    local mount_point="/mnt/tmp-$(c0rc_gen_uuid)"

    sudo mkdir -p $mount_point &&
        sudo chown "$(id -un)":"$(id -gn)" $mount_point
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while creating tmp mount point"
        return 1
    fi

    sudo mount $backend_device $mount_point
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while mounting '${TXT_COLOR_YELLOW}$backend_device${TXT_COLOR_NONE}'"
        sudo rm -d $mount_point
        return 1
    fi
    sudo df $mount_point >/dev/null
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while mounting '${TXT_COLOR_YELLOW}$backend_device${TXT_COLOR_NONE}': file system mount check failed"
        sudo umount $mount_point
        sudo rm -d $mount_point
        return 1
    fi

    local save_loc_base="./insensitive/$C0RC_HH_COOKIE"
    local save_loc="$save_loc_base/$(hostname)-$(date '+%Y%m%d_%H%M')-$(head -c 4 /dev/urandom | xxd -c 4 -l 4 -p)"
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while generating name of tmp save location"
        sudo umount $mount_point
        sudo rm -d $mount_point
        return 1
    fi

    pushd $mount_point >/dev/null
    sudo mkdir -p $save_loc &&
        sudo mkdir -p "$save_loc/boot/grub" &&
        sudo mkdir -p "$save_loc/etc" &&
        sudo mkdir -p "$save_loc/etc/apt" &&
        sudo mkdir -p "$save_loc/etc/apt/sources.list.d" &&
        sudo mkdir -p "$save_loc/etc/ssh" &&
        sudo mkdir -p "$save_loc/home/.secrets" &&
        sudo mkdir -p "$save_loc/home/.gnupg" &&
        sudo mkdir -p "$save_loc/home/workspace/_backup/os-settings" &&
        sudo mkdir -p "$save_loc/root" &&
        sudo mkdir -p "$save_loc/usr/share/keyrings" &&
        sudo cp -aL ~/.2fa "$save_loc/home/" &&
        sudo cp -aL ~/.capetown0rc "$save_loc/home/" &&
        sudo cp -aL ~/.clickhouse-client-history "$save_loc/home/" &&
        sudo cp -aL ~/.gitconfig "$save_loc/home/" &&
        sudo cp -aL ~/.gnupg/gpg-agent.conf "$save_loc/home/.gnupg/" &&
        sudo cp -aL ~/.gnupg/gpg.conf "$save_loc/home/.gnupg/" &&
        sudo cp -aL ~/.gnupg/gpgsm.conf "$save_loc/home/.gnupg/" &&
        sudo cp -aL ~/.gnupg/scdaemon.conf "$save_loc/home/.gnupg/" &&
        sudo cp -aL ~/.gnupg/sshcontrol "$save_loc/home/.gnupg/" &&
        sudo cp -aL ~/.profile "$save_loc/home/" &&
        sudo cp -aL ~/.ssh "$save_loc/home/" &&
        sudo cp -aL ~/.zsh_history "$save_loc/home/" &&
        sudo cp -aL ~/.zshrc "$save_loc/home/" &&
        sudo cp -aL ~/workspace/_backup/os-settings "$save_loc/home/workspace/_backup/" &&
        sudo cp -aL ~/workspace/corsair-keyboard.ckb "$save_loc/home/workspace/" &&
        sudo cp -aL ~/workspace/logitech-default.gpfl "$save_loc/home/workspace/" &&
        sudo cp -aL ~/workspace/my-ublock-* "$save_loc/home/workspace/" &&
        sudo cp -aL /boot/grub/themes "$save_loc/boot/grub/" &&
        sudo cp -aL /etc/apt/sources.list "$save_loc/etc/apt/" &&
        sudo cp -aL /etc/apt/sources.list.d "$save_loc/etc/apt/" &&
        sudo cp -aL /etc/crypttab "$save_loc/etc/" &&
        sudo cp -aL /etc/default "$save_loc/etc/" &&
        sudo cp -aL /etc/environment "$save_loc/etc/" &&
        sudo cp -aL /etc/fstab "$save_loc/etc/" &&
        sudo cp -aL /etc/sddm "$save_loc/etc/" &&
        sudo cp -aL /etc/sddm.conf "$save_loc/etc/" &&
        sudo cp -aL /etc/sddm.conf.d "$save_loc/etc/" &&
        sudo cp -aL /etc/ssh/ssh_config "$save_loc/etc/ssh/" &&
        sudo cp -aL /etc/ssh/ssh_config.d "$save_loc/etc/ssh/" &&
        sudo cp -aL /etc/ssh/sshd_config.d "$save_loc/etc/ssh/" &&
        sudo cp -aL /root/.profile "$save_loc/root/" &&
        sudo cp -aL /root/.zsh_history "$save_loc/root/" &&
        sudo cp -aL /root/.zshrc "$save_loc/root/" &&
        sudo cp -aL /usr/share/keyrings "$save_loc/usr/share"
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while copying"
        sudo rm -fdrv "$save_loc"
        popd >/dev/null
        sudo umount $mount_point
        sudo rm -d $mount_point
        return 1
    fi

    local secret_file_exclude_pattern=$(echo '.*\/'"$target"'[^\/]+$')
    c0rc_bck_warn "copy secrets' files NOT matching pattern '${TXT_COLOR_YELLOW}$secret_file_exclude_pattern${TXT_COLOR_NONE}'"
    find "$C0RC_SECRETS_DIR" -mindepth 1 -maxdepth 1 |
        grep -v -E "$secret_file_exclude_pattern" |
        LC_ALL=C sort |
        xargs -I{} sudo cp -aL {} "$save_loc/home/.secrets/"
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while copying"
        sudo rm -fdrv "$save_loc"
        popd >/dev/null
        sudo umount $mount_point
        sudo rm -d $mount_point
        return 1
    fi

    sync -f
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while syncing fs"
        sudo rm -fdrv "$save_loc"
        popd >/dev/null
        sudo umount $mount_point
        sudo rm -d $mount_point
        return 1
    fi

    local save_loc_full=$(realpath $save_loc)
    for dir_to_remove in $(find $save_loc_base -mindepth 1 -maxdepth 1 -type d | xargs realpath); do
        if [ ! "$save_loc_full" = "$dir_to_remove" ]; then
            c0rc_bck_warn "remove backup '${TXT_COLOR_YELLOW}$dir_to_remove${TXT_COLOR_NONE}': $C0RC_OP_PROGRESS"
            sudo chattr -i -R "$dir_to_remove"
            sudo rm -fdr "$dir_to_remove"
            if [ $? -ne 0 ]; then
                c0rc_bck_warn "remove backup '${TXT_COLOR_YELLOW}$dir_to_remove${TXT_COLOR_NONE}': $C0RC_OP_FAIL"
            else
                c0rc_bck_warn "remove backup '${TXT_COLOR_YELLOW}$dir_to_remove${TXT_COLOR_NONE}': $C0RC_OP_OK"
            fi
        fi
    done

    sudo chattr +i -R "$save_loc"
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while setting read-only attr"
        sudo rm -fdrv "$save_loc"
        popd >/dev/null
        sudo umount $mount_point
        sudo rm -d $mount_point
        return 1
    fi

    sync -f
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while syncing fs"
    fi

    c0rc_bck_info "size '${TXT_COLOR_YELLOW}$(du -sh $save_loc)${TXT_COLOR_NONE}'"
    popd >/dev/null

    c0rc_bck_info "total size '${TXT_COLOR_YELLOW}$(du -sh $mount_point)${TXT_COLOR_NONE}'"

    sudo umount $mount_point
    if [ $? -ne 0 ]; then
        c0rc_bck_warn "error while unmounting backup device '${TXT_COLOR_YELLOW}$backend_device${TXT_COLOR_NONE}'"
    fi

    sudo rm -d $mount_point
    if [ $? -ne 0 ]; then
        c0rc_bck_warn "error while removing tmp mount point '${TXT_COLOR_YELLOW}$mount_point${TXT_COLOR_NONE}'"
    fi

    return 0
}

function c0rc_bck_run_insensitive() {
    local targets=''
    if [ $# -eq 1 ]; then
        targets="$1"
    elif [ $# -eq 0 ]; then
        targets="$C0RC_BCK_INSENSITIVE_TARGETS"
    else
        c0rc_bck_err "too many args passed; only one argument allowed - specifying targets"
        return 1
    fi

    c0rc_bck_run_precond_check
    if [ $? -ne 0 ]; then
        return 1
    fi

    local has_fail='n'
    local failed_targets=''
    local succeeded_targets=''
    for trg in $(<<<$targets); do
        c0rc_splitter
        c0rc_bck_info "[${TXT_COLOR_YELLOW}$trg${TXT_COLOR_NONE}]: run insensitive backup: $C0RC_OP_PROGRESS"
        c0rc_bck_run_insensitive_to "$trg"
        if [ $? -ne 0 ]; then
            has_fail='y'
            failed_targets="$failed_targets $trg"
        else
            succeeded_targets="$succeeded_targets $trg"
        fi
    done

    c0rc_splitter
    for trg in $(<<<$succeeded_targets); do
        c0rc_bck_info "[${TXT_COLOR_YELLOW}$trg${TXT_COLOR_NONE}]: run insensitive backup: $C0RC_OP_OK"
    done
    for trg in $(<<<$failed_targets); do
        c0rc_bck_warn "[${TXT_COLOR_YELLOW}$trg${TXT_COLOR_NONE}]: run insensitive backup: $C0RC_OP_FAIL"
    done

    if [ "$has_fail" = 'n' ]; then
        return 0
    else
        return 1
    fi
}

function c0rc_bck_run_system_to() {
    if [ $# -lt 3 ]; then
        c0rc_bck_err "two arguments specifying backup target name and backup note expected"
        return 1
    fi

    c0rc_bck_run_precond_check
    if [ $? -ne 0 ]; then
        return 1
    fi

    local target_name="$1"
    local bck_note="$2"
    local mount_point=""
    local luks_uuid=""
    local luks_path=""

    local msg_prologue="[${TXT_COLOR_YELLOW}$C0RC_BCK_KIND_SYSTEM${TXT_COLOR_NONE}] [${TXT_COLOR_YELLOW}$target_name${TXT_COLOR_NONE}]:"

    c0rc_bck_open $target_name luks_uuid mount_point luks_path
    if [ $? -ne 0 ]; then
        c0rc_bck_err "$msg_prologue error while opening backup target device"
        return 1
    fi

    sudo timeshift --create --comments "note: $bck_note" --snapshot-device "$luks_uuid"
    if [ $? -ne 0 ]; then
        c0rc_bck_err "$msg_prologue error while making backup"
        c0rc_timeshift_mount_try_unmount
        c0rc_bck_close "$target_name"
        return 1
    fi

    sudo sync -f
    if [ $? -ne 0 ]; then
        c0rc_bck_err "$msg_prologue error while syncing fs"
        c0rc_timeshift_mount_try_unmount
        c0rc_bck_close "$target_name"
        return 1
    fi

    sudo "$c0rc_cmd" bck timeshift clean --retain-count=$C0RC_BCK_SYSTEM_RETENTION
    if [ $? -ne 0 ]; then
        c0rc_bck_warn "$msg_prologue error while cleaning backups"
    fi

    sudo timeshift --list --snapshot-device "$luks_uuid"
    if [ $? -ne 0 ]; then
        c0rc_bck_warn "$msg_prologue error while listing backups"
    fi

    c0rc_timeshift_mount_try_unmount

    c0rc_bck_info "$msg_prologue stats for '${TXT_COLOR_YELLOW}$luks_path${TXT_COLOR_NONE}':\n$(lsblk -ao SIZE,FSSIZE,FSTYPE,FSAVAIL,FSUSED,FSUSE% $luks_path)"

    c0rc_bck_close $target_name
    if [ $? -ne 0 ]; then
        c0rc_bck_warn "$msg_prologue error while closing backup target device"
        return 1
    fi

    return 0
}

function c0rc_bck_run_system() {
    local targets=''
    if [ $# -eq 1 ]; then
        targets="$1"
    elif [ $# -eq 0 ]; then
        targets="$C0RC_BCK_SYSTEM_TARGETS"
    else
        c0rc_bck_err "too many args passed; only one argument allowed - specifying targets"
        return 1
    fi

    c0rc_bck_run_precond_check
    if [ $? -ne 0 ]; then
        return 1
    fi

    local has_fail='n'
    local failed_targets=''
    local succeeded_targets=''
    for trg in $(<<<$targets); do
        c0rc_splitter
        c0rc_bck_info "[${TXT_COLOR_YELLOW}$trg${TXT_COLOR_NONE}]: run system backup: $C0RC_OP_PROGRESS"
        c0rc_bck_run_system_to "$trg" "regular on $(date '+%Y-%m-%dT%H:%M:%S%z')"
        if [ $? -ne 0 ]; then
            has_fail='y'
            failed_targets="$failed_targets $trg"
            c0rc_bck_warn "[${TXT_COLOR_YELLOW}$trg${TXT_COLOR_NONE}]: run system backup: $C0RC_OP_FAIL"
        else
            succeeded_targets="$succeeded_targets $trg"
        fi
    done

    c0rc_splitter
    for trg in $(<<<$succeeded_targets); do
        c0rc_bck_info "[${TXT_COLOR_YELLOW}$trg${TXT_COLOR_NONE}]: run system backup: $C0RC_OP_OK"
    done
    for trg in $(<<<$failed_targets); do
        c0rc_bck_warn "[${TXT_COLOR_YELLOW}$trg${TXT_COLOR_NONE}]: run system backup: $C0RC_OP_FAIL"
    done

    if [ "$has_fail" = 'n' ]; then
        return 0
    else
        return 1
    fi
}

function c0rc_bck_run_ws_to() {
    local target_name=""
    while [ $# -gt 0 ]; do
        case "$1" in
        --target_name=?*)
            target_name=${1#*=}
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
    if [ -z "$target_name" ]; then
        c0rc_bck_err "parameter '${TXT_COLOR_YELLOW}--target_name${TXT_COLOR_NONE}' is missing"
        return 1
    fi

    c0rc_bck_run_precond_check
    if [ $? -ne 0 ]; then
        return 1
    fi

    local msg_prologue="[${TXT_COLOR_YELLOW}$C0RC_BCK_KIND_WS${TXT_COLOR_NONE}] [${TXT_COLOR_YELLOW}$target_name${TXT_COLOR_NONE}]:"

    # open target {{{
    local mount_point=""
    local luks_uuid=""
    local luks_path=""
    c0rc_bck_open $target_name luks_uuid mount_point luks_path
    if [ $? -ne 0 ]; then
        c0rc_bck_err "$msg_prologue error while opening backup target device"
        return 1
    fi
    # }}}

    # target root dir {{{
    local target_ws_root="$mount_point/c0rc_ws"
    sudo mkdir -p "$target_ws_root"
    if [ $? -ne 0 ]; then
        c0rc_bck_err "$msg_prologue error while creating target root dir"
        c0rc_bck_close $target_name
        return 1
    fi
    sudo chown "$(id -un)":"$(id -gn)" "$target_ws_root"
    if [ $? -ne 0 ]; then
        c0rc_bck_err "$msg_prologue error while tuning owning for target root dir"
        c0rc_bck_close $target_name
        return 1
    fi
    sudo chmod a-rwx "$target_ws_root" &&
        sudo chmod ug+rwx "$target_ws_root"
    if [ $? -ne 0 ]; then
        c0rc_bck_err "$msg_prologue error while tuning perms for target root dir"
        c0rc_bck_close $target_name
        return 1
    fi
    # }}}

    local salt="$(c0rc_gen_hex32bit)"
    if [ $? -ne 0 ]; then
        c0rc_bck_err "$msg_prologue error while generating salt"
        c0rc_bck_close $target_name
        return 1
    fi

    local exclusions_file=$(mktemp)
    if [ $? -ne 0 ]; then
        c0rc_bck_err "$msg_prologue error while generating exclusions file"
        c0rc_bck_close $target_name
        return 1
    fi
    echo \
        '/_backup/***
/_desktop/***
/_garbage/***
/_media/_mus/***
/_media/_music/***
/_media/_os_iso/***
/_media/_videos/@especial_secured/***
/_media/_videos/@especial/***
/_secv-legacy/***
/_secv/***
/_tools/***
/_vm/***' >$exclusions_file
    if [ $? -ne 0 ]; then
        c0rc_bck_err "$msg_prologue error while generating exclusions file"
        c0rc_bck_close $target_name
        return 1
    fi
    c0rc_bck_info "$msg_prologue exclusions:\n$TXT_COLOR_WARN$(cat -n $exclusions_file)$TXT_COLOR_NONE"

    local datetime_str="$(date '+%Y%m%d_%H%M%S')_$salt"
    local snapshots_dir="$target_ws_root/snapshots"
    local current_snapshot_dir="$snapshots_dir/$datetime_str"
    local latest_snapshot_lnk="$snapshots_dir/latest"

    local logs_dir="$target_ws_root/logs/$C0RC_HH_COOKIE"
    local log_file="$logs_dir/$datetime_str.log"

    mkdir -p "$snapshots_dir" &&
        mkdir -p "$current_snapshot_dir" &&
        mkdir -p "$target_ws_root/logs" &&
        mkdir -p "$logs_dir"
    if [ $? -ne 0 ]; then
        c0rc_bck_err "$msg_prologue error while creating dirs"
        c0rc_bck_close $target_name
        rm -f $exclusions_file
        return 1
    fi

    local previous_snapshot_dir=""
    local rsync_link_dest=""
    local rsync_link_dest_val=""
    if [ -d $latest_snapshot_lnk ]; then
        previous_snapshot_dir=$(readlink "$latest_snapshot_lnk")
        if [ $? -ne 0 ]; then
            c0rc_bck_err "$msg_prologue error while reading link on previous snapshot"
            c0rc_bck_close $target_name
            rm -f $exclusions_file
            return 1
        fi
        rsync_link_dest="--link-dest"
        rsync_link_dest_val=$latest_snapshot_lnk
    fi

    c0rc_bck_info "$msg_prologue snapshot '${TXT_COLOR_YELLOW}$current_snapshot_dir${TXT_COLOR_NONE}': $C0RC_OP_PROGRESS"
    rsync \
        -a \
        --delete \
        --recursive \
        --force \
        --whole-file \
        --sparse \
        --log-file="$log_file" \
        $([ -d $latest_snapshot_lnk ] && echo -n $rsync_link_dest "$rsync_link_dest_val") \
        --exclude-from="$exclusions_file" \
        --delete-excluded \
        "$C0RC_WS_DIR/" \
        "$current_snapshot_dir" &&
        rm -f "$latest_snapshot_lnk" &&
        ln -s "$current_snapshot_dir" "$latest_snapshot_lnk"
    if [ $? -ne 0 ]; then
        c0rc_bck_err "$msg_prologue snapshot '${TXT_COLOR_YELLOW}$current_snapshot_dir${TXT_COLOR_NONE}': $C0RC_OP_FAIL"
        c0rc_bck_close $target_name
        rm -f $exclusions_file
        return 1
    else
        c0rc_bck_info "$msg_prologue snapshot '${TXT_COLOR_YELLOW}$current_snapshot_dir${TXT_COLOR_NONE}': $C0RC_OP_OK"
    fi

    c0rc_bck_info "$msg_prologue stats for '${TXT_COLOR_YELLOW}$luks_path${TXT_COLOR_NONE}':\n$(lsblk -ao SIZE,FSSIZE,FSTYPE,FSAVAIL,FSUSED,FSUSE% $luks_path)"

    c0rc_bck_close $target_name
    if [ $? -ne 0 ]; then
        c0rc_bck_warn "$msg_prologue error while closing backup target device"
        rm -f $exclusions_file
        return 1
    fi

    rm -f $exclusions_file

    c0rc_bck_info "$msg_prologue $C0RC_OP_OK"

    return 0
}

function c0rc_bck_restore_ws() {
    local restore_path=""
    while [ $# -gt 0 ]; do
        case "$1" in
        --restore_path=?*)
            restore_path=${1#*=}
            ;;
        --) shift break ;;
        -*)
            c0rc_err "unknown parameter '${TXT_COLOR_YELLOW}$1${TXT_COLOR_NONE}'"
            return 1
            ;;
        *) break ;;
        esac
        shift
    done

    c0rc_bck_run_precond_check
    if [ $? -ne 0 ]; then
        return 1
    fi

    local source_name=$C0RC_BCK_WS_TARGET
    local msg_prologue="[${TXT_COLOR_YELLOW}restore${TXT_COLOR_NONE}] [${TXT_COLOR_YELLOW}$C0RC_BCK_KIND_WS${TXT_COLOR_NONE}] [${TXT_COLOR_YELLOW}$source_name${TXT_COLOR_NONE}]:"

    # target dir {{{
    if [ -z "$restore_path" ]; then
        restore_path="$C0RC_WS_DIR"
    fi
    sudo mkdir -p "$restore_path"
    if [ $? -ne 0 ]; then
        c0rc_bck_err "$msg_prologue error while creating destination dir"
        c0rc_bck_close $source_name
        return 1
    fi
    sudo chown "$(id -un)":"$(id -gn)" "$restore_path"
    if [ $? -ne 0 ]; then
        c0rc_bck_err "$msg_prologue error while tuning owning for destination dir"
        c0rc_bck_close $source_name
        return 1
    fi
    sudo chmod a-rwx "$restore_path" &&
        sudo chmod ug+rwx "$restore_path"
    if [ $? -ne 0 ]; then
        c0rc_bck_err "$msg_prologue error while tuning perms for destination dir"
        c0rc_bck_close $source_name
        return 1
    fi
    # }}}

    # open source {{{
    local mount_point=""
    local luks_uuid=""
    c0rc_bck_open $source_name luks_uuid mount_point
    if [ $? -ne 0 ]; then
        c0rc_bck_err "$msg_prologue error while opening backup target device"
        return 1
    fi
    # }}}

    local source_ws_dir="$mount_point/c0rc_ws"

    local salt="$(c0rc_gen_hex32bit)"
    if [ $? -ne 0 ]; then
        c0rc_bck_err "$msg_prologue error while generating salt"
        c0rc_bck_close $source_name
        return 1
    fi

    local exclusions_file=$(mktemp)
    if [ $? -ne 0 ]; then
        c0rc_bck_err "$msg_prologue error while generating exclusions file"
        c0rc_bck_close $source_name
        return 1
    fi
    echo \
        '/_backup/***
/_desktop/***
/_garbage/***
/_media/_mus/***
/_media/_music/***
/_media/_os_iso/***
/_media/_videos/@especial_secured/***
/_media/_videos/@especial/***
/_secv-legacy/***
/_secv/***
/_tools/***
/_vm/***' >$exclusions_file
    if [ $? -ne 0 ]; then
        c0rc_bck_err "$msg_prologue error while generating exclusions file"
        c0rc_bck_close $source_name
        return 1
    fi
    c0rc_bck_info "$msg_prologue exclusions:\n$TXT_COLOR_WARN$(cat -n $exclusions_file)$TXT_COLOR_NONE"

    local datetime_str="$(date '+%Y%m%d_%H%M%S')_$salt"
    local snapshots_dir="$source_ws_dir/snapshots"
    local latest_snapshot_lnk="$snapshots_dir/latest"
    local logs_dir="${restore_path}_ws-restore/logs/$C0RC_HH_COOKIE"
    local log_file="$logs_dir/$datetime_str.log"

    mkdir -p "$logs_dir"
    if [ $? -ne 0 ]; then
        c0rc_bck_err "$msg_prologue error while creating log dir '${TXT_COLOR_YELLOW}$logs_dir${TXT_COLOR_NONE}'"
        c0rc_bck_close $source_name
        rm -f $exclusions_file
        return 1
    fi

    local current_snapshot_dir=""
    if [ -d $latest_snapshot_lnk ]; then
        current_snapshot_dir=$(readlink "$latest_snapshot_lnk")
        if [ $? -ne 0 ]; then
            c0rc_bck_err "$msg_prologue error while reading link to latest snapshot"
            c0rc_bck_close $source_name
            rm -f $exclusions_file
            return 1
        fi
    else
        c0rc_bck_err "$msg_prologue there is no any latest snapshot"
        c0rc_bck_close $source_name
        rm -f $exclusions_file
        return 1
    fi

    c0rc_bck_info "$msg_prologue snapshot '${TXT_COLOR_YELLOW}$current_snapshot_dir${TXT_COLOR_NONE}': need for your confirmation: $C0RC_OP_PROGRESS"
    echo -n "${TXT_COLOR_WARN}is it ok, continue? (y/n) ... " &&
        read -qs -t 15
    if [ $? -ne 0 ]; then
        echo
        c0rc_bck_err "$msg_prologue no confirmation received from you; cancel"
        c0rc_bck_close $source_name
        rm -f $exclusions_file
        return 1
    fi
    echo
    c0rc_bck_info "$msg_prologue need for your confirmation: $C0RC_OP_OK"

    c0rc_bck_info "$msg_prologue snapshot '${TXT_COLOR_YELLOW}$current_snapshot_dir${TXT_COLOR_NONE}': $C0RC_OP_PROGRESS"
    rsync \
        -a \
        --delete \
        --force \
        --whole-file \
        --sparse \
        --log-file="$log_file" \
        --exclude-from="$exclusions_file" \
        "$current_snapshot_dir/" \
        "$restore_path"
    if [ $? -ne 0 ]; then
        c0rc_bck_err "$msg_prologue snapshot '${TXT_COLOR_YELLOW}$current_snapshot_dir${TXT_COLOR_NONE}': $C0RC_OP_FAIL"
        c0rc_bck_close $source_name
        rm -f $exclusions_file
        return 1
    else
        c0rc_bck_info "$msg_prologue snapshot '${TXT_COLOR_YELLOW}$current_snapshot_dir${TXT_COLOR_NONE}': $C0RC_OP_OK"
    fi

    c0rc_bck_close $source_name
    if [ $? -ne 0 ]; then
        c0rc_bck_warn "$msg_prologue error while closing backup target device"
        rm -f $exclusions_file
        return 1
    fi

    rm -f $exclusions_file

    c0rc_bck_info "$msg_prologue $C0RC_OP_OK"

    return 0
}

function c0rc_bck_run_regular() {
    local kinds=''
    if [ $# -eq 1 ]; then
        kinds="$1"
    elif [ $# -eq 0 ]; then
        kinds="$C0RC_BCK_REGULAR_PLAN_KINDS"
    else
        c0rc_bck_err "too many args passed; only one argument allowed - specifying kinds"
        return 1
    fi

    c0rc_bck_run_precond_check
    if [ $? -ne 0 ]; then
        return 1
    fi

    local has_fail='n'
    local failed_kinds=''
    local succeeded_kinds=''
    for knd in $(<<<$kinds); do
        c0rc_splitter
        c0rc_bck_info "[${TXT_COLOR_YELLOW}$knd${TXT_COLOR_NONE}]: run regular backup $C0RC_OP_PROGRESS"

        local knd_status=1
        if [ "$knd" = "$C0RC_BCK_KIND_INSENSITIVE" ]; then
            c0rc_bck_run_insensitive && knd_status=0
        elif [ "$knd" = "$C0RC_BCK_KIND_SYSTEM" ]; then
            c0rc_bck_run_system && knd_status=0
        elif [ "$knd" = "$C0RC_BCK_KIND_WS" ]; then
            c0rc_bck_run_ws_to --target_name="$C0RC_BCK_WS_TARGET" && knd_status=0
        else
            c0rc_bck_warn "[${TXT_COLOR_YELLOW}$knd${TXT_COLOR_NONE}]: run regular backup; specified kind '${TXT_COLOR_YELLOW}$knd${TXT_COLOR_NONE}' not supported"
        fi

        if [ $knd_status -ne 0 ]; then
            has_fail='y'
            failed_kinds="$failed_kinds $knd"
        else
            succeeded_kinds="$succeeded_kinds $knd"
        fi
    done

    c0rc_splitter
    for knd in $(<<<$succeeded_kinds); do
        c0rc_bck_info "[${TXT_COLOR_YELLOW}$knd${TXT_COLOR_NONE}]: run regular backup $C0RC_OP_OK"
    done
    for knd in $(<<<$failed_kinds); do
        c0rc_bck_warn "[${TXT_COLOR_YELLOW}$knd${TXT_COLOR_NONE}]: run regular backup $C0RC_OP_FAIL"
    done

    if [ "$has_fail" = 'n' ]; then
        return 0
    else
        return 1
    fi
}

function c0rc_bck_ls_system() {
    if [ $# -ne 1 ]; then
        c0rc_bck_err "one argument specifying backup target name expected"
        return 1
    fi

    c0rc_bck_run_precond_check
    if [ $? -ne 0 ]; then
        return 1
    fi

    local bck_target="$1"

    local bck_device_uuid=""
    c0rc_bck_open "$bck_target" bck_device_uuid
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while opening backup target device; backup target '${TXT_COLOR_YELLOW}$bck_target${TXT_COLOR_NONE}'"
        return 1
    fi

    sudo timeshift --list --snapshot-device "$bck_device_uuid"
    if [ $? -ne 0 ]; then
        c0rc_bck_warn "error while listing backups; backup target '${TXT_COLOR_YELLOW}$bck_target${TXT_COLOR_NONE}'"
    fi

    c0rc_timeshift_mount_try_unmount

    c0rc_bck_close "$bck_target"
    if [ $? -ne 0 ]; then
        c0rc_bck_warn "error while closing backup target device; backup target '${TXT_COLOR_YELLOW}$bck_target${TXT_COLOR_NONE}'"
        return 1
    else
        return 0
    fi
}
