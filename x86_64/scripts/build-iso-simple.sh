#!/bin/bash
# Honey Badger OS Simple ISO Builder
# Creates bootable ISO directly using debootstrap

set -e

# Source configuration
source "$(dirname "$0")/../config/honey-badger-os.conf"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
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

# Setup build directories
setup_build_dirs() {
    log "Setting up build directories..."
    
    WORK_DIR="$BUILD_DIR/work"
    CHROOT_DIR="$WORK_DIR/chroot"
    ISO_DIR="$WORK_DIR/iso"
    
    rm -rf "$WORK_DIR"
    mkdir -p "$CHROOT_DIR" "$ISO_DIR" "$ISO_OUTPUT_DIR"
}

# Create base system with debootstrap
create_base_system() {
    log "Creating base ARM64 system with debootstrap..."
    
    # Install base system
    debootstrap --arch=arm64 \
                --include=systemd,systemd-sysv,dbus \
                --components=main,contrib,non-free \
                "$DEBIAN_RELEASE" \
                "$CHROOT_DIR" \
                "$MIRROR"
    
    # Configure APT sources in chroot
    cat > "$CHROOT_DIR/etc/apt/sources.list" << EOF
deb $MIRROR $DEBIAN_RELEASE main contrib non-free
deb-src $MIRROR $DEBIAN_RELEASE main contrib non-free
deb $SECURITY_MIRROR $DEBIAN_RELEASE-security main contrib non-free
deb-src $SECURITY_MIRROR $DEBIAN_RELEASE-security main contrib non-free
deb $MIRROR $DEBIAN_RELEASE-updates main contrib non-free
deb-src $MIRROR $DEBIAN_RELEASE-updates main contrib non-free
EOF
    
    # Update package lists
    chroot "$CHROOT_DIR" apt-get update
}

# Install packages
install_packages() {
    log "Installing packages..."
    
    # Install kernel first
    chroot "$CHROOT_DIR" apt-get install -y linux-image-arm64 linux-headers-arm64
    
    # Install essential packages
    while IFS= read -r package; do
        if [[ ! "$package" =~ ^#.*$ ]] && [[ -n "$package" ]]; then
            log "Installing: $package"
            chroot "$CHROOT_DIR" apt-get install -y "$package" || warn "Failed to install $package"
        fi
    done < "$CONFIG_DIR/../packages/base-packages.list"
    
    # Install XFCE packages
    while IFS= read -r package; do
        if [[ ! "$package" =~ ^#.*$ ]] && [[ -n "$package" ]]; then
            log "Installing XFCE package: $package"
            chroot "$CHROOT_DIR" apt-get install -y "$package" || warn "Failed to install $package"
        fi
    done < "$CONFIG_DIR/../packages/xfce-packages.list"
    
    # Install developer tools
    while IFS= read -r package; do
        if [[ ! "$package" =~ ^#.*$ ]] && [[ -n "$package" ]]; then
            log "Installing developer tool: $package"
            chroot "$CHROOT_DIR" apt-get install -y "$package" || warn "Failed to install $package"
        fi
    done < "$CONFIG_DIR/../packages/developer-packages.list"
    
    # Install applications
    while IFS= read -r package; do
        if [[ ! "$package" =~ ^#.*$ ]] && [[ -n "$package" ]]; then
            log "Installing application: $package"
            chroot "$CHROOT_DIR" apt-get install -y "$package" || warn "Failed to install $package"
        fi
    done < "$CONFIG_DIR/../packages/applications.list"
    
    # Install live system packages
    chroot "$CHROOT_DIR" apt-get install -y live-boot live-config live-config-systemd
}

# Configure system
configure_system() {
    log "Configuring system..."
    
    # Set hostname
    echo "$HOSTNAME" > "$CHROOT_DIR/etc/hostname"
    
    # Configure hosts
    cat > "$CHROOT_DIR/etc/hosts" << EOF
127.0.0.1   localhost
127.0.1.1   $HOSTNAME
::1         localhost ip6-localhost ip6-loopback
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
EOF
    
    # Set timezone
    chroot "$CHROOT_DIR" ln -sf /usr/share/zoneinfo/"$TIMEZONE" /etc/localtime
    
    # Configure locale
    echo "$LOCALE UTF-8" >> "$CHROOT_DIR/etc/locale.gen"
    chroot "$CHROOT_DIR" locale-gen
    echo "LANG=$LOCALE" > "$CHROOT_DIR/etc/locale.conf"
    
    # Copy theme files
    mkdir -p "$CHROOT_DIR/usr/share/themes/HoneyBadger"
    cp -r "$CONFIG_DIR/../theme/"* "$CHROOT_DIR/usr/share/themes/HoneyBadger/"
    
    # Configure nano as default editor
    cp "$CONFIG_DIR/environment" "$CHROOT_DIR/etc/environment"
    cp "$CONFIG_DIR/nanorc" "$CHROOT_DIR/etc/nanorc"
    
    # Configure default user
    chroot "$CHROOT_DIR" useradd -m -s /bin/bash -G sudo,audio,video,plugdev "$LIVE_USER"
    echo "$LIVE_USER:$LIVE_USER_PASSWORD" | chroot "$CHROOT_DIR" chpasswd
    
    # Configure nano for user
    cp "$CONFIG_DIR/nanorc" "$CHROOT_DIR/home/$LIVE_USER/.nanorc"
    chroot "$CHROOT_DIR" chown "$LIVE_USER:$LIVE_USER" "/home/$LIVE_USER/.nanorc"
    
    # Enable services
    chroot "$CHROOT_DIR" systemctl enable lightdm
    chroot "$CHROOT_DIR" systemctl enable NetworkManager
}

# Create squashfs filesystem
create_squashfs() {
    log "Creating SquashFS filesystem..."
    
    # Clean up
    chroot "$CHROOT_DIR" apt-get clean
    rm -rf "$CHROOT_DIR/var/cache/apt/archives/"*
    
    # Create squashfs
    mksquashfs "$CHROOT_DIR" "$ISO_DIR/live/filesystem.squashfs" \
               -comp xz -b 1M -e boot
}

# Setup ISO structure
setup_iso_structure() {
    log "Setting up ISO structure..."
    
    mkdir -p "$ISO_DIR/live"
    mkdir -p "$ISO_DIR/boot/grub"
    
    # Copy kernel and initrd
    cp "$CHROOT_DIR/boot/vmlinuz-"* "$ISO_DIR/live/vmlinuz"
    cp "$CHROOT_DIR/boot/initrd.img-"* "$ISO_DIR/live/initrd"
    
    # Create GRUB configuration
    cat > "$ISO_DIR/boot/grub/grub.cfg" << 'EOF'
set default="0"
set timeout=10

menuentry "Honey Badger OS (Live)" {
    linux /live/vmlinuz boot=live components quiet splash
    initrd /live/initrd
}

menuentry "Honey Badger OS (Install)" {
    linux /live/vmlinuz boot=live components quiet splash live-installer
    initrd /live/initrd
}
EOF
}

# Create ISO image
create_iso() {
    log "Creating ISO image..."
    
    grub-mkrescue -o "$ISO_OUTPUT_DIR/$ISO_NAME" "$ISO_DIR" \
                  --compress=xz \
                  --install-modules="linux normal iso9660 biosdisk search" \
                  --themes="" \
                  --locales=""
    
    if [ -f "$ISO_OUTPUT_DIR/$ISO_NAME" ]; then
        log "ISO created successfully: $ISO_OUTPUT_DIR/$ISO_NAME"
        ls -lh "$ISO_OUTPUT_DIR/$ISO_NAME"
    else
        error "Failed to create ISO"
    fi
}

# Main build function
main() {
    log "Starting Honey Badger OS ISO build..."
    
    check_root
    setup_build_dirs
    create_base_system
    install_packages
    configure_system
    create_squashfs
    setup_iso_structure
    create_iso
    
    log "Build completed successfully!"
    log "ISO location: $ISO_OUTPUT_DIR/$ISO_NAME"
    log "Size: $(du -h "$ISO_OUTPUT_DIR/$ISO_NAME" | cut -f1)"
}

# Run main function
main "$@"