#!/bin/zsh

set -o errexit
set -o nounset
set -o pipefail

echo "";
echo -e "${__color_yellow}===================================================${__color_none}";
echo -e "${__color_yellow}==== Locking ${__color_red}_docs${__color_yellow}:${__color_none}";
fusermount -u "${HOME}/workspace/_docs" && echo -en "${__color_yellow}done${__color_none}";

# commented by vitalik 2021-10-31T20:05
# echo "";
# echo -e "${__color_yellow}===================================================${__color_none}";
# echo -e "${__color_yellow}==== Locking ${__color_red}@especial${__color_yellow}:${__color_none}";
# fusermount -u "${HOME}/workspace/_media/_videos/@especial" && echo -e "${__color_yellow}done!${__color_none}";

echo "";
