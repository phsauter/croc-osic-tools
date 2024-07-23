# Copyright (c) 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Authors:
# - Philippe Sauter <phsauter@ethz.ch>

# Directories
# directory of the path to the last called Makefile (this one)
DOCKER_DIR 		:= $(realpath $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

IMG_NAME = phsauter/pulp-croc-osic-tools
IMG_TAG = dev

pull:
	docker pull $(IMG_NAME):$(IMG_TAG)

build: build-pickle
	cd $(DOCKER_DIR)/all && \
	docker build --build-arg PICKLE_IMG=pulp-croc-pickle:$(IMG_TAG) \
				 -t $(IMG_NAME):$(IMG_TAG) .

build-pickle:
	cd $(DOCKER_DIR)/pickle && \
	docker build -t pulp-croc-pickle:$(IMG_TAG) .
	
.PHONY: pull build build-pickle
