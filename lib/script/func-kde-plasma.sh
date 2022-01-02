function c0rc_restart_plasma() {
    kquitapp5 plasmashell &>/dev/null || killall plasmashell && kstart5 plasmashell &>/dev/null &

    return 0
}
