#!/bin/bash -e

if [ ! -d pico-sdk ]; then
    git clone https://github.com/raspberrypi/pico-sdk.git --branch master
fi

pushd pico-sdk
rm -rf ./build
cmake -S ./ -B ./build
cmake --build ./build --target picotoolBuild
popd

cp pico-sdk/build/_deps/picotool-build/picotool tools
