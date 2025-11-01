#!/bin/bash
#
# Honey Badger OS Archboot ISO Builder
# Creates a custom Archboot ISO with Honey Badger post-install script
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
WORK_DIR="/tmp/honey-badger-archboot-$$"
ISO_DIR="$WORK_DIR/iso"
CUSTOM_DIR="$WORK_DIR/custom"
OUTPUT_DIR="$PROJECT_ROOT/../ISOs"

# Archboot ISO details
ARCHBOOT_ISO="$PROJECT_ROOT/archboot-2025.08.26-02.27-6.16.3-1-aarch64-ARCH-local-aarch64.iso"
OUTPUT_ISO="$OUTPUT_DIR/honey-badger-archboot-$(date +%Y%m%d).iso"

cleanup() {
    log "Cleaning up temporary files..."
    sudo umount "$ISO_DIR" 2>/dev/null || true
    rm -rf "$WORK_DIR"
}
trap cleanup EXIT

log "Starting Honey Badger Archboot ISO build process..."

# Check dependencies
log "Checking dependencies..."
MISSING_DEPS=()

for cmd in xorriso unsquashfs mksquashfs; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        MISSING_DEPS+=("$cmd")
    fi
done

if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
    error "Missing dependencies: ${MISSING_DEPS[*]}"
    log "Please install missing dependencies and try again."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        log "On macOS, you can install with: brew install xorriso squashfs"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        log "On Linux, install: sudo apt-get install xorriso squashfs-tools (Ubuntu/Debian)"
        log "                   sudo pacman -S xorriso squashfs-tools (Arch)"
    fi
    exit 1
fi

# Check if original archboot ISO exists
if [ ! -f "$ARCHBOOT_ISO" ]; then
    error "Archboot ISO not found: $ARCHBOOT_ISO"
    log "Please ensure the archboot ISO is available in the project root."
    exit 1
fi

# Check if hb.jpg exists
if [ ! -f "$PROJECT_ROOT/hb.jpg" ]; then
    error "hb.jpg not found in project root"
    exit 1
fi

# Create working directories
log "Creating working directories..."
mkdir -p "$WORK_DIR" "$ISO_DIR" "$CUSTOM_DIR" "$OUTPUT_DIR"

# Mount the original ISO
log "Mounting original archboot ISO..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS mounting
    hdiutil attach "$ARCHBOOT_ISO" -mountpoint "$ISO_DIR" -readonly
else
    # Linux mounting
    sudo mount -o loop,ro "$ARCHBOOT_ISO" "$ISO_DIR"
fi

# Copy ISO contents to working directory
log "Copying ISO contents..."
cp -r "$ISO_DIR"/* "$CUSTOM_DIR/"

# Unmount the original ISO
if [[ "$OSTYPE" == "darwin"* ]]; then
    hdiutil detach "$ISO_DIR"
else
    sudo umount "$ISO_DIR"
fi

# Create honey-badger directory in the custom ISO
log "Adding Honey Badger customizations..."
mkdir -p "$CUSTOM_DIR/honey-badger"
mkdir -p "$CUSTOM_DIR/honey-badger/scripts"
mkdir -p "$CUSTOM_DIR/honey-badger/assets"
mkdir -p "$CUSTOM_DIR/honey-badger/config"
mkdir -p "$CUSTOM_DIR/honey-badger/theme"

# Copy post-install script
cp "$PROJECT_ROOT/scripts/post-install-setup.sh" "$CUSTOM_DIR/honey-badger/scripts/"
chmod +x "$CUSTOM_DIR/honey-badger/scripts/post-install-setup.sh"

# Copy hb.jpg and other assets
cp "$PROJECT_ROOT/hb.jpg" "$CUSTOM_DIR/honey-badger/assets/"

# Copy wallpapers if available
if [ -d "$PROJECT_ROOT/assets/wallpapers" ]; then
    cp -r "$PROJECT_ROOT/assets/wallpapers" "$CUSTOM_DIR/honey-badger/assets/"
fi

# Copy theme files if available
if [ -d "$PROJECT_ROOT/theme" ]; then
    cp -r "$PROJECT_ROOT/theme"/* "$CUSTOM_DIR/honey-badger/theme/"
fi

# Create honey-badger installer script
cat > "$CUSTOM_DIR/honey-badger/install-honey-badger.sh" << 'EOF'
#!/bin/bash
#
# Honey Badger OS Installer Script
# Run this after basic Arch installation to set up Honey Badger environment
#

set -e

echo "=== Honey Badger OS Post-Installation Setup ==="
echo ""
echo "This script will configure your fresh Arch Linux installation"
echo "with the complete Honey Badger environment including:"
echo ""
echo "• XFCE desktop environment with goodies"
echo "• Complete developer tools and utilities"
echo "• nano as default editor"
echo "• Custom Honey Badger theme and branding"
echo "• hb.jpg as distro icon"
echo ""
read -p "Continue with Honey Badger setup? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup cancelled."
    exit 0
fi

# Create temporary directory for setup files
SETUP_DIR="/tmp/honey-badger-setup"
mkdir -p "$SETUP_DIR"

# Copy assets to temporary location
if [ -d "/run/archiso/bootmnt/honey-badger" ]; then
    cp -r /run/archiso/bootmnt/honey-badger/* "$SETUP_DIR/"
elif [ -d "/honey-badger" ]; then
    cp -r /honey-badger/* "$SETUP_DIR/"
else
    echo "Warning: Honey Badger assets not found, some features may be limited"
fi

# Run the main setup script
if [ -f "$SETUP_DIR/scripts/post-install-setup.sh" ]; then
    bash "$SETUP_DIR/scripts/post-install-setup.sh"
else
    echo "Error: Post-install setup script not found!"
    exit 1
fi

# Cleanup
rm -rf "$SETUP_DIR"

echo ""
echo "Honey Badger OS setup completed successfully!"
echo "Please reboot to start using your new Honey Badger environment."
EOF

chmod +x "$CUSTOM_DIR/honey-badger/install-honey-badger.sh"

# Create README for the custom ISO
cat > "$CUSTOM_DIR/honey-badger/README.md" << 'EOF'
# Honey Badger OS - Archboot Edition

This is a customized Archboot ISO that includes the Honey Badger OS post-installation setup.

## Quick Start

1. Boot from this ISO
2. Install Arch Linux as usual using the archboot installer
3. After basic installation, run the Honey Badger setup:
   ```bash
   /honey-badger/install-honey-badger.sh
   ```

## What's Included

- **Desktop Environment**: XFCE4 with full goodies package
- **Default Editor**: nano (configured as system default)
- **Developer Tools**: Complete development stack including:
  - Languages: Python, Node.js, Go, Rust, C/C++
  - Editors: nano, vim, neovim, VS Code
  - Version Control: Git, GitHub CLI
  - Containers: Docker, Docker Compose
  - Cloud Tools: kubectl, helm, terraform
  - Virtualization: VirtualBox, QEMU, libvirt
  - And many more...
- **Applications**: Firefox, LibreOffice, GIMP, VLC, and essential tools
- **Theme**: Custom Honey Badger theme with hb.jpg as distro icon
- **Utilities**: System management and monitoring tools

## Manual Installation Steps

If you prefer to install step by step:

1. Boot from ISO and install base Arch Linux
2. Reboot into new system
3. Copy the honey-badger directory from ISO:
   ```bash
   mkdir -p /mnt/iso
   mount /dev/sr0 /mnt/iso  # or appropriate device
   cp -r /mnt/iso/honey-badger /tmp/
   ```
4. Run the setup script:
   ```bash
   cd /tmp/honey-badger
   ./install-honey-badger.sh
   ```

## Features

- **Comprehensive Development Environment**: Everything needed for software development
- **User-Friendly Desktop**: XFCE4 configured for productivity
- **Custom Branding**: Honey Badger theme and iconography
- **Optimized Configuration**: Sensible defaults for development work
- **Easy Maintenance**: Built-in update and backup scripts

## Support Scripts

After installation, you'll have access to:
- `honey-badger-info` - System information and tool overview
- `honey-badger-update` - Update system and development tools
- `honey-badger-backup` - Backup user configurations

Enjoy your Honey Badger OS experience! 🦡
EOF

# Create autorun script that will be executed during boot
cat > "$CUSTOM_DIR/honey-badger/autorun.sh" << 'EOF'
#!/bin/bash
# Auto-setup script that runs during ISO boot

# Make honey-badger directory accessible
if [ -d "/run/archiso/bootmnt/honey-badger" ]; then
    ln -sf /run/archiso/bootmnt/honey-badger /honey-badger
fi

# Display welcome message
cat << 'WELCOME'

=== Welcome to Honey Badger OS Archboot Edition ===

This ISO includes the Honey Badger OS post-installation setup.

After installing Arch Linux with archboot, run:
    /honey-badger/install-honey-badger.sh

Or access the setup files in: /honey-badger/

For more information: cat /honey-badger/README.md

WELCOME
EOF

chmod +x "$CUSTOM_DIR/honey-badger/autorun.sh"

# Modify the boot configuration to include our autorun script
log "Modifying boot configuration..."

# Find and modify isolinux.cfg or grub.cfg if they exist
if [ -f "$CUSTOM_DIR/boot/grub/grub.cfg" ]; then
    log "Adding Honey Badger boot entry to GRUB..."
    
    # Backup original grub.cfg
    cp "$CUSTOM_DIR/boot/grub/grub.cfg" "$CUSTOM_DIR/boot/grub/grub.cfg.orig"
    
    # Add Honey Badger entry (insert after first menuentry)
    sed -i '/^menuentry.*{$/a\\n# Honey Badger OS Entry\nmenuentry "Honey Badger OS (Archboot with Auto-Setup)" {\n    set gfxpayload=keep\n    linux /boot/vmlinuz-linux archisobasedir=arch archisolabel=ARCH_CUSTOM cow_spacesize=1G copytoram\n    initrd /boot/initramfs-linux.img\n}' "$CUSTOM_DIR/boot/grub/grub.cfg"
fi

if [ -f "$CUSTOM_DIR/isolinux/isolinux.cfg" ]; then
    log "Adding Honey Badger boot entry to isolinux..."
    
    # Backup original isolinux.cfg
    cp "$CUSTOM_DIR/isolinux/isolinux.cfg" "$CUSTOM_DIR/isolinux/isolinux.cfg.orig"
    
    # Add our custom boot entry
    cat >> "$CUSTOM_DIR/isolinux/isolinux.cfg" << 'ISOLINUX_EOF'

LABEL honeybadger
MENU LABEL Honey Badger OS (Archboot with Auto-Setup)
LINUX /boot/vmlinuz-linux
APPEND archisobasedir=arch archisolabel=ARCH_CUSTOM cow_spacesize=1G copytoram
INITRD /boot/initramfs-linux.img
ISOLINUX_EOF
fi

# Create custom airootfs overlay if directory structure allows
if [ -d "$CUSTOM_DIR/arch/x86_64/airootfs" ] || [ -d "$CUSTOM_DIR/arch/aarch64/airootfs" ]; then
    log "Adding airootfs customizations..."
    
    # Determine architecture
    if [ -d "$CUSTOM_DIR/arch/aarch64/airootfs" ]; then
        AIROOTFS_DIR="$CUSTOM_DIR/arch/aarch64/airootfs"
    else
        AIROOTFS_DIR="$CUSTOM_DIR/arch/x86_64/airootfs"
    fi
    
    # Add our autorun script to be executed on boot
    mkdir -p "$AIROOTFS_DIR/usr/local/bin"
    cp "$CUSTOM_DIR/honey-badger/autorun.sh" "$AIROOTFS_DIR/usr/local/bin/"
    
    # Add systemd service to run our script
    mkdir -p "$AIROOTFS_DIR/etc/systemd/system"
    cat > "$AIROOTFS_DIR/etc/systemd/system/honey-badger-welcome.service" << 'SERVICE_EOF'
[Unit]
Description=Honey Badger OS Welcome Script
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/autorun.sh
StandardOutput=journal+console
StandardError=journal+console

[Install]
WantedBy=multi-user.target
SERVICE_EOF

    # Enable the service
    mkdir -p "$AIROOTFS_DIR/etc/systemd/system/multi-user.target.wants"
    ln -sf ../honey-badger-welcome.service "$AIROOTFS_DIR/etc/systemd/system/multi-user.target.wants/"
fi

# Update ISO label
log "Updating ISO configuration..."

# Modify any references to the original ISO to include Honey Badger branding
find "$CUSTOM_DIR" -name "*.cfg" -type f -exec sed -i 's/ARCH_[0-9]*/HONEYBADGER_ARCH/g' {} \;
find "$CUSTOM_DIR" -name "*.txt" -type f -exec sed -i 's/Arch Linux/Honey Badger OS (Arch-based)/g' {} \;

# Create the new ISO
log "Creating Honey Badger Archboot ISO..."

# Set volume label
VOLUME_LABEL="HONEYBADGER_ARCH"

# Build the ISO
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS ISO creation
    hdiutil makehybrid -iso -joliet -o "$OUTPUT_ISO.tmp" "$CUSTOM_DIR"
    mv "$OUTPUT_ISO.tmp.iso" "$OUTPUT_ISO"
else
    # Linux ISO creation
    xorriso -as mkisofs \
        -V "$VOLUME_LABEL" \
        -r -J -joliet-long \
        -b isolinux/isolinux.bin \
        -c isolinux/boot.cat \
        -no-emul-boot \
        -boot-load-size 4 \
        -boot-info-table \
        -eltorito-alt-boot \
        -e boot/grub/efi.img \
        -no-emul-boot \
        -isohybrid-gpt-basdat \
        -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
        -o "$OUTPUT_ISO" \
        "$CUSTOM_DIR"
fi

# Verify the ISO was created
if [ -f "$OUTPUT_ISO" ]; then
    ISO_SIZE=$(du -h "$OUTPUT_ISO" | cut -f1)
    success "Honey Badger Archboot ISO created successfully!"
    echo ""
    echo "  📀 File: $OUTPUT_ISO"
    echo "  📏 Size: $ISO_SIZE"
    echo ""
    echo "🚀 Features included:"
    echo "  ✓ Base Archboot installation system"
    echo "  ✓ Honey Badger post-install setup script"
    echo "  ✓ XFCE desktop environment with goodies"
    echo "  ✓ Complete developer tool stack"
    echo "  ✓ nano as default editor"
    echo "  ✓ Custom Honey Badger theme and branding"
    echo "  ✓ hb.jpg as distro icon"
    echo ""
    echo "📋 Usage:"
    echo "  1. Boot from the ISO"
    echo "  2. Install Arch Linux using archboot installer"
    echo "  3. After installation, run: /honey-badger/install-honey-badger.sh"
    echo ""
    echo "🦡 Enjoy your Honey Badger OS experience!"
else
    error "Failed to create ISO"
    exit 1
fi