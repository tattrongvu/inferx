# Use Ubuntu as the base image
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    gcc \
    make \
    libaio-dev \
    libpciaccess-dev \
    python3 \
    python3-pip \
    pciutils \
    pkg-config kmod \
    libjson-c-dev libcunit1-dev libssl-dev libcmocka-dev uuid-dev libiscsi-dev libkeyutils-dev libncurses5-dev libncursesw5-dev unzip libfuse3-dev patchelf \
    python3-configshell-fb python3-pexpect nasm libnuma-dev \
    autoconf automake libtool help2man systemtap-sdt-dev \
    astyle lcov clang sg3-utils shellcheck abigail-tools bash-completion ruby-dev pycodestyle bundler rake python3-paramiko curl \
    libpmem-dev libpmemblk-dev libpmemobj-dev \
    librados-dev librbd-dev libibverbs-dev librdmacm-dev 

# Clone the SPDK repository
RUN git clone https://github.com/spdk/spdk.git /spdk --recursive

# Set working directory
WORKDIR /spdk

RUN ./scripts/pkgdep.sh --all
RUN ./configure
RUN make

# Set up entrypoint to provide SPDK CLI tools
ENTRYPOINT scripts/gen_nvme.sh --json-with-subsystems > /opt/inferx/config/nvme_bdev_all.json && scripts/setup.sh
