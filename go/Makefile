MAKEFILE_PATH := $(abspath $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
SHELL = /bin/bash

COLOR_YELLOW="\033[38;2;255;255;0m"
COLOR_RED="\033[38;2;255;0;0m"
COLOR_GREEN="\033[38;2;0;255;0m"
COLOR_CYAN="\033[0;36m"
COLOR_NONE="\033[0m"

.PHONY: build
build:
	@echo -en $(COLOR_YELLOW)[go build...]:$(COLOR_NONE)
	@rm -fdR ./bin && go build -o ./bin/capetown0 . && echo -e $(COLOR_GREEN) success$(COLOR_NONE)