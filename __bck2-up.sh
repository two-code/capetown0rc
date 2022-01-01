#! /bin/bash

COLOR_YELLOW='\033[0;33m'
COLOR_RED='\033[5;31m'
COLOR_GREEN='\033[4;32m'
COLOR_CYAN='\033[0;36m'
COLOR_NONE='\033[0m' # No Color

readonly _mnt_name="bck2";
readonly _mnt_path="/mnt/${_mnt_name}";
readonly _ramfs_mnt_path="/mnt/ramfs-$(head -c 16 /dev/urandom | xxd -l 16 -p)";

readonly _ikey="/home/vitalik/.secrets/bck2-ikey.gpg";
readonly _ikey_raw="${_ramfs_mnt_path}/ikey"
readonly _key="/home/vitalik/.secrets/bck2-key.gpg";
readonly _header="/home/vitalik/.secrets/bck2-header.gpg";
readonly _header_raw="${_ramfs_mnt_path}/header"

readonly _imap="bck2-int";
readonly _imap_full="/dev/mapper/${_imap}";
readonly _emap="bck2-enc";
readonly _emap_full="/dev/mapper/${_emap}";

readonly _back_dev="/dev/$(basename $(readlink /dev/disk/by-id/wwn-0x5000c500a3a9d628-part4))";
readonly _last_up_mark_file="${_mnt_path}/.last-up.txt";

echo -e "${COLOR_YELLOW}create mount points...${COLOR_NONE}";
sudo mkdir -pv "${_mnt_path}" \
	&& sudo chown vitalik:vitalik "${_mnt_path}" \
	&& sudo mkdir -pv "${_ramfs_mnt_path}" \;

echo -e "${COLOR_YELLOW}open integrity-device...${COLOR_NONE}" \
	&& echo -e "${COLOR_RED}mount ramfs...${COLOR_NONE}" \
	&& sudo mount -t ramfs ramfs "${_ramfs_mnt_path}" \
	&& sudo chown vitalik:vitalik "${_ramfs_mnt_path}" \
	&& gpg2 --quiet --output "${_ikey_raw}" --decrypt "${_ikey}" \
	&& sudo integritysetup open "${_back_dev}" "${_imap}" --integrity=hmac-sha256 --integrity-key-file="${_ikey_raw}" --integrity-key-size=32 \
	&& echo -e "${COLOR_YELLOW}open crypt-device...${COLOR_NONE}" \
	&& gpg2 --quiet --output "${_header_raw}" --decrypt "${_header}" \
	&& ( gpg2 --quiet --decrypt "${_key}" | sudo cryptsetup --key-file=- --key-slot=4 --header="${_header_raw}" --perf-no_read_workqueue --perf-no_write_workqueue --persistent luksOpen "${_imap_full}" "${_emap}" ) \
	&& echo -e "${COLOR_YELLOW}mount device...${COLOR_NONE}" \
	&& sudo mount "${_emap_full}" "${_mnt_path}" \
	&& echo -e "${COLOR_YELLOW}tune mount point permissions...${COLOR_NONE}" \
	&& sudo chown vitalik:vitalik "${_mnt_path}" \
	&& ( ( echo -en "${COLOR_CYAN}previous up: " && sudo cat ${_last_up_mark_file} ) || ( echo -n "" > /dev/null ) ) \
	&& echo -e "${COLOR_NONE}" \
	&& $(echo -n $(date) | sudo tee ${_last_up_mark_file} > /dev/null) \
	&& echo -e "${COLOR_GREEN}done!${COLOR_NONE}";

sudo umount -l "${_ramfs_mnt_path}" && sudo rm -fRd "${_ramfs_mnt_path}" && echo -e "${COLOR_RED}ramfs unmounted.${COLOR_NONE}";