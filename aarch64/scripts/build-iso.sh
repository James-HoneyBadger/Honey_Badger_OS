#!/bin/bash
# Honey Badger OS Build Script
# Builds a custom ARM64 Linux distribution with enhanced stability and hardware support

set -euo pipefail

# Get absolute path to config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../config/honey-badger-os.conf"

# Source configuration
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "ERROR: Configuration file not found: $CONFIG_FILE"
    exit 1
fi

source "$CONFIG_FILE"

# Override build directory to use absolute path
BUILD_DIR="/tmp/honey-badger-build"
LIVE_BUILD_DIR="$BUILD_DIR/live-build"
CONFIG_DIR="$SCRIPT_DIR/../config"
SCRIPTS_DIR="$SCRIPT_DIR"

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
    
    # Update package lists
    apt-get update || error "Failed to update package lists"
    
    # Install essential build tools (ARM64 optimized)
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
        || error "Failed to install build dependencies"
    
    # Enable qemu-user-static for cross-compilation support
    systemctl enable binfmt-support || warn "Failed to enable binfmt-support"
    
    log "Build dependencies installed successfully"
}

# Create build environment
create_build_env() {
    log "Creating build environment..."
    
    # Clean and create directories
    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    mkdir -p "$ISO_OUTPUT_DIR"
    mkdir -p "$LIVE_BUILD_DIR"
    
    cd "$LIVE_BUILD_DIR" || error "Failed to change to build directory"
    
    # Initialize live-build with enhanced configuration
    lb config \
        --architecture "$ARCH" \
        --distribution "$DEBIAN_RELEASE" \
        --archive-areas "main contrib non-free non-free-firmware" \
        --linux-flavours "generic" \
        --linux-packages "linux-image linux-headers" \
        --bootappend-live "boot=live components quiet splash noswap noeject" \
        --bootloader "grub-efi" \
        --binary-images "iso-hybrid" \
        --mode "debian" \
        --system "live" \
        --memtest "none" \
        --iso-application "$DISTRO_NAME" \
        --iso-publisher "$DISTRO_NAME Team" \
        --iso-volume "$DISTRO_NAME $DISTRO_VERSION" \
        --debian-installer "false" \
        --firmware-chroot "true" \
        --firmware-binary "true" \
        --updates "true" \
        --security "true" \
        --backports "false" \
        --cache "false" \
        --apt-recommends "false" \
        --compression "xz" \
        --zsync "false" \
        || error "Failed to configure live-build"
        
    log "Build environment created successfully"
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
    
    # Create package lists directory
    mkdir -p "$LIVE_BUILD_DIR/config/package-lists"
    
    # Use essential packages only for space-constrained build
    if [ "${BUILD_MINIMAL:-}" = "1" ]; then
        grep -v '^#\|^$' "$CONFIG_DIR/../packages/essential-only.list" > "$LIVE_BUILD_DIR/config/package-lists/honey-badger.list.chroot"
        log "Using minimal package set for space-constrained build"
    else
        # Combine all package lists, filtering out comments and empty lines
        {
            grep -v '^#\|^$' "$CONFIG_DIR/../packages/base-packages.list"
            grep -v '^#\|^$' "$CONFIG_DIR/../packages/xfce-packages.list"  
            grep -v '^#\|^$' "$CONFIG_DIR/../packages/developer-packages.list"
            grep -v '^#\|^$' "$CONFIG_DIR/../packages/applications.list"
        } | sort -u > "$LIVE_BUILD_DIR/config/package-lists/honey-badger.list.chroot"
    fi
    
    # Essential packages for live system with ARM64 specifics
    cat > "$LIVE_BUILD_DIR/config/package-lists/live.list.chroot" << EOF
live-boot
live-config
live-config-systemd
systemd
systemd-sysv
udev
dbus
networkd-dispatcher
calamares
calamares-settings-debian
openssh-server
firmware-linux
firmware-linux-free
firmware-linux-nonfree
firmware-misc-nonfree
linux-firmware
u-boot-tools
device-tree-compiler
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
    if [ -d "$CONFIG_DIR/../theme" ]; then
        cp -r "$CONFIG_DIR/../theme/"* "$LIVE_BUILD_DIR/config/includes.chroot/usr/share/themes/HoneyBadger/"
    fi
    
    # Copy wallpapers and branding
    mkdir -p "$LIVE_BUILD_DIR/config/includes.chroot/usr/share/backgrounds"
    mkdir -p "$LIVE_BUILD_DIR/config/includes.chroot/usr/share/pixmaps"
    
    if [ -d "$CONFIG_DIR/../assets/wallpapers" ]; then
        cp "$CONFIG_DIR/../assets/wallpapers/"* "$LIVE_BUILD_DIR/config/includes.chroot/usr/share/backgrounds/" 2>/dev/null || true
    fi
    
    if [ -d "$CONFIG_DIR/../assets/icons" ]; then
        cp "$CONFIG_DIR/../assets/icons/"* "$LIVE_BUILD_DIR/config/includes.chroot/usr/share/pixmaps/" 2>/dev/null || true
    fi
    
    # Create default wallpaper if none exists
    if [ ! -f "$LIVE_BUILD_DIR/config/includes.chroot/usr/share/backgrounds/honey-badger-wallpaper.jpg" ]; then
        # Create a simple colored background as placeholder
        mkdir -p "$LIVE_BUILD_DIR/config/includes.chroot/usr/share/backgrounds"
        # This would be replaced with an actual image file in production
        touch "$LIVE_BUILD_DIR/config/includes.chroot/usr/share/backgrounds/honey-badger-wallpaper.jpg"
    fi
    
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
    
    # Copy all configuration hooks
    mkdir -p "$LIVE_BUILD_DIR/config/hooks/live"
    
    # Copy hardware support hook
    if [ -f "$SCRIPTS_DIR/hooks/01-hardware-support.hook.chroot" ]; then
        cp "$SCRIPTS_DIR/hooks/01-hardware-support.hook.chroot" "$LIVE_BUILD_DIR/config/hooks/live/"
        chmod +x "$LIVE_BUILD_DIR/config/hooks/live/01-hardware-support.hook.chroot"
    fi
    
    # Copy stability hook
    if [ -f "$SCRIPTS_DIR/hooks/02-system-stability.hook.chroot" ]; then
        cp "$SCRIPTS_DIR/hooks/02-system-stability.hook.chroot" "$LIVE_BUILD_DIR/config/hooks/live/"
        chmod +x "$LIVE_BUILD_DIR/config/hooks/live/02-system-stability.hook.chroot"
    fi
    
    # Copy live config hook
    if [ -f "$SCRIPTS_DIR/hooks/03-live-config.hook.chroot" ]; then
        cp "$SCRIPTS_DIR/hooks/03-live-config.hook.chroot" "$LIVE_BUILD_DIR/config/hooks/live/"
        chmod +x "$LIVE_BUILD_DIR/config/hooks/live/03-live-config.hook.chroot"
    fi
    
    # Copy bootloader config hook
    if [ -f "$SCRIPTS_DIR/hooks/04-bootloader-config.hook.chroot" ]; then
        cp "$SCRIPTS_DIR/hooks/04-bootloader-config.hook.chroot" "$LIVE_BUILD_DIR/config/hooks/live/"
        chmod +x "$LIVE_BUILD_DIR/config/hooks/live/04-bootloader-config.hook.chroot"
    fi
    
    # Copy editor configuration script
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
    
    # Build the complete ISO using lb build (handles all stages properly)
    log "Building complete ARM64 live ISO..."
    if ! lb build 2>&1 | tee build.log; then
        log "Build failed. Checking logs..."
        
        # Show the last part of the build log for debugging
        if [ -f build.log ]; then
            echo "=== Last 50 lines of build log ==="
            tail -50 build.log
        fi
        
        # Show specific stage logs if they exist
        for stage_log in bootstrap.log chroot.log binary.log; do
            if [ -f "$stage_log" ]; then
                echo "=== Last 20 lines of $stage_log ==="
                tail -20 "$stage_log"
            fi
        done
        
        error "ISO build failed"
    fi
    
    # Move ISO to output directory
    if [ -f "live-image-$ARCH.hybrid.iso" ]; then
        mv "live-image-$ARCH.hybrid.iso" "$ISO_OUTPUT_DIR/$ISO_NAME"
        log "ISO created successfully: $ISO_OUTPUT_DIR/$ISO_NAME"
        
        # Show ISO details
        ls -lh "$ISO_OUTPUT_DIR/$ISO_NAME"
        
        # Verify ISO integrity
        if command -v file >/dev/null 2>&1; then
            file "$ISO_OUTPUT_DIR/$ISO_NAME"
        fi
        
        if command -v isoinfo >/dev/null 2>&1; then
            log "ISO filesystem information:"
            isoinfo -d -i "$ISO_OUTPUT_DIR/$ISO_NAME" | head -10
        fi
        
    else
        error "ISO build failed - no ISO file found"
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