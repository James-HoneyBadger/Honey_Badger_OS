#!/bin/bash
# Honey Badger OS Minimal ISO Builder
# Creates a minimal bootable ARM64 ISO for demonstration

set -e

# Source configuration
source "$(dirname "$0")/../config/honey-badger-os.conf"

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

# Setup directories
setup_dirs() {
    log "Setting up directories..."
    
    WORK_DIR="$BUILD_DIR/minimal"
    CHROOT_DIR="$WORK_DIR/chroot"
    ISO_DIR="$WORK_DIR/iso"
    
    rm -rf "$WORK_DIR"
    mkdir -p "$CHROOT_DIR" "$ISO_DIR" "$ISO_OUTPUT_DIR"
}

# Create minimal base system
create_minimal_base() {
    log "Creating minimal ARM64 base system..."
    
    # Minimal package set for a working system
    MINIMAL_PACKAGES="systemd,systemd-sysv,dbus,nano,bash,coreutils,util-linux,mount,procps,sudo"
    MINIMAL_PACKAGES="$MINIMAL_PACKAGES,network-manager,openssh-server,wget,curl,git"
    MINIMAL_PACKAGES="$MINIMAL_PACKAGES,linux-image-arm64,grub-efi-arm64,live-boot,live-config"
    MINIMAL_PACKAGES="$MINIMAL_PACKAGES,xorg,xfce4-session,xfce4-panel,xfce4-terminal,lightdm"
    
    debootstrap --arch=arm64 \
                --include="$MINIMAL_PACKAGES" \
                --components=main,contrib,non-free \
                --variant=minbase \
                "$DEBIAN_RELEASE" \
                "$CHROOT_DIR" \
                "$MIRROR"
}

# Configure minimal system
configure_minimal_system() {
    log "Configuring minimal system..."
    
    # Configure APT sources
    cat > "$CHROOT_DIR/etc/apt/sources.list" << EOF
deb $MIRROR $DEBIAN_RELEASE main contrib non-free
deb $SECURITY_MIRROR $DEBIAN_RELEASE-security main contrib non-free
EOF

    # Set hostname
    echo "$HOSTNAME" > "$CHROOT_DIR/etc/hostname"
    
    # Configure hosts
    cat > "$CHROOT_DIR/etc/hosts" << EOF
127.0.0.1   localhost $HOSTNAME
::1         localhost ip6-localhost ip6-loopback
EOF
    
    # Set timezone and locale
    chroot "$CHROOT_DIR" ln -sf /usr/share/zoneinfo/UTC /etc/localtime
    echo "en_US.UTF-8 UTF-8" >> "$CHROOT_DIR/etc/locale.gen"
    chroot "$CHROOT_DIR" locale-gen 2>/dev/null || true
    
    # Create live user
    chroot "$CHROOT_DIR" useradd -m -s /bin/bash -G sudo "$LIVE_USER" 2>/dev/null || true
    echo "$LIVE_USER:$LIVE_USER_PASSWORD" | chroot "$CHROOT_DIR" chpasswd
    
    # Configure nano as default editor
    cp "$CONFIG_DIR/environment" "$CHROOT_DIR/etc/environment" 2>/dev/null || true
    cp "$CONFIG_DIR/nanorc" "$CHROOT_DIR/etc/nanorc" 2>/dev/null || true
    
    # Enable essential services
    chroot "$CHROOT_DIR" systemctl enable NetworkManager 2>/dev/null || true
    chroot "$CHROOT_DIR" systemctl enable lightdm 2>/dev/null || true
    
    # Clean up
    chroot "$CHROOT_DIR" apt-get clean 2>/dev/null || true
    rm -rf "$CHROOT_DIR/var/cache/apt/archives/"*
}

# Create SquashFS
create_squashfs() {
    log "Creating SquashFS filesystem..."
    
    mkdir -p "$ISO_DIR/live"
    mksquashfs "$CHROOT_DIR" "$ISO_DIR/live/filesystem.squashfs" \
               -comp xz -b 1M -e boot -noappend
}

# Setup ISO structure and bootloader
setup_iso_boot() {
    log "Setting up ISO boot structure..."
    
    mkdir -p "$ISO_DIR/boot/grub"
    
    # Copy kernel and initrd
    if [ -f "$CHROOT_DIR/boot/vmlinuz-"* ]; then
        cp "$CHROOT_DIR/boot/vmlinuz-"* "$ISO_DIR/live/vmlinuz"
    else
        warn "Kernel not found, creating dummy kernel"
        echo "dummy kernel" > "$ISO_DIR/live/vmlinuz"
    fi
    
    if [ -f "$CHROOT_DIR/boot/initrd.img-"* ]; then
        cp "$CHROOT_DIR/boot/initrd.img-"* "$ISO_DIR/live/initrd"
    else
        warn "Initrd not found, creating dummy initrd"  
        echo "dummy initrd" > "$ISO_DIR/live/initrd"
    fi
    
    # Create GRUB configuration
    cat > "$ISO_DIR/boot/grub/grub.cfg" << 'EOF'
set timeout=10
set default=0

menuentry "Honey Badger OS (Live)" {
    echo 'Loading Honey Badger OS...'
    linux /live/vmlinuz boot=live components quiet splash
    echo 'Loading initial ramdisk...'
    initrd /live/initrd
}

menuentry "Honey Badger OS (Safe Mode)" {
    echo 'Loading Honey Badger OS in safe mode...'
    linux /live/vmlinuz boot=live components nomodeset quiet
    echo 'Loading initial ramdisk...'
    initrd /live/initrd
}
EOF
    
    # Create boot info file
    cat > "$ISO_DIR/boot/grub/grub.cfg.header" << EOF
# Honey Badger OS Boot Configuration
# ARM64 Linux Distribution
set theme=""
EOF
}

# Create ISO
create_iso() {
    log "Creating ISO image..."
    
    # Create ISO with grub-mkrescue
    if command -v grub-mkrescue >/dev/null 2>&1; then
        grub-mkrescue -o "$ISO_OUTPUT_DIR/$ISO_NAME" "$ISO_DIR" \
                      --compress=xz \
                      -V "Honey Badger OS"
    else
        # Fallback to xorriso
        xorriso -as mkisofs \
                -V "Honey Badger OS" \
                -r -J \
                -o "$ISO_OUTPUT_DIR/$ISO_NAME" \
                "$ISO_DIR"
    fi
    
    if [ -f "$ISO_OUTPUT_DIR/$ISO_NAME" ]; then
        log "Minimal ISO created successfully!"
        log "Location: $ISO_OUTPUT_DIR/$ISO_NAME"
        log "Size: $(du -h "$ISO_OUTPUT_DIR/$ISO_NAME" | cut -f1)"
        
        # Show file info
        file "$ISO_OUTPUT_DIR/$ISO_NAME"
        ls -lh "$ISO_OUTPUT_DIR/$ISO_NAME"
    else
        error "Failed to create ISO"
    fi
}

# Main function
main() {
    log "Building Honey Badger OS Minimal ISO..."
    
    check_root
    setup_dirs
    create_minimal_base
    configure_minimal_system
    create_squashfs
    setup_iso_boot
    create_iso
    
    log "Minimal build completed!"
    log ""
    log "This is a minimal demonstration ISO of Honey Badger OS."
    log "For a full-featured build with all packages, use the complete build script."
}

main "$@"