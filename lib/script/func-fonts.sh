function c0rc_font_install_zip() {
    if [ $# -ne 1 ]; then
        c0rc_err "one argument specifying font zip-file expected"
        return 1
    fi

    local font_file=$(realpath $1)
    if [ $? -ne 0 ]; then
        c0rc_err "error (see msgs above, if any)"
        return 1
    fi

    c0rc_info "install font from '${TXT_COLOR_YELLOW}$font_file${TXT_COLOR_NONE}'"

    local tmp_dir=$(mktemp -d)
    unzip "$font_file" -d $tmp_dir
    if [ $? -ne 0 ]; then
        c0rc_err "error while unzipping"
        return 1
    fi

    c0rc_info "list of font files:\n$(find $tmp_dir -iname '*.ttf' -type f | xargs realpath --relative-to $tmp_dir)"
    for f in $(find $tmp_dir -iname '*.ttf' -type f); do
        local f_target="$(realpath ~/.fonts/$(basename $f))"
        mv $f $f_target
        if [ $? -ne 0 ]; then
            c0rc_err "error while moving font file '${TXT_COLOR_YELLOW}$f${TXT_COLOR_NONE}' into '${TXT_COLOR_YELLOW}$f_target${TXT_COLOR_NONE}'"
            return 1
        fi
        c0rc_info "font '${TXT_COLOR_YELLOW}$f${TXT_COLOR_NONE}' moved into '${TXT_COLOR_YELLOW}$f_target${TXT_COLOR_NONE}'"
    done

    c0rc_info "update font cache"
    fc-cache -fv

    rm -fdr $tmp_dir

    c0rc_ok

    return 0
}

function c0rc_font_personal_move_to_system() {
    for f in $(find ~/.fonts -iname '*.ttf' -type f); do
        local f_target="$(realpath /usr/share/fonts/truetype/$(basename $f))"
        sudo mv $f $f_target && sudo chmod a+r $f_target
        if [ $? -ne 0 ]; then
            c0rc_err "error while moving font file '${TXT_COLOR_YELLOW}$f${TXT_COLOR_NONE}' into '${TXT_COLOR_YELLOW}$f_target${TXT_COLOR_NONE}'"
            return 1
        fi
        c0rc_info "font '${TXT_COLOR_YELLOW}$f${TXT_COLOR_NONE}' moved into '${TXT_COLOR_YELLOW}$f_target${TXT_COLOR_NONE}'"
    done

    c0rc_info "update font cache"
    fc-cache -fv

    c0rc_ok

    return 0
}
