#! /bin/bash

COLOR_YELLOW='\033[0;33m'
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[4;32m'
COLOR_CYAN='\033[0;36m'
COLOR_NONE='\033[0m' # No Color

readonly _mnt_name="bck2";
readonly _mnt_path="/mnt/${_mnt_name}";

readonly _imap="bck2-int";
readonly _emap="bck2-enc";

echo -e "${COLOR_YELLOW}unmount device...${COLOR_NONE}";
sudo umount --verbose "${_mnt_path}";

echo -e "${COLOR_YELLOW}close crypt-device...${COLOR_NONE}";
sudo cryptsetup --verbose close "${_emap}"

echo -e "${COLOR_YELLOW}close integrity-device...${COLOR_NONE}";
sudo cryptsetup --verbose close "${_imap}"

echo -e "${COLOR_GREEN}done!${COLOR_NONE}";