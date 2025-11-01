FROM debian:bookworm

# Install build dependencies
RUN apt-get update && \
    apt-get install -y \
    debootstrap \
    squashfs-tools \
    xorriso \
    isolinux \
    syslinux-efi \
    grub-efi-arm64 \
    grub-efi-arm64-bin \
    grub-efi-arm64-signed \
    mtools \
    dosfstools \
    live-build \
    calamares \
    calamares-settings-debian \
    wget \
    curl \
    rsync \
    qemu-user-static \
    binfmt-support \
    fdisk \
    parted \
    util-linux \
    systemd-container \
    sudo && \
    apt-get clean

# Enable qemu-user-static
RUN systemctl enable binfmt-support || true

# Create build user
RUN useradd -m -s /bin/bash builder && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/builder

WORKDIR /build
USER root

# Set entrypoint
ENTRYPOINT ["/build/aarch64/scripts/build-iso.sh"]
