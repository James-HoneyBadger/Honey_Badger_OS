#!/bin/bash
# Honey Badger OS - Void Linux Post-Install Script
# Supports: Void Linux (glibc and musl)

set -euo pipefail

# Source shared library
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

hb_init_distro_log "void"

# ── Package lists ────────────────────────────────────────────────────────────
declare -a BASE_PACKAGES=(
    "base-devel" "curl" "wget" "git" "git-lfs" "unzip" "zip" "p7zip"
    "htop" "neofetch" "tree" "tmux" "screen"
    "NetworkManager" "wpa_supplicant"
    "openssh" "rsync" "nmap"
    "gparted" "ntfs-3g" "exfatprogs" "dosfstools"
    "pulseaudio" "pavucontrol" "alsa-utils"
    "dejavu-fonts-ttf" "liberation-fonts-ttf" "noto-fonts-ttf" "noto-fonts-emoji"
)

declare -a DEVELOPER_PACKAGES=(
    "python3" "python3-pip"
    "nodejs" "npm"
    "go" "rust" "cargo"
    "openjdk17" "openjdk17-jre"
    "ruby"
    "make" "cmake" "ninja" "meson"
    "gcc" "clang" "gdb" "valgrind"
    "docker" "docker-compose"
    "postgresql-client" "sqlite" "redis"
    "neovim"
    "autoconf" "automake" "libtool" "pkg-config"
)

declare -a DESKTOP_PACKAGES=(
    "xfce4" "xfce4-plugins" "xfce4-terminal" "xfce4-screenshooter"
    "xfce4-taskmanager" "xfce4-clipman-plugin" "xfce4-pulseaudio-plugin"
    "xfce4-whiskermenu-plugin" "xfce4-notifyd" "xfce4-power-manager"
    "thunar" "thunar-volman" "thunar-archive-plugin"
    "lightdm" "lightdm-gtk3-greeter"
    "file-roller" "gvfs" "gvfs-smb" "gvfs-mtp"
    "rofi" "dmenu" "blueman" "network-manager-applet"
    "ImageMagick"
)

declare -a APPLICATIONS_PACKAGES=(
    "firefox" "chromium"
    "libreoffice" "hunspell" "hunspell-en_US"
    "gimp" "inkscape" "vlc" "audacity"
    "ImageMagick" "ffmpeg"
    "thunderbird" "telegram-desktop"
    "galculator" "mousepad" "xarchiver"
    "gstreamer1" "gst-plugins-base1" "gst-plugins-good1" "gst-plugins-bad1" "gst-plugins-ugly1" "gst-libav"
)

# ── Banner ───────────────────────────────────────────────────────────────────
show_banner() {
    hb_show_banner "Void Linux" "Fearless Void Linux Distribution Setup"
}

# ── System check ─────────────────────────────────────────────────────────────
check_void_system() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        log_info "Detected: ${PRETTY_NAME:-Void Linux}"
    fi
}

# ── System update ────────────────────────────────────────────────────────────
update_system() {
    hb_next_step "Updating system packages..."
    hb_sudo xbps-install -Syu
    log_success "System updated successfully"
}

# ── Package installation ────────────────────────────────────────────────────
install_xbps_packages() {
    local -n packages_ref=$1
    local package_type="$2"
    if [[ ${#packages_ref[@]} -eq 0 ]]; then
        log_info "No $package_type packages to install"
        return 0
    fi
    hb_next_step "Installing $package_type packages..."
    local -a available_packages=()
    for package in "${packages_ref[@]}"; do
        if xbps-query "$package" >/dev/null 2>&1; then
            log_info "$package already installed"
        else
            available_packages+=("$package")
        fi
    done
    if [[ ${#available_packages[@]} -gt 0 ]]; then
        if hb_sudo xbps-install -y "${available_packages[@]}"; then
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

# ── Void-specific service management (runit) ────────────────────────────────
enable_runit_service() {
    local service="$1"
    if [[ -d "/etc/sv/$service" ]]; then
        if [[ ! -L "/var/service/$service" ]]; then
            hb_sudo ln -sf "/etc/sv/$service" /var/service/
            log_success "Enabled runit service: $service"
        else
            log_info "Service $service already enabled"
        fi
    else
        log_warning "Service $service not found in /etc/sv/"
    fi
}

# ── XFCE setup (Void-specific with runit) ───────────────────────────────────
setup_xfce_void() {
    hb_next_step "Setting up XFCE desktop for Void Linux..."
    enable_runit_service "lightdm"
    enable_runit_service "NetworkManager"
    enable_runit_service "dbus"
    setup_xfce
}

# ── Main installation by type ───────────────────────────────────────────────
install_packages_by_type() {
    local install_type="${HONEY_BADGER_INSTALL_TYPE:-full}"
    log_info "Installation type: $install_type"
    install_xbps_packages BASE_PACKAGES "base"
    case "$install_type" in
        "full")
            install_xbps_packages DEVELOPER_PACKAGES "developer"
            install_xbps_packages DESKTOP_PACKAGES "desktop"
            install_xbps_packages APPLICATIONS_PACKAGES "applications"
            setup_xfce_void
            ;;
        "developer")
            install_xbps_packages DEVELOPER_PACKAGES "developer"
            install_xbps_packages DESKTOP_PACKAGES "basic desktop"
            setup_xfce_void
            ;;
        "desktop")
            install_xbps_packages DESKTOP_PACKAGES "desktop"
            install_xbps_packages APPLICATIONS_PACKAGES "applications"
            local -a basic_dev=("python3" "python3-pip" "nodejs" "git")
            install_xbps_packages basic_dev "basic development"
            setup_xfce_void
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

# ── Docker setup (Void-specific with runit) ─────────────────────────────────
setup_docker_void() {
    if command -v docker >/dev/null 2>&1; then
        enable_runit_service "docker"
    fi
    setup_development_environment
}

# ── Main ─────────────────────────────────────────────────────────────────────
main() {
    echo "Honey Badger OS - Void Linux Installation Log" > "$LOG_FILE"
    echo "Started: $(date)" >> "$LOG_FILE"
    hb_json_init
    hb_rollback_init
    export HONEY_BADGER_DISTRO="void"
    local install_type="${HONEY_BADGER_INSTALL_TYPE:-full}"
    case "$install_type" in
        full)    hb_set_total_steps 12 ;;
        developer) hb_set_total_steps 10 ;;
        desktop) hb_set_total_steps 9 ;;
        minimal) hb_set_total_steps 5 ;;
    esac
    show_banner
    check_void_system
    update_system
    install_packages_by_type
    setup_nano
    create_utility_scripts \
        "sudo xbps-install -Syu" \
        "sudo xbps-install -y" \
        "sudo xbps-remove -Oo"
    if [[ "$install_type" != "minimal" ]]; then
        if ! hb_skip_component "theme"; then
            setup_honey_badger_theme
            install_assets
        fi
    fi
    if [[ "$install_type" == "full" || "$install_type" == "developer" ]]; then
        setup_docker_void
    fi
    show_post_install
}

main "$@"
