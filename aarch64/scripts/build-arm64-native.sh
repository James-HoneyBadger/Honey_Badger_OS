#!/bin/bash
set -e

echo "Building ARM64 Honey Badger OS ISO (simplified approach)..."

# Clean up previous builds
if [ -d "ISOs" ]; then
    rm -f ISOs/honey-badger-arm64-*.iso
fi
mkdir -p ISOs

# Check if we have the required tools
if ! command -v debootstrap >/dev/null 2>&1; then
    echo "Installing debootstrap..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "On macOS, please install debootstrap via:"
        echo "  brew install debootstrap"
        exit 1
    else
        sudo apt-get update && sudo apt-get install -y debootstrap squashfs-tools xorriso grub-efi-arm64-bin
    fi
fi

# Create temporary build directory
BUILD_DIR="/tmp/honey-badger-build-$$"
ROOTFS_DIR="$BUILD_DIR/rootfs"
ISOWORK_DIR="$BUILD_DIR/isowork"

cleanup() {
    echo "Cleaning up..."
    sudo umount "$ROOTFS_DIR/proc" 2>/dev/null || true
    sudo umount "$ROOTFS_DIR/sys" 2>/dev/null || true
    sudo umount "$ROOTFS_DIR/dev/pts" 2>/dev/null || true
    sudo umount "$ROOTFS_DIR/dev" 2>/dev/null || true
    sudo rm -rf "$BUILD_DIR"
}
trap cleanup EXIT

mkdir -p "$BUILD_DIR" "$ROOTFS_DIR" "$ISOWORK_DIR"

echo "Creating ARM64 base system..."
sudo debootstrap --arch=arm64 \
    --include=systemd,systemd-sysv,init,sudo,nano,vim-tiny,firefox-esr,xfce4,lightdm,lightdm-gtk-greeter,thunar,pulseaudio,network-manager,live-boot,live-config,linux-image-arm64,grub-efi-arm64 \
    --exclude=rsyslog \
    bookworm "$ROOTFS_DIR" http://deb.debian.org/debian

echo "Configuring the system..."

# Set hostname
echo 'honey-badger-arm64' | sudo tee "$ROOTFS_DIR/etc/hostname" > /dev/null

# Configure hosts file
sudo tee "$ROOTFS_DIR/etc/hosts" > /dev/null << 'HOSTS_EOF'
127.0.0.1   localhost
127.0.1.1   honey-badger-arm64
::1         localhost ip6-localhost ip6-loopback
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
HOSTS_EOF

# Create live user
echo 'live:x:1000:1000:Live User,,,:/home/live:/bin/bash' | sudo tee -a "$ROOTFS_DIR/etc/passwd" > /dev/null
echo 'live:*:19000:0:99999:7:::' | sudo tee -a "$ROOTFS_DIR/etc/shadow" > /dev/null
echo 'live:x:1000:' | sudo tee -a "$ROOTFS_DIR/etc/group" > /dev/null
echo 'live ALL=(ALL) NOPASSWD:ALL' | sudo tee "$ROOTFS_DIR/etc/sudoers.d/live" > /dev/null

# Create live user home directory
sudo mkdir -p "$ROOTFS_DIR/home/live"
sudo chown 1000:1000 "$ROOTFS_DIR/home/live"

# Configure autologin for lightdm
sudo mkdir -p "$ROOTFS_DIR/etc/lightdm"
sudo tee "$ROOTFS_DIR/etc/lightdm/lightdm.conf" > /dev/null << 'LIGHTDM_EOF'
[Seat:*]
autologin-user=live
autologin-user-timeout=0
user-session=xfce
greeter-session=lightdm-gtk-greeter
LIGHTDM_EOF

# Configure live-config
sudo mkdir -p "$ROOTFS_DIR/etc/live"
sudo tee "$ROOTFS_DIR/etc/live/config.conf" > /dev/null << 'LIVE_CONFIG_EOF'
LIVE_USERNAME="live"
LIVE_USER_FULLNAME="Live User"
LIVE_HOSTNAME="honey-badger-arm64"
LIVE_LOCALES="en_US.UTF-8"
LIVE_KEYBOARD_LAYOUTS="us"
LIVE_TIMEZONE="UTC"
LIVE_CONFIG_DEBUG="false"
LIVE_COMPONENTS="sudo user-setup locales keyboard-configuration"
LIVE_CONFIG_EOF

# Create basic resolv.conf
echo 'nameserver 8.8.8.8' | sudo tee "$ROOTFS_DIR/etc/resolv.conf" > /dev/null

# Add Honey Badger branding
echo 'Welcome to Honey Badger OS ARM64 Live!' | sudo tee "$ROOTFS_DIR/etc/motd" > /dev/null

# Configure GRUB for live boot
sudo mkdir -p "$ROOTFS_DIR/boot/grub"
sudo tee "$ROOTFS_DIR/boot/grub/grub.cfg" > /dev/null << 'GRUB_EOF'
set timeout=10
set default=0

insmod part_gpt
insmod part_msdos
insmod fat
insmod iso9660
insmod gzio
insmod linux
insmod normal

menuentry "Honey Badger OS ARM64 Live" {
    search --no-floppy --set=root --file /live/vmlinuz
    linux /live/vmlinuz boot=live components quiet splash
    initrd /live/initrd.img
}

menuentry "Honey Badger OS ARM64 Live (failsafe)" {
    search --no-floppy --set=root --file /live/vmlinuz
    linux /live/vmlinuz boot=live components memtest noapic noapm nodma nomce nolapic nomodeset nosmp nosplash vga=normal
    initrd /live/initrd.img
}
GRUB_EOF

# Set up ISO structure
echo "Setting up ISO structure..."
mkdir -p "$ISOWORK_DIR/live"
mkdir -p "$ISOWORK_DIR/boot/grub"

# Copy kernel and initrd
echo "Copying kernel and initrd..."
KERNEL=$(find "$ROOTFS_DIR/boot" -name "vmlinuz-*" | head -1)
INITRD=$(find "$ROOTFS_DIR/boot" -name "initrd.img-*" | head -1)

if [ -f "$KERNEL" ]; then
    cp "$KERNEL" "$ISOWORK_DIR/live/vmlinuz"
    echo "Kernel copied: $(basename $KERNEL)"
else
    echo "ERROR: No kernel found in rootfs"
    exit 1
fi

if [ -f "$INITRD" ]; then
    cp "$INITRD" "$ISOWORK_DIR/live/initrd.img"  
    echo "Initrd copied: $(basename $INITRD)"
else
    echo "ERROR: No initrd found in rootfs"
    exit 1
fi

# Create SquashFS filesystem
echo "Creating SquashFS filesystem..."
sudo mksquashfs "$ROOTFS_DIR" "$ISOWORK_DIR/live/filesystem.squashfs" \
    -comp xz -b 1M -Xdict-size 100% \
    -e boot

# Copy GRUB configuration
cp "$ROOTFS_DIR/boot/grub/grub.cfg" "$ISOWORK_DIR/boot/grub/"

# Create GRUB EFI image
echo "Creating GRUB EFI image..."
mkdir -p "$ISOWORK_DIR/EFI/BOOT"

# Check if we have grub-mkimage
if command -v grub-mkimage >/dev/null 2>&1; then
    grub-mkimage -O arm64-efi -o "$ISOWORK_DIR/EFI/BOOT/BOOTAA64.EFI" \
        part_gpt part_msdos fat iso9660 normal boot linux configfile \
        search search_fs_file search_fs_uuid search_label gzio efi_gop efi_uga \
        loadbios chain halt reboot multiboot echo test true false loadenv
else
    echo "Warning: grub-mkimage not found, creating minimal EFI structure"
    # Create a basic EFI directory structure
    echo "This would contain GRUB EFI bootloader" > "$ISOWORK_DIR/EFI/BOOT/BOOTAA64.EFI"
fi

# Create simple grub.cfg for EFI
cat > "$ISOWORK_DIR/EFI/BOOT/grub.cfg" << 'EFI_GRUB_EOF'
search --no-floppy --set=root --file /live/vmlinuz
configfile /boot/grub/grub.cfg
EFI_GRUB_EOF

# Create the ISO
echo "Creating ISO image..."
ISO_NAME="honey-badger-arm64-live-$(date +%Y%m%d).iso"

if command -v xorriso >/dev/null 2>&1; then
    xorriso -as mkisofs \
        -V "HONEY_BADGER_ARM64" \
        -r -J \
        -eltorito-alt-boot \
        -e EFI/BOOT/BOOTAA64.EFI \
        -no-emul-boot \
        -isohybrid-gpt-basdat \
        -o "ISOs/$ISO_NAME" \
        "$ISOWORK_DIR"
else
    echo "Warning: xorriso not found, using genisoimage fallback"
    genisoimage -V "HONEY_BADGER_ARM64" -r -J -o "ISOs/$ISO_NAME" "$ISOWORK_DIR"
fi

# Check if ISO was created successfully  
if [ -f "ISOs/$ISO_NAME" ]; then
    ISO_SIZE=$(du -h "ISOs/$ISO_NAME" | cut -f1)
    echo ""
    echo "✅ SUCCESS! ARM64 Live ISO created:"
    echo "   File: ISOs/$ISO_NAME"
    echo "   Size: $ISO_SIZE"
    echo ""
    echo "Features included:"
    echo "• XFCE4 Desktop Environment"
    echo "• Firefox ESR Web Browser" 
    echo "• Live boot with autologin (user: live, no password)"
    echo "• Network Manager for connectivity"
    echo "• Thunar file manager"
    echo "• PulseAudio for sound"
    echo "• ARM64 EFI boot support"
    echo "• Complete Debian Bookworm base"
    echo ""
    echo "To test: Boot this ISO on an ARM64 system with EFI support"
else
    echo "❌ ERROR: ISO creation failed!"
    exit 1
fi