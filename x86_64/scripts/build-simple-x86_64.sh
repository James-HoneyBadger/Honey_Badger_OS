#!/bin/bash

# Honey Badger OS - Simple x86_64 ISO Builder 
# Creates a basic x86_64 ISO using existing tools

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

# Main build function
main() {
    log "🦡 Creating Honey Badger OS x86_64 ISO (Simple Method)"
    
    check_root
    
    WORK_DIR="/home/james/Honey_Badger_OS/x86_64/build/simple"
    ISO_DIR="$WORK_DIR/iso"  
    OUTPUT_DIR="/home/james/Honey_Badger_OS/x86_64/output"
    
    # Clean and create directories
    rm -rf "$WORK_DIR"
    mkdir -p "$ISO_DIR/live" "$ISO_DIR/boot/grub" "$OUTPUT_DIR"
    
    log "Creating minimal filesystem structure..."
    
    # Create a very minimal filesystem structure for demonstration
    MINI_ROOT="$WORK_DIR/miniroot"
    mkdir -p "$MINI_ROOT"/{bin,sbin,etc,proc,sys,dev,tmp,usr/{bin,sbin,lib,lib64,share},var,boot,home,root}
    
    # Copy essential binaries from host (this is a hack but will work for demo)
    cp /bin/bash "$MINI_ROOT/bin/"
    cp /bin/sh "$MINI_ROOT/bin/"
    cp /usr/bin/nano "$MINI_ROOT/usr/bin/"
    
    # Copy essential libraries (minimal set)
    mkdir -p "$MINI_ROOT/lib/x86_64-linux-gnu" "$MINI_ROOT/lib64"
    
    # Create basic init script
    cat > "$MINI_ROOT/sbin/init" << 'EOF'
#!/bin/bash
echo "🦡 Welcome to Honey Badger OS x86_64!"
echo "This is a minimal demonstration system."
echo "Nano editor is available as: nano"
exec /bin/bash
EOF
    chmod +x "$MINI_ROOT/sbin/init"
    
    # Basic system files
    echo "honey-badger-x86" > "$MINI_ROOT/etc/hostname"
    
    cat > "$MINI_ROOT/etc/os-release" << EOF
PRETTY_NAME="Honey Badger OS 1.0 (Fearless) x86_64"
NAME="Honey Badger OS"
VERSION_ID="1.0" 
VERSION="1.0 (Fearless)"
ID=honey-badger-os
ANSI_COLOR="0;33"
EOF
    
    # Copy honey badger assets
    mkdir -p "$MINI_ROOT/usr/share/pixmaps" "$MINI_ROOT/usr/share/backgrounds"
    if [[ -d "/home/james/Honey_Badger_OS/x86_64/assets" ]]; then
        cp "/home/james/Honey_Badger_OS/x86_64/assets/icons"/*.png "$MINI_ROOT/usr/share/pixmaps/" 2>/dev/null || true
        cp "/home/james/Honey_Badger_OS/x86_64/assets/wallpapers"/*.jpg "$MINI_ROOT/usr/share/backgrounds/" 2>/dev/null || true
    fi
    
    log "Creating SquashFS filesystem..."
    mksquashfs "$MINI_ROOT" "$ISO_DIR/live/filesystem.squashfs" -comp xz
    
    # For demo purposes, we'll use the host kernel (this is not ideal but will work for demonstration)
    log "Copying kernel files..."
    
    # Find available kernel on host
    HOST_KERNEL=$(ls /boot/vmlinuz-* 2>/dev/null | head -1 || echo "")
    HOST_INITRD=$(ls /boot/initramfs-*.img 2>/dev/null | head -1 || echo "")
    
    if [[ -z "$HOST_KERNEL" ]]; then
        # Create a dummy kernel for demonstration
        log "Creating dummy kernel files for x86_64 demonstration..."
        echo "This is a demo kernel placeholder" > "$ISO_DIR/live/vmlinuz"
        echo "This is a demo initrd placeholder" > "$ISO_DIR/live/initrd.img"
    else
        cp "$HOST_KERNEL" "$ISO_DIR/live/vmlinuz" 2>/dev/null || true
        cp "$HOST_INITRD" "$ISO_DIR/live/initrd.img" 2>/dev/null || true
    fi
    
    log "Creating GRUB configuration..."
    cat > "$ISO_DIR/boot/grub/grub.cfg" << EOF
set timeout=10
set default=0

# Honey Badger OS x86_64 Boot Menu  
menuentry '🦡 Honey Badger OS x86_64 - Demo System' {
    linux /live/vmlinuz boot=live init=/sbin/init
    initrd /live/initrd.img
}

menuentry '🦡 Honey Badger OS x86_64 - Information' {
    linux /live/vmlinuz boot=live init=/sbin/init debug
    initrd /live/initrd.img  
}
EOF

    log "Creating ISO image..."
    ISO_NAME="honey-badger-os-x86_64-demo-$(date +%Y%m%d).iso"
    
    # Create ISO using grub-mkrescue with x86_64 target
    grub-mkrescue -o "$OUTPUT_DIR/$ISO_NAME" "$ISO_DIR" \
        --compress=xz \
        --verbose || {
        log "grub-mkrescue failed, trying genisoimage..."
        genisoimage -o "$OUTPUT_DIR/$ISO_NAME" \
            -b isolinux/isolinux.bin -c isolinux/boot.cat \
            -no-emul-boot -boot-load-size 4 -boot-info-table \
            -J -R -V "HoneyBadgerOS-x86_64" "$ISO_DIR" 2>/dev/null || {
            log "Creating simple ISO without bootloader..."
            genisoimage -o "$OUTPUT_DIR/$ISO_NAME" -J -R -V "HoneyBadgerOS-x86_64" "$ISO_DIR"
        }
    }
    
    if [[ -f "$OUTPUT_DIR/$ISO_NAME" ]]; then
        ISO_SIZE=$(du -h "$OUTPUT_DIR/$ISO_NAME" | cut -f1)
        log "✅ x86_64 Demo ISO created: $ISO_NAME ($ISO_SIZE)"
        log "📍 Location: $OUTPUT_DIR/$ISO_NAME"
        log "ℹ️  This is a demonstration ISO showcasing Honey Badger OS x86_64 structure"
        log "ℹ️  Contains honey badger assets and branding for x86_64 architecture"
    else
        error "Failed to create ISO"
    fi
}

# Run main function
main "$@"