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
        c0rc_bck_err "error while resolving disk by backup partition label '${TXT_COLOR_YELLOW}$partition_label${TXT_COLOR_NONE}'"
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

    if [ $# -eq 2 ]; then
        eval "$2=$luks_device_uuid_loc"
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
    if [ $# -ne 1 ]; then
        c0rc_bck_err "one argument specifying backup name expected"
        return 1
    fi

    local backend_device=$(realpath /dev/disk/by-partlabel/$1)
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while getting device path for '${TXT_COLOR_YELLOW}$1${TXT_COLOR_NONE}'"
        return 1
    fi

    local mnt_pth="/mnt/tmp-$(c0rc_gen_uuid)"

    sudo mkdir -p $mnt_pth &&
        sudo chown vitalik:vitalik $mnt_pth
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while creating tmp mount point"
        return 1
    fi

    sudo mount $backend_device "$mnt_pth"
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while mounting '${TXT_COLOR_YELLOW}$backend_device${TXT_COLOR_NONE}'"
        return 1
    fi

    local save_loc="./insensitive/$(hostname)-$(date '+%Y%m%d_%H%M')-$(head -c 4 /dev/urandom | xxd -c 4 -l 4 -p)"
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while generating name of tmp save location"
        return 1
    fi

    pushd $mnt_pth >/dev/null
    sudo mkdir -p $save_loc &&
        sudo mkdir -p "$save_loc/root" &&
        sudo mkdir -p "$save_loc/etc" &&
        sudo mkdir -p "$save_loc/etc/apt" &&
        sudo mkdir -p "$save_loc/etc/apt/sources.list.d" &&
        sudo mkdir -p "$save_loc/usr/share/keyrings" &&
        sudo mkdir -p "$save_loc/boot/grub/themes/kali" &&
        sudo mkdir -p "$save_loc/workspace/_backup/os-settings" &&
        sudo cp -ar ~/workspace/_backup/os-settings "$save_loc/workspace/_backup/" &&
        sudo cp -ar ~/workspace/corsair-keyboard.ckb "$save_loc/workspace/" &&
        sudo cp -ar ~/workspace/logitech-default.gpfl "$save_loc/workspace/" &&
        sudo cp -ar ~/workspace/my-ublock-* "$save_loc/workspace/" &&
        sudo cp -ar ~/.gitconfig "$save_loc/" &&
        sudo cp -ar ~/.clickhouse-client-history "$save_loc/" &&
        sudo cp -ar ~/.capetown0rc "$save_loc/" &&
        sudo cp -ar ~/.secrets "$save_loc/" &&
        sudo cp -ar ~/.ssh "$save_loc/" &&
        sudo cp -ar ~/.2fa "$save_loc/" &&
        sudo cp -ar ~/.zsh_history "$save_loc/" &&
        sudo cp -ar ~/.zshrc "$save_loc/" &&
        sudo cp -ar ~/.profile "$save_loc/" &&
        sudo cp -ar /root/.zsh_history "$save_loc/root/" &&
        sudo cp -ar /root/.zshrc "$save_loc/root/" &&
        sudo cp -ar /root/.profile "$save_loc/root/" &&
        sudo cp -ar /etc/environment "$save_loc/etc/" &&
        sudo cp -ar /etc/ssh "$save_loc/etc/" &&
        sudo cp -ar /etc/sddm "$save_loc/etc/" &&
        sudo cp -ar /etc/sddm.conf.d "$save_loc/etc/" &&
        sudo cp -ar /etc/sddm.conf "$save_loc/etc/" &&
        sudo cp -ar /etc/apt/sources.list "$save_loc/etc/apt" &&
        sudo cp -ar /etc/apt/sources.list.d "$save_loc/etc/apt" &&
        sudo cp -ar /usr/share/keyrings "$save_loc/usr/share" &&
        sudo cp -ar /etc/fstab "$save_loc/etc/" &&
        sudo cp -ar /etc/crypttab "$save_loc/etc/" &&
        sudo cp -ar /boot/grub/themes "$save_loc/boot/grub/themes" &&
        sudo cp -ar /etc/default "$save_loc/etc/"
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while copying"
        popd >/dev/null
        return 1
    fi

    sync -f
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while syncing fs"
        popd >/dev/null
        return 1
    fi

    local save_loc_full=$(realpath $save_loc)
    for dir_to_remove in $(find ./insensitive -mindepth 1 -maxdepth 1 -type d | xargs realpath); do
        if [ ! "$save_loc_full" = "$dir_to_remove" ]; then
            c0rc_bck_warn "remove backup '${TXT_COLOR_YELLOW}$dir_to_remove${TXT_COLOR_NONE}': ..."
            sudo chattr -i -R "$dir_to_remove"
            sudo rm -fdr "$dir_to_remove"
            if [ $? -ne 0 ]; then
                c0rc_bck_warn "remove backup '${TXT_COLOR_YELLOW}$dir_to_remove${TXT_COLOR_NONE}': ${TXT_COLOR_RED}FAIL${TXT_COLOR_NONE}"
            else
                c0rc_bck_warn "remove backup '${TXT_COLOR_YELLOW}$dir_to_remove${TXT_COLOR_NONE}': ${TXT_COLOR_GREEN}OK${TXT_COLOR_NONE}"
            fi
        fi
    done

    sudo chattr +i -R "$save_loc"
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while setting read-only attr"
        popd >/dev/null
        return 1
    fi

    sync -f
    if [ $? -ne 0 ]; then
        c0rc_bck_err "error while syncing fs"
        popd >/dev/null
        return 1
    fi

    c0rc_bck_info "size '${TXT_COLOR_YELLOW}$(du -sh $save_loc)${TXT_COLOR_NONE}'"
    popd >/dev/null

    c0rc_bck_info "total size '${TXT_COLOR_YELLOW}$(du -sh $mnt_pth)${TXT_COLOR_NONE}'"

    sudo umount "$mnt_pth"
    if [ $? -ne 0 ]; then
        c0rc_bck_warn "error while unmounting backup device '${TXT_COLOR_YELLOW}$backend_device${TXT_COLOR_NONE}'"
    fi

    sudo rm -d "$mnt_pth"
    if [ $? -ne 0 ]; then
        c0rc_bck_warn "error while removing tmp mount point '${TXT_COLOR_YELLOW}$mnt_pth${TXT_COLOR_NONE}'"
    fi

    return 0
}

function c0rc_bck_run_insensitive() {
    local has_fail='n'
    for trg in $(<<<$C0RC_BCK_INSENSITIVE_TARGETS); do
        c0rc_bck_info "run insensitive backup to '${TXT_COLOR_YELLOW}$trg${TXT_COLOR_NONE}': ..."
        c0rc_bck_run_insensitive_to "$trg"
        if [ $? -ne 0 ]; then
            has_fail='y'
            c0rc_bck_warn "run insensitive backup to '${TXT_COLOR_YELLOW}$trg${TXT_COLOR_NONE}': ${TXT_COLOR_RED}FAIL${TXT_COLOR_NONE}"
        else
            c0rc_bck_info "run insensitive backup to '${TXT_COLOR_YELLOW}$trg${TXT_COLOR_NONE}': ${TXT_COLOR_GREEN}OK${TXT_COLOR_NONE}"
        fi
    done

    if [ "$has_fail" = 'n' ]; then
        return 0
    else
        return 1
    fi
}
