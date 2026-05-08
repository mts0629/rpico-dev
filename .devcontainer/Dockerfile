FROM debian:bookworm-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    sudo \
    git \
    cmake \
    udev \
    usbutils \
    build-essential \
    libusb-1.0.0-dev \
    libhidapi-dev \
    libftdi1-dev

# Build OpenOCD and utilities
RUN git clone https://github.com/raspberrypi/pico-sdk-tools.git \
    && cd pico-sdk-tools \
    && SKIP_RISCV=1 bash build_linux.sh

# Environment
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    git \
    vim \
    udev \
    usbutils \
    make \
    gcc-arm-none-eabi \
    gdb-arm-none-eabi \
    libusb-1.0.0-dev \
    libhidapi-dev \
    libftdi1-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# From devcontainer.json
ARG USERNAME
ARG USER_UID
ARG USER_GID
# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Install prebuilt tools
COPY --from=builder \
    /pico-sdk-tools/build/openocd-install/usr/local/bin/openocd \
    /pico-sdk-tools/build/pico-sdk-tools/pioasm \
    /pico-sdk-tools/build/picotool-install/picotool \
    /usr/local/bin/
COPY --from=builder /pico-sdk-tools/build/openocd-install/usr/local/share/ /usr/local/share/

USER $USERNAME
