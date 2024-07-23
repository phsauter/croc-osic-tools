# Copyright (c) 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Authors:
# - Philippe Sauter <phsauter@ethz.ch>
#
# based on: https://docs.docker.com/build/building/multi-stage/
# syntax=docker/dockerfile:1
ARG DOCKER_BASE_IMG=hpretl/iic-osic-tools:2024.07
ARG PICKLE_IMG
FROM ${PICKLE_IMG} AS pickle

FROM ${DOCKER_BASE_IMG} AS runner
USER root
# install packages
RUN apt-get update && \
    apt-get -y upgrade
COPY packages.txt /packages.txt
RUN apt-get install -y $(cat /packages.txt)
COPY requirements.txt /requirements.txt
RUN pip3 install --no-cache-dir -r /requirements.txt

# Verible
RUN wget https://github.com/chipsalliance/verible/releases/download/v0.0-3724-gdec56671/verible-v0.0-3724-gdec56671-linux-static-x86_64.tar.gz && \
    tar -xzf verible-v0.0-3724-gdec56671-linux-static-x86_64.tar.gz && \
    mkdir -p /foss/tools/verible/bin && \
    cp verible-v0.0-3724-gdec56671/bin/* /foss/tools/verible/bin
RUN for file in /foss/tools/verible/bin/*; do \
        ln -sr "$file" /foss/tools/bin/; \
    done

# copy into runnner
RUN mkdir -p /foss/tools/pickle/bin
COPY --from=pickle /build/bin /foss/tools/pickle/bin
RUN for file in /foss/tools/pickle/bin/*; do \
        ln -sr "$file" /foss/tools/bin/; \
    done

ENV PATH=/foss/tools/bin:$PATH
USER 1000:1000