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
