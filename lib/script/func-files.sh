function ww_cp_content() {
    local dst=""
    local exclude_regexp=""
    local src=""

    while [ $# -gt 0 ]; do
        case $1 in
        --from=?*)
            src="${1#*=}"
            ;;
        --to=?*)
            dst="${1#*=}"
            ;;
        --exclude_regexp=?*)
            exclude_regexp="${1#*=}"
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

    c0rc_info "[ww_cp_content]: from '${TXT_COLOR_WHITE}${src}${TXT_COLOR_NONE}' to '${TXT_COLOR_WHITE}${dst}${TXT_COLOR_NONE}': ..."

    local src_dirs=""
    if [ -z $exclude_regexp ]; then
        src_dirs="$(find "$src" -mindepth 1 -type d -print | xargs -P "$(nproc)" -I{} realpath --relative-to "$src" "{}")"
    else
        src_dirs="$(find "$src" -mindepth 1 -type d -print | xargs -P "$(nproc)" -I{} realpath --relative-to "$src" "{}" | grep -v -E "$exclude_regexp")"
    fi

    local src_files=""
    if [ -z $exclude_regexp ]; then
        src_files="$(find "$src" -not -type d -print | xargs -P "$(nproc)" -I{} realpath --relative-to "$src" "{}")"
    else
        src_files="$(find "$src" -not -type d -print | xargs -P "$(nproc)" -I{} realpath --relative-to "$src" "{}" | grep -v -E "$exclude_regexp")"
    fi

    echo $src_dirs | xargs -P "$(nproc)" -I{} mkdir -p "$dst/{}" &&
        echo $src_files | xargs -P "$(nproc)" -I{} cp -av "$src/{}" "$dst/{}" &&
        c0rc_ok &&
        return 0

    c0rc_err "[ww_cp_content]: from '${TXT_COLOR_WHITE}${src}${TXT_COLOR_NONE}' to '${TXT_COLOR_WHITE}${dst}${TXT_COLOR_NONE}': error (see msgs above, if any)"

    return 1
}
