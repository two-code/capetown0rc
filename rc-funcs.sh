function _otp() {
    oathtool -b --totp $(gpg2 --quiet -u "${__gpg_kid}" -r "me@vitalik-malkin.email" --decrypt $__2fa/$1)
}

# commented by vitalik 2021-10-31T19:47
# _bck() {
#     echo -e "${__color_cyan}do backup plans: '$1', '$2' ${__color_none}";
#
#     local _isBck4Up="n";
#     local _bck4MountPoint="/mnt/bck4";
#     local _isBck3Up="n";
#     local _bck3MountPoint="/mnt/storage-v";
#
#     if [ $_bck4MountPoint == $( lsblk -l -o MOUNTPOINT | awk '/^\/mnt\/bck4$/ {print $1}' ) ]
#     then
#         _isBck4Up='y'
#     fi
#
#     if [ $_bck3MountPoint == $( lsblk -l -o MOUNTPOINT | awk '/^\/mnt\/storage\-v$/ {print $1}' ) ]
#     then
#         _isBck3Up='y'
#     fi
#
#     echo -e "${__color_cyan}================================================================================"
#     echo "bck4 up: ${_isBck4Up}";
#     echo "bck3 up: ${_isBck3Up}${__color_none}";
#
#     if [ $1 == "home" ] || [ $2 == "home" ]
#     then
#         echo -e "${__color_cyan}================================================================================"
#         echo -e "do backup plan 'home'...${__color_none}";
#
#         cd ~/ \
#         && ( ( if [ $_isBck3Up == "n" ]; then; ./__bck3-up.sh; fi; ) || ( echo -n "" > /dev/null; ) ) \
#         && ./__bck3-do-home.sh \
#         && ( ( if [ $_isBck3Up == "n" ]; then; ./__bck3-down.sh; fi; ) || ( echo -n "" > /dev/null; ) ) \
#         && ( ( if [ $_isBck4Up == "n" ]; then; ./__bck4-up.sh; fi; ) || ( echo -n "" > /dev/null; ) ) \
#         && ./__bck4-do-home.sh \
#         && ( ( if [ $_isBck4Up == "n" ]; then; ./__bck4-down.sh; fi; ) || ( echo -n "" > /dev/null; ) );
#
#     fi
#
#     if [ $1 == "sys" ] || [ $2 == "sys" ]
#     then
#         echo -e "${__color_cyan}================================================================================"
#         echo -e "do backup plan 'sys'...${__color_none}";
#
#         cd ~/ \
#         && ( ( if [ $_isBck3Up == "n" ]; then; ./__bck3-up.sh; fi; ) || ( echo -n "" > /dev/null; ) ) \
#         && ./__bck3-do-sys.sh \
#         && ( ( if [ $_isBck3Up == "n" ]; then; ./__bck3-down.sh; fi; ) || ( echo -n "" > /dev/null; ) ) \
#         && ( ( if [ $_isBck4Up == "n" ]; then; ./__bck4-up.sh; fi; ) || ( echo -n "" > /dev/null; ) ) \
#         && ./__bck4-do-sys.sh \
#         && ( ( if [ $_isBck4Up == "n" ]; then; ./__bck4-down.sh; fi; ) || ( echo -n "" > /dev/null; ) );
#
#     fi
#
# }

function _get_secret() {
    locFileName=$(echo $1 | basenc --base32hex)
    locFileName="${__gpg_secrets_dir}/${locFileName}"
    gpg2 --quiet -u "${__gpg_kid}" -r "me@vitalik-malkin.email" --decrypt "${locFileName}"
}

function _set_secret() {
    locFileName=$(echo $1 | basenc --base32hex)
    locFileName="${__gpg_secrets_dir}/${locFileName}"
    gpg2 -u "${__gpg_kid}" -r "${__gpg_uid}" --quiet --encrypt -o "${locFileName}" && echo -e "\n${__color_yellow}done.${__color_none}"
}

function _docs_up() {
    $__script_root/__docs-up.sh &&
        _info "${TXT_COLOR_GREEN}[_docs_up]${TXT_COLOR_NONE}: all done"
    return 0
}

function _docs_down() {
    $__script_root/__docs-down.sh &&
        _info "${TXT_COLOR_GREEN}[_docs_down]${TXT_COLOR_NONE}: all done"
    return 0
}

function _secs_up() {
    $__script_root/__sec-up.sh &&
        _info "${TXT_COLOR_GREEN}[_secs_up]${TXT_COLOR_NONE}: all done"
    return 0
}

function _secs_down() {
    $__script_root/__sec-down.sh &&
        _info "${TXT_COLOR_GREEN}[_secs_down]${TXT_COLOR_NONE}: all done"
    return 0
}

function _bck3_timeshift() {
    $__script_root/__bck3-up.sh &&
        sudo timeshift --create --comments "note: $1" --snapshot-device ee29302d-f7e7-407b-9896-8cff86efed75 &&
        sync -f &&
        _bck_timeshift_clean &&
        sudo timeshift --list --snapshot-device ee29302d-f7e7-407b-9896-8cff86efed75 &&
        sudo umount --verbose "/run/timeshift/backup" &&
        $__script_root/__bck3-down.sh &&
        _info "${TXT_COLOR_GREEN}[_bck3_timeshift]${TXT_COLOR_NONE}: all done"
    return 0
}

function _bck3_up() {
    $__script_root/__bck3-up.sh &&
        _info "${TXT_COLOR_GREEN}[_bck3_up]${TXT_COLOR_NONE}: all done"
    return 0
}

function _bck3_down() {
    sudo umount --verbose "/run/timeshift/backup"
    $__script_root/__bck3-down.sh &&
        _info "${TXT_COLOR_GREEN}[_bck3_down]${TXT_COLOR_NONE}: all done"
    return 0
}

function _bck4_timeshift() {
    $__script_root/__bck4-up.sh &&
        sudo timeshift --create --comments "note: $1" --snapshot-device 52997247-9b4a-4cae-80c1-8fd4bdb384ae &&
        sync -f &&
        _bck_timeshift_clean &&
        sudo timeshift --list --snapshot-device 52997247-9b4a-4cae-80c1-8fd4bdb384ae &&
        sudo umount --verbose "/run/timeshift/backup" &&
        $__script_root/__bck4-down.sh &&
        _info "${TXT_COLOR_GREEN}[_bck4_timeshift]${TXT_COLOR_NONE}: all done"
    return 0
}

function _bck4_up() {
    $__script_root/__bck4-up.sh &&
        _info "${TXT_COLOR_GREEN}[_bck4_up]${TXT_COLOR_NONE}: all done"
    return 0
}

function _bck4_down() {
    sudo umount --verbose "/run/timeshift/backup"
    $__script_root/__bck4-down.sh &&
        _info "${TXT_COLOR_GREEN}[_bck4_down]${TXT_COLOR_NONE}: all done"
    return 0
}

function _bck7_timeshift() {
    $__script_root/__bck7-up.sh &&
        sudo timeshift --create --comments "note: $1" --snapshot-device 10b8f361-2861-4c1d-98c7-08673758f700 &&
        sync -f &&
        _bck_timeshift_clean &&
        sudo timeshift --list --snapshot-device 10b8f361-2861-4c1d-98c7-08673758f700 &&
        sudo umount --verbose "/run/timeshift/backup" &&
        $__script_root/__bck7-down.sh &&
        _info "${TXT_COLOR_GREEN}[_bck7_timeshift]${TXT_COLOR_NONE}: all done"
    return 0
}

function _bck7_up() {
    $__script_root/__bck7-up.sh &&
        _info "${TXT_COLOR_GREEN}[_bck7_up]${TXT_COLOR_NONE}: all done"
    return 0
}

function _bck7_down() {
    sudo umount --verbose "/run/timeshift/backup"
    $__script_root/__bck7-down.sh &&
        _info "${TXT_COLOR_GREEN}[_bck7_down]${TXT_COLOR_NONE}: all done"
    return 0
}

function _bck_timeshift_clean() {
    sudo $__script_root/go/bin/capetown0 bck timeshift clean --retain-count=11 &&
        _info "${TXT_COLOR_GREEN}[_bck_timeshift_clean]${TXT_COLOR_NONE}: all done"
    return 0
}

function _bck_timeshift_regular() {
    _bck7_timeshift "regular - $(date)"
    _bck4_timeshift "regular - $(date)"
    return 0
}

function _bck_insensitive() {
    _bck_insensitive_one "bck7-key"
    _bck_insensitive_one "bck4-key"
}

function _bck_insensitive_one() {
    local bck_device=$(realpath /dev/disk/by-partlabel/$1)
    if [ $? -ne 0 ]; then
        _err "error while getting device path for '$1'"
        return 1
    fi

    local mnt_pth="/mnt/tmp-$(head -c 16 /dev/urandom | xxd -l 16 -p)"

    sudo mkdir -p $mnt_pth &&
        sudo chown vitalik:vitalik $mnt_pth
    if [ $? -ne 0 ]; then
        _err "error while creating tmp mount point"
        return 1
    fi

    sudo mount $bck_device "${mnt_pth}"
    if [ $? -ne 0 ]; then
        _err "error while mounting backup device '$1'"
        return 1
    fi

    local save_loc="./insensitive/$(hostname)-$(date '+%Y%m%d_%H%M')-$(head -c 4 /dev/urandom | xxd -l 4 -p)"
    pushd $mnt_pth >/dev/null
    sudo mkdir -p $save_loc &&
        sudo mkdir -p "${save_loc}/root" &&
        sudo mkdir -p "${save_loc}/etc" &&
        sudo mkdir -p "${save_loc}/etc/apt" &&
        sudo mkdir -p "${save_loc}/etc/apt/sources.list.d" &&
        sudo mkdir -p "${save_loc}/usr/share/keyrings" &&
        sudo mkdir -p "${save_loc}/boot/grub/themes/kali" &&
        sudo mkdir -p "${save_loc}/workspace/_backup/os-settings" &&
        sudo cp -ar ~/workspace/_backup/os-settings "${save_loc}/workspace/_backup/" &&
        sudo cp -ar ~/workspace/corsair-keyboard.ckb "${save_loc}/workspace/" &&
        sudo cp -ar ~/workspace/logitech-default.gpfl "${save_loc}/workspace/" &&
        sudo cp -ar ~/workspace/my-ublock-* "${save_loc}/workspace/" &&
        sudo cp -ar ~/.gitconfig "${save_loc}/" &&
        sudo cp -ar ~/.clickhouse-client-history "${save_loc}/" &&
        sudo cp -ar ~/.capetown0rc "${save_loc}/" &&
        sudo cp -ar ~/.secrets "${save_loc}/" &&
        sudo cp -ar ~/.ssh "${save_loc}/" &&
        sudo cp -ar ~/.2fa "${save_loc}/" &&
        sudo cp -ar ~/.zsh_history "${save_loc}/" &&
        sudo cp -ar ~/.zshrc "${save_loc}/" &&
        sudo cp -ar ~/.profile "${save_loc}/" &&
        sudo cp -ar /root/.zsh_history "${save_loc}/root/" &&
        sudo cp -ar /root/.zshrc "${save_loc}/root/" &&
        sudo cp -ar /root/.profile "${save_loc}/root/" &&
        sudo cp -ar /etc/environment "${save_loc}/etc/" &&
        sudo cp -ar /etc/ssh "${save_loc}/etc/" &&
        sudo cp -ar /etc/sddm "${save_loc}/etc/" &&
        sudo cp -ar /etc/sddm.conf.d "${save_loc}/etc/" &&
        sudo cp -ar /etc/sddm.conf "${save_loc}/etc/" &&
        sudo cp -ar /etc/apt/sources.list "${save_loc}/etc/apt" &&
        sudo cp -ar /etc/apt/sources.list.d "${save_loc}/etc/apt" &&
        sudo cp -ar /usr/share/keyrings "${save_loc}/usr/share" &&
        sudo cp -ar /etc/fstab "${save_loc}/etc/" &&
        sudo cp -ar /etc/crypttab "${save_loc}/etc/" &&
        sudo cp -ar /boot/grub/themes "${save_loc}/boot/grub/themes" &&
        sudo cp -ar /etc/default "${save_loc}/etc/"
    if [ $? -ne 0 ]; then
        _err "error while copying"
        popd >/dev/null
        return 1
    fi

    sync -f
    if [ $? -ne 0 ]; then
        _err "error while flushing fs buffers"
        return 1
    fi

    local save_loc_full=$(realpath $save_loc)
    for dir_to_remove in $(find ./insensitive -mindepth 1 -maxdepth 1 -type d | xargs realpath); do
        if [ ! "${save_loc_full}" = "${dir_to_remove}" ]; then
            _warn "remove backup '$dir_to_remove'"
            sudo chattr -i -R "${dir_to_remove}"
            sudo rm -fdr "${dir_to_remove}"
        fi
    done

    sudo chattr +i -R "${save_loc}"
    if [ $? -ne 0 ]; then
        _err "error while setting read-only attr"
        popd >/dev/null
        return 1
    fi

    sync -f
    if [ $? -ne 0 ]; then
        _err "error while flushing fs buffers"
        return 1
    fi

    _info "size: $(du -sh $save_loc)"
    popd >/dev/null

    _info "total size: $(du -sh $mnt_pth)"

    sudo umount "${mnt_pth}"
    if [ $? -ne 0 ]; then
        _err "error while unmounting backup device '$1'"
        return 1
    fi

    sudo rm -d "${mnt_pth}"
    if [ $? -ne 0 ]; then
        _err "error while removing tmp mount point '$mnt_pth'"
        return 1
    fi

    _info "${TXT_COLOR_GREEN}[$1]${TXT_COLOR_NONE}: all done"

    return 0
}

function _upgrade_pkgs() {
    sudo apt-get update && sudo apt-get check
    if [ $? -ne 0 ]; then
        _err "error while updating and checking packages"
        return 1
    fi

    local non_kali_pkgs=$(sudo apt list --upgradable 2>/dev/null | sort | perl -n -e'/^((?!kali).*)\// && print "$1 "')
    if [ -n "${non_kali_pkgs}" ]; then
        _info "non-kali packages:\n${non_kali_pkgs}"

        _info "begin non-kali upgrade..."
        while true; do
            local pkgs_part=$(sudo apt list --upgradable 2>/dev/null | sort | perl -n -e'/^((?!kali).*)\// && print "$1\n"' | head -n 20 | tr '\n' ' ')
            if [ -n "${pkgs_part}" ]; then
                _info "${TXT_SPLITTER}"
                _info "upgrade part:\n${pkgs_part}"
                sudo apt-get -y install $(echo -n $pkgs_part)
                if [ $? -ne 0 ]; then
                    _err "error while upgrading packages (see msgs above)"
                    return 1
                fi

                continue
            fi
            break
        done
        _info "non-kali upgrade done"
    fi

    local kali_pkgs=$(sudo apt list --upgradable 2>/dev/null | sort | perl -n -e'/^(kali.*)\// && print "$1 "')
    if [ -n "${kali_pkgs}" ]; then
        _warn "upgradable kali packages:\n${kali_pkgs}"
    fi

    _info "all done"

    return 0
}

function _dump_installed_pkgs() {
    local pkgs=$(sudo apt list --installed 2>/dev/null | sort | perl -n -e'/^([^\/]+)\/.+$/ && print "$1 "')
    if [ $? -ne 0 ]; then
        _err "error while listing installed packages"
        return 1
    fi

    echo -n "" >~/.installed-pkgs.tmp
    for pkg_name in $(echo $pkgs); do
        local pkg_status=$(dpkg -s $pkg_name)
        if [ $? -ne 0 ]; then
            _err "error while getting status of package $pkg_name"
            rm -f ~/.installed-pkgs.tmp
            return 1
        fi

        local pkg_version=$(echo $pkg_status | perl -n -e'/^Version:\s(.+)$/ && print "$1"')
        if [ $? -ne 0 ]; then
            _err "error while getting status of package $pkg_name"
            rm -f ~/.installed-pkgs.tmp
            return 1
        fi

        _info "${pkg_name}=${pkg_version}"
        echo "${pkg_name}=${pkg_version}" >>~/.installed-pkgs.tmp
    done

    sync -f
    if [ $? -ne 0 ]; then
        _err "error while flushing fs buffers"
        return 1
    fi

    local pkg_count=$(wc -l <~/.installed-pkgs.tmp)

    _info "total packages count: ${pkg_count}"
    if ((pkg_count > 0)); then
        local save_loc="/home/vitalik/workspace/_backup/os-settings/$(hostname)/installed-pkgs"
        mkdir -pv "${save_loc}"
        save_loc="${save_loc}/$(date '+%Y%m%d_%H%M%S').txt"
        cp -a ~/.installed-pkgs.tmp "${save_loc}" && _info "saved to: ${save_loc}"
    fi

    rm -f ~/.installed-pkgs.tmp

    _info "all done"

    return 0
}

function _restart_plasma() {
    bash -c 'kquitapp5 plasmashell || killall plasmashell && kstart5 plasmashell &'

    return 0
}

function _install_font_zip() {
    local font_file=$(realpath $1)
    if [ $? -ne 0 ]; then
        _err "error (see msgs above, if any)..."
        return 1
    fi

    _info "install font from '$font_file'..."

    local tmp_dir=$(mktemp -d)
    unzip "$font_file" -d $tmp_dir
    if [ $? -ne 0 ]; then
        _err "error while unzipping"
        return 1
    fi

    _info "list of font files:\n$(find $tmp_dir -iname '*.ttf' -type f | xargs realpath --relative-to $tmp_dir)"
    for f in $(find $tmp_dir -iname '*.ttf' -type f); do
        local f_target="$(realpath ~/.fonts/$(basename $f))"
        mv $f $f_target
        if [ $? -ne 0 ]; then
            _err "error while moving font file '$f' into '$f_target'"
            return 1
        fi
        _info "font '$f' moved into '$f_target'"
    done

    _info "update font cache..."
    fc-cache -fv

    rm -fdr $tmp_dir

    _info "all done"

    return 0
}

function _move_personal_tt_fonts_to_system() {
    for f in $(find ~/.fonts -iname '*.ttf' -type f); do
        local f_target="$(realpath /usr/share/fonts/truetype/$(basename $f))"
        sudo mv $f $f_target && sudo chmod a+r $f_target
        if [ $? -ne 0 ]; then
            _err "error while moving font file '$f' into '$f_target'"
            return 1
        fi
        _info "font '$f' moved into '$f_target'"
    done

    _info "update font cache..."
    fc-cache -fv

    _info "all done"

    return 0
}
