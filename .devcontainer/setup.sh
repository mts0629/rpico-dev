#!/bin/bash -e

if [ ! -d pico-sdk-tools ]; then
    git clone https://github.com/raspberrypi/pico-sdk-tools.git
fi

pushd pico-sdk-tools
SKIP_RISCV=1 bash build_linux.sh
popd
