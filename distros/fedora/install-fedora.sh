#!/bin/bash
# Honey Badger OS - Fedora/RHEL Post-Install Script
# Supports: Fedora, RHEL, CentOS, AlmaLinux, Rocky Linux

set -euo pipefail

# Color definitions
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

readonly LOG_FILE="/tmp/honeybadger-fedora-install.log"

log_info() { echo -e "${CYAN}[INFO]${NC} $1" | tee -a "$LOG_FILE"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1" | tee -a "$LOG_FILE"; }

show_banner() {
    echo -e "${YELLOW}🦡 HONEY BADGER OS - FEDORA/RHEL INSTALLER 🦡${NC}" | tee -a "$LOG_FILE"
}

main() {
    echo "Honey Badger OS - Fedora Installation Log" > "$LOG_FILE"
    show_banner
    
    log_step "Checking system..."
    if ! command -v dnf >/dev/null 2>&1 && ! command -v yum >/dev/null 2>&1; then
        log_error "This script requires dnf or yum package manager"
        exit 1
    fi
    
    local pm="dnf"
    if ! command -v dnf >/dev/null 2>&1; then
        pm="yum"
    fi
    
    log_step "Updating system packages..."
    sudo $pm update -y
    
    log_step "Installing base packages..."
    sudo $pm install -y \
        curl wget git nano htop neofetch tree \
        NetworkManager-wifi firefox \
        python3 python3-pip nodejs npm \
        gcc make cmake
    
    local install_type="${HONEY_BADGER_INSTALL_TYPE:-full}"
    
    if [[ "$install_type" != "minimal" ]]; then
        log_step "Installing XFCE desktop..."
        sudo $pm groupinstall -y "Xfce Desktop"
        sudo systemctl set-default graphical.target
    fi
    
    if [[ "$install_type" == "full" || "$install_type" == "developer" ]]; then
        log_step "Installing development tools..."
        sudo $pm groupinstall -y "Development Tools"
        sudo $pm install -y docker podman golang rust cargo
        sudo systemctl enable --now docker 2>/dev/null || true
    fi
    
    log_step "Setting up nano configuration..."
    mkdir -p ~/.nano/backups
    
    # Find script directory and copy config
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    if [[ -f "$script_dir/config/nanorc" ]]; then
        cp "$script_dir/config/nanorc" ~/.nanorc
    else
        log_warning "nanorc configuration file not found"
    fi
    echo 'export EDITOR=nano' >> ~/.bashrc
    
    log_success "Honey Badger OS installation completed!"
    echo -e "${YELLOW}🦡 Fearless and ready! Reboot to use desktop environment. 🦡${NC}"
}

trap 'echo -e "\n${RED}Installation interrupted${NC}"; exit 1' INT TERM
main "$@"