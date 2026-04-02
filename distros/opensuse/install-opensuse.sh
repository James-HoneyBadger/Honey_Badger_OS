#!/bin/bash
# Honey Badger OS - openSUSE Post-Install Script
# Supports: openSUSE Tumbleweed, openSUSE Leap, SLES, GeckoLinux

set -euo pipefail

# Source shared library
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

LOG_FILE="/tmp/honeybadger-opensuse-install.log"

# ── Package lists ────────────────────────────────────────────────────────────
declare -a BASE_PACKAGES=(
    "curl" "wget" "git" "git-lfs" "unzip" "zip" "p7zip"
    "htop" "neofetch" "tree" "tmux" "screen"
    "NetworkManager" "NetworkManager-connection-editor" "wpa_supplicant"
    "openssh" "rsync" "nmap"
    "gparted" "ntfs-3g" "exfatprogs" "dosfstools"
    "pulseaudio" "pulseaudio-utils" "pavucontrol" "alsa-utils"
    "dejavu-fonts" "liberation-fonts" "noto-sans-fonts" "noto-coloremoji-fonts"
    "google-roboto-fonts"
)

declare -a DEVELOPER_PACKAGES=(
    "python3" "python3-pip" "python3-virtualenv"
    "nodejs" "npm"
    "go" "rust" "cargo"
    "java-17-openjdk" "java-17-openjdk-devel"
    "ruby" "rubygem-bundler"
    "php8" "php8-cli"
    "make" "cmake" "ninja" "meson"
    "gcc" "gcc-c++" "clang" "gdb" "valgrind"
    "docker" "docker-compose" "podman"
    "postgresql" "mariadb" "sqlite3" "redis"
    "neovim" "gh" "git-delta"
    "autoconf" "automake" "libtool" "pkgconf"
    "patterns-devel-base-devel_basis"
)

declare -a DESKTOP_PACKAGES=(
    "xfce4-panel" "xfce4-session" "xfce4-settings" "xfce4-terminal"
    "xfce4-appfinder" "xfce4-power-manager" "xfce4-screenshooter"
    "xfce4-taskmanager" "xfce4-whiskermenu-plugin" "xfce4-clipman-plugin"
    "xfce4-notifyd" "xfce4-pulseaudio-plugin"
    "thunar" "thunar-volman" "thunar-plugin-archive"
    "lightdm" "lightdm-gtk-greeter" "lightdm-gtk-greeter-settings"
    "file-roller" "gvfs" "gvfs-backends"
    "rofi" "dmenu" "blueman" "NetworkManager-applet"
    "ImageMagick"
)

declare -a APPLICATIONS_PACKAGES=(
    "MozillaFirefox" "chromium"
    "libreoffice" "myspell-en_US"
    "gimp" "inkscape" "vlc" "audacity"
    "ImageMagick" "ffmpeg"
    "MozillaThunderbird" "telegram-desktop"
    "galculator" "mousepad" "xarchiver"
)

# ── Banner ───────────────────────────────────────────────────────────────────
show_banner() {
    echo -e "${YELLOW}${BOLD}" | tee -a "$LOG_FILE"
    echo "  🦡 ================================================== 🦡" | tee -a "$LOG_FILE"
    echo "     HONEY BADGER OS - OPENSUSE INSTALLER" | tee -a "$LOG_FILE"
    echo "     Fearless openSUSE-based Distribution Setup" | tee -a "$LOG_FILE"
    echo "  🦡 ================================================== 🦡" | tee -a "$LOG_FILE"
    echo -e "${NC}" | tee -a "$LOG_FILE"
}

# ── System check ─────────────────────────────────────────────────────────────
check_opensuse_system() {
    if ! command -v zypper >/dev/null 2>&1; then
        log_error "This script requires the zypper package manager"
        exit 1
    fi
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        log_info "Detected: ${PRETTY_NAME:-openSUSE}"
    fi
}

# ── System update ────────────────────────────────────────────────────────────
update_system() {
    hb_next_step "Refreshing repositories and updating system..."
    hb_sudo zypper --non-interactive refresh
    hb_sudo zypper --non-interactive update
    log_success "System updated successfully"
}

# ── Package installation ────────────────────────────────────────────────────
install_zypper_packages() {
    local -n packages_ref=$1
    local package_type="$2"
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
        if hb_sudo zypper --non-interactive install --no-confirm "${available_packages[@]}"; then
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

# ── XFCE service setup (openSUSE-specific) ───────────────────────────────────
setup_xfce_opensuse() {
    hb_next_step "Setting up XFCE desktop for openSUSE..."
    # Install XFCE pattern
    hb_sudo zypper --non-interactive install -t pattern xfce 2>/dev/null || true
    hb_sudo systemctl set-default graphical.target 2>/dev/null || true
    setup_xfce
}

# ── Packman repository (multimedia codecs) ───────────────────────────────────
setup_packman() {
    hb_next_step "Setting up Packman repository for multimedia codecs..."
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        local repo_url=""
        if [[ "$ID" == "opensuse-tumbleweed" ]] || [[ "${VERSION_ID:-}" == "" ]]; then
            repo_url="https://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/"
        else
            repo_url="https://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Leap_${VERSION_ID}/"
        fi
        if ! zypper repos | grep -qi packman; then
            hb_sudo zypper ar -cfp 90 "$repo_url" packman 2>/dev/null || true
            hb_sudo zypper --non-interactive refresh 2>/dev/null || true
        fi
        log_success "Packman repository configured"
    fi
}

# ── Main installation by type ───────────────────────────────────────────────
install_packages_by_type() {
    local install_type="${HONEY_BADGER_INSTALL_TYPE:-full}"
    log_info "Installation type: $install_type"
    install_zypper_packages BASE_PACKAGES "base"
    case "$install_type" in
        "full")
            install_zypper_packages DEVELOPER_PACKAGES "developer"
            install_zypper_packages DESKTOP_PACKAGES "desktop"
            install_zypper_packages APPLICATIONS_PACKAGES "applications"
            setup_packman
            setup_xfce_opensuse
            ;;
        "developer")
            install_zypper_packages DEVELOPER_PACKAGES "developer"
            install_zypper_packages DESKTOP_PACKAGES "basic desktop"
            setup_xfce_opensuse
            ;;
        "desktop")
            install_zypper_packages DESKTOP_PACKAGES "desktop"
            install_zypper_packages APPLICATIONS_PACKAGES "applications"
            local -a basic_dev=("python3" "python3-pip" "nodejs" "npm" "git")
            install_zypper_packages basic_dev "basic development"
            setup_packman
            setup_xfce_opensuse
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

# ── Development tools (openSUSE-specific) ────────────────────────────────────
setup_dev_opensuse() {
    hb_next_step "Installing openSUSE development pattern..."
    hb_sudo zypper --non-interactive install -t pattern devel_basis 2>/dev/null || true
    setup_development_environment
}

# ── Main ─────────────────────────────────────────────────────────────────────
main() {
    echo "Honey Badger OS - openSUSE Installation Log" > "$LOG_FILE"
    echo "Started: $(date)" >> "$LOG_FILE"
    hb_json_init
    export HONEY_BADGER_DISTRO="opensuse"
    local install_type="${HONEY_BADGER_INSTALL_TYPE:-full}"
    case "$install_type" in
        full)    hb_set_total_steps 13 ;;
        developer) hb_set_total_steps 10 ;;
        desktop) hb_set_total_steps 10 ;;
        minimal) hb_set_total_steps 5 ;;
    esac
    show_banner
    check_opensuse_system
    update_system
    install_packages_by_type
    setup_nano
    create_utility_scripts \
        "sudo zypper --non-interactive update" \
        "sudo zypper --non-interactive install" \
        "sudo zypper --non-interactive clean --all"
    if [[ "$install_type" != "minimal" ]]; then
        setup_honey_badger_theme
        install_assets
    fi
    if [[ "$install_type" == "full" || "$install_type" == "developer" ]]; then
        setup_dev_opensuse
    fi
    show_post_install
}

trap 'echo -e "\n${RED}Installation interrupted${NC}"; exit 1' INT TERM
main "$@"
