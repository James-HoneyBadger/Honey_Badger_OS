#!/bin/bash
set -e

echo "Building ARM64 Honey Badger OS ISO with live functionality..."

# Clean up previous builds
if [ -d "ISOs" ]; then
    rm -f ISOs/honey-badger-arm64-*.iso
fi
mkdir -p ISOs

# Create build directory structure
BUILD_DIR="/tmp/honey-badger-build-$$"
ROOTFS_DIR="$BUILD_DIR/rootfs"
ISOWORK_DIR="$BUILD_DIR/isowork"

cleanup() {
    echo "Cleaning up..."
    rm -rf "$BUILD_DIR"
}
trap cleanup EXIT

mkdir -p "$BUILD_DIR" "$ROOTFS_DIR" "$ISOWORK_DIR"

# Use Docker to create the rootfs
echo "Creating ARM64 rootfs with Docker..."
docker run --rm --platform linux/arm64 \
    -v "$BUILD_DIR:/build" \
    debian:bookworm-slim bash -c "
set -e
export DEBIAN_FRONTEND=noninteractive

# Update package lists
apt-get update

# Install essential packages first
apt-get install -y --no-install-recommends \
    debootstrap \
    squashfs-tools \
    xorriso \
    grub-efi-arm64-bin \
    grub2-common

# Create base system
debootstrap --arch=arm64 \
    --include=systemd,systemd-sysv,init,sudo,nano,firefox-esr,xfce4,lightdm,lightdm-gtk-greeter,thunar,pulseaudio,network-manager,live-boot,live-config,linux-image-arm64,grub-efi-arm64 \
    --exclude=rsyslog \
    bookworm /build/rootfs http://deb.debian.org/debian

# Configure the system in chroot without starting services
echo 'Configuring ARM64 system...'

# Set hostname
echo 'honey-badger-arm64' > /build/rootfs/etc/hostname

# Configure hosts file
cat > /build/rootfs/etc/hosts << 'HOSTS_EOF'
127.0.0.1   localhost
127.0.1.1   honey-badger-arm64
::1         localhost ip6-localhost ip6-loopback
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
HOSTS_EOF

# Create live user without chroot (to avoid service start issues)
echo 'live:x:1000:1000:Live User,,,:/home/live:/bin/bash' >> /build/rootfs/etc/passwd
echo 'live:*:19000:0:99999:7:::' >> /build/rootfs/etc/shadow
echo 'live:x:1000:' >> /build/rootfs/etc/group
echo 'live ALL=(ALL) NOPASSWD:ALL' > /build/rootfs/etc/sudoers.d/live

# Create live user home directory
mkdir -p /build/rootfs/home/live
chmod 755 /build/rootfs/home/live

# Configure autologin for lightdm
mkdir -p /build/rootfs/etc/lightdm
cat > /build/rootfs/etc/lightdm/lightdm.conf << 'LIGHTDM_EOF'
[Seat:*]
autologin-user=live
autologin-user-timeout=0
user-session=xfce
greeter-session=lightdm-gtk-greeter
LIGHTDM_EOF

# Configure live-config
echo 'LIVE_USERNAME=\"live\"' > /build/rootfs/etc/live/config.conf
echo 'LIVE_USER_FULLNAME=\"Live User\"' >> /build/rootfs/etc/live/config.conf
echo 'LIVE_HOSTNAME=\"honey-badger-arm64\"' >> /build/rootfs/etc/live/config.conf

# Configure GRUB for live boot
mkdir -p /build/rootfs/boot/grub
cat > /build/rootfs/boot/grub/grub.cfg << 'GRUB_EOF'
set timeout=10
set default=0

insmod part_gpt
insmod part_msdos
insmod fat
insmod iso9660
insmod gzio
insmod linux
insmod normal

menuentry \"Honey Badger OS ARM64 Live\" {
    search --no-floppy --set=root --file /live/vmlinuz
    linux /live/vmlinuz boot=live components quiet splash
    initrd /live/initrd.img
}

menuentry \"Honey Badger OS ARM64 Live (failsafe)\" {
    search --no-floppy --set=root --file /live/vmlinuz
    linux /live/vmlinuz boot=live components memtest noapic noapm nodma nomce nolapic nomodeset nosmp nosplash vga=normal
    initrd /live/initrd.img
}
GRUB_EOF

# Create basic resolv.conf for internet access
echo 'nameserver 8.8.8.8' > /build/rootfs/etc/resolv.conf

# Add Honey Badger branding
echo 'Welcome to Honey Badger OS ARM64!' > /build/rootfs/etc/motd

# Set up live directories
mkdir -p /build/rootfs/live

echo 'ARM64 rootfs created successfully!'
"

# Create ISO structure
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
mksquashfs "$ROOTFS_DIR" "$ISOWORK_DIR/live/filesystem.squashfs" \
    -comp xz -b 1M -Xdict-size 100% \
    -e boot

# Copy GRUB configuration
cp "$ROOTFS_DIR/boot/grub/grub.cfg" "$ISOWORK_DIR/boot/grub/"

# Create GRUB EFI image
echo "Creating GRUB EFI image..."
mkdir -p "$ISOWORK_DIR/EFI/BOOT"

# Use GRUB from the host system to create EFI image
grub-mkimage -O arm64-efi -o "$ISOWORK_DIR/EFI/BOOT/BOOTAA64.EFI" \
    part_gpt part_msdos fat iso9660 normal boot linux configfile \
    search search_fs_file search_fs_uuid search_label gzio efi_gop efi_uga \
    loadbios chain halt reboot multiboot \
    echo test true false loadenv

# Create simple grub.cfg for EFI
cat > "$ISOWORK_DIR/EFI/BOOT/grub.cfg" << 'EFI_GRUB_EOF'
search --no-floppy --set=root --file /live/vmlinuz
configfile /boot/grub/grub.cfg
EFI_GRUB_EOF

# Create the ISO
echo "Creating ISO image..."
ISO_NAME="honey-badger-arm64-live-$(date +%Y%m%d).iso"

xorriso -as mkisofs \
    -V "HONEY_BADGER_ARM64" \
    -r -J \
    -b boot/grub/bios.img \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    -eltorito-alt-boot \
    -e EFI/BOOT/BOOTAA64.EFI \
    -no-emul-boot \
    -isohybrid-gpt-basdat \
    -o "ISOs/$ISO_NAME" \
    "$ISOWORK_DIR"

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
    echo "• Live boot with autologin (user: live)"
    echo "• Network Manager for connectivity"
    echo "• Thunar file manager"
    echo "• PulseAudio for sound"
    echo "• EFI boot support for ARM64"
    echo ""
else
    echo "❌ ERROR: ISO creation failed!"
    exit 1
fi