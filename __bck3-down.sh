#! /bin/zsh

set -o nounset
set -o pipefail

source ${HOME}/.capetown0rc/rc-funcs.sh

readonly _mnt_name="bck3"
readonly _mnt_path="/mnt/${_mnt_name}"
readonly _mapper_dev_name=$_mnt_name

echo -e "${__color_yellow}unmount encrypted device...${__color_none}"
sudo umount --verbose "${_mnt_path}"

echo -e "${__color_yellow}lock encrypted device...${__color_none}"
sudo cryptsetup --verbose close "${_mapper_dev_name}" \
    && echo -e "${__color_green}done${__color_none}"
