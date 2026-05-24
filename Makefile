# SPDX-license-identifier: Apache-2.0
##############################################################################
# Copyright (c) 2025
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

DOCKER_CMD ?= $(shell which docker 2> /dev/null || which podman 2> /dev/null || echo docker)
LOCAL_BIN ?= $(HOME)/.local/bin
SHFMT_VERSION ?= v3.13.1
YAMLFMT_VERSION ?= v0.21.0

export PATH := $(LOCAL_BIN):$(PATH)

.PHONY: lint
lint:
	sudo -E $(DOCKER_CMD) run --rm -v $$(pwd):/tmp/lint \
	-e RUN_LOCAL=true \
	-e LINTER_RULES_PATH=/ \
	-e EDITORCONFIG_FILE_NAME=.editorconfig-checker.json \
	-e VALIDATE_NATURAL_LANGUAGE=false \
	-e VALIDATE_CHECKOV=false \
	ghcr.io/super-linter/super-linter

.PHONY: fmt
fmt:
	mkdir -p $(LOCAL_BIN)
	command -v shfmt > /dev/null || GOBIN=$(LOCAL_BIN) go install mvdan.cc/sh/v3/cmd/shfmt@$(SHFMT_VERSION)
	shfmt -l -w -s  -i 4 .
	command -v yamlfmt > /dev/null || GOBIN=$(LOCAL_BIN) go install github.com/google/yamlfmt/cmd/yamlfmt@$(YAMLFMT_VERSION)
	yamlfmt -dstar **/*.{yaml,yml}
	npm list | grep -e prettier > /dev/null || npm install prettier
	npx prettier . --write
	npm list | grep -e biome > /dev/null || npm install @biomejs/biome
	npx @biomejs/biome format --write .
