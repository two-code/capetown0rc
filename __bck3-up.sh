#! /bin/zsh

set -o errexit
set -o nounset
set -o pipefail

source ${HOME}/.capetown0rc/rc-funcs.sh

readonly _mnt_name="bck3";
readonly _mnt_path="/mnt/${_mnt_name}";
readonly _mapper_dev_name=$_mnt_name;
readonly _mapper_dev="/dev/mapper/${_mapper_dev_name}";
readonly _backend_dev="/dev/$(basename $(readlink /dev/disk/by-uuid/5eecb532-9aff-4471-a71f-2d03c0ea3505))";
readonly _last_up_mark_file="${_mnt_path}/.last-up.txt";
readonly _key_file="${__secrets}/bck3-key.gpg"

echo -e "${__color_yellow}create mount points...${__color_none}";
sudo mkdir -pv "${_mnt_path}";
sudo chown vitalik:vitalik "${_mnt_path}";

echo -e "${__color_yellow}unlock encrypted device...${__color_none}" \
	&& ( gpg2 --quiet --decrypt "${_key_file}" | sudo cryptsetup --key-file=- --key-slot=4 --perf-no_read_workqueue --perf-no_write_workqueue --persistent luksOpen "${_backend_dev}" "${_mapper_dev_name}" ) \
	&& echo -e "${__color_yellow}mount unlocked encrypted device...${__color_none}" \
	&& sudo mount "${_mapper_dev}" "${_mnt_path}" \
	&& echo -e "${__color_yellow}tune mount point permissions...${__color_none}" \
	&& sudo chown vitalik:vitalik "${_mnt_path}" \
	&& ( ( echo -en "${__color_cyan}previous up: " && sudo cat ${_last_up_mark_file} ) || ( echo -n "" > /dev/null ) ) \
	&& echo -e "${__color_none}" \
	&& $(echo $(date) | sudo tee ${_last_up_mark_file} > /dev/null) \
	&& echo -e "${__color_green}done${__color_none}"
