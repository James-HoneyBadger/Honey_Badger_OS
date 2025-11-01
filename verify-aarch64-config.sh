#!/bin/bash
# Honey Badger OS ARM64 Build Verification
# Verifies that all build components are properly configured

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[✓]${NC} $1"
}

error() {
    echo -e "${RED}[✗]${NC} $1"
    return 1
}

warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

info() {
    echo -e "${BLUE}[i]${NC} $1"
}

echo "==================================================="
echo "  Honey Badger OS ARM64 Build Verification"
echo "==================================================="
echo

# Check build script
if [ -f "aarch64/scripts/build-iso.sh" ] && [ -x "aarch64/scripts/build-iso.sh" ]; then
    log "Main build script exists and is executable"
else
    error "Main build script missing or not executable"
fi

# Check configuration
if [ -f "aarch64/config/honey-badger-os.conf" ]; then
    log "Main configuration file exists"
    
    # Verify key configuration parameters
    source aarch64/config/honey-badger-os.conf
    
    if [ "$ARCH" = "arm64" ]; then
        log "Architecture correctly set to ARM64"
    else
        warn "Architecture not set to ARM64: $ARCH"
    fi
    
    if [ "$DEBIAN_RELEASE" = "bookworm" ]; then
        log "Debian release correctly set to Bookworm (stable)"
    else
        warn "Debian release: $DEBIAN_RELEASE"
    fi
else
    error "Configuration file missing"
fi

# Check package lists
package_lists=(
    "aarch64/packages/base-packages.list"
    "aarch64/packages/xfce-packages.list" 
    "aarch64/packages/applications.list"
    "aarch64/packages/developer-packages.list"
)

for list in "${package_lists[@]}"; do
    if [ -f "$list" ]; then
        count=$(grep -v '^#\|^$' "$list" | wc -l)
        log "Package list $list exists ($count packages)"
    else
        error "Package list missing: $list"
    fi
done

# Check hooks
hook_files=(
    "aarch64/scripts/hooks/01-hardware-support.hook.chroot"
    "aarch64/scripts/hooks/02-system-stability.hook.chroot"
    "aarch64/scripts/hooks/03-live-config.hook.chroot"
    "aarch64/scripts/hooks/04-bootloader-config.hook.chroot"
)

for hook in "${hook_files[@]}"; do
    if [ -f "$hook" ] && [ -x "$hook" ]; then
        log "Hook script exists and is executable: $(basename "$hook")"
    else
        error "Hook script missing or not executable: $hook"
    fi
done

# Check support scripts
if [ -f "aarch64/scripts/configure-editor.sh" ] && [ -x "aarch64/scripts/configure-editor.sh" ]; then
    log "Editor configuration script exists and is executable"
else
    error "Editor configuration script missing or not executable"
fi

# Check Calamares configuration
calamares_configs=(
    "aarch64/calamares/settings.conf"
    "aarch64/calamares/branding.desc"
    "aarch64/calamares/users.conf"
    "aarch64/calamares/displaymanager.conf"
)

for config in "${calamares_configs[@]}"; do
    if [ -f "$config" ]; then
        log "Calamares config exists: $(basename "$config")"
    else
        warn "Calamares config missing: $config"
    fi
done

# Check build wrapper
if [ -f "build-aarch64.sh" ] && [ -x "build-aarch64.sh" ]; then
    log "Build wrapper script exists and is executable"
else
    error "Build wrapper script missing or not executable"
fi

# Check output directory
if [ -d "ISOs" ]; then
    log "ISO output directory exists"
else
    warn "ISO output directory doesn't exist (will be created during build)"
fi

echo
echo "==================================================="
echo "  Configuration Summary"
echo "==================================================="
echo "Distribution: Honey Badger OS 1.0 (fearless)"
echo "Architecture: ARM64/AArch64"
echo "Base System: Debian Bookworm (stable)"
echo "Desktop: XFCE4 with custom theming"
echo "Bootloader: GRUB-EFI for ARM64"
echo "Default Editor: nano (system-wide)"
echo "Live User: honeybadger"
echo "Installer: Calamares"
echo

echo "==================================================="
echo "  Hardware Support Features"
echo "==================================================="
echo "• ARM64 kernel with optimized parameters"
echo "• Comprehensive firmware packages"
echo "• Hardware detection and driver loading"
echo "• System stability configurations"
echo "• Memory management optimization"
echo "• I/O scheduler tuning"
echo "• Power management for laptops"
echo "• USB 3.0/3.1 device support"
echo "• Common WiFi chipset drivers"
echo "• Bluetooth hardware support"
echo "• Audio support (HDMI, USB, analog)"
echo

echo "==================================================="
echo "  Software Packages Included"
echo "==================================================="
echo "Development:"
echo "  • Python 3 with pip and development headers"
echo "  • Node.js and npm"
echo "  • Java 17 JDK"
echo "  • GCC/G++ compiler suite"  
echo "  • Rust and Cargo"
echo "  • Go programming language"
echo "  • Git version control"
echo "  • Docker and container tools"
echo
echo "Applications:"
echo "  • Firefox ESR web browser"
echo "  • Chromium browser"
echo "  • LibreOffice office suite"
echo "  • GIMP image editor"
echo "  • VLC media player"
echo "  • File managers and utilities"
echo
echo "System Tools:"
echo "  • GParted partition editor"
echo "  • System monitoring tools"
echo "  • Network management"
echo "  • Archive management"
echo "  • PDF viewers"
echo

echo "==================================================="
echo "  Next Steps"
echo "==================================================="
echo "To build the ISO, you have two options:"
echo
echo "1. Docker Build (Recommended):"
echo "   • Install Docker Desktop"
echo "   • Run: ./build-aarch64.sh docker"
echo
echo "2. Native Linux Build:"  
echo "   • Use a Debian/Ubuntu Linux system"
echo "   • Install build dependencies"
echo "   • Run: sudo ./build-aarch64.sh native"
echo
echo "For detailed instructions, see: BUILD_AARCH64.md"
echo
echo "Expected build time: 30-60 minutes"
echo "Expected ISO size: 3-4GB"
echo "Output location: ISOs/honey-badger-os-1.0-arm64.iso"
echo "=================================================="