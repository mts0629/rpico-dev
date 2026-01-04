#!/bin/bash -e

git clone https://github.com/raspberrypi/pico-sdk.git --branch master

pushd pico-sdk
cmake -S . -B ./build
cmake --build ./build --target picotoolBuild
popd

cp pico-sdk/build/_deps/picotool-build/picotool .
