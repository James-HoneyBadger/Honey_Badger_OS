#!/bin/bash
# Honey Badger OS - Arch Linux Post-Install Script
# Supports: Arch Linux, Manjaro, EndeavourOS, ArcoLinux, Artix

set -euo pipefail

# Source shared library
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

LOG_FILE="/tmp/honeybadger-arch-install.log"

# ── Package lists ────────────────────────────────────────────────────────────
declare -a BASE_PACKAGES=(
    "base-devel" "curl" "wget" "git" "git-lfs" "unzip" "zip" "p7zip"
    "htop" "neofetch" "tree" "tmux" "screen"
    "networkmanager" "network-manager-applet" "wireless_tools" "wpa_supplicant"
    "openssh" "rsync" "nmap" "wireshark-qt"
    "gparted" "ntfs-3g" "exfat-utils" "dosfstools"
    "pulseaudio" "pulseaudio-alsa" "pavucontrol" "alsa-utils"
    "ttf-dejavu" "ttf-liberation" "noto-fonts" "noto-fonts-emoji"
    "ttf-roboto" "ttf-opensans"
)

declare -a DEVELOPER_PACKAGES=(
    "python" "python-pip" "python-virtualenv" "python-poetry"
    "nodejs" "npm" "yarn"
    "go" "rust" "cargo"
    "jdk-openjdk" "openjdk-doc"
    "ruby" "rubygems"
    "php" "composer"
    "make" "cmake" "ninja" "meson"
    "gcc" "clang" "gdb" "valgrind"
    "docker" "docker-compose"
    "postgresql" "mariadb" "sqlite" "redis"
    "neovim" "code"
    "github-cli" "git-delta"
)

declare -a DESKTOP_PACKAGES=(
    "xfce4" "xfce4-goodies" "lightdm" "lightdm-gtk-greeter"
    "lightdm-gtk-greeter-settings"
    "thunar" "thunar-volman" "thunar-archive-plugin" "thunar-media-tags-plugin"
    "file-roller" "gvfs" "gvfs-smb" "gvfs-mtp"
    "xfce4-taskmanager" "xfce4-systemload-plugin" "xfce4-cpugraph-plugin"
    "xfce4-netload-plugin" "xfce4-diskperf-plugin"
    "rofi" "dmenu"
    "xfce4-notifyd" "network-manager-applet" "blueman"
    "imagemagick"
)

declare -a APPLICATIONS_PACKAGES=(
    "firefox" "chromium"
    "libreoffice-fresh" "hunspell" "hunspell-en_us"
    "gimp" "inkscape" "vlc" "audacity" "obs-studio"
    "imagemagick" "ffmpeg"
    "thunderbird" "telegram-desktop" "discord"
    "galculator" "xarchiver" "mousepad"
    "xfce4-screenshooter"
)

declare -a AUR_PACKAGES=(
    "visual-studio-code-bin"
    "postman-bin"
    "slack-desktop"
    "google-chrome"
)

# ── Banner ───────────────────────────────────────────────────────────────────
show_banner() {
    echo -e "${YELLOW}${BOLD}" | tee -a "$LOG_FILE"
    echo "  🦡 ================================================== 🦡" | tee -a "$LOG_FILE"
    echo "     HONEY BADGER OS - ARCH LINUX INSTALLER" | tee -a "$LOG_FILE"
    echo "     Fearless Arch-based Distribution Setup" | tee -a "$LOG_FILE"
    echo "  🦡 ================================================== 🦡" | tee -a "$LOG_FILE"
    echo -e "${NC}" | tee -a "$LOG_FILE"
}

# ── System check ─────────────────────────────────────────────────────────────
check_arch_system() {
    if ! command -v pacman >/dev/null 2>&1; then
        log_error "This script is for Arch-based systems only!"
        exit 1
    fi
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        log_info "Detected: ${PRETTY_NAME:-Arch Linux}"
    fi
}

# ── System update ────────────────────────────────────────────────────────────
update_system() {
    hb_next_step "Updating system packages..."
    hb_sudo pacman -Sy --noconfirm
    hb_sudo pacman -Su --noconfirm
    log_success "System updated successfully"
}

# ── AUR helper ───────────────────────────────────────────────────────────────
install_yay() {
    if command -v yay >/dev/null 2>&1; then
        log_info "yay AUR helper already installed"
        return 0
    fi
    hb_next_step "Installing yay AUR helper..."
    hb_sudo pacman -S --noconfirm --needed base-devel git
    local temp_dir
    temp_dir="$(mktemp -d)"
    hb_register_temp "$temp_dir"
    git clone https://aur.archlinux.org/yay.git "$temp_dir"
    (cd "$temp_dir" && makepkg -si --noconfirm)
    rm -rf "$temp_dir"
    log_success "yay AUR helper installed"
}

# ── Package installation ────────────────────────────────────────────────────
install_pacman_packages() {
    local -n packages_ref=$1
    local package_type="$2"
    if [[ ${#packages_ref[@]} -eq 0 ]]; then
        log_info "No $package_type packages to install"
        return 0
    fi
    hb_next_step "Installing $package_type packages..."
    local -a available_packages=()
    for package in "${packages_ref[@]}"; do
        if pacman -Qi "$package" >/dev/null 2>&1; then
            log_info "$package already installed"
        elif pacman -Si "$package" >/dev/null 2>&1; then
            available_packages+=("$package")
        else
            log_warning "$package not available in repositories"
        fi
    done
    if [[ ${#available_packages[@]} -gt 0 ]]; then
        if hb_sudo pacman -S --noconfirm --needed "${available_packages[@]}"; then
            for p in "${available_packages[@]}"; do hb_json_add_package "$p"; done
            log_success "Installed $package_type packages"
        else
            log_warning "Some $package_type packages failed to install"
            hb_json_add_error "Some $package_type packages failed"
        fi
    else
        log_info "All $package_type packages already installed or unavailable"
    fi
}

install_aur_packages() {
    local -n packages_ref=$1
    local package_type="$2"
    if ! command -v yay >/dev/null 2>&1; then
        log_warning "yay not available, skipping AUR packages"
        return 0
    fi
    if [[ ${#packages_ref[@]} -eq 0 ]]; then return 0; fi
    hb_next_step "Installing $package_type AUR packages..."
    for package in "${packages_ref[@]}"; do
        if pacman -Qi "$package" >/dev/null 2>&1; then
            log_info "$package already installed"
        elif yay -S --noconfirm --needed "$package" 2>/dev/null; then
            hb_json_add_package "$package"
            log_success "Installed $package from AUR"
        else
            log_warning "Failed to install $package from AUR"
        fi
    done
}

# ── Main installation by type ───────────────────────────────────────────────
install_packages_by_type() {
    local install_type="${HONEY_BADGER_INSTALL_TYPE:-full}"
    log_info "Installation type: $install_type"
    install_pacman_packages BASE_PACKAGES "base"
    case "$install_type" in
        "full")
            install_pacman_packages DEVELOPER_PACKAGES "developer"
            install_pacman_packages DESKTOP_PACKAGES "desktop"
            install_pacman_packages APPLICATIONS_PACKAGES "applications"
            install_yay
            install_aur_packages AUR_PACKAGES "AUR"
            setup_xfce
            ;;
        "developer")
            install_pacman_packages DEVELOPER_PACKAGES "developer"
            install_pacman_packages DESKTOP_PACKAGES "basic desktop"
            install_yay
            local -a dev_aur=("visual-studio-code-bin" "postman-bin")
            install_aur_packages dev_aur "development AUR"
            setup_xfce
            ;;
        "desktop")
            install_pacman_packages DESKTOP_PACKAGES "desktop"
            install_pacman_packages APPLICATIONS_PACKAGES "applications"
            local -a basic_dev=("python" "python-pip" "nodejs" "npm" "git")
            install_pacman_packages basic_dev "basic development"
            setup_xfce
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

# ── Main ─────────────────────────────────────────────────────────────────────
main() {
    echo "Honey Badger OS - Arch Linux Installation Log" > "$LOG_FILE"
    echo "Started: $(date)" >> "$LOG_FILE"
    hb_json_init
    export HONEY_BADGER_DISTRO="arch"
    local install_type="${HONEY_BADGER_INSTALL_TYPE:-full}"
    case "$install_type" in
        full)    hb_set_total_steps 12 ;;
        developer) hb_set_total_steps 10 ;;
        desktop) hb_set_total_steps 9 ;;
        minimal) hb_set_total_steps 5 ;;
    esac
    show_banner
    check_arch_system
    update_system
    install_packages_by_type
    setup_nano
    create_utility_scripts \
        "sudo pacman -Syu --noconfirm" \
        "sudo pacman -S --noconfirm" \
        "sudo pacman -Sc --noconfirm"
    if [[ "$install_type" != "minimal" ]]; then
        setup_honey_badger_theme
        install_assets
    fi
    if [[ "$install_type" == "full" || "$install_type" == "developer" ]]; then
        setup_development_environment
    fi
    show_post_install
}

trap 'echo -e "\n${RED}Installation interrupted${NC}"; exit 1' INT TERM
main "$@"
