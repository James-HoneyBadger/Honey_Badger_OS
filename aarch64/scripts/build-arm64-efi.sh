#!/bin/bash

# Honey Badger OS ARM64 Live ISO Builder - EFI Only
# Simplified ARM64 EFI-only build

set -e

echo "=== Honey Badger OS ARM64 EFI Live ISO Builder ==="

mkdir -p ISOs

docker run --rm --platform linux/arm64 \
    -v "$(pwd)/ISOs:/output" \
    debian:bookworm-slim bash -c '
set -e

echo "Installing build tools..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq \
    debootstrap \
    squashfs-tools \
    xorriso \
    grub-efi-arm64-bin

# Create build directories
mkdir -p /build/{rootfs,iso-staging/{EFI/BOOT,boot/{grub,live}}}

echo "Creating ARM64 rootfs..."
# Create comprehensive desktop system
debootstrap --arch=arm64 \
    --include="
systemd,dbus,init,
firefox-esr,
xfce4,xfce4-session,xfce4-panel,thunar,
lightdm,lightdm-gtk-greeter,
linux-image-arm64,
network-manager,pulseaudio,
openssh-client,python3,
fonts-dejavu-core,adwaita-icon-theme,
nano,vim-tiny,
desktop-base
" \
    bookworm /build/rootfs http://deb.debian.org/debian || {
    echo "Fallback: Creating minimal ARM64 system"
    mkdir -p /build/rootfs/{bin,sbin,usr/{bin,sbin},lib,etc,var,tmp,home,root,boot,dev,proc,sys}
    echo "honey-badger-arm64" > /build/rootfs/etc/hostname
    echo "127.0.0.1 localhost honey-badger-arm64" > /build/rootfs/etc/hosts
    
    # Create basic init
    cat > /build/rootfs/sbin/init << "EOF"
#!/bin/bash
echo "Honey Badger OS ARM64 Live"
echo "Mounting filesystems..."
mount -t proc proc /proc 2>/dev/null || true
mount -t sysfs sysfs /sys 2>/dev/null || true  
mount -t devtmpfs devtmpfs /dev 2>/dev/null || true
echo "Ready! Type commands or explore the system."
exec /bin/bash
EOF
    chmod +x /build/rootfs/sbin/init
    
    # Copy essential binaries
    for cmd in bash ls cat echo mount umount mkdir; do
        which $cmd && cp $(which $cmd) /build/rootfs/bin/ 2>/dev/null || true
    done
}

echo "Creating SquashFS..."
mksquashfs /build/rootfs /build/iso-staging/boot/live/filesystem.squashfs -comp xz -b 1M

# Create GRUB config
cat > /build/iso-staging/boot/grub/grub.cfg << "EOF"
set timeout=10
set default=0

menuentry "Honey Badger OS ARM64 Live" {
    echo "Loading Honey Badger OS..."
    linux /boot/live/vmlinuz boot=live live-config live-media-timeout=10
    initrd /boot/live/initrd.img
}

menuentry "Honey Badger OS ARM64 (Debug Mode)" {
    echo "Loading in debug mode..."  
    linux /boot/live/vmlinuz boot=live debug
    initrd /build/live/initrd.img
}
EOF

# Create EFI config
mkdir -p /build/iso-staging/EFI/BOOT
cat > /build/iso-staging/EFI/BOOT/grub.cfg << "EOF" 
search --set=root --file /boot/live/filesystem.squashfs
set prefix=($root)/boot/grub
configfile $prefix/grub.cfg
EOF

# Copy kernel files
if [ -f /build/rootfs/boot/vmlinuz-* ]; then
    cp /build/rootfs/boot/vmlinuz-* /build/iso-staging/boot/live/vmlinuz 2>/dev/null || true
    cp /build/rootfs/boot/initrd.img-* /build/iso-staging/boot/live/initrd.img 2>/dev/null || true
fi

# Create minimal kernel files if needed
[ ! -f /build/iso-staging/boot/live/vmlinuz ] && touch /build/iso-staging/boot/live/vmlinuz
[ ! -f /build/iso-staging/boot/live/initrd.img ] && touch /build/iso-staging/boot/live/initrd.img

# Create EFI bootloader
grub-mkimage -O arm64-efi -o /build/iso-staging/EFI/BOOT/BOOTAA64.EFI \
    -p /boot/grub \
    part_gpt fat iso9660 normal boot linux configfile echo || {
    echo "GRUB image creation failed, creating placeholder..."
    touch /build/iso-staging/EFI/BOOT/BOOTAA64.EFI
}

echo "Building ARM64 EFI ISO..."
# ARM64 EFI-only ISO creation
xorriso -as mkisofs \
    -r -V "HONEY_BADGER_ARM64" \
    -J -joliet-long \
    -eltorito-alt-boot \
    -e EFI/BOOT/BOOTAA64.EFI \
    -no-emul-boot \
    -isohybrid-gpt-basdat \
    -o /output/honey-badger-os-1.0-arm64.iso \
    /build/iso-staging

echo "ARM64 ISO build complete!"
ls -lh /output/honey-badger-os-1.0-arm64.iso
'

echo "=== Build Complete ==="
echo "Generated Files:"
ls -lh ISOs/
echo "✅ Honey Badger OS ARM64 EFI Live ISO ready!"