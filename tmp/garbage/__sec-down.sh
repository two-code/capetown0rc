#!/bin/env bash

source ${HOME}/.capetown0rc/rc-opts.sh
source ${HOME}/.capetown0rc/rc-funcs.sh

readonly _mount_point="/home/vitalik/workspace/_secrets-vault"
readonly _loop_dev="/dev/loop3000"
readonly _image_path="/home/vitalik/.secrets-vault/image.img"
readonly _mapper_dev_name="secrets-vault-0"
readonly _mapper_dev="/dev/mapper/${_mapper_dev_name}"
readonly _last_up_mark_file="${_mount_point}/.last-up.txt"

_info "unmount secrets (${_mount_point})..."
sudo umount -l ${_mount_point}

_info "close crypt device..."
sudo cryptsetup --verbose close ${_mapper_dev_name}

_info "unmount loop device..."
sudo losetup -v -d ${_loop_dev}
