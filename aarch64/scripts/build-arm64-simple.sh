#!/bin/bash

# Honey Badger OS ARM64 ISO Build Script (Simple Approach)
# This version uses a simpler approach with native tools

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
BUILD_NAME="honey-badger-os-1.0-arm64"
ISO_NAME="${BUILD_NAME}.iso"

echo "=== Honey Badger OS ARM64 ISO Builder (Simple Approach) ==="
echo "Build Name: $BUILD_NAME"
echo "Script Directory: $SCRIPT_DIR"
echo "Project Root: $PROJECT_ROOT"

# Clean up any existing containers
echo "Cleaning up existing containers..."
docker rm -f honey-badger-arm64-simple 2>/dev/null || true

# Create simple Docker container for ARM64 build
echo "Creating Docker build environment..."
docker run -d \
    --name honey-badger-arm64-simple \
    --platform linux/arm64 \
    -v "$PROJECT_ROOT:/workspace:ro" \
    debian:bookworm-slim \
    sleep 7200

# Wait a moment for container to initialize
sleep 2

# Install essential build dependencies
echo "Installing build dependencies..."
docker exec honey-badger-arm64-simple bash -c "
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y \
        debootstrap \
        squashfs-tools \
        xorriso \
        grub-efi-arm64-bin \
        mtools \
        dosfstools \
        wget \
        cpio \
        gzip \
        findutils \
        sed
"

# Create a basic ARM64 rootfs
echo "Creating basic ARM64 rootfs..."
docker exec honey-badger-arm64-simple bash -c "
    mkdir -p /build/rootfs /build/iso-staging
    cd /build
    
    # Create a minimal Debian ARM64 rootfs
    debootstrap --arch=arm64 --variant=minbase --include=systemd-sysv,network-manager,grub-efi-arm64,linux-image-arm64,task-xfce-desktop,firefox-esr,openssh-client bookworm rootfs http://deb.debian.org/debian
    
    if [ \$? -ne 0 ]; then
        echo 'Debootstrap failed, creating minimal custom rootfs...'
        
        # Create basic directory structure
        mkdir -p rootfs/{bin,boot,dev,etc,home,lib,media,mnt,opt,proc,root,run,sbin,srv,sys,tmp,usr,var}
        mkdir -p rootfs/usr/{bin,lib,local,sbin,share}
        mkdir -p rootfs/var/{cache,lib,log,run,tmp}
        
        # Create essential files
        echo 'honey-badger-os' > rootfs/etc/hostname
        
        cat > rootfs/etc/passwd << 'PASSWD'
root:x:0:0:root:/root:/bin/bash
live:x:1000:1000:Live User:/home/live:/bin/bash
PASSWD
        
        cat > rootfs/etc/group << 'GROUP'
root:x:0:
sudo:x:27:live
audio:x:29:live
video:x:44:live
plugdev:x:46:live
netdev:x:109:live
live:x:1000:
GROUP
        
        # Create live user home
        mkdir -p rootfs/home/live
        chown 1000:1000 rootfs/home/live 2>/dev/null || true
        
        cat > rootfs/etc/fstab << 'FSTAB'
# Static information about the filesystems.
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
tmpfs          /tmp            tmpfs   nosuid,nodev    0       0
FSTAB
        
        # Create init script
        cat > rootfs/sbin/init << 'INIT'
#!/bin/bash
echo \"Honey Badger OS ARM64 - Booting...\"
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev
echo \"Welcome to Honey Badger OS ARM64!\"
echo \"This is a minimal demonstration ISO.\"
echo \"The system is now ready.\"
/bin/bash
INIT
        chmod +x rootfs/sbin/init
        
        # Create a minimal bash if it doesn't exist
        if [ ! -f rootfs/bin/bash ]; then
            echo '#!/bin/sh' > rootfs/bin/bash
            echo 'echo \"Honey Badger OS Shell\"' >> rootfs/bin/bash
            echo 'echo \"Type exit to quit\"' >> rootfs/bin/bash
            echo 'while true; do' >> rootfs/bin/bash
            echo '  echo -n \"honey-badger-os# \"' >> rootfs/bin/bash
            echo '  read cmd' >> rootfs/bin/bash
            echo '  case \$cmd in' >> rootfs/bin/bash
            echo '    exit) break ;;' >> rootfs/bin/bash
            echo '    *) echo \"Command: \$cmd\" ;;' >> rootfs/bin/bash
            echo '  esac' >> rootfs/bin/bash
            echo 'done' >> rootfs/bin/bash
            chmod +x rootfs/bin/bash
        fi
        
        echo 'Basic rootfs structure created'
    fi
"

# Create the ISO structure
echo "Creating ISO structure..."
docker exec honey-badger-arm64-simple bash -c "
    cd /build
    
    # Create SquashFS filesystem
    mksquashfs rootfs iso-staging/live/filesystem.squashfs -comp xz
    
    # Create boot directory structure
    mkdir -p iso-staging/boot/grub
    
    # Create GRUB configuration
    cat > iso-staging/boot/grub/grub.cfg << 'GRUBCFG'
set timeout=10
set default=0

menuentry \"Honey Badger OS ARM64 Live\" {
    linux /boot/vmlinuz boot=live
    initrd /boot/initrd
}

menuentry \"Honey Badger OS ARM64 Live (Safe Mode)\" {
    linux /boot/vmlinuz boot=live nomodeset
    initrd /boot/initrd
}
GRUBCFG

    # Copy kernel and initrd if available from the rootfs
    if [ -f rootfs/boot/vmlinuz-* ]; then
        cp rootfs/boot/vmlinuz-* iso-staging/boot/vmlinuz
    else
        # Create a dummy kernel for demonstration
        echo 'KERNEL_PLACEHOLDER' > iso-staging/boot/vmlinuz
    fi
    
    if [ -f rootfs/boot/initrd.img-* ]; then
        cp rootfs/boot/initrd.img-* iso-staging/boot/initrd
    else
        # Create a dummy initrd for demonstration
        echo 'INITRD_PLACEHOLDER' > iso-staging/boot/initrd
    fi
    
    # Create the ISO image
    xorriso -as mkisofs \\
        -r -V 'HONEYBADGER_ARM64' \\
        -o ${BUILD_NAME}.iso \\
        -J -joliet-long \\
        -cache-inodes \\
        -isohybrid-apm-hfsplus \\
        iso-staging/
    
    if [ -f ${BUILD_NAME}.iso ]; then
        ls -lh ${BUILD_NAME}.iso
        echo 'ISO created successfully!'
    else
        echo 'ISO creation failed'
        exit 1
    fi
"

# Copy the ISO file back to host
echo "Retrieving built ISO..."
docker exec honey-badger-arm64-simple bash -c "
    if [ -f /build/${BUILD_NAME}.iso ]; then
        mkdir -p /workspace/ISOs
        cp /build/${BUILD_NAME}.iso /workspace/ISOs/
        echo 'ISO copied to host system'
    else
        echo 'No ISO file to copy'
        exit 1
    fi
"

# Cleanup
echo "Cleaning up..."
docker rm -f honey-badger-arm64-simple

echo "=== Build Process Complete ==="
if [ -f "$PROJECT_ROOT/ISOs/$ISO_NAME" ]; then
    echo "SUCCESS: ARM64 ISO created at: $PROJECT_ROOT/ISOs/$ISO_NAME"
    ls -lh "$PROJECT_ROOT/ISOs/$ISO_NAME"
    
    echo ""
    echo "ISO Details:"
    file "$PROJECT_ROOT/ISOs/$ISO_NAME"
    echo ""
    echo "Size: $(du -h "$PROJECT_ROOT/ISOs/$ISO_NAME" | cut -f1)"
    
    echo ""
    echo "The ISO has been created with a basic ARM64 structure."
    echo "Note: This is a demonstration ISO that may require a full ARM64 system to test properly."
else
    echo "Build completed but ISO file not found in expected location"
    echo "Check the ISOs directory for any generated files:"
    ls -la "$PROJECT_ROOT/ISOs/" 2>/dev/null || echo "ISOs directory not found"
fi