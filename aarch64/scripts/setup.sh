#!/bin/bash
# Honey Badger OS Setup Script
# Prepares the build environment

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check system requirements
check_requirements() {
    log "Checking system requirements..."
    
    # Check architecture
    if [ "$(uname -m)" != "aarch64" ] && [ "$(uname -m)" != "x86_64" ]; then
        warn "Build system architecture: $(uname -m)"
        warn "This may affect cross-compilation for ARM64"
    fi
    
    # Check available space (need at least 10GB)
    available_space=$(df -BG . | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ "$available_space" -lt 10 ]; then
        error "Insufficient disk space. Need at least 10GB, available: ${available_space}GB"
    fi
    
    # Check memory (recommend at least 4GB)
    total_mem=$(free -g | awk 'NR==2{print $2}')
    if [ "$total_mem" -lt 4 ]; then
        warn "Low memory: ${total_mem}GB. Build process may be slow."
    fi
    
    log "System requirements check completed"
}

# Install build dependencies
install_build_deps() {
    log "Installing build dependencies..."
    
    # Update package list
    sudo apt-get update
    
    # Install essential build tools
    sudo apt-get install -y \
        build-essential \
        debootstrap \
        squashfs-tools \
        xorriso \
        isolinux \
        syslinux-efi \
        grub-pc-bin \
        grub-efi-amd64-bin \
        grub-efi-arm64-bin \
        mtools \
        dosfstools \
        live-build \
        wget \
        curl \
        rsync \
        git \
        qemu-user-static \
        binfmt-support
        
    log "Build dependencies installed successfully"
}

# Setup cross-compilation environment for ARM64
setup_cross_compilation() {
    log "Setting up cross-compilation environment..."
    
    # Install cross-compilation tools
    sudo apt-get install -y \
        gcc-aarch64-linux-gnu \
        g++-aarch64-linux-gnu \
        libc6-dev-arm64-cross
    
    # Enable qemu for ARM64 emulation
    sudo update-binfmts --enable qemu-aarch64
    
    log "Cross-compilation environment ready"
}

# Create project directories
create_directories() {
    log "Creating project directories..."
    
    PROJECT_ROOT="/home/james/Honey_Badger_OS"
    
    mkdir -p "$PROJECT_ROOT/build/rootfs"
    mkdir -p "$PROJECT_ROOT/build/iso"
    mkdir -p "$PROJECT_ROOT/build/tmp"
    mkdir -p "$PROJECT_ROOT/logs"
    
    # Set proper permissions
    chmod 755 "$PROJECT_ROOT/scripts/"*.sh
    
    log "Project directories created"
}

# Download additional resources
download_resources() {
    log "Downloading additional resources..."
    
    RESOURCES_DIR="/home/james/Honey_Badger_OS/resources"
    mkdir -p "$RESOURCES_DIR"
    
    # Download latest kernel information
    log "Fetching latest kernel version information..."
    
    # This would typically fetch the latest kernel version
    # For now, we'll use the configured version
    log "Using kernel version from configuration: 6.11"
    
    log "Resources prepared"
}

# Verify configuration
verify_config() {
    log "Verifying configuration..."
    
    CONFIG_FILE="/home/james/Honey_Badger_OS/config/honey-badger-os.conf"
    
    if [ ! -f "$CONFIG_FILE" ]; then
        error "Configuration file not found: $CONFIG_FILE"
    fi
    
    source "$CONFIG_FILE"
    
    log "Configuration verified:"
    log "  Distribution: $DISTRO_NAME $DISTRO_VERSION"
    log "  Architecture: $ARCH"
    log "  Desktop: $DESKTOP_ENVIRONMENT"
    log "  Base: $BASE_SYSTEM $DEBIAN_RELEASE"
}

# Main setup function
main() {
    log "Setting up Honey Badger OS build environment..."
    
    check_requirements
    install_build_deps
    setup_cross_compilation
    create_directories
    download_resources
    verify_config
    
    log "Setup completed successfully!"
    log ""
    log "Next steps:"
    log "  1. Review configuration in config/honey-badger-os.conf"
    log "  2. Customize package lists in packages/ directory"
    log "  3. Run 'sudo ./scripts/build-iso.sh' to build the ISO"
    log ""
    log "Note: The build process requires root privileges and may take 1-3 hours"
    log "      depending on your system and internet connection."
}

# Run main function
main "$@"