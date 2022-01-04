#!/bin/zsh

set -o errexit
set -o nounset
set -o pipefail

source ${HOME}/.capetown0rc/rc-funcs.sh

echo -n $(_get_secret doc)
