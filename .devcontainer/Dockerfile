# Use Node.js image for xpm
FROM node:latest

RUN apt-get update && apt install -y \
    git \
    vim && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install xpm
RUN npm install --location=global xpm@latest

# Install xPack-dev-tools
# https://xpack-dev-tools.github.io/
# - xPack GNU Arm Embedded GCC
# - xPack OpenOCD (On-Chip Debugger)
# - xPack bison
RUN xpm init \
    && xpm install @xpack-dev-tools/arm-none-eabi-gcc@14.2.1-1.1.1 \
    && xpm install @xpack-dev-tools/openocd@0.12.0-6.1 \
    && xpm install @xpack-dev-tools/bison@3.8.2-1.1

ENV PATH=$HOME/xpacks/.bin:$PATH

USER node
