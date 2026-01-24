FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    sudo \
    git \
    vim \
    cmake \
    build-essential \
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

USER $USERNAME
