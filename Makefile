SHELL  := /bin/bash

.DEFAULT_GOAL := usage

BOLD   := \033[1m
BRED   := \033[1;31m
RED    := \033[0;31m
GREEN  := \033[0;32m
CYAN   := \033[0;36m
YELLOW := \033[0;33m
NC     := \033[0m

.PHONY: usage
usage:
	@printf "\n$(YELLOW)Usage:$(NC)\n\n"
	@printf "$(YELLOW)make build       $(GREEN)# Build the code of the project $(NC)\n"
	@printf "$(YELLOW)make patch       $(GREEN)# Patches the project to the next version$(NC)\n\n"
	@exit 0

# ---- defaults and macros ---------------------------------------------------------------------------------------------

# the version macro is used for tagging the builds in git
# BEWARE: this macro expands at the start when the make file is run, if you do something
#         to the version file, this variable will be set to the old version !!!
VERSION ?= $(shell cat .bumpversion.cfg | grep current_version | awk '{ print $$3 }')

# ---- build process ---------------------------------------------------------------------------------------------------

.PHONY: clean
clean:
	@rm -rf dist/ build/

dist/:
	@mkdir dist

dist/VERSION: dist/
	@echo "$(VERSION)" > dist/VERSION

dist/code-v$(VERSION).zip: dist/
	@zip -b src/main/resources dist/code-v$(VERSION).zip *

.PHONY: sign
sign: dist/code-v$(VERSION).zip
	@echo "FIXME fake sign $(VERSION)" > dist/code-v$(VERSION).zip.asc
	@md5sum -b dist/code-v$(VERSION).zip > dist/code-v$(VERSION).zip.md5

.PHONY: build
build: dist/VERSION sign
	-which pip3
	-pip3 install bump2version

# ---- patch release ---------------------------------------------------------------------------------------------------

# bump a minor version number
.PHONY: patch
patch:
	@bumpversion patch
