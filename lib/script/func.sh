. $C0RC_SCRIPT_DIR/func-apt.sh
. $C0RC_SCRIPT_DIR/func-bck.sh
. $C0RC_SCRIPT_DIR/func-docs.sh
. $C0RC_SCRIPT_DIR/func-fonts.sh
. $C0RC_SCRIPT_DIR/func-git.sh
. $C0RC_SCRIPT_DIR/func-kde-plasma.sh
. $C0RC_SCRIPT_DIR/func-ramfs.sh
. $C0RC_SCRIPT_DIR/func-rand.sh
. $C0RC_SCRIPT_DIR/func-sec-gocryptfs.sh
. $C0RC_SCRIPT_DIR/func-sec-gpg.sh
. $C0RC_SCRIPT_DIR/func-sec.sh
. $C0RC_SCRIPT_DIR/func-srch.sh
. $C0RC_SCRIPT_DIR/func-ssh-gpg.sh

function c0rc_env() {
    c0rc_splitter
    c0rc_info "environment:"
    printenv |
        grep -i -E '^C0RC' |
        LC_ALL=C sort |
        sed -r "s/^([^=]+)=(.+)$/\1 = $(echo -n $TXT_COLOR_YELLOW | sed 's/\\/\\\\/')\2$(echo -n $TXT_COLOR_NONE | sed 's/\\/\\\\/')/g" |
        cat -n -

    c0rc_splitter
    c0rc_info "params:"
    set |
        grep -i -E '^C0RC' |
        LC_ALL=C sort |
        sed -r "s/^([^=]+)=(.+)$/\1 = $(echo -n $TXT_COLOR_YELLOW | sed 's/\\/\\\\/')\2$(echo -n $TXT_COLOR_NONE | sed 's/\\/\\\\/')/g" |
        cat -n -
}
