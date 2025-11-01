#!/bin/bash

# Honey Badger OS - Ultra-minimal ISO Builder
# This creates a truly basic bootable ISO to demonstrate the concept

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
    if [[ -f "/home/james/Honey_Badger_OS/config/honey-badger-os.conf" ]]; then
        source "/home/james/Honey_Badger_OS/config/honey-badger-os.conf"
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
    
    rm -rf "$WORK_DIR"
    mkdir -p "$CHROOT_DIR" "$ISO_DIR" "$ISO_OUTPUT_DIR"
}

# Create ultra-minimal base system
create_basic_base() {
    log "Creating ultra-minimal ARM64 base system..."
    
    # Essential packages for live boot system
    BASIC_PACKAGES="systemd,nano,bash,coreutils,util-linux,mount,procps"
    BASIC_PACKAGES="$BASIC_PACKAGES,openssh-server,wget,sudo"
    BASIC_PACKAGES="$BASIC_PACKAGES,linux-image-arm64,grub-efi-arm64"
    # CRITICAL: Live boot packages to prevent kernel panic
    BASIC_PACKAGES="$BASIC_PACKAGES,live-boot,live-config,squashfs-tools"
    BASIC_PACKAGES="$BASIC_PACKAGES,initramfs-tools,busybox-initramfs"
    
    # Use minbase variant for absolute minimum
    debootstrap --arch=arm64 \
                --include="$BASIC_PACKAGES" \
                --components=main \
                --variant=minbase \
                --no-check-gpg \
                "$DEBIAN_RELEASE" \
                "$CHROOT_DIR" \
                "$MIRROR"
}

# Configure basic system with Honey Badger branding
configure_basic_system() {
    log "Configuring basic system with Honey Badger theming..."
    
    # Basic hostname
    echo "honey-badger" > "$CHROOT_DIR/etc/hostname"
    
    # Basic hosts file
    cat > "$CHROOT_DIR/etc/hosts" << EOF
127.0.0.1   localhost honey-badger
127.0.1.1   honey-badger
::1         localhost ip6-localhost ip6-loopback
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
EOF

    # Set nano as default editor
    echo "EDITOR=nano" >> "$CHROOT_DIR/etc/environment"
    echo "export EDITOR=nano" >> "$CHROOT_DIR/etc/bash.bashrc"
    
    # Copy nano configuration with honey badger theming
    if [[ -f "/home/james/Honey_Badger_OS/config/nanorc" ]]; then
        cp "/home/james/Honey_Badger_OS/config/nanorc" "$CHROOT_DIR/etc/nanorc"
    fi
    
    # Install Honey Badger branding assets
    mkdir -p "$CHROOT_DIR/usr/share/pixmaps"
    mkdir -p "$CHROOT_DIR/usr/share/backgrounds"
    mkdir -p "$CHROOT_DIR/usr/local/bin"
    mkdir -p "$CHROOT_DIR/etc/update-motd.d"
    
    # Copy honey badger icons and wallpapers
    if [[ -f "/home/james/Honey_Badger_OS/assets/icons/honey-badger-64.png" ]]; then
        cp "/home/james/Honey_Badger_OS/assets/icons/honey-badger-64.png" "$CHROOT_DIR/usr/share/pixmaps/honey-badger-os.png"
        cp "/home/james/Honey_Badger_OS/assets/icons"/*.png "$CHROOT_DIR/usr/share/pixmaps/" 2>/dev/null || true
    fi
    
    # Copy wallpapers
    if [[ -f "/home/james/Honey_Badger_OS/assets/wallpapers/honey-badger-1920x1080.jpg" ]]; then
        cp "/home/james/Honey_Badger_OS/assets/wallpapers/honey-badger-1920x1080.jpg" "$CHROOT_DIR/usr/share/backgrounds/honey-badger-os-wallpaper.jpg"
        cp "/home/james/Honey_Badger_OS/assets/wallpapers"/*.jpg "$CHROOT_DIR/usr/share/backgrounds/" 2>/dev/null || true
    fi
    
    # Install OS release information
    if [[ -f "/home/james/Honey_Badger_OS/config/os-release" ]]; then
        cp "/home/james/Honey_Badger_OS/config/os-release" "$CHROOT_DIR/etc/os-release"
        cp "/home/james/Honey_Badger_OS/config/os-release" "$CHROOT_DIR/usr/lib/os-release"
    fi
    
    # Install welcome banner
    if [[ -f "/home/james/Honey_Badger_OS/assets/branding/honey-badger-banner.sh" ]]; then
        cp "/home/james/Honey_Badger_OS/assets/branding/honey-badger-banner.sh" "$CHROOT_DIR/usr/local/bin/honey-badger-banner"
        chmod +x "$CHROOT_DIR/usr/local/bin/honey-badger-banner"
        
        # Add to login profile
        echo ". /usr/local/bin/honey-badger-banner" >> "$CHROOT_DIR/etc/profile"
    fi
    
    # Install MOTD
    if [[ -f "/home/james/Honey_Badger_OS/assets/branding/motd" ]]; then
        cp "/home/james/Honey_Badger_OS/assets/branding/motd" "$CHROOT_DIR/etc/motd"
    fi
    
    # Basic fstab
    cat > "$CHROOT_DIR/etc/fstab" << EOF
# Honey Badger OS filesystem table
proc    /proc   proc    defaults    0   0
sysfs   /sys    sysfs   defaults    0   0
tmpfs   /tmp    tmpfs   defaults    0   0
EOF

    # Configure chroot environment for proper operation
    mount -t proc proc "$CHROOT_DIR/proc" || true
    mount -t sysfs sysfs "$CHROOT_DIR/sys" || true
    mount -t devtmpfs dev "$CHROOT_DIR/dev" || true
    
    # Update initramfs with live-boot support - CRITICAL for preventing kernel panic
    chroot "$CHROOT_DIR" /bin/bash -c "
        export DEBIAN_FRONTEND=noninteractive
        # Update initramfs to include live-boot components
        update-initramfs -u -k all
        # Ensure live-boot services are enabled
        systemctl enable live-config || true
    " || warn "Chroot configuration had issues but continuing..."
    
    # Cleanup mounts
    umount "$CHROOT_DIR/proc" 2>/dev/null || true
    umount "$CHROOT_DIR/sys" 2>/dev/null || true  
    umount "$CHROOT_DIR/dev" 2>/dev/null || true
}

# Create simple filesystem
create_filesystem() {
    log "Creating basic filesystem..."
    
    # Create directories first
    mkdir -p "$ISO_DIR/live"
    
    # Create SquashFS
    mksquashfs "$CHROOT_DIR" "$ISO_DIR/live/filesystem.squashfs" \
        -comp xz -b 1M -Xdict-size 100% -no-recovery
        
    # Calculate size for ISO
    SQUASHFS_SIZE=$(du -sb "$ISO_DIR/live/filesystem.squashfs" | cut -f1)
    echo "$SQUASHFS_SIZE" > "$ISO_DIR/live/filesystem.size"
}

# Create bootloader configuration with Honey Badger branding
create_bootloader() {
    log "Creating bootloader configuration..."
    
    mkdir -p "$ISO_DIR/boot/grub"
    
    # Honey Badger GRUB configuration
    cat > "$ISO_DIR/boot/grub/grub.cfg" << EOF
set timeout=10
set default=0

# Honey Badger OS Boot Menu
menuentry '🦡 Honey Badger OS - Live System' {
    linux /live/vmlinuz boot=live components quiet splash toram=filesystem.squashfs
    initrd /live/initrd.img
}

menuentry '🦡 Honey Badger OS - Debug Mode' {
    linux /live/vmlinuz boot=live components debug nosplash toram=filesystem.squashfs
    initrd /live/initrd.img
}

menuentry '🦡 Honey Badger OS - Safe Mode' {
    linux /live/vmlinuz boot=live components single nosplash noapic nolapic
    initrd /live/initrd.img
}
EOF

    # Copy kernel and initrd
    KERNEL_VERSION=$(ls "$CHROOT_DIR/boot/vmlinuz-"* | head -1 | sed 's/.*vmlinuz-//')
    cp "$CHROOT_DIR/boot/vmlinuz-$KERNEL_VERSION" "$ISO_DIR/live/vmlinuz"
    cp "$CHROOT_DIR/boot/initrd.img-$KERNEL_VERSION" "$ISO_DIR/live/initrd.img"
}

# Create ISO image
create_iso() {
    log "Creating ISO image..."
    
    ISO_NAME="honey-badger-os-basic-$(date +%Y%m%d).iso"
    
    grub-mkrescue -o "$ISO_OUTPUT_DIR/$ISO_NAME" "$ISO_DIR" \
        --compress=xz \
        --verbose
        
    if [[ -f "$ISO_OUTPUT_DIR/$ISO_NAME" ]]; then
        ISO_SIZE=$(du -h "$ISO_OUTPUT_DIR/$ISO_NAME" | cut -f1)
        log "✅ ISO created successfully: $ISO_NAME ($ISO_SIZE)"
        log "📍 Location: $ISO_OUTPUT_DIR/$ISO_NAME"
    else
        error "Failed to create ISO"
    fi
}

# Cleanup function
cleanup() {
    if [[ -n "$CHROOT_DIR" && -d "$CHROOT_DIR" ]]; then
        log "Cleaning up chroot mounts..."
        umount -f "$CHROOT_DIR/proc" 2>/dev/null || true
        umount -f "$CHROOT_DIR/sys" 2>/dev/null || true
        umount -f "$CHROOT_DIR/dev" 2>/dev/null || true
    fi
}

# Main execution
main() {
    log "🦡 Starting Honey Badger OS Basic ISO Build"
    
    check_root
    load_config
    setup_dirs
    
    # Set trap for cleanup
    trap cleanup EXIT
    
    create_basic_base
    configure_basic_system
    create_filesystem
    create_bootloader
    create_iso
    
    log "🎉 Honey Badger OS Basic ISO build completed successfully!"
}

# Run main function
main "$@"