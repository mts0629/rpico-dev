#!/bin/bash -e

if [ ! -d pico-sdk-tools ]; then
    git clone https://github.com/raspberrypi/pico-sdk-tools.git
fi

pushd pico-sdk-tools
if [ ! -e ./build/openocd-install/usr/local/bin/openocd ] || \
   [ ! -e ./build/pico-sdk-tools/pioasm/pioasm ] || \
   [ ! -e ./build/picotool-install/picotool/picotool ] ; then
    SKIP_RISCV=1 bash build_linux.sh
fi
sudo cp -r build/openocd-install/usr/local/* /usr/local/
sudo cp -r build/pico-sdk-tools/pioasm /usr/local/
sudo cp -r build/picotool-install/picotool /usr/local/
sudo cp build/picotool/udev/60-picotool.rules /usr/lib/udev/rules.d/
popd
