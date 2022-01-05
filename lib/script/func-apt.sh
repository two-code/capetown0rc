function c0rc_apt_dump_installed_pkgs() {
    local pkgs=$(sudo apt list --installed 2>/dev/null | sort | perl -n -e'/^([^\/]+)\/.+$/ && print "$1 "')
    if [ $? -ne 0 ]; then
        c0rc_err "error while listing installed packages"
        return 1
    fi

    echo -n "" >~/.installed-pkgs.tmp
    for pkg_name in $(echo $pkgs); do
        local pkg_status=$(dpkg -s $pkg_name)
        if [ $? -ne 0 ]; then
            c0rc_err "error while getting status of package $pkg_name"
            rm -f ~/.installed-pkgs.tmp
            return 1
        fi

        local pkg_version=$(echo $pkg_status | perl -n -e'/^Version:\s(.+)$/ && print "$1"')
        if [ $? -ne 0 ]; then
            c0rc_err "error while getting status of package $pkg_name"
            rm -f ~/.installed-pkgs.tmp
            return 1
        fi

        echo "${pkg_name}=${pkg_version}" >>~/.installed-pkgs.tmp
        c0rc_info "${pkg_name}=${pkg_version}"
    done

    sync -f
    if [ $? -ne 0 ]; then
        c0rc_err "error while syncing fs"
        return 1
    fi

    local pkg_count=$(wc -l <~/.installed-pkgs.tmp)

    c0rc_info "total packages count: ${pkg_count}"
    if ((pkg_count > 0)); then
        local save_loc="$C0RC_WS_BCK_OSSETTINGS_DIR/$(hostname)/installed-pkgs"
        mkdir -pv "${save_loc}"
        save_loc="${save_loc}/$(date '+%Y%m%d_%H%M%S').txt"
        cp -a ~/.installed-pkgs.tmp "${save_loc}" && c0rc_info "saved to: ${save_loc}"
    fi

    rm -f ~/.installed-pkgs.tmp

    c0rc_ok

    return 0
}

function c0rc_apt_upgrade_pkgs() {
    sudo apt-get update && sudo apt-get check
    if [ $? -ne 0 ]; then
        c0rc_err "error while updating and checking packages"
        return 1
    fi

    local non_kali_pkgs=$(sudo apt list --upgradable 2>/dev/null | sort | perl -n -e'/^((?!kali|openrazer|python3-openrazer|sublime-merge).*)\// && print "$1 "')
    if [ -n "$non_kali_pkgs" ]; then
        c0rc_info "non-kali packages:\n$non_kali_pkgs"

        c0rc_info "non-kali upgrade: $C0RC_OP_PROGRESS"
        while true; do
            local pkgs_part=$(sudo apt list --upgradable 2>/dev/null | sort | perl -n -e'/^((?!kali|openrazer|python3-openrazer|sublime-merge).*)\// && print "$1\n"' | head -n 20 | tr '\n' ' ')
            if [ -n "$pkgs_part" ]; then
                c0rc_splitter
                c0rc_info "upgrade part:\n$pkgs_part"
                sudo apt-get -y install $(echo -n $pkgs_part)
                if [ $? -ne 0 ]; then
                    c0rc_err "error while upgrading packages (see msgs above)"
                    return 1
                fi

                continue
            fi
            break
        done
        c0rc_info "non-kali upgrade: $C0RC_OP_OK"
    fi

    local kali_pkgs=$(sudo apt list --upgradable 2>/dev/null | sort | perl -n -e'/^((kali|openrazer|python3-openrazer|sublime-merge).*)\// && print "$1 "')
    if [ -n "$kali_pkgs" ]; then
        c0rc_warn "upgradable kali packages:\n$kali_pkgs"
    fi

    c0rc_ok

    return 0
}
