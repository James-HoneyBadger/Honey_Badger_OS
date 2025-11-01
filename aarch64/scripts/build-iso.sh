#!/bin/bash
# Honey Badger OS Build Script
# Builds a custom ARM64 Linux distribution

set -e

# Source configuration
source "$(dirname "$0")/../config/honey-badger-os.conf"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
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

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root"
    fi
}

# Install dependencies
install_dependencies() {
    log "Installing build dependencies..."
    
    apt-get update
    apt-get install -y \
        debootstrap \
        squashfs-tools \
        xorriso \
        isolinux \
        syslinux-efi \
        grub-pc-bin \
        grub-efi-amd64-bin \
        grub-efi-arm64-bin \
        mtools \
        dosfstools \
        live-build \
        calamares \
        calamares-settings-ubuntu \
        wget \
        curl \
        rsync
}

# Create build environment
create_build_env() {
    log "Creating build environment..."
    
    mkdir -p "$BUILD_DIR"
    mkdir -p "$ISO_OUTPUT_DIR"
    mkdir -p "$LIVE_BUILD_DIR"
    
    cd "$LIVE_BUILD_DIR"
    
    # Initialize live-build
    lb config \
        --architecture "$ARCH" \
        --distribution "$DEBIAN_RELEASE" \
        --archive-areas "main contrib non-free" \
        --linux-flavours "generic" \
        --bootappend-live "boot=live components quiet splash" \
        --bootloader "grub-efi" \
        --binary-images "iso-hybrid" \
        --mode "debian" \
        --system "live" \
        --memtest "memtest86+" \
        --iso-application "$DISTRO_NAME" \
        --iso-publisher "$DISTRO_NAME Team" \
        --iso-volume "$DISTRO_NAME $DISTRO_VERSION"
}

# Configure APT sources
configure_apt_sources() {
    log "Configuring APT sources..."
    
    cat > "$LIVE_BUILD_DIR/config/archives/debian.list.chroot" << EOF
deb $MIRROR $DEBIAN_RELEASE main contrib non-free
deb-src $MIRROR $DEBIAN_RELEASE main contrib non-free
deb $SECURITY_MIRROR $DEBIAN_RELEASE-security main contrib non-free
deb-src $SECURITY_MIRROR $DEBIAN_RELEASE-security main contrib non-free
deb $MIRROR $DEBIAN_RELEASE-updates main contrib non-free
deb-src $MIRROR $DEBIAN_RELEASE-updates main contrib non-free
EOF

    # Copy for binary as well
    cp "$LIVE_BUILD_DIR/config/archives/debian.list.chroot" \
       "$LIVE_BUILD_DIR/config/archives/debian.list.binary"
}

# Install packages
install_packages() {
    log "Configuring package installation..."
    
    # Combine all package lists
    cat "$CONFIG_DIR/../packages/base-packages.list" \
        "$CONFIG_DIR/../packages/xfce-packages.list" \
        "$CONFIG_DIR/../packages/developer-packages.list" \
        "$CONFIG_DIR/../packages/applications.list" \
        > "$LIVE_BUILD_DIR/config/package-lists/honey-badger.list.chroot"
    
    # Essential packages for live system
    cat > "$LIVE_BUILD_DIR/config/package-lists/live.list.chroot" << EOF
live-boot
live-config
live-config-systemd
calamares
calamares-settings-ubuntu
EOF
}

# Configure system
configure_system() {
    log "Configuring system settings..."
    
    mkdir -p "$LIVE_BUILD_DIR/config/includes.chroot/etc"
    
    # Hostname
    echo "$HOSTNAME" > "$LIVE_BUILD_DIR/config/includes.chroot/etc/hostname"
    
    # Hosts file
    cat > "$LIVE_BUILD_DIR/config/includes.chroot/etc/hosts" << EOF
127.0.0.1   localhost
127.0.1.1   $HOSTNAME

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF

    # Create live user
    mkdir -p "$LIVE_BUILD_DIR/config/includes.chroot/etc/skel"
    
    # Copy theme files
    mkdir -p "$LIVE_BUILD_DIR/config/includes.chroot/usr/share/themes/HoneyBadger"
    cp -r "$CONFIG_DIR/../theme/"* "$LIVE_BUILD_DIR/config/includes.chroot/usr/share/themes/HoneyBadger/"
    
    # Configure nano as default editor
    mkdir -p "$LIVE_BUILD_DIR/config/includes.chroot/etc/environment.d"
    cp "$CONFIG_DIR/environment" "$LIVE_BUILD_DIR/config/includes.chroot/etc/environment"
    
    # System-wide nano configuration
    cp "$CONFIG_DIR/nanorc" "$LIVE_BUILD_DIR/config/includes.chroot/etc/nanorc"
    
    # User skeleton nano configuration
    mkdir -p "$LIVE_BUILD_DIR/config/includes.chroot/etc/skel"
    cp "$CONFIG_DIR/nanorc" "$LIVE_BUILD_DIR/config/includes.chroot/etc/skel/.nanorc"
    
    # Configure alternatives for editor
    mkdir -p "$LIVE_BUILD_DIR/config/includes.chroot/var/lib/dpkg/alternatives"
    
    # Copy editor configuration script
    mkdir -p "$LIVE_BUILD_DIR/config/hooks/live"
    cp "$SCRIPTS_DIR/configure-editor.sh" "$LIVE_BUILD_DIR/config/hooks/live/9999-configure-editor.hook.chroot"
    chmod +x "$LIVE_BUILD_DIR/config/hooks/live/9999-configure-editor.hook.chroot"
}

# Configure Calamares
configure_calamares() {
    log "Configuring Calamares installer..."
    
    mkdir -p "$LIVE_BUILD_DIR/config/includes.chroot/etc/calamares"
    cp -r "$CONFIG_DIR/../calamares/"* "$LIVE_BUILD_DIR/config/includes.chroot/etc/calamares/"
}

# Build ISO
build_iso() {
    log "Building ISO image..."
    
    cd "$LIVE_BUILD_DIR"
    
    # Clean previous build
    lb clean
    
    # Build the system
    lb build
    
    # Move ISO to output directory
    if [ -f "live-image-$ARCH.hybrid.iso" ]; then
        mv "live-image-$ARCH.hybrid.iso" "$ISO_OUTPUT_DIR/$ISO_NAME"
        log "ISO created successfully: $ISO_OUTPUT_DIR/$ISO_NAME"
    else
        error "ISO build failed"
    fi
}

# Main build process
main() {
    log "Starting Honey Badger OS build process..."
    
    check_root
    install_dependencies
    create_build_env
    configure_apt_sources
    install_packages
    configure_system
    configure_calamares
    build_iso
    
    log "Build completed successfully!"
    log "ISO location: $ISO_OUTPUT_DIR/$ISO_NAME"
}

# Run main function
main "$@"