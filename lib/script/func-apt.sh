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

function c0rc_apt_upgradable_pkgs_names() {
    local exclude_hold=""
    if [ $# -eq 1 ]; then
        if [ "$1" = "y" ]; then
            exclude_hold="y"
        elif [ "$1" = "n" ]; then
            exclude_hold="n"
        else
            c0rc_err "value of arg [ exclude_hold ] is out of range: 'y' or 'n' expected"
            return 1
        fi
    elif [ $# -ne 0 ]; then
        c0rc_err "one or zero args expected: [ exclude_hold ]"
        return 1
    else
        exclude_hold="y"
    fi

    local upgradable_pkgs=$(sudo \
        apt \
        list --upgradable 2>/dev/null |
        LC_ALL=C sed 's/Listing\.\.\.//g' |
        LC_ALL=C sed '/^[[:space:]]*$/d' |
        LC_ALL=C sed -r 's/^([^[:space:]]+).*$/\1/g' |
        LC_ALL=C sed -r 's/^([^\/]*)\/.*$/\1/g' |
        LC_ALL=C sort)
    if [ $? -ne 0 ]; then
        c0rc_err "error while constructing list of upgradable pkgs (see msgs above)"
        return 1
    fi

    if [ "$exclude_hold" = "n" ]; then
        echo $upgradable_pkgs
        return 0
    fi

    local hold_pkgs_file=$(mktemp)
    if [ $? -ne 0 ]; then
        c0rc_err "error while creating tmp file"
        return 1
    fi

    local upgradable_pkgs_file=$(mktemp)
    if [ $? -ne 0 ]; then
        c0rc_err "error while creating tmp file"
        rm -f $hold_pkgs_file
        return 1
    fi
    echo $upgradable_pkgs >$upgradable_pkgs_file
    if [ $? -ne 0 ]; then
        c0rc_err "error while constructing list of upgradable pkgs (see msgs above)"
        rm -f $hold_pkgs_file
        rm -f $upgradable_pkgs_file
        return 1
    fi

    sudo apt-mark showhold | LC_ALL=C sort >$hold_pkgs_file
    if [ $? -ne 0 ]; then
        c0rc_err "error while constructing list of hold pkgs (see msgs above)"
        rm -f $hold_pkgs_file
        rm -f $upgradable_pkgs_file
        return 1
    fi

    LC_ALL=C comm -23 $upgradable_pkgs_file $hold_pkgs_file
    if [ $? -ne 0 ]; then
        c0rc_err "error while comparing list of pkgs"
        rm -f $hold_pkgs_file
        rm -f $upgradable_pkgs_file
        return 1
    fi

    rm -f $hold_pkgs_file
    rm -f $upgradable_pkgs_file

    return 0
}

function c0rc_apt_upgrade() {
    c0rc_info "update and check: $C0RC_OP_PROGRESS"
    sudo apt-get update && sudo apt-get check
    if [ $? -ne 0 ]; then
        c0rc_err "error while updating and checking packages"
        return 1
    fi
    c0rc_info "update and check: $C0RC_OP_OK"

    local unhold_upgradable_pkgs=$(c0rc_apt_upgradable_pkgs_names)
    if [ $? -ne 0 ]; then
        c0rc_err "error while build upgradable pkgs list names (excluding held pkgs)"
        return 1
    fi

    if [ -n "$unhold_upgradable_pkgs" ]; then
        c0rc_info "non-held pkgs:\n$(echo $unhold_upgradable_pkgs | cat -n)"

        c0rc_info "non-held upgrade: $C0RC_OP_PROGRESS"
        ((offset = 1))
        ((part_size = 23))
        ((part_num = 1))
        while true; do
            local pkgs_part=$(echo $unhold_upgradable_pkgs | tail -n +"$offset" | head -n "$part_size" | tr '\n' ' ')
            if [ -n "$pkgs_part" ]; then
                c0rc_splitter
                c0rc_info "upgrade part $part_num:\n$(echo $pkgs_part | cat -n)"
                sudo apt-get -y "$@" install $(echo -n $pkgs_part)
                if [ $? -ne 0 ]; then
                    c0rc_err "error while upgrading packages (see msgs above)"
                    return 1
                fi

                ((offset = offset + part_size))
                ((part_num++))

                continue
            fi

            break
        done
        c0rc_splitter
        c0rc_info "non-held upgrade: $C0RC_OP_OK"
    else
        c0rc_info "no non-held pkgs to upgrade"
    fi

    local upgradable_pkgs=$(c0rc_apt_upgradable_pkgs_names n)
    if [ $? -ne 0 ]; then
        c0rc_err "error while build upgradable pkgs list names"
        return 1
    elif [ -n "$upgradable_pkgs" ]; then
        c0rc_warn "rest of upgradable pkgs (${TXT_COLOR_WARN}possibly, these pkgs are held${TXT_COLOR_NONE}):\n$(echo $upgradable_pkgs | cat -n)"
    fi

    c0rc_ok

    return 0
}
