MAKEFILE_DIR := $(abspath $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
SHELL = /bin/bash

export TXT_COLOR_YELLOW ?= \033[0;33m
export TXT_COLOR_WHITE ?= \033[1;37m
export TXT_COLOR_RED ?= \033[1;31m
export TXT_COLOR_GREEN ?= \033[0;32m
export TXT_COLOR_CYAN ?= \033[0;36m
export TXT_COLOR_NONE ?= \033[0m
export TXT_SPLITTER ?= ========

.PHONY: build
build:
	@echo -en "$(TXT_COLOR_YELLOW)[go build]:$(TXT_COLOR_NONE) ..." \
	&& rm -f "$(C0RC_BIN_DIR)/c0rc" \
	&& go build -o "$(C0RC_BIN_DIR)/c0rc" "$(C0RC_GO_DIR)" \
	&& echo -e "$(TXT_COLOR_GREEN) OK$(TXT_COLOR_NONE)"
