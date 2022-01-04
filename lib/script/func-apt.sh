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

    _info "total packages count: ${pkg_count}"
    if ((pkg_count > 0)); then
        local save_loc="$C0RC_WS_BCK_OSSETTINGS_DIR/$(hostname)/installed-pkgs"
        mkdir -pv "${save_loc}"
        save_loc="${save_loc}/$(date '+%Y%m%d_%H%M%S').txt"
        cp -a ~/.installed-pkgs.tmp "${save_loc}" && _info "saved to: ${save_loc}"
    fi

    rm -f ~/.installed-pkgs.tmp

    c0rc_ok

    return 0
}
