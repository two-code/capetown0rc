export TXT_COLOR_CYAN="${TXT_COLOR_CYAN:-\033[0;36m}"
export TXT_COLOR_GREEN="${TXT_COLOR_GREEN:-\033[0;32m}"
export TXT_COLOR_NONE="${TXT_COLOR_NONE:-\033[0m}"
export TXT_COLOR_ORANGE="${TXT_COLOR_ORANGE:-\033[38;5;208m}"
export TXT_COLOR_RED="${TXT_COLOR_RED:-\033[1;31m}"
export TXT_COLOR_WHITE="${TXT_COLOR_WHITE:-\033[1;37m}"
export TXT_COLOR_YELLOW="${TXT_COLOR_YELLOW:-\033[0;33m}"

export TXT_COLOR_ERR="${TXT_COLOR_ERR:-$TXT_COLOR_RED}"
export TXT_COLOR_WARN="${TXT_COLOR_WARN:-$TXT_COLOR_ORANGE}"

export TXT_SPLITTER_COLOR="${TXT_SPLITTER_COLOR:-\033[38;5;147m}"
export TXT_SPLITTER="${TXT_SPLITTER:---------------------------------------------------------------------------------}"

export GDK_SCALE=1.0
export GDK_DPI_SCALE=1.0

# op status {{{
export readonly C0RC_OP_PROGRESS="..."
export readonly C0RC_OP_OK="... ${TXT_COLOR_GREEN}OK${TXT_COLOR_NONE}"
export readonly C0RC_OP_FAIL="... ${TXT_COLOR_RED}FAIL${TXT_COLOR_NONE}"
# }}}

# backup {{{
export readonly C0RC_BCK_KIND_SYSTEM="system"
export readonly C0RC_BCK_KIND_INSENSITIVE="insensitive"

export C0RC_BCK_OUTPUT_INIT_PARAMS="${C0RC_BCK_OUTPUT_INIT_PARAMS:-n}"

export C0RC_BCK_VOLUME_DEFAULT_FS="${C0RC_BCK_VOLUME_DEFAULT_FS:-ext4}"

export C0RC_BCK_INSENSITIVE_TARGET_POSTFIX="${C0RC_BCK_INSENSITIVE_TARGET_POSTFIX:--key}"
export C0RC_BCK_INSENSITIVE_TARGETS="${C0RC_BCK_INSENSITIVE_TARGETS:-}"
if [ -z $C0RC_BCK_INSENSITIVE_TARGETS ]; then
    if [ "$(hostname)" = "capetown0" ]; then
        C0RC_BCK_INSENSITIVE_TARGETS="bck7 bck4 bck3"
    elif [ "$(hostname)" = "capetown2" ]; then
        C0RC_BCK_INSENSITIVE_TARGETS="bck3-key"
    else
        C0RC_BCK_INSENSITIVE_TARGETS=""
        echo -e "${TXT_COLOR_ORANGE}[$(date +'%Y-%m-%dT%H:%M:%S%z')] WARN:${TXT_COLOR_NONE} can't set appropriate value for '${TXT_COLOR_YELLOW}C0RC_BCK_INSENSITIVE_TARGETS${TXT_COLOR_NONE}'; unrecognized hostname '${TXT_COLOR_YELLOW}$(hostname)${TXT_COLOR_NONE}'" >&2
    fi
fi

export C0RC_BCK_SYSTEM_TARGETS="${C0RC_BCK_SYSTEM_TARGETS:-}"
if [ -z $C0RC_BCK_SYSTEM_TARGETS ]; then
    if [ "$(hostname)" = "capetown0" ]; then
        C0RC_BCK_SYSTEM_TARGETS="bck7 bck4"
    elif [ "$(hostname)" = "capetown2" ]; then
        C0RC_BCK_SYSTEM_TARGETS="bck3"
    else
        C0RC_BCK_SYSTEM_TARGETS=""
        echo -e "${TXT_COLOR_ORANGE}[$(date +'%Y-%m-%dT%H:%M:%S%z')] WARN:${TXT_COLOR_NONE} can't set appropriate value for '${TXT_COLOR_YELLOW}C0RC_BCK_SYSTEM_TARGETS${TXT_COLOR_NONE}'; unrecognized hostname '${TXT_COLOR_YELLOW}$(hostname)${TXT_COLOR_NONE}'" >&2
    fi
fi

export C0RC_BCK_SYSTEM_RETENTION="${C0RC_BCK_SYSTEM_RETENTION:-3}"

export C0RC_BCK_REGULAR_PLAN_KINDS="${C0RC_BCK_REGULAR_PLAN_KINDS:-}"
if [ -z $C0RC_BCK_REGULAR_PLAN_KINDS ]; then
    if [ "$(hostname)" = "capetown0" ]; then
        C0RC_BCK_REGULAR_PLAN_KINDS="$C0RC_BCK_KIND_INSENSITIVE $C0RC_BCK_KIND_SYSTEM"
    elif [ "$(hostname)" = "capetown2" ]; then
        C0RC_BCK_REGULAR_PLAN_KINDS="$C0RC_BCK_KIND_INSENSITIVE $C0RC_BCK_KIND_SYSTEM"
    else
        C0RC_BCK_REGULAR_PLAN_KINDS=""
        echo -e "${TXT_COLOR_ORANGE}[$(date +'%Y-%m-%dT%H:%M:%S%z')] WARN:${TXT_COLOR_NONE} can't set appropriate value for '${TXT_COLOR_YELLOW}C0RC_BCK_REGULAR_PLAN_KINDS${TXT_COLOR_NONE}'; unrecognized hostname '${TXT_COLOR_YELLOW}$(hostname)${TXT_COLOR_NONE}'" >&2
    fi
fi
# }}}

# security/crypto/luks/gpg {{{
export C0RC_SECRETS_DIR="${C0RC_SECRETS_DIR:-"$HOME/.secrets"}"
export C0RC_SECRETS_GPG_DIR="${C0RC_SECRETS_GPG_DIR:-"$C0RC_SECRETS_DIR/gpg"}"
export C0RC_2FA_DIR="${C0RC_2FA_DIR:-"$HOME/.2fa"}"

export C0RC_SECV_LEGACY_IMG="${C0RC_SECV_LEGACY_IMG:-"$HOME/.secv-legacy/image.img"}"

export C0RC_SECV_IMG="${C0RC_SECV_IMG:-}"
if [ -z $C0RC_SECV_IMG ]; then
    if [ "$(hostname)" = "capetown0" ]; then
        C0RC_SECV_IMG="$HOME/.secv-c0.img"
    elif [ "$(hostname)" = "capetown2" ]; then
        C0RC_SECV_IMG="$HOME/.secv-c2.img"
    else
        C0RC_SECV_IMG=""
        echo -e "${TXT_COLOR_WARN}[$(date +'%Y-%m-%dT%H:%M:%S%z')] WARN:${TXT_COLOR_NONE} can't set appropriate value for '${TXT_COLOR_YELLOW}C0RC_SECV_IMG${TXT_COLOR_NONE}'; unrecognized hostname '${TXT_COLOR_YELLOW}$(hostname)${TXT_COLOR_NONE}'" >&2
    fi
fi

export C0RC_SECV_LOOP_NAME="${C0RC_SECV_LOOP_NAME:-}"
if [ -z $C0RC_SECV_LOOP_NAME ]; then
    if [ "$(hostname)" = "capetown0" ]; then
        C0RC_SECV_LOOP_NAME="loop937"
    elif [ "$(hostname)" = "capetown2" ]; then
        C0RC_SECV_LOOP_NAME="loop941"
    else
        C0RC_SECV_LOOP_NAME=""
        echo -e "${TXT_COLOR_WARN}[$(date +'%Y-%m-%dT%H:%M:%S%z')] WARN:${TXT_COLOR_NONE} can't set appropriate value for '${TXT_COLOR_YELLOW}C0RC_SECV_LOOP_NAME${TXT_COLOR_NONE}'; unrecognized hostname '${TXT_COLOR_YELLOW}$(hostname)${TXT_COLOR_NONE}'" >&2
    fi
fi

export C0RC_SECV_LUKS_CONTAINER_NAME="${C0RC_SECV_LUKS_CONTAINER_NAME:-}"
if [ -z $C0RC_SECV_LUKS_CONTAINER_NAME ]; then
    if [ "$(hostname)" = "capetown0" ]; then
        C0RC_SECV_LUKS_CONTAINER_NAME="secv-c0"
    elif [ "$(hostname)" = "capetown2" ]; then
        C0RC_SECV_LUKS_CONTAINER_NAME="secv-c2"
    else
        C0RC_SECV_LUKS_CONTAINER_NAME=""
        echo -e "${TXT_COLOR_WARN}[$(date +'%Y-%m-%dT%H:%M:%S%z')] WARN:${TXT_COLOR_NONE} can't set appropriate value for '${TXT_COLOR_YELLOW}C0RC_SECV_LUKS_CONTAINER_NAME${TXT_COLOR_NONE}'; unrecognized hostname '${TXT_COLOR_YELLOW}$(hostname)${TXT_COLOR_NONE}'" >&2
    fi
fi

export C0RC_GPG_UID="${C0RC_GPG_UID:-me@vitalik-malkin.email}"
export C0RC_GPG_KID="${C0RC_GPG_KID:-9e3fc240cbe6345d79a2ba91757b48c7d9de7823}"
export C0RC_GPG_VERBOSE="${C0RC_GPG_VERBOSE:-n}"
export C0RC_GPG_EXPERT="${C0RC_GPG_EXPERT:-n}"
export C0RC_GPG_CMD_OPTS="${C0RC_GPG_CMD_OPTS:-}"
if [ -z $C0RC_GPG_CMD_OPTS ]; then
    C0RC_GPG_CMD_OPTS=""
    if [ "$C0RC_GPG_EXPERT" = "y" ]; then
        C0RC_GPG_CMD_OPTS="$C0RC_GPG_CMD_OPTS --expert"
    fi
    if [ "$C0RC_GPG_VERBOSE" = "y" ]; then
        C0RC_GPG_CMD_OPTS="$C0RC_GPG_CMD_OPTS --verbose"
    fi
fi

export C0RC_SHELL_SALT="${C0RC_SHELL_SALT:-$(head -c 16 /dev/urandom | xxd -l 16 -p -c 16)}"
if [ $? -ne 0 ]; then
    echo -e "${TXT_COLOR_ORANGE}[$(date +'%Y-%m-%dT%H:%M:%S%z')] WARN:${TXT_COLOR_NONE} error while setting value of '${TXT_COLOR_YELLOW}C0RC_SHELL_SALT${TXT_COLOR_NONE}'" >&2
fi

export C0RC_LUKS_DEFAULT_KEYSLOT="${C0RC_LUKS_DEFAULT_KEYSLOT:-4}"
export C0RC_LUKS_OUTPUT_INIT_PARAMS="${C0RC_LUKS_OUTPUT_INIT_PARAMS:-n}"
export C0RC_LUKS_DEFAULT_FS="${C0RC_LUKS_DEFAULT_FS:-ext4}"

export C0RC_PLAIN_TEXT_SECRET_FILE_NAME_EXT="${C0RC_PLAIN_TEXT_SECRET_FILE_NAME_EXT:-.c0rc-secret}"
# }}}

# workspace {{{
export C0RC_WS_DIR="${C0RC_WS_DIR:-"$HOME/workspace"}"

export C0RC_WS_BCK_DIR="${C0RC_WS_BCK_DIR:-"$C0RC_WS_DIR/_backup"}"
export C0RC_WS_BCK_OSSETTINGS_DIR="${C0RC_WS_BCK_OSSETTINGS_DIR:-"$C0RC_WS_BCK_DIR/os-settings"}"

export C0RC_WS_SECV_LEGACY_DIR="${C0RC_WS_SECV_LEGACY_DIR:-"$C0RC_WS_DIR/_secv-legacy"}"
export C0RC_WS_SECV_DIR="${C0RC_WS_SECV_DIR:-"$C0RC_WS_DIR/_secv"}"

export C0RC_WS_DOCS_DIR="${C0RC_WS_DOCS_DIR:-"$C0RC_WS_DIR/_docs"}"
export C0RC_WS_DOCS_ENC_DIR="${C0RC_WS_DOCS_ENC_DIR:-"$C0RC_WS_DIR/_docs_secured"}"
export C0RC_WS_DOCS_ENC_SECRET_NAME="${C0RC_WS_DOCS_ENC_SECRET_NAME:-doc}"

export C0RC_WS_VIDESS_DIR="${C0RC_WS_VIDESS_DIR:-"$C0RC_WS_DIR/_media/_videos/@especial"}"
export C0RC_WS_VIDESS_ENC_DIR="${C0RC_WS_VIDESS_ENC_DIR:-"$C0RC_WS_DIR/_media/_videos/@especial_secured"}"
export C0RC_WS_VIDESS_ENC_SECRET_NAME="${C0RC_WS_VIDESS_ENC_SECRET_NAME:-videss}"
# }}}

# cookie {{{
export C0RC_HH_COOKIE="${C0RC_HH_COOKIE:-}"
function c0rc_set_hh_cookie() {
    set -o pipefail

    if [ -f "$HOME/.c0rc-hh-cookie" ]; then
        C0RC_HH_COOKIE=$(cat "$HOME/.c0rc-hh-cookie")
        if [ $? -ne 0 ]; then
            echo -e "${TXT_COLOR_ERR}[$(date +'%Y-%m-%dT%H:%M:%S%z')] WARN:${TXT_COLOR_NONE} can't set appropriate value for '${TXT_COLOR_YELLOW}C0RC_HH_COOKIE${TXT_COLOR_NONE}'" >&2
        fi
    else
        local cookie_tmp="$(head -c 8 /dev/urandom | xxd -l 8 -p -c 8)_$(hostname)_$(whoami)"
        cookie_tmp="$(hostname)_$(whoami)_$(sha256 <<<$cookie_tmp | xxd -p -c 32 | head -c 12)"
        if [ $? -ne 0 ]; then
            echo -e "${TXT_COLOR_ERR}[$(date +'%Y-%m-%dT%H:%M:%S%z')] WARN:${TXT_COLOR_NONE} can't set appropriate value for '${TXT_COLOR_YELLOW}C0RC_HH_COOKIE${TXT_COLOR_NONE}'" >&2
        else
            echo -n "$cookie_tmp" >"$HOME/.c0rc-hh-cookie"
            if [ $? -ne 0 ]; then
                echo -e "${TXT_COLOR_ERR}[$(date +'%Y-%m-%dT%H:%M:%S%z')] WARN:${TXT_COLOR_NONE} can't set appropriate value for '${TXT_COLOR_YELLOW}C0RC_HH_COOKIE${TXT_COLOR_NONE}'" >&2
            else
                C0RC_HH_COOKIE=$cookie_tmp
            fi
        fi
    fi
}
if [ -z "$C0RC_HH_COOKIE" ]; then
    c0rc_set_hh_cookie
fi
# }}}
