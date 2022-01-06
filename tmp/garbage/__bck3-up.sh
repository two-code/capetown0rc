#! /bin/zsh

set -o errexit
set -o nounset
set -o pipefail

readonly _mnt_name="bck3"
readonly _mnt_path="/mnt/${_mnt_name}"
readonly _mapper_dev_name=$_mnt_name
readonly _mapper_dev="/dev/mapper/${_mapper_dev_name}"
readonly _backend_dev="/dev/$(basename $(readlink /dev/disk/by-uuid/5eecb532-9aff-4471-a71f-2d03c0ea3505))"
readonly _last_up_mark_file="${_mnt_path}/.last-up.txt"
readonly _key_file="$C0RC_SECRETS_DIR/bck3-key.gpg"

echo -e "${TXT_COLOR_YELLOW}create mount points...${TXT_COLOR_NONE}"
sudo mkdir -pv "${_mnt_path}"
sudo chown vitalik:vitalik "${_mnt_path}"

echo -e "${TXT_COLOR_YELLOW}unlock encrypted device...${TXT_COLOR_NONE}" &&
    (gpg2 --quiet --decrypt "${_key_file}" | sudo cryptsetup --key-file=- --key-slot=4 --perf-no_read_workqueue --perf-no_write_workqueue --persistent luksOpen "${_backend_dev}" "${_mapper_dev_name}") &&
    echo -e "${TXT_COLOR_YELLOW}mount unlocked encrypted device...${TXT_COLOR_NONE}" &&
    sudo mount "${_mapper_dev}" "${_mnt_path}" &&
    echo -e "${TXT_COLOR_YELLOW}tune mount point permissions...${TXT_COLOR_NONE}" &&
    sudo chown vitalik:vitalik "${_mnt_path}" &&
    ( (echo -en "${TXT_COLOR_CYAN}previous up: " && sudo cat ${_last_up_mark_file}) || (echo -n "" >/dev/null)) &&
    echo -e "${TXT_COLOR_NONE}" &&
    $(echo $(date) | sudo tee ${_last_up_mark_file} >/dev/null) &&
    echo -e "${TXT_COLOR_GREEN}done${TXT_COLOR_NONE}"
