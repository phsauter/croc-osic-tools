# Copyright (c) 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Authors:
# - Philippe Sauter <phsauter@ethz.ch>
#
# based on: https://docs.docker.com/build/building/multi-stage/
# syntax=docker/dockerfile:1
ARG DOCKER_BASE_IMG=ubuntu:jammy

FROM ${DOCKER_BASE_IMG} AS builder
ARG BENDER_TAR=https://github.com/pulp-platform/bender/releases/download/v0.28.1/bender-0.28.1-x86_64-linux-gnu-ubuntu22.04.tar.gz
ARG MORTY_REPO=https://github.com/pulp-platform/morty
ARG MORTY_COMMIT=v0.9.0
ARG SVASE_REPO=https://github.com/pulp-platform/svase
ARG SVASE_COMMIT=50cb9b9d0acc06f05bb4fe30774f276c188ed942
ARG SV2V_REPO=https://github.com/zachjs/sv2v
ARG SV2V_COMMIT=v0.0.12

# install packages
RUN apt-get update && \
    apt-get -y upgrade
COPY packages.txt /packages.txt
RUN apt-get install -y $(cat /packages.txt)
# install correct cmake version (svase)
RUN wget https://github.com/Kitware/CMake/releases/download/v3.20.6/cmake-3.20.6-linux-x86_64.sh && \
    bash cmake-3.20.6-linux-x86_64.sh --prefix=/usr/local --skip-license
# install correct clang version (svase)
RUN wget https://apt.llvm.org/llvm.sh && \
    chmod +x llvm.sh && \
    ./llvm.sh 16
ENV CC=clang-16
ENV CXX=clang++-16
# install rust cargo (morty)
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:$PATH"
# install haskell stack (sv2v)
RUN curl -sSL https://get.haskellstack.org/ | bash


WORKDIR /build/bin
RUN curl -L ${BENDER_TAR} | tar -xzC .

WORKDIR /morty
RUN curl -L ${MORTY_REPO}/archive/${MORTY_COMMIT}.tar.gz | tar -xzC . --strip-components=1 && \
    cargo build --release && \
    cp target/release/morty /build/bin/morty

# ToDo: submodules lose their correct versions if done via archive -> fix in svase?
WORKDIR /svase
RUN git clone ${SVASE_REPO}.git . && git checkout ${SVASE_COMMIT} && \
    git submodule update --init --recursive && \
    export CXX=clang++-16 && \
    make -j && \
    cp build/svase /build/bin/svase

WORKDIR /sv2v
RUN curl -L ${SV2V_REPO}/archive/${SV2V_COMMIT}.tar.gz | tar -xzC . --strip-components=1 && \
    make -j && \
    cp bin/sv2v /build/bin/sv2v

# copy into runnner
FROM ${DOCKER_BASE_IMG} AS runner
COPY --from=builder /build /build
ENV PATH=/build/bin:$PATH
