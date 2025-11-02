#!/bin/bash
#
# Honey Badger OS - Universal Post-Install Script
# Fearlessly transform any supported Linux distribution into a development powerhouse
#
# Author: James-HoneyBadger
# Version: 1.0.0
# Repository: https://github.com/James-HoneyBadger/Honey_Badger_OS
#
# Supported Distributions:
# - Arch Linux (and derivatives like Manjaro, EndeavourOS)
# - Debian (and derivatives like Ubuntu, Linux Mint, Pop!_OS)
# - Slackware (and derivatives like Salix)
# - Fedora (and derivatives like RHEL, CentOS, AlmaLinux, Rocky Linux)
# - Void Linux
#

set -euo pipefail

# Color definitions for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# Script information
readonly SCRIPT_NAME="Honey Badger OS - Universal Installer"
readonly VERSION="1.0.0"
readonly REPO_URL="https://github.com/James-HoneyBadger/Honey_Badger_OS"

# Distribution detection results
DISTRO=""
DISTRO_FAMILY=""
DISTRO_VERSION=""
DISTRO_CODENAME=""
SCRIPT_PATH=""

# Installation types
readonly FULL="full"
readonly DEVELOPER="developer"
readonly MINIMAL="minimal"
readonly DESKTOP="desktop"

# Default installation type
INSTALL_TYPE="${FULL}"

# Detect non-interactive execution (no TTY on stdin). If running unattended
# the caller can set HONEY_BADGER_AUTO_CONFIRM=1 to accept prompts automatically.
if [[ ! -t 0 ]]; then
    NONINTERACTIVE=true
else
    NONINTERACTIVE=false
fi

# CLI options (supports long and short forms)
UNATTENDED=false
DRY_RUN=false
TYPE_EXPLICIT=false

show_usage() {
    cat <<EOF
Usage: ${0##*/} [options]

Options:
  -y, --unattended    Run without interactive prompts (equivalent to HONEY_BADGER_AUTO_CONFIRM=1)
    -t, --type <type>   Choose installation type: full | developer | minimal | desktop
  --dry-run           Show what would be done but do not perform actions
  -h, --help          Show this help message

Environment:
  HONEY_BADGER_AUTO_CONFIRM=1  Alternative to --unattended to auto-confirm prompts
    HONEY_BADGER_INSTALL_TYPE=...  Alternative to --type to select install type

Examples:
  ${0##*/} --unattended          # Run unattended (non-interactive)
  HONEY_BADGER_AUTO_CONFIRM=1 ${0##*/} < /dev/null  # Unattended via env var
  ${0##*/} --dry-run             # Show actions without executing
    ${0##*/} --unattended --type minimal  # Unattended minimal install
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -y|--unattended)
            UNATTENDED=true
            shift
            ;;
        -t|--type)
            shift
            if [[ -z "${1:-}" ]]; then
                echo "ERROR: --type requires an argument (full|developer|minimal|desktop)"
                show_usage
                exit 1
            fi
            INSTALL_TYPE="$(echo "$1" | tr '[:upper:]' '[:lower:]')"
            TYPE_EXPLICIT=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        --)
            shift
            break
            ;;
        -*|--*)
            echo "ERROR: Unknown option: $1"
            show_usage
            exit 1
            ;;
        *)
            break
            ;;
    esac
done

# If unattended flag supplied, set the auto-confirm env variable so existing logic works
if [[ "$UNATTENDED" == "true" ]]; then
    export HONEY_BADGER_AUTO_CONFIRM=1
fi

# Logging
readonly LOG_FILE="/tmp/honeybadger-universal-install.log"
exec 1> >(tee -a "${LOG_FILE}")
exec 2> >(tee -a "${LOG_FILE}" >&2)

#######################################
# Print colored output
# Arguments:
#   $1: Color code
#   $2: Message
#######################################
print_colored() {
    echo -e "${1}${2}${NC}"
}

#######################################
# Print status message
# Arguments:
#   $1: Message
#######################################
print_status() {
    print_colored "${BLUE}" "[ INFO ] ${1}"
}

#######################################
# Print success message
# Arguments:
#   $1: Message
#######################################
print_success() {
    print_colored "${GREEN}" "[ SUCCESS ] ${1}"
}

#######################################
# Print warning message
# Arguments:
#   $1: Message
#######################################
print_warning() {
    print_colored "${YELLOW}" "[ WARNING ] ${1}"
}

#######################################
# Print error message and exit
# Arguments:
#   $1: Message
#######################################
print_error() {
    print_colored "${RED}" "[ ERROR ] ${1}"
}

#######################################
# Print honey badger banner
#######################################
print_banner() {
    print_colored "${YELLOW}" "
████████████████████████████████████████████████████████████████████████████
█                                                                          █
█  🦡 HONEY BADGER OS - UNIVERSAL POST-INSTALL SCRIPT 🦡                   █
█                                                                          █
█  Fearless • Determined • Uncompromising                                  █
█  Transform ANY Linux distribution into a development powerhouse          █
█                                                                          █
████████████████████████████████████████████████████████████████████████████
"
    print_colored "${CYAN}" "Version: ${VERSION}"
    print_colored "${CYAN}" "Repository: ${REPO_URL}"
    echo
}

#######################################
# Check if running as root
#######################################
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root"
        print_error "Please run as a regular user with sudo privileges"
        exit 1
    fi
}

#######################################
# Detect the Linux distribution
#######################################
detect_distribution() {
    print_status "Detecting Linux distribution..."
    
    # Check for os-release file (most modern distributions)
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        local distro_id="${ID:-unknown}"
        local distro_id_like="${ID_LIKE:-}"
        local distro_name="${NAME:-unknown}"
        local distro_version="${VERSION_ID:-unknown}"
        local distro_codename="${VERSION_CODENAME:-}"
        
        print_status "Found os-release: $distro_name"
        
        # Determine distribution family and specific distribution
        case "$distro_id" in
            arch|manjaro|endeavouros|arcolinux|artix)
                DISTRO="arch"
                DISTRO_FAMILY="arch"
                SCRIPT_PATH="distros/arch/install-arch.sh"
                ;;
            debian)
                DISTRO="debian" 
                DISTRO_FAMILY="debian"
                SCRIPT_PATH="distros/debian/install-debian.sh"
                ;;
            ubuntu|linuxmint|pop|elementary|zorin|neon)
                DISTRO="ubuntu"
                DISTRO_FAMILY="debian"
                SCRIPT_PATH="distros/debian/install-debian.sh"
                ;;
            slackware|salix)
                DISTRO="slackware"
                DISTRO_FAMILY="slackware"
                SCRIPT_PATH="distros/slackware/install-slackware.sh"
                ;;
            fedora)
                DISTRO="fedora"
                DISTRO_FAMILY="redhat"
                SCRIPT_PATH="distros/fedora/install-fedora.sh"
                ;;
            rhel|centos|almalinux|rocky)
                DISTRO="rhel"
                DISTRO_FAMILY="redhat"
                SCRIPT_PATH="distros/fedora/install-fedora.sh"
                ;;
            void)
                DISTRO="void"
                DISTRO_FAMILY="void"
                SCRIPT_PATH="distros/void/install-void.sh"
                ;;
            *)
                # Check ID_LIKE for compatibility
                case "$distro_id_like" in
                    *arch*)
                        DISTRO="arch-like"
                        DISTRO_FAMILY="arch"
                        SCRIPT_PATH="distros/arch/install-arch.sh"
                        ;;
                    *debian*)
                        DISTRO="debian-like"
                        DISTRO_FAMILY="debian" 
                        SCRIPT_PATH="distros/debian/install-debian.sh"
                        ;;
                    *rhel*|*fedora*)
                        DISTRO="rhel-like"
                        DISTRO_FAMILY="redhat"
                        SCRIPT_PATH="distros/fedora/install-fedora.sh"
                        ;;
                    *)
                        DISTRO="unknown"
                        DISTRO_FAMILY="unknown"
                        ;;
                esac
                ;;
        esac
        
        DISTRO_VERSION="$distro_version"
        DISTRO_CODENAME="$distro_codename"
        
    # Fallback: Check for specific release files
    elif [[ -f /etc/arch-release ]]; then
        DISTRO="arch"
        DISTRO_FAMILY="arch"
        SCRIPT_PATH="distros/arch/install-arch.sh"
    elif [[ -f /etc/debian_version ]]; then
        DISTRO="debian"
        DISTRO_FAMILY="debian"
        SCRIPT_PATH="distros/debian/install-debian.sh"
    elif [[ -f /etc/slackware-version ]]; then
        DISTRO="slackware"
        DISTRO_FAMILY="slackware"
        SCRIPT_PATH="distros/slackware/install-slackware.sh"
    elif [[ -f /etc/fedora-release ]]; then
        DISTRO="fedora"
        DISTRO_FAMILY="redhat"
        SCRIPT_PATH="distros/fedora/install-fedora.sh"
    elif [[ -f /etc/redhat-release ]]; then
        DISTRO="rhel"
        DISTRO_FAMILY="redhat"
        SCRIPT_PATH="distros/fedora/install-fedora.sh"
    elif [[ -f /etc/void-release ]]; then
        DISTRO="void"
        DISTRO_FAMILY="void"
        SCRIPT_PATH="distros/void/install-void.sh"
    else
        DISTRO="unknown"
        DISTRO_FAMILY="unknown"
    fi
    
    # Final check using package managers if distribution is still unknown
    if [[ "$DISTRO" == "unknown" ]]; then
        if command -v pacman &> /dev/null; then
            DISTRO="arch-compatible"
            DISTRO_FAMILY="arch"
            SCRIPT_PATH="distros/arch/install-arch.sh"
        elif command -v apt &> /dev/null; then
            DISTRO="debian-compatible"
            DISTRO_FAMILY="debian"
            SCRIPT_PATH="distros/debian/install-debian.sh"
        elif command -v slackpkg &> /dev/null; then
            DISTRO="slackware-compatible"
            DISTRO_FAMILY="slackware"
            SCRIPT_PATH="distros/slackware/install-slackware.sh"
        elif command -v dnf &> /dev/null || command -v yum &> /dev/null; then
            DISTRO="redhat-compatible"
            DISTRO_FAMILY="redhat"
            SCRIPT_PATH="distros/fedora/install-fedora.sh"
        elif command -v xbps-install &> /dev/null; then
            DISTRO="void-compatible"
            DISTRO_FAMILY="void"
            SCRIPT_PATH="distros/void/install-void.sh"
        fi
    fi
}

#######################################
# Show detected distribution information
#######################################
show_distribution_info() {
    print_colored "${GREEN}" "🐧 DISTRIBUTION DETECTED"
    print_colored "${GREEN}" "========================"
    echo
    print_colored "${CYAN}" "Distribution: ${DISTRO}"
    print_colored "${CYAN}" "Family: ${DISTRO_FAMILY}"
    
    if [[ -n "$DISTRO_VERSION" ]]; then
        print_colored "${CYAN}" "Version: ${DISTRO_VERSION}"
    fi
    
    if [[ -n "$DISTRO_CODENAME" ]]; then
        print_colored "${CYAN}" "Codename: ${DISTRO_CODENAME}"
    fi
    
    print_colored "${CYAN}" "Script: ${SCRIPT_PATH}"
    echo
}

#######################################
# Check if distribution is supported
#######################################
check_supported_distribution() {
    if [[ "$DISTRO" == "unknown" || "$DISTRO_FAMILY" == "unknown" ]]; then
        print_error "Unsupported or undetected Linux distribution!"
        echo
        print_colored "${YELLOW}" "Supported distributions:"
        print_colored "${WHITE}" "• Arch Linux (and derivatives: Manjaro, EndeavourOS, ArcoLinux)"
        print_colored "${WHITE}" "• Debian (and derivatives: Ubuntu, Linux Mint, Pop!_OS, Elementary)"
        print_colored "${WHITE}" "• Slackware (and derivatives: Salix)"
        print_colored "${WHITE}" "• Fedora (and derivatives: RHEL, CentOS, AlmaLinux, Rocky Linux)"
        print_colored "${WHITE}" "• Void Linux"
        echo
        print_colored "${YELLOW}" "If you believe your distribution should be supported, please:"
        print_colored "${WHITE}" "1. Check if it's based on one of the supported families"
        print_colored "${WHITE}" "2. Open an issue at: ${REPO_URL}/issues"
        echo
        print_error "Installation cannot continue."
        exit 1
    fi
}

#######################################
# Check if distribution script exists
#######################################
check_script_availability() {
    local script_dir
    script_dir="$(dirname "${BASH_SOURCE[0]}")"
    local full_script_path="${script_dir}/${SCRIPT_PATH}"
    
    if [[ ! -f "$full_script_path" ]]; then
        print_error "Distribution script not found: $full_script_path"
        print_error "This might be due to:"
        print_colored "${WHITE}" "• Incomplete installation/download of Honey Badger OS"
        print_colored "${WHITE}" "• Missing distribution-specific script"
        print_colored "${WHITE}" "• Corrupted repository"
        echo
        print_colored "${YELLOW}" "Please ensure you have the complete Honey Badger OS repository:"
        print_colored "${WHITE}" "git clone ${REPO_URL}"
        print_colored "${WHITE}" "cd Honey_Badger_OS"
        print_colored "${WHITE}" "./install.sh"
        exit 1
    fi
    
    if [[ ! -x "$full_script_path" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            print_status "[dry-run] Would make distribution script executable: $full_script_path"
        else
            print_status "Making distribution script executable..."
            chmod +x "$full_script_path"
        fi
    fi
}

#######################################
# Installation type selection
#######################################
select_install_type() {
    # If type provided explicitly via CLI or environment, validate and skip menu
    local env_type="${HONEY_BADGER_INSTALL_TYPE:-}"
    if [[ -n "$env_type" && "$TYPE_EXPLICIT" != "true" ]]; then
        INSTALL_TYPE="$(echo "$env_type" | tr '[:upper:]' '[:lower:]')"
        TYPE_EXPLICIT=true
    fi

    case "$INSTALL_TYPE" in
        "$FULL"|"$DEVELOPER"|"$MINIMAL"|"$DESKTOP")
            if [[ "$TYPE_EXPLICIT" == "true" ]]; then
                print_success "Selected (pre-set): $(echo "$INSTALL_TYPE" | tr '[:lower:]' '[:upper:]') installation"
                return
            fi
            ;;
        *)
            # Not a valid pre-set type
            if [[ "$TYPE_EXPLICIT" == "true" ]]; then
                print_error "Invalid installation type: $INSTALL_TYPE"
                print_colored "${WHITE}" "Valid types: full, developer, minimal, desktop"
                exit 1
            fi
            ;;
    esac

    # Non-interactive handling
    if [[ "$NONINTERACTIVE" == "true" ]]; then
        if [[ "${HONEY_BADGER_AUTO_CONFIRM:-0}" == "1" ]]; then
            INSTALL_TYPE="${INSTALL_TYPE:-$FULL}"
            case "$INSTALL_TYPE" in
                "$FULL"|"$DEVELOPER"|"$MINIMAL"|"$DESKTOP") : ;;
                *) INSTALL_TYPE="$FULL" ;;
            esac
            print_status "Non-interactive: selected $(echo "$INSTALL_TYPE" | tr '[:lower:]' '[:upper:]') installation"
            return
        else
            print_error "Non-interactive session without auto-confirm: cannot show selection menu."
            print_colored "${WHITE}" "Set HONEY_BADGER_AUTO_CONFIRM=1 or pass --unattended and optionally --type <full|developer|minimal|desktop>."
            exit 1
        fi
    fi

    # Interactive menu
    print_colored "${YELLOW}" "🛠️  Select Installation Type:"
    echo
    print_colored "${WHITE}" "1) Full Installation (Recommended)"
    print_colored "${CYAN}" "   • Complete XFCE desktop environment with all applications"
    print_colored "${CYAN}" "   • Full development stack (Python, Node.js, Go, Rust, C/C++, Java)"
    print_colored "${CYAN}" "   • Productivity suite (LibreOffice, GIMP, VLC, Firefox)"
    print_colored "${CYAN}" "   • Enhanced nano editor with custom configuration"
    print_colored "${CYAN}" "   • Custom Honey Badger theme and branding"
    print_colored "${CYAN}" "   • Size: ~3-5GB depending on distribution"
    echo
    print_colored "${WHITE}" "2) Developer Focus"
    print_colored "${CYAN}" "   • Programming languages and development tools"
    print_colored "${CYAN}" "   • Basic desktop environment"
    print_colored "${CYAN}" "   • Container tools (Docker/Podman)"
    print_colored "${CYAN}" "   • Code editors and IDEs"
    print_colored "${CYAN}" "   • Enhanced nano configuration"
    print_colored "${CYAN}" "   • Size: ~2-3GB"
    echo
    print_colored "${WHITE}" "3) Minimal Installation"
    print_colored "${CYAN}" "   • Essential command-line tools only"
    print_colored "${CYAN}" "   • Enhanced nano editor"
    print_colored "${CYAN}" "   • Basic development utilities"
    print_colored "${CYAN}" "   • No desktop environment"
    print_colored "${CYAN}" "   • Size: ~500MB-1GB"
    echo
    print_colored "${WHITE}" "4) Desktop Focus"
    print_colored "${CYAN}" "   • Complete XFCE desktop environment"
    print_colored "${CYAN}" "   • Productivity applications"
    print_colored "${CYAN}" "   • Basic development tools"
    print_colored "${CYAN}" "   • Media and office applications"
    print_colored "${CYAN}" "   • Custom theming"
    print_colored "${CYAN}" "   • Size: ~2-3GB"
    echo

    while true; do
        read -p "Enter your choice (1-4): " choice
        case $choice in
            1) INSTALL_TYPE="$FULL"; break ;;
            2) INSTALL_TYPE="$DEVELOPER"; break ;;
            3) INSTALL_TYPE="$MINIMAL"; break ;;
            4) INSTALL_TYPE="$DESKTOP"; break ;;
            *) print_error "Invalid choice. Please enter 1, 2, 3, or 4." ;;
        esac
    done

    print_success "Selected: $(echo "$INSTALL_TYPE" | tr '[:lower:]' '[:upper:]') installation"
}

#######################################
# Show pre-installation summary
#######################################
show_pre_install_summary() {
    print_colored "${YELLOW}" "📋 INSTALLATION SUMMARY"
    print_colored "${YELLOW}" "======================"
    echo
    print_colored "${CYAN}" "Target Distribution: ${DISTRO} (${DISTRO_FAMILY} family)"
    print_colored "${CYAN}" "Installation Type: $(echo "$INSTALL_TYPE" | tr '[:lower:]' '[:upper:]')"
    print_colored "${CYAN}" "Script to Execute: ${SCRIPT_PATH}"
    echo
    
    case "$INSTALL_TYPE" in
        "$FULL")
            print_colored "${WHITE}" "This will install:"
            print_colored "${GREEN}" "✅ Complete XFCE desktop environment"
            print_colored "${GREEN}" "✅ Full development stack"
            print_colored "${GREEN}" "✅ Productivity applications"
            print_colored "${GREEN}" "✅ Enhanced nano editor"
            print_colored "${GREEN}" "✅ Custom Honey Badger theme"
            ;;
        "$DEVELOPER")
            print_colored "${WHITE}" "This will install:"
            print_colored "${GREEN}" "✅ Development tools and languages"
            print_colored "${GREEN}" "✅ Basic desktop environment"
            print_colored "${GREEN}" "✅ Container tools"
            print_colored "${GREEN}" "✅ Enhanced nano editor"
            print_colored "${GREEN}" "✅ Custom theme"
            ;;
        "$MINIMAL")
            print_colored "${WHITE}" "This will install:"
            print_colored "${GREEN}" "✅ Essential command-line tools"
            print_colored "${GREEN}" "✅ Enhanced nano editor"
            print_colored "${GREEN}" "✅ Basic utilities"
            ;;
        "$DESKTOP")
            print_colored "${WHITE}" "This will install:"
            print_colored "${GREEN}" "✅ Complete desktop environment"
            print_colored "${GREEN}" "✅ Productivity applications"
            print_colored "${GREEN}" "✅ Basic development tools"
            print_colored "${GREEN}" "✅ Enhanced nano editor"
            print_colored "${GREEN}" "✅ Custom theme"
            ;;
    esac
    
    echo
    print_colored "${YELLOW}" "⚠️  This will modify your system configuration!"
    print_colored "${YELLOW}" "   Make sure you have a backup if this is a production system."
    echo
}

#######################################
# Execute distribution-specific script
#######################################
execute_distribution_script() {
    local script_dir
    script_dir="$(dirname "${BASH_SOURCE[0]}")"
    local full_script_path="${script_dir}/${SCRIPT_PATH}"
    
    print_status "Executing distribution-specific installer..."
    print_status "Script: $full_script_path"
    print_status "Installation type: $INSTALL_TYPE"
    
    # Export installation type so the distribution script can use it
    export HONEY_BADGER_INSTALL_TYPE="$INSTALL_TYPE"
    
    # Execute the distribution-specific script
    if [[ "$DRY_RUN" == "true" ]]; then
        print_status "[dry-run] Executing distribution script in dry-run mode"
        export HONEY_BADGER_DRY_RUN=1
        if bash "$full_script_path"; then
            print_success "Distribution-specific dry-run completed successfully!"
            return 0
        else
            print_error "Distribution-specific dry-run encountered errors (see log)."
            return 1
        fi
    elif bash "$full_script_path"; then
        print_success "Distribution-specific installation completed successfully!"
        return 0
    else
        print_error "Distribution-specific installation failed!"
        print_error "Check the log file for details: ${LOG_FILE}"
        return 1
    fi
}

#######################################
# Show final installation summary
#######################################
show_final_summary() {
    print_colored "${GREEN}" "
🦡 HONEY BADGER OS UNIVERSAL INSTALLATION COMPLETE! 🦡
===================================================="
    
    echo
    print_colored "${YELLOW}" "Distribution: ${DISTRO} (${DISTRO_FAMILY} family)"
    print_colored "${YELLOW}" "Installation Type: $(echo "$INSTALL_TYPE" | tr '[:lower:]' '[:upper:]')"
    print_colored "${YELLOW}" "Architecture: $(uname -m)"
    
    echo
    print_colored "${YELLOW}" "🔧 Universal Commands (available on all installations):"
    print_colored "${WHITE}" "  honey-badger-info     - Display system information"
    print_colored "${WHITE}" "  honey-badger-update   - Update system and packages"
    print_colored "${WHITE}" "  honey-badger-install  - Install packages"
    
    # Show distribution-specific commands
    case "$DISTRO_FAMILY" in
        "arch")
            print_colored "${WHITE}" "  honey-badger-aur      - Install AUR packages"
            ;;
        "redhat")
            print_colored "${WHITE}" "  honey-badger-rpm      - Manage RPM packages"
            ;;
        "slackware")
            print_colored "${WHITE}" "  honey-badger-slackbuild - Install SlackBuilds"
            ;;
        "void")
            print_colored "${WHITE}" "  honey-badger-service  - Manage runit services"
            ;;
    esac
    
    echo
    print_colored "${YELLOW}" "📝 Default Editor:"
    print_colored "${WHITE}" "  nano is now configured as your default editor"
    print_colored "${WHITE}" "  Enhanced with syntax highlighting and custom key bindings"
    
    if [[ "$INSTALL_TYPE" != "$MINIMAL" ]]; then
        echo
        print_colored "${YELLOW}" "🖥️ Desktop Environment:"
        print_colored "${WHITE}" "  XFCE4 desktop with Honey Badger theme installed"
        print_colored "${WHITE}" "  Reboot to start using your new desktop environment!"
    fi
    
    echo
    print_colored "${YELLOW}" "📋 Installation Log:"
    print_colored "${WHITE}" "  Full installation log: ${LOG_FILE}"
    
    echo
    print_colored "${YELLOW}" "🦡 Welcome to the Honey Badger OS Family!"
    print_colored "${PURPLE}" "Like the honey badger, your system is now fearless and ready for anything!"
    
    # Distribution-specific notes
    case "$DISTRO_FAMILY" in
        "arch")
            echo
            print_colored "${CYAN}" "Arch Linux Notes:"
            print_colored "${WHITE}" "• AUR helper (yay) installed for additional packages"
            print_colored "${WHITE}" "• Use 'honey-badger-aur <package>' for AUR installs"
            ;;
        "debian")
            echo
            print_colored "${CYAN}" "Debian/Ubuntu Notes:"
            print_colored "${WHITE}" "• Additional repositories configured (VS Code, Docker)"
            print_colored "${WHITE}" "• Snap packages available if snapd is installed"
            ;;
        "redhat")
            echo
            print_colored "${CYAN}" "Fedora/RHEL Notes:"
            print_colored "${WHITE}" "• RPM Fusion repositories enabled"
            print_colored "${WHITE}" "• SELinux configured for development work"
            ;;
        "slackware")
            echo
            print_colored "${CYAN}" "Slackware Notes:"
            print_colored "${WHITE}" "• SlackBuilds.org repository configured"
            print_colored "${WHITE}" "• Use 'honey-badger-slackbuild <package>' for SBo packages"
            ;;
        "void")
            echo
            print_colored "${CYAN}" "Void Linux Notes:"
            print_colored "${WHITE}" "• Uses runit instead of systemd"
            print_colored "${WHITE}" "• Podman configured instead of Docker"
            print_colored "${WHITE}" "• Use 'honey-badger-service' to manage services"
            ;;
    esac
    
    echo
}

#######################################
# Check system requirements
#######################################
check_requirements() {
    print_status "Checking system requirements..."
    
    # Check available disk space (rough estimate)
    local available_space
    available_space=$(df / | tail -1 | awk '{print $4}')
    local required_space
    
    case "$INSTALL_TYPE" in
        "$FULL") required_space=5242880 ;; # 5GB in KB
        "$DEVELOPER"|"$DESKTOP") required_space=3145728 ;; # 3GB in KB  
        "$MINIMAL") required_space=1048576 ;; # 1GB in KB
    esac
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_status "[dry-run] Would check disk space: need $(($required_space / 1024 / 1024))GB; available $(($available_space / 1024 / 1024))GB"
    else
    if [[ $available_space -lt $required_space ]]; then
        print_warning "Low disk space detected!"
        print_warning "Available: $(($available_space / 1024 / 1024))GB, Required: $(($required_space / 1024 / 1024))GB"
        if [[ "$NONINTERACTIVE" == "true" ]]; then
            if [[ "${HONEY_BADGER_AUTO_CONFIRM:-0}" == "1" ]]; then
                REPLY="Y"
                print_status "Non-interactive: auto-confirm enabled, continuing despite low disk space."
            else
                print_error "Non-interactive shell detected and no auto-confirm. Aborting."
                print_colored "${WHITE}" "To run unattended set: HONEY_BADGER_AUTO_CONFIRM=1"
                exit 1
            fi
        else
            read -p "Do you want to continue anyway? [y/N]: " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi
    fi
    fi
    
    # Check internet connectivity
    if [[ "$DRY_RUN" == "true" ]]; then
        print_status "[dry-run] Would check internet connectivity (ping 8.8.8.8)"
    elif ! ping -c 1 8.8.8.8 &> /dev/null; then
        print_warning "No internet connectivity detected!"
        print_warning "Internet access is required to download packages."
        if [[ "$NONINTERACTIVE" == "true" ]]; then
            if [[ "${HONEY_BADGER_AUTO_CONFIRM:-0}" == "1" ]]; then
                REPLY="Y"
                print_status "Non-interactive: auto-confirm enabled, continuing despite no internet."
            else
                print_error "Non-interactive shell detected and no auto-confirm. Aborting."
                print_colored "${WHITE}" "To run unattended set: HONEY_BADGER_AUTO_CONFIRM=1"
                exit 1
            fi
        else
            read -p "Do you want to continue anyway? [y/N]: " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi
    fi
    
    print_success "System requirements check completed"
}

#######################################
# Main function
#######################################
main() {
    # Clear screen and show banner
    clear
    print_banner
    
    # Pre-flight checks
    check_root
    
    # Detect distribution
    detect_distribution
    show_distribution_info
    check_supported_distribution
    check_script_availability
    
    # System requirements
    check_requirements
    
    # Installation type selection
    select_install_type
    
    # Show summary and get confirmation
    show_pre_install_summary
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_status "[dry-run] Would prompt to confirm installation; auto-continue in dry-run."
    elif [[ "$NONINTERACTIVE" == "true" ]]; then
        if [[ "${HONEY_BADGER_AUTO_CONFIRM:-0}" == "1" ]]; then
            REPLY="Y"
            print_status "Non-interactive: auto-confirm enabled, proceeding with installation."
        else
            print_error "Non-interactive shell detected. Aborting."
            print_colored "${WHITE}" "To run unattended set: HONEY_BADGER_AUTO_CONFIRM=1"
            exit 1
        fi
    else
        read -p "Do you want to continue with the installation? [y/N]: " -n 1 -r
        echo

        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_colored "${RED}" "Installation cancelled by user."
            exit 0
        fi
    fi
    
    # Execute installation
    print_colored "${GREEN}" "🚀 Starting Honey Badger OS installation..."
    
    if execute_distribution_script; then
        show_final_summary
        
        # Offer reboot for desktop installations
        if [[ "$INSTALL_TYPE" != "$MINIMAL" ]]; then
            echo
            if [[ "$DRY_RUN" == "true" ]]; then
                print_success "[dry-run] Would ask to reboot now — skipping in dry-run."
                print_colored "${YELLOW}" "Please reboot manually to complete the desktop environment setup."
            elif [[ "$NONINTERACTIVE" == "true" ]]; then
                if [[ "${HONEY_BADGER_AUTO_CONFIRM:-0}" == "1" ]]; then
                    print_success "Non-interactive: auto-confirm enabled — reboot suppressed in unattended mode."
                    print_colored "${YELLOW}" "Please reboot manually to complete the desktop environment setup."
                else
                    print_colored "${YELLOW}" "Non-interactive session: skipping reboot prompt. Please reboot manually to complete the desktop environment setup."
                fi
            else
                read -p "Would you like to reboot now to complete the installation? [y/N]: " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    print_success "Rebooting in 5 seconds... 🦡"
                    sleep 5
                    sudo reboot
                else
                    print_colored "${YELLOW}" "Please reboot manually to complete the desktop environment setup."
                fi
            fi
        fi
        
        exit 0
    else
        print_error "Installation failed! Check the log for details: ${LOG_FILE}"
        exit 1
    fi
}

# Run main function with all arguments
main "$@"