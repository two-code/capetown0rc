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
