#!/bin/bash
#
# Honey Badger OS - Quick Archboot Setup
# This script provides a simplified setup process for users who want
# to get started quickly with Honey Badger OS on Archboot
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Banner
cat << 'EOF'
 _   _                        ____            _                   ___  ____  
| | | | ___  _ __   ___ _   _ | __ )  __ _  __| | __ _  ___ _ __  / _ \/ ___| 
| |_| |/ _ \| '_ \ / _ \ | | ||  _ \ / _` |/ _` |/ _` |/ _ \ '__|| | | \___ \ 
|  _  | (_) | | | |  __/ |_| || |_) | (_| | (_| | (_| |  __/ |   | |_| |___) |
|_| |_|\___/|_| |_|\___|\__, ||____/ \__,_|\__,_|\__, |\___|_|    \___/|____/ 
                       |___/                    |___/                        

                    Archboot Edition - Quick Setup
EOF

echo ""
echo "Welcome to Honey Badger OS Archboot Edition!"
echo "This script will help you set up a complete development environment."
echo ""

# Check if we're in the right environment
if [ ! -d "/honey-badger" ] && [ ! -d "/run/archiso/bootmnt/honey-badger" ]; then
    error "Honey Badger assets not found. Are you running from the Honey Badger Archboot ISO?"
    exit 1
fi

# Find the honey-badger directory
HB_DIR=""
if [ -d "/honey-badger" ]; then
    HB_DIR="/honey-badger"
elif [ -d "/run/archiso/bootmnt/honey-badger" ]; then
    HB_DIR="/run/archiso/bootmnt/honey-badger"
fi

log "Honey Badger assets found at: $HB_DIR"

# Installation options
echo "Setup Options:"
echo "1. Full Installation (Complete development environment with XFCE)"
echo "2. Minimal Installation (Essential tools only)"  
echo "3. Developer Focus (Programming tools and editors)"
echo "4. Desktop Focus (XFCE with productivity applications)"
echo "5. Custom Installation (Choose components)"
echo "6. Exit"
echo ""

read -p "Please select an option (1-6): " choice

case $choice in
    1)
        log "Starting full Honey Badger OS installation..."
        export HB_INSTALL_TYPE="full"
        ;;
    2) 
        log "Starting minimal installation..."
        export HB_INSTALL_TYPE="minimal"
        ;;
    3)
        log "Starting developer-focused installation..."
        export HB_INSTALL_TYPE="developer"
        ;;
    4)
        log "Starting desktop-focused installation..."  
        export HB_INSTALL_TYPE="desktop"
        ;;
    5)
        log "Starting custom installation..."
        export HB_INSTALL_TYPE="custom"
        ;;
    6)
        log "Exiting setup..."
        exit 0
        ;;
    *)
        error "Invalid option selected"
        exit 1
        ;;
esac

# Arch Linux installation check
if ! arch-chroot /mnt echo "Arch installation found" 2>/dev/null; then
    warning "No Arch Linux installation detected at /mnt"
    echo ""
    echo "Please complete the base Arch Linux installation first:"
    echo "1. Partition your disk (cfdisk, fdisk, or parted)"
    echo "2. Format partitions (mkfs.ext4, mkfs.fat, etc.)"
    echo "3. Mount root partition to /mnt"
    echo "4. Install base system: pacstrap /mnt base linux linux-firmware"
    echo "5. Generate fstab: genfstab -U /mnt >> /mnt/etc/fstab"
    echo "6. Chroot: arch-chroot /mnt"
    echo "7. Set timezone, locale, hostname, users, bootloader"
    echo "8. Exit chroot and run this script again"
    echo ""
    read -p "Do you want to continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Setup cancelled. Please complete Arch installation first."
        exit 0
    fi
fi

# Copy honey-badger assets to the installed system
log "Copying Honey Badger assets to installed system..."
arch-chroot /mnt mkdir -p /tmp/honey-badger-setup
cp -r "$HB_DIR"/* /mnt/tmp/honey-badger-setup/

# Create installation script based on type
cat > /mnt/tmp/install-honeybadger.sh << EOF
#!/bin/bash
set -e

cd /tmp/honey-badger-setup

# Export installation type
export HB_INSTALL_TYPE="$HB_INSTALL_TYPE"

# Run the main post-install script
if [ -f "scripts/post-install-setup.sh" ]; then
    bash scripts/post-install-setup.sh
else
    echo "Error: Post-install script not found!"
    exit 1
fi
EOF

chmod +x /mnt/tmp/install-honeybadger.sh

# Run the installation in chroot
log "Running Honey Badger setup in chroot environment..."
arch-chroot /mnt /tmp/install-honeybadger.sh

# Clean up
arch-chroot /mnt rm -rf /tmp/honey-badger-setup /tmp/install-honeybadger.sh

success "Honey Badger OS setup completed successfully!"
echo ""
echo "🦡 Your system is now configured with:"
case $HB_INSTALL_TYPE in
    "full")
        echo "  ✓ Complete XFCE desktop environment"
        echo "  ✓ Full developer tool stack"
        echo "  ✓ Productivity applications"
        echo "  ✓ Multimedia support"
        ;;
    "minimal")
        echo "  ✓ Essential system tools"
        echo "  ✓ nano editor configuration"
        echo "  ✓ Basic development tools"
        ;;
    "developer")
        echo "  ✓ Programming languages and tools"
        echo "  ✓ Code editors and IDEs"
        echo "  ✓ Version control systems"
        echo "  ✓ Container and cloud tools"
        ;;
    "desktop")
        echo "  ✓ XFCE desktop environment"
        echo "  ✓ Office and productivity apps"
        echo "  ✓ Media applications"
        echo "  ✓ System utilities"
        ;;
esac
echo "  ✓ Custom Honey Badger theme and branding"
echo "  ✓ nano as default system editor"  
echo "  ✓ hb.jpg as distro icon"
echo ""
echo "Next steps:"
echo "1. Exit the chroot environment (if you're in one)"
echo "2. Unmount partitions: umount -R /mnt"
echo "3. Reboot: reboot"
echo "4. Log into your new Honey Badger OS system!"
echo ""
echo "After reboot, run 'honey-badger-info' to see your system information."
echo ""
success "Thank you for choosing Honey Badger OS! 🦡"