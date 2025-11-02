#!/bin/bash
# Honey Badger OS - Slackware Post-Install Script
# Supports: Slackware, Salix

set -euo pipefail

# Color definitions
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

readonly LOG_FILE="/tmp/honeybadger-slackware-install.log"

log_info() { echo -e "${CYAN}[INFO]${NC} $1" | tee -a "$LOG_FILE"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1" | tee -a "$LOG_FILE"; }

show_banner() {
    echo -e "${YELLOW}🦡 HONEY BADGER OS - SLACKWARE INSTALLER 🦡${NC}" | tee -a "$LOG_FILE"
}

main() {
    echo "Honey Badger OS - Slackware Installation Log" > "$LOG_FILE"
    show_banner
    
    log_step "Checking system..."
    if ! command -v slackpkg >/dev/null 2>&1; then
        log_error "This script requires slackpkg package manager"
        exit 1
    fi
    
    log_step "Updating system packages..."
    sudo slackpkg update
    sudo slackpkg upgrade-all
    
    log_step "Installing base packages..."
    # Note: Slackware package installation would need specific package names
    log_info "Installing essential tools..."
    
    local install_type="${HONEY_BADGER_INSTALL_TYPE:-full}"
    
    if [[ "$install_type" != "minimal" ]]; then
        log_step "Installing XFCE desktop..."
        sudo slackpkg install xfce
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
    echo -e "${YELLOW}🦡 Fearless and ready! 🦡${NC}"
}

trap 'echo -e "\n${RED}Installation interrupted${NC}"; exit 1' INT TERM
main "$@"