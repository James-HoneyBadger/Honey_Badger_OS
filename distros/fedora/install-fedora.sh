#!/bin/bash
# Honey Badger OS - Fedora/RHEL Post-Install Script
# Supports: Fedora, RHEL, CentOS, AlmaLinux, Rocky Linux

set -euo pipefail

# Source shared library
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

LOG_FILE="/tmp/honeybadger-fedora-install.log"

# ── Package lists ────────────────────────────────────────────────────────────
declare -a BASE_PACKAGES=(
    "curl" "wget" "git" "git-lfs" "unzip" "zip" "p7zip"
    "htop" "neofetch" "tree" "tmux" "screen"
    "NetworkManager" "NetworkManager-wifi" "wpa_supplicant"
    "openssh-clients" "openssh-server" "rsync" "nmap"
    "gparted" "ntfs-3g" "exfatprogs" "dosfstools"
    "pulseaudio" "pulseaudio-utils" "pavucontrol" "alsa-utils"
    "dejavu-sans-fonts" "liberation-fonts" "google-noto-fonts-common"
    "google-noto-emoji-fonts"
)

declare -a DEVELOPER_PACKAGES=(
    "python3" "python3-pip" "python3-virtualenv"
    "nodejs" "npm"
    "golang" "rust" "cargo"
    "java-latest-openjdk" "java-latest-openjdk-devel"
    "ruby" "rubygems"
    "php" "php-cli"
    "make" "cmake" "ninja-build" "meson"
    "gcc" "gcc-c++" "clang" "gdb" "valgrind"
    "docker" "docker-compose" "podman"
    "postgresql" "mariadb" "sqlite" "redis"
    "neovim" "gh" "git-delta"
    "autoconf" "automake" "libtool" "pkgconf"
)

declare -a DESKTOP_PACKAGES=(
    "xfce4-panel" "xfce4-session" "xfce4-settings" "xfce4-terminal"
    "xfce4-appfinder" "xfce4-power-manager" "xfce4-screenshooter"
    "xfce4-taskmanager" "xfce4-whiskermenu-plugin" "xfce4-clipman-plugin"
    "xfce4-notifyd" "xfce4-pulseaudio-plugin"
    "thunar" "thunar-volman" "thunar-archive-plugin"
    "lightdm" "lightdm-gtk-greeter" "lightdm-gtk-greeter-settings"
    "file-roller" "gvfs" "gvfs-smb" "gvfs-mtp"
    "rofi" "dmenu" "blueman" "network-manager-applet"
    "ImageMagick"
)

declare -a APPLICATIONS_PACKAGES=(
    "firefox" "chromium"
    "libreoffice" "hunspell" "hunspell-en-US"
    "gimp" "inkscape" "vlc" "audacity"
    "ImageMagick" "ffmpeg-free"
    "thunderbird" "telegram-desktop"
    "galculator" "mousepad" "xarchiver"
)

# ── Banner ───────────────────────────────────────────────────────────────────
show_banner() {
    echo -e "${YELLOW}${BOLD}" | tee -a "$LOG_FILE"
    echo "  🦡 ================================================== 🦡" | tee -a "$LOG_FILE"
    echo "     HONEY BADGER OS - FEDORA/RHEL INSTALLER" | tee -a "$LOG_FILE"
    echo "     Fearless Fedora-based Distribution Setup" | tee -a "$LOG_FILE"
    echo "  🦡 ================================================== 🦡" | tee -a "$LOG_FILE"
    echo -e "${NC}" | tee -a "$LOG_FILE"
}

# ── System check ─────────────────────────────────────────────────────────────
check_fedora_system() {
    if ! command -v dnf >/dev/null 2>&1 && ! command -v yum >/dev/null 2>&1; then
        log_error "This script requires dnf or yum package manager"
        exit 1
    fi
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        log_info "Detected: ${PRETTY_NAME:-Fedora}"
    fi
}

# Determine package manager
get_pm() {
    if command -v dnf >/dev/null 2>&1; then
        echo "dnf"
    else
        echo "yum"
    fi
}

# ── System update ────────────────────────────────────────────────────────────
update_system() {
    hb_next_step "Updating system packages..."
    local pm
    pm="$(get_pm)"
    hb_sudo "$pm" update -y
    log_success "System updated successfully"
}

# ── Package installation ────────────────────────────────────────────────────
install_dnf_packages() {
    local -n packages_ref=$1
    local package_type="$2"
    local pm
    pm="$(get_pm)"
    if [[ ${#packages_ref[@]} -eq 0 ]]; then
        log_info "No $package_type packages to install"
        return 0
    fi
    hb_next_step "Installing $package_type packages..."
    local -a available_packages=()
    for package in "${packages_ref[@]}"; do
        if rpm -q "$package" >/dev/null 2>&1; then
            log_info "$package already installed"
        else
            available_packages+=("$package")
        fi
    done
    if [[ ${#available_packages[@]} -gt 0 ]]; then
        if hb_sudo "$pm" install -y "${available_packages[@]}"; then
            for p in "${available_packages[@]}"; do hb_json_add_package "$p"; done
            log_success "Installed $package_type packages"
        else
            log_warning "Some $package_type packages failed to install"
            hb_json_add_error "Some $package_type packages failed"
        fi
    else
        log_info "All $package_type packages already installed"
    fi
}

# ── XFCE service setup (Fedora-specific) ─────────────────────────────────────
setup_xfce_fedora() {
    hb_next_step "Setting up XFCE desktop for Fedora..."
    # Install XFCE group
    local pm
    pm="$(get_pm)"
    hb_sudo "$pm" groupinstall -y "Xfce Desktop" 2>/dev/null || true
    hb_sudo systemctl set-default graphical.target 2>/dev/null || true
    setup_xfce
}

# ── Main installation by type ───────────────────────────────────────────────
install_packages_by_type() {
    local install_type="${HONEY_BADGER_INSTALL_TYPE:-full}"
    log_info "Installation type: $install_type"
    install_dnf_packages BASE_PACKAGES "base"
    case "$install_type" in
        "full")
            install_dnf_packages DEVELOPER_PACKAGES "developer"
            install_dnf_packages DESKTOP_PACKAGES "desktop"
            install_dnf_packages APPLICATIONS_PACKAGES "applications"
            setup_xfce_fedora
            ;;
        "developer")
            install_dnf_packages DEVELOPER_PACKAGES "developer"
            install_dnf_packages DESKTOP_PACKAGES "basic desktop"
            setup_xfce_fedora
            ;;
        "desktop")
            install_dnf_packages DESKTOP_PACKAGES "desktop"
            install_dnf_packages APPLICATIONS_PACKAGES "applications"
            local -a basic_dev=("python3" "python3-pip" "nodejs" "npm" "git")
            install_dnf_packages basic_dev "basic development"
            setup_xfce_fedora
            ;;
        "minimal")
            log_info "Minimal installation - desktop environment skipped"
            ;;
        *)
            log_error "Unknown installation type: $install_type"
            exit 1
            ;;
    esac
}

# ── Development tools (Fedora-specific) ──────────────────────────────────────
setup_dev_fedora() {
    hb_next_step "Installing Fedora development group..."
    local pm
    pm="$(get_pm)"
    hb_sudo "$pm" groupinstall -y "Development Tools" 2>/dev/null || true
    setup_development_environment
}

# ── Main ─────────────────────────────────────────────────────────────────────
main() {
    echo "Honey Badger OS - Fedora Installation Log" > "$LOG_FILE"
    echo "Started: $(date)" >> "$LOG_FILE"
    hb_json_init
    export HONEY_BADGER_DISTRO="fedora"
    local install_type="${HONEY_BADGER_INSTALL_TYPE:-full}"
    local pm
    pm="$(get_pm)"
    case "$install_type" in
        full)    hb_set_total_steps 12 ;;
        developer) hb_set_total_steps 10 ;;
        desktop) hb_set_total_steps 9 ;;
        minimal) hb_set_total_steps 5 ;;
    esac
    show_banner
    check_fedora_system
    update_system
    install_packages_by_type
    setup_nano
    create_utility_scripts \
        "sudo $pm update -y" \
        "sudo $pm install -y" \
        "sudo $pm autoremove -y && sudo $pm clean all"
    if [[ "$install_type" != "minimal" ]]; then
        setup_honey_badger_theme
        install_assets
    fi
    if [[ "$install_type" == "full" || "$install_type" == "developer" ]]; then
        setup_dev_fedora
    fi
    show_post_install
}

trap 'echo -e "\n${RED}Installation interrupted${NC}"; exit 1' INT TERM
main "$@"
