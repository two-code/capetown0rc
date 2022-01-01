#! /bin/zsh

set -o errexit
set -o nounset
set -o pipefail

source ${HOME}/.capetown0rc/rc-funcs.sh

readonly _mnt_name="bck4";
readonly _mnt_path="/mnt/${_mnt_name}";
readonly _ramfs_mnt_path="/mnt/ramfs-$(head -c 16 /dev/urandom | xxd -l 16 -p)";

readonly _ikey="${__secrets}/bck4-ikey.gpg";
readonly _ikey_raw="${_ramfs_mnt_path}/ikey"
readonly _key="${__secrets}/bck4-key.gpg";
readonly _header="${__secrets}/bck4-header.gpg";
readonly _header_raw="${_ramfs_mnt_path}/header"

readonly _imap="bck4-int";
readonly _imap_full="/dev/mapper/${_imap}";
readonly _emap="bck4-enc";
readonly _emap_full="/dev/mapper/${_emap}";

readonly _back_dev="/dev/$(basename $(readlink /dev/disk/by-partlabel/bck4-vault))";
readonly _last_up_mark_file="${_mnt_path}/.last-up.txt";

echo -e "${__color_yellow}create mount points...${__color_none}";
sudo mkdir -pv "${_mnt_path}" \
&& sudo chown vitalik:vitalik "${_mnt_path}" \
&& sudo mkdir -pv "${_ramfs_mnt_path}";

echo -e "${__color_yellow}open integrity-device...${__color_none}" \
    && echo -e "${__color_red}mount ramfs...${__color_none}" \
    && sudo mount -t ramfs ramfs "${_ramfs_mnt_path}" \
    && sudo chown vitalik:vitalik "${_ramfs_mnt_path}" \
    && gpg2 --quiet --output "${_ikey_raw}" --decrypt "${_ikey}" \
    && sudo integritysetup open "${_back_dev}" "${_imap}" --integrity=hmac-sha256 --integrity-key-file="${_ikey_raw}" --integrity-key-size=32 \
    && echo -e "${__color_yellow}open crypt-device...${__color_none}" \
    && gpg2 --quiet --output "${_header_raw}" --decrypt "${_header}" \
    && ( gpg2 --quiet --decrypt "${_key}" | sudo cryptsetup --key-file=- --key-slot=4 --header="${_header_raw}" --perf-no_read_workqueue --perf-no_write_workqueue --persistent luksOpen "${_imap_full}" "${_emap}" ) \
    && echo -e "${__color_yellow}mount device...${__color_none}" \
    && sudo mount -t ext4 "${_emap_full}" "${_mnt_path}" \
    && echo -e "${__color_yellow}tune mount point permissions...${__color_none}" \
    && sudo chown vitalik:vitalik "${_mnt_path}" \
    && ( ( echo -en "${__color_cyan}previous up: " && sudo cat ${_last_up_mark_file} ) || ( echo -n "" > /dev/null ) ) \
    && echo -e "${__color_none}" \
    && $(echo -n $(date) | sudo tee ${_last_up_mark_file} > /dev/null) \
    && echo -e "${__color_green}done${__color_none}"

sudo umount -l "${_ramfs_mnt_path}" && sudo rm -fRd "${_ramfs_mnt_path}" && echo -e "${__color_red}ramfs unmounted.${__color_none}";
