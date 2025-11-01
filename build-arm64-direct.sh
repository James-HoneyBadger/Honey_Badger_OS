#!/bin/bash
# Honey Badger OS ARM64 Direct Build Script
# Simple, direct approach to building ARM64 live ISO

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

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Configuration
WORK_DIR="/tmp/honey-badger-arm64-build"
ISO_NAME="honey-badger-os-1.0-arm64.iso"
DISTRO_NAME="Honey Badger OS"

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    error "This script must be run as root (in Docker)"
fi

# Clean up any previous build
cleanup() {
    log "Cleaning up previous build..."
    rm -rf "$WORK_DIR"
}

# Install build dependencies
install_deps() {
    log "Installing build dependencies..."
    
    export DEBIAN_FRONTEND=noninteractive
    
    # Update package lists
    apt-get update || error "Failed to update package lists"
    
    # Install live-build and dependencies
    apt-get install -y \
        live-build \
        debootstrap \
        squashfs-tools \
        xorriso \
        isolinux \
        syslinux-efi \
        grub-efi-arm64 \
        grub-efi-arm64-bin \
        dosfstools \
        mtools \
        wget \
        curl \
        || error "Failed to install dependencies"
    
    log "Dependencies installed successfully"
}

# Create build environment
setup_build() {
    log "Setting up build environment..."
    
    # Create and enter work directory
    mkdir -p "$WORK_DIR"
    cd "$WORK_DIR"
    
    # Initialize live-build configuration
    log "Initializing live-build configuration..."
    lb config \
        --architecture arm64 \
        --distribution bookworm \
        --archive-areas "main contrib non-free non-free-firmware" \
        --linux-flavours generic \
        --bootloaders grub-efi \
        --binary-images iso-hybrid \
        --memtest none \
        --iso-application "$DISTRO_NAME" \
        --iso-publisher "$DISTRO_NAME Team" \
        --iso-volume "$DISTRO_NAME ARM64" \
        --debian-installer false \
        --firmware-chroot true \
        --firmware-binary true \
        --updates true \
        --security true \
        --backports false \
        --cache false \
        --apt-recommends false \
        --compression xz \
        --zsync false \
        --bootappend-live "boot=live components quiet splash noswap noeject" \
        || error "Failed to configure live-build"
        
    log "Live-build configuration completed"
}

# Add essential packages
add_packages() {
    log "Configuring package selection..."
    
    # Create package list directory
    mkdir -p config/package-lists
    
    # Essential packages for a functional ARM64 system
    cat > config/package-lists/essential.list.chroot << 'EOF'
# Essential system packages
live-boot
live-config
live-config-systemd
systemd
systemd-sysv
udev
dbus
network-manager
openssh-server

# Basic desktop environment
xfce4
xfce4-goodies
lightdm
lightdm-gtk-greeter

# Essential applications
firefox-esr
thunar
xfce4-terminal
nano
git
curl
wget

# Hardware support
firmware-linux
firmware-linux-free
firmware-linux-nonfree
firmware-misc-nonfree
linux-firmware

# ARM64 specific
u-boot-tools
device-tree-compiler

# Installation tools
calamares
calamares-settings-debian
gparted
EOF

    log "Package configuration completed"
}

# Configure system
configure_system() {
    log "Configuring system settings..."
    
    # Create includes directory for custom files
    mkdir -p config/includes.chroot/etc
    
    # Set hostname
    echo "honey-badger" > config/includes.chroot/etc/hostname
    
    # Create hosts file
    cat > config/includes.chroot/etc/hosts << 'EOF'
127.0.0.1   localhost
127.0.1.1   honey-badger

::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF

    # Create live user configuration
    mkdir -p config/hooks/live
    cat > config/hooks/live/0001-create-user.hook.chroot << 'EOF'
#!/bin/bash
# Create live user

# Add live user
adduser --disabled-password --gecos "Live User" live
echo "live:live" | chpasswd
usermod -aG sudo,adm,cdrom,floppy,audio,dip,video,plugdev,netdev live

# Configure autologin
mkdir -p /etc/lightdm/lightdm.conf.d
cat > /etc/lightdm/lightdm.conf.d/12-autologin.conf << 'CONF'
[Seat:*]
autologin-user=live
autologin-user-timeout=0
CONF

# Set default session
echo "xfce" > /home/live/.xsession
chown live:live /home/live/.xsession
EOF

    chmod +x config/hooks/live/0001-create-user.hook.chroot
    
    log "System configuration completed"
}

# Build the ISO
build_iso() {
    log "Building ARM64 ISO image..."
    
    # Ensure we're in the right directory
    cd "$WORK_DIR"
    
    # Build the complete live system
    log "Starting live-build process..."
    if lb build 2>&1 | tee build.log; then
        log "Build completed successfully!"
        
        # Check for ISO file
        if [ -f "live-image-arm64.hybrid.iso" ]; then
            # Move ISO to output location
            mkdir -p "/build"
            cp "live-image-arm64.hybrid.iso" "/build/$ISO_NAME"
            
            # Show ISO details
            log "ISO created successfully!"
            log "ISO file: /build/$ISO_NAME"
            ls -lh "/build/$ISO_NAME"
            
            # Show ISO info if available
            if command -v file >/dev/null 2>&1; then
                file "/build/$ISO_NAME"
            fi
            
        else
            error "Build completed but no ISO file found"
        fi
    else
        error "Live-build failed"
    fi
}

# Main execution
main() {
    log "Starting Honey Badger OS ARM64 build..."
    
    cleanup
    install_deps
    setup_build
    add_packages
    configure_system
    build_iso
    
    log "Build completed successfully!"
    log "ARM64 ISO available at: /build/$ISO_NAME"
}

# Run main function
main "$@"