#!/bin/bash
# Honey Badger OS ARM64 Build Wrapper
# Provides multiple build options including Docker and native Linux

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

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

show_help() {
    cat << EOF
Honey Badger OS ARM64 Build System

Usage: $0 [OPTIONS] [BUILD_TYPE]

Build Types:
  docker      - Build using Docker container (recommended)
  native      - Build on native Linux system (requires root)
  check       - Check system requirements and dependencies
  clean       - Clean build artifacts

Options:
  -h, --help     Show this help message
  -v, --verbose  Enable verbose output
  -f, --force    Force rebuild (clean first)

Examples:
  $0 docker      # Build using Docker
  $0 native      # Build on Linux (requires sudo)
  $0 check       # Check requirements
  $0 clean       # Clean build artifacts

Requirements:
  - Docker (for docker build)
  - Linux with live-build, debootstrap (for native build)
  - At least 8GB free disk space
  - Internet connection for package downloads

EOF
}

check_requirements() {
    log "Checking system requirements..."
    
    # Check disk space (need at least 8GB)
    available_space=$(df . | awk 'NR==2 {print $4}')
    required_space=8388608  # 8GB in KB
    
    if [ "$available_space" -lt "$required_space" ]; then
        error "Insufficient disk space. Need at least 8GB free."
    fi
    
    # Check if we're on macOS or Linux
    if [[ "$OSTYPE" == "darwin"* ]]; then
        info "Detected macOS - Docker build recommended"
        if ! command -v docker &> /dev/null; then
            warn "Docker not found. Install Docker Desktop for macOS"
            echo "Download from: https://www.docker.com/products/docker-desktop"
            return 1
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        info "Detected Linux - Native build available"
        
        # Check for required packages
        missing_packages=()
        
        for package in debootstrap live-build squashfs-tools xorriso; do
            if ! command -v "$package" &> /dev/null; then
                missing_packages+=("$package")
            fi
        done
        
        if [ ${#missing_packages[@]} -gt 0 ]; then
            warn "Missing packages: ${missing_packages[*]}"
            echo "Install with: sudo apt-get install ${missing_packages[*]}"
            return 1
        fi
    fi
    
    log "System requirements check passed"
    return 0
}

build_with_docker() {
    log "Building Honey Badger OS ARM64 using Docker..."
    
    if ! command -v docker &> /dev/null; then
        error "Docker not found. Please install Docker first."
    fi
    
    # Create Dockerfile for the build environment
    cat > Dockerfile << 'EOF'
FROM debian:bookworm

# Install build dependencies
RUN apt-get update && \
    apt-get install -y \
    debootstrap \
    squashfs-tools \
    xorriso \
    isolinux \
    syslinux-efi \
    grub-efi-arm64 \
    grub-efi-arm64-bin \
    grub-efi-arm64-signed \
    mtools \
    dosfstools \
    live-build \
    calamares \
    calamares-settings-debian \
    wget \
    curl \
    rsync \
    qemu-user-static \
    binfmt-support \
    fdisk \
    parted \
    util-linux \
    systemd-container \
    sudo && \
    apt-get clean

# Enable qemu-user-static
RUN systemctl enable binfmt-support || true

# Create build user
RUN useradd -m -s /bin/bash builder && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/builder

WORKDIR /build
USER root

# Set entrypoint
ENTRYPOINT ["/build/aarch64/scripts/build-iso.sh"]
EOF

    # Build Docker image
    log "Building Docker image..."
    docker build -t honey-badger-build .
    
    # Run the build
    log "Starting ISO build in container..."
    docker run --rm --privileged \
        -v "$(pwd):/build" \
        -v "/dev:/dev" \
        honey-badger-build
    
    # Clean up
    rm -f Dockerfile
    
    log "Docker build completed"
}

build_native() {
    log "Building Honey Badger OS ARM64 natively..."
    
    if [[ "$OSTYPE" != "linux-gnu"* ]]; then
        error "Native build only supported on Linux"
    fi
    
    if [[ $EUID -ne 0 ]]; then
        error "Native build must be run as root. Use: sudo $0 native"
    fi
    
    # Run the build script directly
    ./aarch64/scripts/build-iso.sh
}

build_minimal() {
    log "Building minimal Honey Badger OS ARM64 using Docker..."
    
    if ! command -v docker &> /dev/null; then
        error "Docker not found. Please install Docker first."
    fi
    
    # Create minimal Dockerfile
    cat > Dockerfile.minimal << 'EOF'
FROM debian:bookworm

# Install minimal build dependencies
RUN apt-get update && \
    apt-get install -y \
    debootstrap \
    squashfs-tools \
    xorriso \
    grub-efi-arm64 \
    grub-efi-arm64-bin \
    mtools \
    dosfstools \
    live-build \
    wget \
    curl \
    sudo && \
    apt-get clean

# Create build user
RUN useradd -m -s /bin/bash builder && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/builder

WORKDIR /build
USER root

# Set entrypoint
ENTRYPOINT ["/build/aarch64/scripts/build-minimal-iso.sh"]
EOF

    # Build minimal Docker image
    log "Building minimal Docker image..."
    docker build -f Dockerfile.minimal -t honey-badger-minimal .
    
    # Run the build with limited resources
    log "Starting minimal ISO build in container..."
    docker run --rm --privileged \
        -v "$(pwd):/build" \
        -e "BUILD_MINIMAL=1" \
        honey-badger-minimal
    
    # Clean up
    rm -f Dockerfile.minimal
    docker rmi honey-badger-minimal 2>/dev/null || true
    
    log "Minimal build completed"
}

clean_build() {
    log "Cleaning build artifacts..."
    
    # Remove build directories
    rm -rf /tmp/honey-badger-build
    rm -rf ./live-build
    rm -rf ./.build
    rm -rf ./cache
    rm -rf ./chroot*
    rm -rf ./binary*
    
    # Clean Docker images if they exist
    if command -v docker &> /dev/null; then
        docker rmi honey-badger-build 2>/dev/null || true
    fi
    
    log "Build artifacts cleaned"
}

# Main execution
case "${1:-}" in
    docker)
        check_requirements || exit 1
        build_with_docker
        ;;
    native)
        check_requirements || exit 1
        build_native
        ;;
    minimal)
        log "Building minimal ISO with reduced space requirements..."
        build_minimal
        ;;
    check)
        check_requirements
        ;;
    clean)
        clean_build
        ;;
    -h|--help|help)
        show_help
        ;;
    *)
        echo "Usage: $0 [docker|native|minimal|check|clean|help]"
        echo "Run '$0 help' for detailed information"
        exit 1
        ;;
esac