#!/bin/bash
# Honey Badger OS Universal Installer
# Detect distribution and run appropriate installation script

set -euo pipefail

# Color definitions for consistent output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[0;37m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# Banner and branding
show_banner() {
    echo -e "${YELLOW}${BOLD}"
    echo "  🦡 ================================================== 🦡"
    echo "     HONEY BADGER OS - UNIVERSAL INSTALLER"
    echo "     Fearless Multi-Distribution Post-Install Scripts"
    echo "  🦡 ================================================== 🦡"
    echo -e "${NC}"
}

# Logging functions
log_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}${BOLD}[STEP]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root!"
        log_info "Please run as a regular user with sudo privileges."
        exit 1
    fi
}

# Check for sudo privileges
check_sudo() {
    if ! sudo -n true 2>/dev/null; then
        log_info "Testing sudo privileges..."
        if ! sudo true; then
            log_error "This script requires sudo privileges."
            log_info "Please ensure your user is in the sudo group."
            exit 1
        fi
    fi
    log_success "Sudo privileges confirmed"
}

# Enhanced distribution detection
detect_distribution() {
    local distro=""
    local version=""
    local id_like=""
    
    # Method 1: /etc/os-release (most reliable)
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        distro="$ID"
        version="$VERSION_ID"
        id_like="${ID_LIKE:-}"
        
        log_info "Detected distribution: $NAME ${VERSION:-}"
        
        # Handle distribution families
        case "$distro" in
            arch|manjaro|endeavouros|arcolinux|artix)
                echo "arch"
                return 0
                ;;
            debian|ubuntu|linuxmint|pop|elementary|zorin|kali)
                echo "debian"
                return 0
                ;;
            fedora|rhel|centos|almalinux|rocky)
                echo "fedora"
                return 0
                ;;
            slackware|salix)
                echo "slackware"
                return 0
                ;;
            void)
                echo "void"
                return 0
                ;;
        esac
        
        # Check ID_LIKE for derivatives
        if [[ -n "$id_like" ]]; then
            case "$id_like" in
                *arch*)
                    echo "arch"
                    return 0
                    ;;
                *debian*|*ubuntu*)
                    echo "debian"
                    return 0
                    ;;
                *rhel*|*fedora*)
                    echo "fedora"
                    return 0
                    ;;
                *suse*)
                    log_error "openSUSE is not currently supported"
                    return 1
                    ;;
            esac
        fi
    fi
    
    # Method 2: Check for package managers
    if command -v pacman >/dev/null 2>&1; then
        echo "arch"
        return 0
    elif command -v apt-get >/dev/null 2>&1; then
        echo "debian"
        return 0
    elif command -v dnf >/dev/null 2>&1; then
        echo "fedora"
        return 0
    elif command -v yum >/dev/null 2>&1; then
        echo "fedora"
        return 0
    elif command -v slackpkg >/dev/null 2>&1; then
        echo "slackware"
        return 0
    elif command -v xbps-install >/dev/null 2>&1; then
        echo "void"
        return 0
    fi
    
    # Method 3: Check specific files
    if [[ -f /etc/arch-release ]]; then
        echo "arch"
        return 0
    elif [[ -f /etc/debian_version ]]; then
        echo "debian"
        return 0
    elif [[ -f /etc/redhat-release ]]; then
        echo "fedora"
        return 0
    elif [[ -f /etc/slackware-version ]]; then
        echo "slackware"
        return 0
    elif [[ -f /etc/void-release ]]; then
        echo "void"
        return 0
    fi
    
    # If we get here, distribution is not supported
    log_error "Unable to detect supported Linux distribution"
    return 1
}

# Check architecture
check_architecture() {
    local arch=$(uname -m)
    case "$arch" in
        x86_64|amd64)
            log_info "Architecture: x86_64 (64-bit Intel/AMD)"
            ;;
        aarch64|arm64)
            log_info "Architecture: aarch64 (64-bit ARM)"
            ;;
        *)
            log_warning "Architecture '$arch' may not be fully supported"
            log_info "Continuing with best-effort installation..."
            ;;
    esac
}

# Show installation types
show_installation_types() {
    echo -e "${BOLD}${MAGENTA}Available Installation Types:${NC}\n"
    
    echo -e "${GREEN}1. Full Installation (Recommended)${NC}"
    echo "   • Complete XFCE desktop environment"
    echo "   • Full development stack (all languages)"
    echo "   • Productivity suite (LibreOffice, GIMP, VLC)"
    echo "   • Enhanced nano editor configuration"
    echo "   • Custom Honey Badger theme"
    echo "   • Size: ~3-5GB"
    echo ""
    
    echo -e "${CYAN}2. Developer Focus${NC}"
    echo "   • Programming languages and development tools"
    echo "   • Basic desktop environment (XFCE core)"
    echo "   • Container tools (Docker/Podman)"
    echo "   • Code editors and IDEs"
    echo "   • Enhanced nano configuration"
    echo "   • Size: ~2-3GB"
    echo ""
    
    echo -e "${BLUE}3. Desktop Focus${NC}"
    echo "   • Complete XFCE desktop environment"
    echo "   • Productivity applications"
    echo "   • Basic development tools"
    echo "   • Enhanced nano editor"
    echo "   • Custom theming"
    echo "   • Size: ~2-3GB"
    echo ""
    
    echo -e "${YELLOW}4. Minimal Installation${NC}"
    echo "   • Essential command-line tools"
    echo "   • Enhanced nano editor"
    echo "   • Basic development utilities"
    echo "   • System monitoring tools"
    echo "   • No desktop environment"
    echo "   • Size: ~500MB-1GB"
    echo ""
}

# Get installation type
get_installation_type() {
    # Check for environment variable first
    if [[ -n "${HONEY_BADGER_INSTALL_TYPE:-}" ]]; then
        case "${HONEY_BADGER_INSTALL_TYPE}" in
            full|developer|desktop|minimal)
                echo "${HONEY_BADGER_INSTALL_TYPE}"
                return 0
                ;;
            *)
                log_warning "Invalid HONEY_BADGER_INSTALL_TYPE: ${HONEY_BADGER_INSTALL_TYPE}"
                log_info "Valid options: full, developer, desktop, minimal"
                ;;
        esac
    fi
    
    show_installation_types
    
    while true; do
        echo -e "${BOLD}Select installation type [1-4]: ${NC}"
        read -r choice
        
        case "$choice" in
            1|full)
                echo "full"
                return 0
                ;;
            2|developer)
                echo "developer"
                return 0
                ;;
            3|desktop)
                echo "desktop"
                return 0
                ;;
            4|minimal)
                echo "minimal"
                return 0
                ;;
            *)
                log_error "Invalid choice. Please enter 1-4."
                ;;
        esac
    done
}

# Pre-flight checks
run_preflight_checks() {
    log_step "Running pre-flight checks..."
    
    # Check internet connectivity
    log_info "Checking internet connectivity..."
    if ! ping -c 1 google.com >/dev/null 2>&1; then
        if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
            log_error "No internet connectivity detected"
            log_info "Please check your network connection and try again"
            exit 1
        fi
    fi
    log_success "Internet connectivity confirmed"
    
    # Check disk space (at least 1GB free)
    log_info "Checking available disk space..."
    local available=$(df / | awk 'NR==2 {print $4}')
    local available_gb=$((available / 1024 / 1024))
    
    if [[ $available_gb -lt 1 ]]; then
        log_error "Insufficient disk space. At least 1GB free space required."
        log_info "Available: ${available_gb}GB"
        exit 1
    fi
    log_success "Disk space check passed (${available_gb}GB available)"
    
    # Check if required directories exist
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [[ ! -d "$script_dir/distros" ]]; then
        log_error "Required 'distros' directory not found"
        log_info "Please ensure you've downloaded the complete Honey Badger OS package"
        exit 1
    fi
    
    log_success "Pre-flight checks completed successfully"
}

# Show installation summary
show_installation_summary() {
    local distro="$1"
    local install_type="$2"
    
    echo -e "\n${BOLD}${MAGENTA}Installation Summary:${NC}"
    echo -e "${CYAN}Distribution:${NC} $(uname -o) (${distro} family)"
    echo -e "${CYAN}Architecture:${NC} $(uname -m)"
    echo -e "${CYAN}Installation Type:${NC} ${install_type}"
    echo -e "${CYAN}User:${NC} $(whoami)"
    echo -e "${CYAN}Home Directory:${NC} $HOME"
    echo ""
    
    # Show what will be installed based on type
    case "$install_type" in
        full)
            echo -e "${GREEN}This will install:${NC}"
            echo "  • Complete XFCE desktop environment"
            echo "  • Full development stack (Python, Node.js, Go, Rust, etc.)"
            echo "  • Productivity suite (LibreOffice, GIMP, VLC, Firefox)"
            echo "  • Enhanced nano editor with syntax highlighting"
            echo "  • Custom Honey Badger theme and branding"
            echo "  • System utilities and monitoring tools"
            ;;
        developer)
            echo -e "${GREEN}This will install:${NC}"
            echo "  • Programming languages and development tools"
            echo "  • Basic XFCE desktop environment"
            echo "  • Container tools (Docker/Podman)"
            echo "  • Code editors (VS Code, Neovim)"
            echo "  • Enhanced nano configuration"
            echo "  • Version control and build tools"
            ;;
        desktop)
            echo -e "${GREEN}This will install:${NC}"
            echo "  • Complete XFCE desktop environment"
            echo "  • Productivity applications (office, media)"
            echo "  • Basic development tools"
            echo "  • Enhanced nano editor"
            echo "  • Custom Honey Badger theme"
            ;;
        minimal)
            echo -e "${GREEN}This will install:${NC}"
            echo "  • Essential command-line tools"
            echo "  • Enhanced nano editor configuration"
            echo "  • Basic development utilities"
            echo "  • System monitoring tools (htop, neofetch)"
            echo "  • No desktop environment"
            ;;
    esac
    echo ""
}

# Confirm installation
confirm_installation() {
    echo -e "${BOLD}${YELLOW}Proceed with installation? [y/N]: ${NC}"
    read -r response
    
    case "$response" in
        [yY]|[yY][eE][sS])
            return 0
            ;;
        *)
            log_info "Installation cancelled by user"
            exit 0
            ;;
    esac
}

# Run the distribution-specific installer
run_installer() {
    local distro="$1"
    local install_type="$2"
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local installer_script="$script_dir/distros/$distro/install-$distro.sh"
    
    if [[ ! -f "$installer_script" ]]; then
        log_error "Installer script not found: $installer_script"
        log_info "Please ensure you have the complete Honey Badger OS package"
        exit 1
    fi
    
    if [[ ! -x "$installer_script" ]]; then
        log_info "Making installer script executable..."
        chmod +x "$installer_script"
    fi
    
    log_step "Starting ${distro} installation (${install_type} type)..."
    
    # Set environment variable for the installer script
    export HONEY_BADGER_INSTALL_TYPE="$install_type"
    
    # Run the installer
    if "$installer_script"; then
        log_success "Installation completed successfully!"
        show_post_install_message "$install_type"
    else
        log_error "Installation failed!"
        log_info "Check the installation logs for details:"
        log_info "  • /tmp/honeybadger-install.log"
        log_info "  • /tmp/honeybadger-${distro}-install.log"
        exit 1
    fi
}

# Show post-installation message
show_post_install_message() {
    local install_type="$1"
    
    echo -e "\n${BOLD}${GREEN}🦡 Honey Badger OS Installation Complete! 🦡${NC}\n"
    
    case "$install_type" in
        full|desktop)
            echo -e "${CYAN}Next steps:${NC}"
            echo "  1. Reboot your system to start the new desktop environment:"
            echo -e "     ${YELLOW}sudo reboot${NC}"
            echo "  2. After reboot, log in to see your new Honey Badger themed desktop"
            echo "  3. Open a terminal and run: ${YELLOW}honey-badger-info${NC}"
            ;;
        developer|minimal)
            echo -e "${CYAN}Next steps:${NC}"
            echo "  1. Restart your terminal or run: ${YELLOW}source ~/.bashrc${NC}"
            echo "  2. Try the enhanced nano editor: ${YELLOW}nano${NC}"
            echo "  3. Check system info: ${YELLOW}honey-badger-info${NC}"
            ;;
    esac
    
    echo ""
    echo -e "${CYAN}Available commands:${NC}"
    echo "  • ${YELLOW}honey-badger-info${NC}    - Display system information"
    echo "  • ${YELLOW}honey-badger-update${NC}  - Update system and packages"
    echo "  • ${YELLOW}honey-badger-install${NC} - Install additional packages"
    
    echo ""
    echo -e "${BOLD}${MAGENTA}Like the honey badger, you're now fearless and ready for anything!${NC}"
    echo -e "${YELLOW}Happy coding! 🦡${NC}"
}

# Create installation log
setup_logging() {
    local log_file="/tmp/honeybadger-universal-install.log"
    exec 1> >(tee -a "$log_file")
    exec 2> >(tee -a "$log_file" >&2)
    log_info "Installation log: $log_file"
}

# Main function
main() {
    # Setup logging
    setup_logging
    
    # Show banner
    show_banner
    
    # Basic checks
    check_root
    check_sudo
    check_architecture
    
    # Run pre-flight checks
    run_preflight_checks
    
    # Detect distribution
    log_step "Detecting Linux distribution..."
    local distro
    if ! distro=$(detect_distribution); then
        log_error "Your Linux distribution is not currently supported."
        echo ""
        log_info "Currently supported distribution families:"
        echo "  • Arch Linux (Arch, Manjaro, EndeavourOS, ArcoLinux, Artix)"
        echo "  • Debian (Debian, Ubuntu, Mint, Pop!_OS, Elementary, Zorin)"
        echo "  • Red Hat (Fedora, RHEL, CentOS, AlmaLinux, Rocky Linux)"
        echo "  • Slackware (Slackware, Salix)"
        echo "  • Void Linux"
        echo ""
        log_info "If you believe your distribution should be supported, please open an issue at:"
        log_info "https://github.com/James-HoneyBadger/Honey_Badger_OS/issues"
        exit 1
    fi
    
    log_success "Detected distribution family: $distro"
    
    # Get installation type
    log_step "Selecting installation type..."
    local install_type
    install_type=$(get_installation_type)
    log_success "Selected installation type: $install_type"
    
    # Show summary and confirm
    show_installation_summary "$distro" "$install_type"
    confirm_installation
    
    # Run the installer
    run_installer "$distro" "$install_type"
}

# Handle interruption gracefully
trap 'echo -e "\n${RED}Installation interrupted by user${NC}"; exit 1' INT TERM

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi