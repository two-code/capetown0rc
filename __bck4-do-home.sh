#! /bin/bash

COLOR_YELLOW='\033[0;33m'
COLOR_RED='\033[5;31m'
COLOR_GREEN='\033[4;32m'
COLOR_CYAN='\033[0;36m'
COLOR_NONE='\033[0m' # No Color

set -o errexit
set -o nounset
set -o pipefail

. $(dirname "$0")/__bck-clean.sh;

readonly _src_dir="${HOME}"
readonly _dst_mnt_name="bck4";
readonly _dst_mnt_path="/mnt/${_dst_mnt_name}";

if [ ! $_dst_mnt_path == $(lsblk -l -o MOUNTPOINT | awk '/^\/mnt\/bck4$/ {print $1}') ];
then
    echo -e "${COLOR_RED}${_dst_mnt_path} is not mount point for any block device!${COLOR_NONE}";
    return -1
fi;

readonly _datetime="$(date '+%Y-%m-%d_%H:%M:%S')";
readonly _backup_dir="${_dst_mnt_path}/backup-home/$(whoami)";
readonly _backup_path="${_backup_dir}/${_datetime}";
readonly _latest_link="${_backup_dir}/latest";
readonly _log_file="${HOME}/__backup/logs/backup-home.${_datetime}.txt";
readonly _exclusion_file="${HOME}/__backup/__backup-home-exclusions.txt";
_prev_backup_path="";

if [ -d $_latest_link ]; then
    _prev_backup_path=$(readlink "${_latest_link}");
    echo -e "${COLOR_YELLOW}previous backup dir: ${_prev_backup_path}${COLOR_NONE}";
fi

sudo mkdir -pv "${_backup_dir}";

echo -e "${COLOR_YELLOW}making backup...${COLOR_NONE}";
sudo \
rsync \
-a \
-v \
--delete \
--recursive \
--force \
--whole-file \
--sparse \
--log-file="${_log_file}" \
--link-dest "${_latest_link}" \
--exclude-from="${_exclusion_file}" \
--delete-excluded \
"${_src_dir}/" \
"${_backup_path}" \
&& sudo rm -rvf "${_latest_link}" \
&& sudo ln -s "${_backup_path}" "${_latest_link}";

_clean "${_backup_dir}";

if [ ! $_prev_backup_path = "" ]; then
    echo -e "${COLOR_GREEN}actual size of previous and current backups:";
    sudo du -hs "${_prev_backup_path}" "${_backup_path}"
fi;

echo -e "${COLOR_YELLOW}done!${COLOR_NONE}";