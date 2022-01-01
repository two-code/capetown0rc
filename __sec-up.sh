#! /bin/bash

source ${HOME}/.capetown0rc/rc-funcs.sh

COLOR_YELLOW='\033[0;33m'
COLOR_RED='\033[0;31m'
COLOR_NONE='\033[0m' # No Color

readonly _mount_point="/home/vitalik/workspace/_secrets-vault"
readonly _loop_dev="/dev/loop3000"
readonly _image_path="/home/vitalik/.secrets-vault/image.img"
readonly _mapper_dev_name="secrets-vault-0"
readonly _mapper_dev="/dev/mapper/${_mapper_dev_name}"
readonly _last_up_mark_file="${_mount_point}/.last-up.txt"
readonly _key_file="${__secrets}/secv-key.gpg"

echo -e "${COLOR_YELLOW}create mount points...${COLOR_NONE}" &&
	sudo mkdir -pv ${_mount_point} &&
	echo -e "${COLOR_YELLOW}mount loop device...${COLOR_NONE}" &&
	sudo losetup --verbose ${_loop_dev} ${_image_path} &&
	echo -e "${COLOR_YELLOW}open crypt device...${COLOR_NONE}" &&
	(gpg2 --quiet --decrypt "${_key_file}" | sudo cryptsetup --key-file=- --key-slot=4 luksOpen ${_loop_dev} ${_mapper_dev_name}) &&
	echo -e "${COLOR_YELLOW}mount secrets to '${_mount_point}'...${COLOR_NONE}" &&
	sudo mount ${_mapper_dev} ${_mount_point} &&
	( (echo -e "${COLOR_RED}previous up: " && sudo cat ${_last_up_mark_file}) || (echo "" >/dev/null)) &&
	echo -e "${COLOR_NONE}" &&
	$(echo $(date) | sudo tee ${_last_up_mark_file} >/dev/null) &&
	echo -e "${COLOR_YELLOW}done!${COLOR_NONE}"
