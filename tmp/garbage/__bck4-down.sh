#! /bin/zsh

set -o nounset
set -o pipefail

source ${HOME}/.capetown0rc/rc-funcs.sh

readonly _mnt_name="bck4";
readonly _mnt_path="/mnt/${_mnt_name}";
readonly _imap="bck4-int";
readonly _emap="bck4-enc";

echo -e "${__color_yellow}unmount device...${__color_none}";
sudo umount --verbose "${_mnt_path}";

echo -e "${__color_yellow}close crypt-device...${__color_none}";
sudo cryptsetup --verbose close "${_emap}"

echo -e "${__color_yellow}close integrity-device...${__color_none}";
sudo cryptsetup --verbose close "${_imap}" \
    && echo -e "${__color_green}done${__color_none}"
