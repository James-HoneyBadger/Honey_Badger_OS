#!/bin/bash

# Honey Badger OS - x86_64 ISO Builder with Cross-compilation Support
# This creates a bootable x86_64 ISO on an ARM64 host

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    exit 1
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root"
    fi
}

# Load configuration
load_config() {
    if [[ -f "/home/james/Honey_Badger_OS/x86_64/config/honey-badger-os.conf" ]]; then
        source "/home/james/Honey_Badger_OS/x86_64/config/honey-badger-os.conf"
    else
        error "Configuration file not found"
    fi
}

# Setup directories
setup_dirs() {
    log "Setting up directories..."
    
    WORK_DIR="$BUILD_DIR/basic"
    CHROOT_DIR="$WORK_DIR/chroot"
    ISO_DIR="$WORK_DIR/iso"
    OUTPUT_DIR="/home/james/Honey_Badger_OS/x86_64/output"
    
    rm -rf "$WORK_DIR"
    mkdir -p "$CHROOT_DIR" "$ISO_DIR" "$OUTPUT_DIR"
}

# Create minimal x86_64 rootfs manually (since debootstrap cross-compilation can be tricky)
create_minimal_rootfs() {
    log "Creating minimal x86_64 rootfs using Docker..."
    
    # Use Docker to create a clean x86_64 Debian environment
    if ! command -v docker &> /dev/null; then
        error "Docker is required for cross-compilation but not found"
    fi
    
    # Create rootfs using Docker with proper emulation
    log "Creating Debian bookworm x86_64 rootfs..."
    
    # Create a temporary Docker container and export its filesystem
    docker run --rm --platform=linux/amd64 \
        -v "$CHROOT_DIR:/mnt/target" \
        debian:bookworm-slim \
        bash -c "
        apt-get update && 
        apt-get install -y --no-install-recommends \
            systemd nano bash coreutils util-linux mount procps \
            openssh-server wget sudo linux-image-amd64 \
            grub-pc-bin grub-efi-amd64 initramfs-tools && 
        cp -a /bin /boot /etc /lib /lib64 /opt /root /sbin /usr /var /mnt/target/ &&
        mkdir -p /mnt/target/dev /mnt/target/proc /mnt/target/sys /mnt/target/tmp &&
        chmod 1777 /mnt/target/tmp
        "
}

# Configure basic system
configure_system() {
    log "Configuring x86_64 system with Honey Badger theming..."
    
    # Basic hostname
    echo "honey-badger-x86" > "$CHROOT_DIR/etc/hostname"
    
    # Basic hosts file
    cat > "$CHROOT_DIR/etc/hosts" << EOF
127.0.0.1   localhost honey-badger-x86
127.0.1.1   honey-badger-x86
::1         localhost ip6-localhost ip6-loopback
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
EOF

    # Set nano as default editor
    echo "EDITOR=nano" >> "$CHROOT_DIR/etc/environment"
    echo "export EDITOR=nano" >> "$CHROOT_DIR/etc/bash.bashrc"
    
    # Copy nano configuration with honey badger theming
    if [[ -f "/home/james/Honey_Badger_OS/x86_64/config/nanorc" ]]; then
        cp "/home/james/Honey_Badger_OS/x86_64/config/nanorc" "$CHROOT_DIR/etc/nanorc"
    fi
    
    # Install Honey Badger branding assets
    mkdir -p "$CHROOT_DIR/usr/share/pixmaps"
    mkdir -p "$CHROOT_DIR/usr/share/backgrounds"
    mkdir -p "$CHROOT_DIR/usr/local/bin"
    
    # Copy honey badger assets
    if [[ -d "/home/james/Honey_Badger_OS/x86_64/assets" ]]; then
        cp "/home/james/Honey_Badger_OS/x86_64/assets/icons"/*.png "$CHROOT_DIR/usr/share/pixmaps/" 2>/dev/null || true
        cp "/home/james/Honey_Badger_OS/x86_64/assets/wallpapers"/*.jpg "$CHROOT_DIR/usr/share/backgrounds/" 2>/dev/null || true
        
        # Install honey badger banner
        if [[ -f "/home/james/Honey_Badger_OS/x86_64/assets/branding/honey-badger-banner.sh" ]]; then
            cp "/home/james/Honey_Badger_OS/x86_64/assets/branding/honey-badger-banner.sh" "$CHROOT_DIR/usr/local/bin/"
            chmod +x "$CHROOT_DIR/usr/local/bin/honey-badger-banner.sh"
        fi
    fi
    
    # OS release information
    cat > "$CHROOT_DIR/etc/os-release" << EOF
PRETTY_NAME="Honey Badger OS 1.0 (Fearless) x86_64"
NAME="Honey Badger OS"
VERSION_ID="1.0"
VERSION="1.0 (Fearless)"
VERSION_CODENAME=fearless
ID=honey-badger-os
ID_LIKE=debian
HOME_URL="https://github.com/honey-badger-os"
SUPPORT_URL="https://github.com/honey-badger-os/support"
BUG_REPORT_URL="https://github.com/honey-badger-os/issues"
PRIVACY_POLICY_URL="https://honey-badger-os.org/privacy"
UBUNTU_CODENAME=bookworm
LOGO="honey-badger-os"
ANSI_COLOR="0;33"
EOF
}

# Create filesystem and bootloader
create_iso() {
    log "Creating x86_64 ISO filesystem..."
    
    mkdir -p "$ISO_DIR/live"
    mkdir -p "$ISO_DIR/boot/grub"
    
    # Create SquashFS
    log "Creating SquashFS filesystem..."
    mksquashfs "$CHROOT_DIR" "$ISO_DIR/live/filesystem.squashfs" \
        -comp xz -e boot -wildcards
    
    # Copy kernel and initrd
    KERNEL_VERSION=$(ls "$CHROOT_DIR/boot/vmlinuz-"* | head -1 | sed 's/.*vmlinuz-//')
    cp "$CHROOT_DIR/boot/vmlinuz-$KERNEL_VERSION" "$ISO_DIR/live/vmlinuz"
    cp "$CHROOT_DIR/boot/initrd.img-$KERNEL_VERSION" "$ISO_DIR/live/initrd.img"
    
    # Create GRUB configuration
    cat > "$ISO_DIR/boot/grub/grub.cfg" << EOF
set timeout=10
set default=0

# Honey Badger OS x86_64 Boot Menu
menuentry '🦡 Honey Badger OS x86_64 - Live System' {
    linux /live/vmlinuz boot=live quiet splash
    initrd /live/initrd.img
}

menuentry '🦡 Honey Badger OS x86_64 - Debug Mode' {
    linux /live/vmlinuz boot=live debug
    initrd /live/initrd.img
}
EOF

    # Create ISO
    log "Creating ISO image..."
    ISO_NAME="honey-badger-os-x86_64-$(date +%Y%m%d).iso"
    
    grub-mkrescue -o "$OUTPUT_DIR/$ISO_NAME" "$ISO_DIR" \
        --compress=xz \
        --verbose
        
    if [[ -f "$OUTPUT_DIR/$ISO_NAME" ]]; then
        ISO_SIZE=$(du -h "$OUTPUT_DIR/$ISO_NAME" | cut -f1)
        log "✅ x86_64 ISO created successfully: $ISO_NAME ($ISO_SIZE)"
        log "📍 Location: $OUTPUT_DIR/$ISO_NAME"
    else
        error "Failed to create ISO"
    fi
}

# Main execution
main() {
    log "🦡 Starting Honey Badger OS x86_64 ISO Build"
    
    check_root
    load_config
    setup_dirs
    create_minimal_rootfs
    configure_system
    create_iso
    
    log "🎉 Honey Badger OS x86_64 build complete!"
}

# Run main function
main "$@"