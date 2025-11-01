#!/bin/bash
# Honey Badger OS Clean Script
# Cleans build artifacts and temporary files

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

# Source configuration
PROJECT_ROOT="$(dirname "$(dirname "$(readlink -f "$0")")")"
source "$PROJECT_ROOT/config/honey-badger-os.conf"

# Clean build artifacts
clean_build() {
    log "Cleaning build artifacts..."
    
    # Clean ISO output
    if [ -d "$ISO_OUTPUT_DIR" ]; then
        rm -rf "$ISO_OUTPUT_DIR"/*
        log "Cleaned ISO output directory"
    fi
    
    # Clean temporary build files
    if [ -d "$BUILD_DIR/tmp" ]; then
        rm -rf "$BUILD_DIR/tmp"/*
        log "Cleaned temporary files"
    fi
    
    # Clean live-build artifacts
    if [ -d "$LIVE_BUILD_DIR" ]; then
        cd "$LIVE_BUILD_DIR"
        
        # Remove live-build generated files
        rm -rf .build/
        rm -rf binary/
        rm -rf binary.*/
        rm -rf cache/
        rm -rf chroot/
        rm -rf chroot.*/
        rm -rf config/
        rm -rf local/
        rm -f live-image-*.iso
        rm -f live-image-*.hybrid.iso
        rm -f live-image-*.img
        rm -f *.log
        
        log "Cleaned live-build artifacts"
    fi
}

# Clean downloaded packages cache
clean_cache() {
    log "Cleaning package cache..."
    
    if [ -d "/var/cache/apt/archives" ]; then
        sudo apt-get clean
        log "Cleaned APT cache"
    fi
    
    # Clean any downloaded source packages
    if [ -d "$BUILD_DIR/cache" ]; then
        rm -rf "$BUILD_DIR/cache"/*
        log "Cleaned build cache"
    fi
}

# Reset live-build configuration
reset_config() {
    log "Resetting live-build configuration..."
    
    if [ -d "$LIVE_BUILD_DIR" ]; then
        cd "$LIVE_BUILD_DIR"
        
        # Clean live-build configuration
        if command -v lb >/dev/null 2>&1; then
            lb clean --all 2>/dev/null || true
        fi
        
        log "Reset live-build configuration"
    fi
}

# Show disk space recovered
show_space_recovered() {
    log "Disk space analysis:"
    
    echo "Build directory size:"
    if [ -d "$BUILD_DIR" ]; then
        du -sh "$BUILD_DIR" 2>/dev/null || echo "  0 bytes"
    else
        echo "  Directory does not exist"
    fi
    
    echo ""
    echo "Available disk space:"
    df -h . | tail -n 1
}

# Main clean function
main() {
    case "${1:-all}" in
        "build")
            log "Cleaning build artifacts only..."
            clean_build
            ;;
        "cache")
            log "Cleaning cache only..."
            clean_cache
            ;;
        "config")
            log "Resetting configuration only..."
            reset_config
            ;;
        "all"|"")
            log "Performing full cleanup..."
            clean_build
            clean_cache
            reset_config
            ;;
        "help"|"-h"|"--help")
            echo "Honey Badger OS Clean Script"
            echo "Usage: $0 [option]"
            echo ""
            echo "Options:"
            echo "  build    - Clean build artifacts only"
            echo "  cache    - Clean package cache only"
            echo "  config   - Reset live-build configuration only"
            echo "  all      - Perform full cleanup (default)"
            echo "  help     - Show this help message"
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            echo "Use '$0 help' for usage information"
            exit 1
            ;;
    esac
    
    show_space_recovered
    log "Cleanup completed successfully!"
}

# Run main function
main "$@"