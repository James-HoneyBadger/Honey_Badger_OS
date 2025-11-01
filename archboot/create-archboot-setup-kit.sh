#!/bin/bash
#
# Honey Badger OS - Archboot Setup Kit Creator
# Creates a setup kit that can be used with any archboot ISO
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1"
}

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="$PROJECT_ROOT/../ISOs"
SETUP_KIT="$OUTPUT_DIR/honey-badger-archboot-setup-$(date +%Y%m%d).tar.gz"

log "Creating Honey Badger OS Archboot Setup Kit..."

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Create temporary directory for setup kit
TEMP_DIR="/tmp/honey-badger-setup-$$"
mkdir -p "$TEMP_DIR/honey-badger"

# Copy all archboot components
log "Packaging Honey Badger components..."

# Copy scripts
cp -r "$SCRIPT_DIR/scripts" "$TEMP_DIR/honey-badger/"

# Copy assets
cp -r "$SCRIPT_DIR/assets" "$TEMP_DIR/honey-badger/"
if [ -f "$PROJECT_ROOT/hb.jpg" ]; then
    cp "$PROJECT_ROOT/hb.jpg" "$TEMP_DIR/honey-badger/assets/"
fi

# Copy config files
cp -r "$SCRIPT_DIR/config" "$TEMP_DIR/honey-badger/"

# Copy theme files  
cp -r "$SCRIPT_DIR/theme" "$TEMP_DIR/honey-badger/"

# Copy additional assets from main project
if [ -d "$PROJECT_ROOT/assets" ]; then
    cp -r "$PROJECT_ROOT/assets"/* "$TEMP_DIR/honey-badger/assets/" 2>/dev/null || true
fi

if [ -d "$PROJECT_ROOT/theme" ]; then
    cp -r "$PROJECT_ROOT/theme"/* "$TEMP_DIR/honey-badger/theme/" 2>/dev/null || true
fi

# Create main installer script
log "Creating main installer script..."
cat > "$TEMP_DIR/honey-badger/install-honey-badger.sh" << 'EOF'
#!/bin/bash
#
# Honey Badger OS Installer
# Run this after booting from any archboot ISO and completing base Arch installation
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Banner
cat << 'BANNER'
 _   _                        ____            _                   ___  ____  
| | | | ___  _ __   ___ _   _ | __ )  __ _  __| | __ _  ___ _ __  / _ \/ ___| 
| |_| |/ _ \| '_ \ / _ \ | | ||  _ \ / _` |/ _` |/ _` |/ _ \ '__|| | | \___ \ 
|  _  | (_) | | | |  __/ |_| || |_) | (_| | (_| | (_| |  __/ |   | |_| |___) |
|_| |_|\___/|_| |_|\___|\__, ||____/ \__,_|\__,_|\__, |\___|_|    \___/|____/ 
                       |___/                    |___/                        

                        Archboot Installation
BANNER

echo ""
echo "Welcome to Honey Badger OS!"
echo ""
echo "This installer will set up a complete development environment with:"
echo "• XFCE4 desktop with custom Honey Badger theme"
echo "• Complete developer tool stack"
echo "• nano as default editor with enhanced configuration"
echo "• hb.jpg as distro icon throughout the system"
echo "• Productivity applications and utilities"
echo ""

# Check if we're running on an installed system
if [ ! -d "/mnt" ] || [ ! "$(mount | grep -c '/mnt')" -gt 0 ]; then
    warning "No mounted system detected at /mnt"
    echo ""
    echo "Please complete the Arch Linux base installation first:"
    echo "1. Boot from any archboot ISO"
    echo "2. Partition your disk and format filesystems"
    echo "3. Mount your root partition to /mnt"
    echo "4. Install base system: pacstrap /mnt base linux linux-firmware"
    echo "5. Generate fstab: genfstab -U /mnt >> /mnt/etc/fstab"
    echo "6. Chroot and configure: timezone, locale, hostname, users, bootloader"
    echo "7. Exit chroot and run this installer"
    echo ""
    read -p "Do you want to continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Installation cancelled."
        exit 0
    fi
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Installation type selection
echo "Installation Options:"
echo "1. Full Installation (Recommended - Complete environment)"
echo "2. Minimal Installation (Essential tools only)"
echo "3. Developer Focus (Programming tools and editors)"
echo "4. Desktop Focus (XFCE with productivity apps)"
echo "5. Exit"
echo ""

read -p "Select installation type (1-5): " choice

case $choice in
    1) INSTALL_TYPE="full";;
    2) INSTALL_TYPE="minimal";;
    3) INSTALL_TYPE="developer";;
    4) INSTALL_TYPE="desktop";;
    5) log "Exiting..."; exit 0;;
    *) error "Invalid choice"; exit 1;;
esac

log "Selected: $INSTALL_TYPE installation"

# Copy setup files to target system
log "Copying Honey Badger setup to target system..."
if [ -d "/mnt" ]; then
    cp -r "$SCRIPT_DIR" /mnt/tmp/honey-badger-setup
    
    # Create installation script in chroot
    cat > /mnt/tmp/install-in-chroot.sh << CHROOT_EOF
#!/bin/bash
set -e
export HB_INSTALL_TYPE="$INSTALL_TYPE"
cd /tmp/honey-badger-setup
bash scripts/post-install-setup.sh
rm -rf /tmp/honey-badger-setup /tmp/install-in-chroot.sh
CHROOT_EOF
    
    chmod +x /mnt/tmp/install-in-chroot.sh
    
    # Run installation in chroot
    log "Running Honey Badger setup..."
    arch-chroot /mnt /tmp/install-in-chroot.sh
    
    success "Honey Badger OS installation completed successfully!"
    echo ""
    echo "🦡 Your system is now configured with Honey Badger OS!"
    echo ""
    echo "Next steps:"
    echo "1. Unmount filesystems: umount -R /mnt"
    echo "2. Reboot your system"
    echo "3. Boot into your new Honey Badger OS environment"
    echo "4. Log in and run: honey-badger-info"
    echo ""
    success "Enjoy your fearless development environment! 🦡"
else
    # Direct installation (if already in the target system)
    export HB_INSTALL_TYPE="$INSTALL_TYPE"
    bash "$SCRIPT_DIR/scripts/post-install-setup.sh"
    
    success "Honey Badger OS installation completed!"
    echo "Please reboot to ensure all changes take effect."
fi
EOF

chmod +x "$TEMP_DIR/honey-badger/install-honey-badger.sh"

# Create quick start guide
log "Creating documentation..."
cat > "$TEMP_DIR/honey-badger/QUICK_START.md" << 'EOF'
# Honey Badger OS - Quick Start Guide

## Overview

This setup kit installs the complete Honey Badger OS environment on top of any Arch Linux installation. It provides a developer-focused desktop environment with custom theming and comprehensive tools.

## Installation Steps

### 1. Boot from Archboot ISO
Use any standard archboot ISO to boot your system.

### 2. Install Base Arch Linux
Follow standard Arch installation process:
```bash
# Partition disk
cfdisk /dev/sda

# Format partitions (example)
mkfs.fat -F32 /dev/sda1    # EFI partition
mkfs.ext4 /dev/sda2        # Root partition

# Mount filesystems
mount /dev/sda2 /mnt
mkdir -p /mnt/boot
mount /dev/sda1 /mnt/boot

# Install base system
pacstrap /mnt base linux linux-firmware nano

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Configure system
arch-chroot /mnt
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "honeybadger" > /etc/hostname
passwd  # Set root password

# Create user
useradd -m -G wheel -s /bin/bash yourusername
passwd yourusername

# Enable sudo
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# Install bootloader (example for systemd-boot)
bootctl install
echo "title Honey Badger OS
linux /vmlinuz-linux
initrd /initramfs-linux.img
options root=/dev/sda2 rw" > /boot/loader/entries/honeybadger.conf

exit
```

### 3. Extract Honey Badger Setup
```bash
# Extract setup kit
cd /tmp
tar -xzf honey-badger-archboot-setup-YYYYMMDD.tar.gz
cd honey-badger
```

### 4. Run Honey Badger Installer
```bash
./install-honey-badger.sh
```

### 5. Reboot and Enjoy
```bash
umount -R /mnt
reboot
```

## Installation Types

- **Full**: Complete environment (recommended for most users)
- **Minimal**: Essential tools only (servers, limited resources)
- **Developer**: Programming focus (software developers)
- **Desktop**: Productivity focus (office work, general use)

## What's Included

### Desktop Environment
- XFCE4 with custom Honey Badger theme
- Custom panels, menus, and window decorations
- hb.jpg integrated as system icon

### Development Tools
- Languages: Python, Node.js, Go, Rust, C/C++, Java
- Editors: nano (default), vim, neovim, VS Code
- Version Control: Git with GitHub CLI
- Containers: Docker, Docker Compose
- Cloud Tools: kubectl, helm, terraform

### Applications
- Firefox (default browser)
- LibreOffice (office suite)
- GIMP (image editor)
- VLC (media player)
- Thunderbird (email)

### System Utilities
- Enhanced nano configuration
- Custom shell environment
- System monitoring tools
- Development utilities

## Post-Installation

After rebooting into Honey Badger OS:

```bash
# View system information
honey-badger-info

# Update system
honey-badger-update  

# Backup configuration
honey-badger-backup
```

## Customization

All theme files and configurations are stored in:
- `~/.config/honey-badger/` - User configurations
- `~/.local/share/honey-badger/` - User assets
- `/usr/share/honey-badger/` - System-wide assets

## Support

For issues or questions:
1. Check system logs: `journalctl -xe`
2. Verify installation: `honey-badger-info`
3. GitHub issues: [project repository]

Enjoy your Honey Badger OS experience! 🦡
EOF

# Create installation verification script
cat > "$TEMP_DIR/honey-badger/verify-installation.sh" << 'EOF'
#!/bin/bash
# Honey Badger OS Installation Verification Script

echo "=== Honey Badger OS Installation Verification ==="
echo ""

# Check if we're on Arch Linux
if [ -f /etc/arch-release ]; then
    echo "✓ Arch Linux base detected"
else
    echo "✗ Not running on Arch Linux"
fi

# Check for XFCE
if command -v xfce4-session >/dev/null 2>&1; then
    echo "✓ XFCE4 desktop environment installed"
else
    echo "✗ XFCE4 not found"
fi

# Check for nano configuration
if [ -f ~/.nanorc ]; then
    echo "✓ Enhanced nano configuration found"
else
    echo "✗ nano configuration missing"
fi

# Check for Honey Badger assets
if [ -f ~/.local/share/honey-badger/honey-badger-icon.jpg ]; then
    echo "✓ Honey Badger assets installed"
else
    echo "✗ Honey Badger assets missing"
fi

# Check for development tools
dev_tools=("python" "node" "go" "rustc" "gcc" "git" "docker")
for tool in "${dev_tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "✓ $tool installed"
    else
        echo "✗ $tool missing"
    fi
done

# Check services
services=("lightdm" "NetworkManager" "docker")
for service in "${services[@]}"; do
    if systemctl is-enabled "$service" >/dev/null 2>&1; then
        echo "✓ $service service enabled"
    else
        echo "✗ $service service not enabled"
    fi
done

echo ""
echo "Verification complete!"
EOF

chmod +x "$TEMP_DIR/honey-badger/verify-installation.sh"

# Create the setup kit tarball
log "Creating setup kit archive..."
cd "$TEMP_DIR"
tar -czf "$SETUP_KIT" honey-badger/

# Cleanup
rm -rf "$TEMP_DIR"

# Verify creation
if [ -f "$SETUP_KIT" ]; then
    SETUP_SIZE=$(du -h "$SETUP_KIT" | cut -f1)
    success "Honey Badger Archboot Setup Kit created successfully!"
    echo ""
    echo "📦 Setup Kit: $SETUP_KIT"
    echo "📏 Size: $SETUP_SIZE"
    echo ""
    echo "🚀 Usage:"
    echo "  1. Boot from any archboot ISO"
    echo "  2. Complete base Arch Linux installation"
    echo "  3. Extract: tar -xzf $(basename "$SETUP_KIT")"
    echo "  4. Run: cd honey-badger && ./install-honey-badger.sh"
    echo ""
    echo "📋 Features:"
    echo "  ✓ XFCE desktop with Honey Badger theme"
    echo "  ✓ Complete developer tool stack"
    echo "  ✓ nano as enhanced default editor"
    echo "  ✓ hb.jpg as distro icon"
    echo "  ✓ Multiple installation types"
    echo "  ✓ Comprehensive documentation"
    echo ""
    echo "🦡 Compatible with any archboot ISO!"
else
    error "Failed to create setup kit"
    exit 1
fi