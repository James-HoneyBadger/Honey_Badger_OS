#!/bin/bash
# Honey Badger OS - Debian/Ubuntu Post-Install Script
# Supports: Debian, Ubuntu, Linux Mint, Pop!_OS, Elementary, Zorin

set -euo pipefail

# Source shared library
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

hb_init_distro_log "debian"

# ── Package lists ────────────────────────────────────────────────────────────
declare -a BASE_PACKAGES=(
    "build-essential" "curl" "wget" "git" "git-lfs" "unzip" "zip" "p7zip-full"
    "htop" "neofetch" "tree" "tmux" "screen" "software-properties-common"
    "network-manager" "network-manager-gnome" "wireless-tools" "wpasupplicant"
    "openssh-client" "openssh-server" "rsync" "nmap" "wireshark"
    "gparted" "ntfs-3g" "exfat-fuse" "dosfstools"
    "pulseaudio" "pulseaudio-utils" "pavucontrol" "alsa-utils"
    "fonts-dejavu" "fonts-liberation" "fonts-noto" "fonts-noto-color-emoji"
    "fonts-roboto" "fonts-opensans"
    "rar" "unrar" "cabextract" "lzip" "lunzip"
    "apt-transport-https" "ca-certificates" "gnupg" "lsb-release"
)

declare -a DEVELOPER_PACKAGES=(
    "python3" "python3-pip" "python3-venv" "python3-dev"
    "nodejs" "npm"
    "golang-go"
    "rustc" "cargo"
    "default-jdk" "default-jre"
    "ruby" "ruby-dev" "rubygems"
    "php" "composer"
    "make" "cmake" "ninja-build" "meson"
    "gcc" "g++" "clang" "gdb" "valgrind"
    "docker.io" "docker-compose"
    "postgresql-client" "mysql-client" "sqlite3" "redis-tools"
    "gh" "git-delta"
    "autoconf" "automake" "libtool" "pkg-config"
)

declare -a DESKTOP_PACKAGES=(
    "xfce4" "xfce4-goodies" "lightdm" "lightdm-gtk-greeter"
    "lightdm-gtk-greeter-settings"
    "thunar" "thunar-volman" "thunar-archive-plugin" "thunar-media-tags-plugin"
    "file-roller" "gvfs" "gvfs-backends" "gvfs-fuse"
    "xfce4-taskmanager" "xfce4-systemload-plugin" "xfce4-cpugraph-plugin"
    "xfce4-netload-plugin" "xfce4-diskperf-plugin" "xfce4-sensors-plugin"
    "rofi" "dmenu" "xfce4-notifyd" "network-manager-gnome" "blueman"
    "xfce4-screenshooter" "xfce4-power-manager" "xfce4-clipman-plugin"
    "imagemagick"
)

declare -a APPLICATIONS_PACKAGES=(
    "firefox" "chromium"
    "libreoffice" "hunspell-en-us"
    "gimp" "inkscape" "vlc" "audacity" "obs-studio"
    "imagemagick" "ffmpeg"
    "thunderbird" "telegram-desktop"
    "galculator" "mousepad" "xarchiver"
    "synaptic" "gdebi"
    "gstreamer1.0-plugins-base" "gstreamer1.0-plugins-good" "gstreamer1.0-plugins-bad" "gstreamer1.0-plugins-ugly" "gstreamer1.0-libav"
)

declare -a SNAP_PACKAGES=(
    "code --classic"
    "postman"
    "discord"
    "slack --classic"
)

declare -a FLATPAK_PACKAGES=(
    "com.github.tchx84.Flatseal"
    "org.gnome.Calculator"
)

# ── Banner ───────────────────────────────────────────────────────────────────
show_banner() {
    hb_show_banner "Debian/Ubuntu" "Fearless Debian-based Distribution Setup"
}

# ── System check ─────────────────────────────────────────────────────────────
check_debian_system() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        log_info "Detected: ${PRETTY_NAME:-Debian}"
    fi
}

# ── System update ────────────────────────────────────────────────────────────
update_system() {
    hb_next_step "Updating system packages..."
    hb_sudo apt update
    hb_sudo apt upgrade -y
    hb_sudo apt install -y software-properties-common apt-transport-https ca-certificates gnupg lsb-release
    log_success "System updated successfully"
}

# ── Repository setup (secured) ──────────────────────────────────────────────
add_repositories() {
    hb_next_step "Adding additional repositories..."

    # Add universe repository for Ubuntu
    if command -v add-apt-repository >/dev/null 2>&1; then
        if lsb_release -i 2>/dev/null | grep -q Ubuntu; then
            hb_sudo add-apt-repository universe -y
            log_info "Added Ubuntu universe repository"
        fi
    fi

    # Node.js: download setup script to temp file first (no pipe to bash)
    if ! command -v nodejs >/dev/null 2>&1 || [[ $(nodejs --version 2>/dev/null | cut -d'v' -f2 | cut -d'.' -f1) -lt 16 ]]; then
        log_info "Adding Node.js repository..."
        local node_setup
        node_setup="$(mktemp)"
        hb_register_temp "$node_setup"
        if curl -fsSL https://deb.nodesource.com/setup_lts.x -o "$node_setup"; then
            hb_sudo bash "$node_setup"
            rm -f "$node_setup"
            log_success "Node.js repository added"
        else
            rm -f "$node_setup"
            log_warning "Failed to download Node.js setup script"
            hb_json_add_error "Node.js repository setup failed"
        fi
    fi

    # Docker repository - detect correct distro (not hardcoded to ubuntu)
    log_info "Adding Docker repository..."
    local distro_id
    distro_id="$(lsb_release -is 2>/dev/null | tr '[:upper:]' '[:lower:]')"
    # Map derivatives to their upstream for Docker repos
    case "$distro_id" in
        linuxmint|pop|elementary|zorin|kali) distro_id="ubuntu" ;;
        "") distro_id="debian" ;;
    esac
    local docker_codename
    docker_codename="$(lsb_release -cs 2>/dev/null)"
    curl -fsSL "https://download.docker.com/linux/${distro_id}/gpg" | hb_sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg 2>/dev/null || {
        log_warning "Failed to download Docker GPG key for ${distro_id}"
        hb_json_add_error "Docker GPG key download failed"
    }
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/${distro_id} ${docker_codename} stable" | hb_sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # GitHub CLI repository
    log_info "Adding GitHub CLI repository..."
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | hb_sudo tee /usr/share/keyrings/githubcli-archive-keyring.gpg > /dev/null 2>&1 || {
        log_warning "Failed to download GitHub CLI GPG key"
        hb_json_add_error "GitHub CLI GPG key download failed"
    }
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | hb_sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

    # VS Code repository (if not using Snap)
    if ! snap list code >/dev/null 2>&1; then
        log_info "Adding VS Code repository..."
        local gpg_tmp
        gpg_tmp="$(mktemp)"
        hb_register_temp "$gpg_tmp"
        if wget -qO "$gpg_tmp" https://packages.microsoft.com/keys/microsoft.asc; then
            gpg --batch --yes --dearmor < "$gpg_tmp" | hb_sudo tee /etc/apt/trusted.gpg.d/packages.microsoft.gpg > /dev/null
            hb_sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
        fi
        rm -f "$gpg_tmp"
    fi

    hb_sudo apt update
    log_success "Additional repositories added"
}

# ── Package installation ────────────────────────────────────────────────────
install_apt_packages() {
    local -n packages_ref=$1
    local package_type="$2"
    if [[ ${#packages_ref[@]} -eq 0 ]]; then
        log_info "No $package_type packages to install"
        return 0
    fi
    hb_next_step "Installing $package_type packages..."
    local -a available_packages=()
    for package in "${packages_ref[@]}"; do
        if dpkg -l "$package" 2>/dev/null | grep -q "^ii"; then
            log_info "$package already installed"
        elif apt-cache show "$package" >/dev/null 2>&1; then
            available_packages+=("$package")
        else
            log_warning "$package not available in repositories"
        fi
    done
    if [[ ${#available_packages[@]} -gt 0 ]]; then
        if hb_sudo apt install -y "${available_packages[@]}"; then
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

install_snap_packages() {
    local -n packages_ref=$1
    local package_type="$2"
    if ! command -v snap >/dev/null 2>&1; then
        log_info "Installing snapd..."
        hb_sudo apt install -y snapd
        hb_sudo systemctl enable --now snapd.socket 2>/dev/null || true
    fi
    if [[ ${#packages_ref[@]} -eq 0 ]]; then return 0; fi
    hb_next_step "Installing $package_type Snap packages..."
    for entry in "${packages_ref[@]}"; do
        local package_name flags
        package_name="$(echo "$entry" | awk '{print $1}')"
        flags="$(echo "$entry" | awk '{$1=""; print}' | xargs)"
        if snap list "$package_name" >/dev/null 2>&1; then
            log_info "$package_name already installed"
        else
            if [[ -n "$flags" ]]; then
                hb_sudo snap install "$package_name" $flags 2>/dev/null && \
                    hb_json_add_package "snap:$package_name" || \
                    log_warning "Failed to install snap $package_name"
            else
                hb_sudo snap install "$package_name" 2>/dev/null && \
                    hb_json_add_package "snap:$package_name" || \
                    log_warning "Failed to install snap $package_name"
            fi
        fi
    done
}

install_flatpak_packages() {
    local -n packages_ref=$1
    local package_type="$2"
    if ! command -v flatpak >/dev/null 2>&1; then
        log_info "Installing Flatpak..."
        hb_sudo apt install -y flatpak
        hb_sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    fi
    if [[ ${#packages_ref[@]} -eq 0 ]]; then return 0; fi
    hb_next_step "Installing $package_type Flatpak packages..."
    for package in "${packages_ref[@]}"; do
        if flatpak list 2>/dev/null | grep -q "$package"; then
            log_info "$package already installed"
        else
            hb_sudo flatpak install -y flathub "$package" 2>/dev/null && \
                hb_json_add_package "flatpak:$package" || \
                log_warning "Failed to install $package"
        fi
    done
}

# ── Main installation by type ───────────────────────────────────────────────
install_packages_by_type() {
    local install_type="${HONEY_BADGER_INSTALL_TYPE:-full}"
    log_info "Installation type: $install_type"
    add_repositories
    install_apt_packages BASE_PACKAGES "base"
    case "$install_type" in
        "full")
            install_apt_packages DEVELOPER_PACKAGES "developer"
            install_apt_packages DESKTOP_PACKAGES "desktop"
            install_apt_packages APPLICATIONS_PACKAGES "applications"
            install_snap_packages SNAP_PACKAGES "Snap"
            install_flatpak_packages FLATPAK_PACKAGES "Flatpak"
            setup_xfce
            ;;
        "developer")
            install_apt_packages DEVELOPER_PACKAGES "developer"
            install_apt_packages DESKTOP_PACKAGES "basic desktop"
            local -a dev_snaps=("code --classic" "postman")
            install_snap_packages dev_snaps "development Snap"
            setup_xfce
            ;;
        "desktop")
            install_apt_packages DESKTOP_PACKAGES "desktop"
            install_apt_packages APPLICATIONS_PACKAGES "applications"
            local -a basic_dev=("python3" "python3-pip" "nodejs" "npm" "git")
            install_apt_packages basic_dev "basic development"
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
    echo "Honey Badger OS - Debian/Ubuntu Installation Log" > "$LOG_FILE"
    echo "Started: $(date)" >> "$LOG_FILE"
    hb_json_init
    hb_rollback_init
    export HONEY_BADGER_DISTRO="debian"
    local install_type="${HONEY_BADGER_INSTALL_TYPE:-full}"
    case "$install_type" in
        full)    hb_set_total_steps 14 ;;
        developer) hb_set_total_steps 11 ;;
        desktop) hb_set_total_steps 10 ;;
        minimal) hb_set_total_steps 5 ;;
    esac
    show_banner
    check_debian_system
    update_system
    install_packages_by_type
    setup_nano
    create_utility_scripts \
        "sudo apt update && sudo apt upgrade -y" \
        "sudo apt install -y" \
        "sudo apt autoremove -y && sudo apt autoclean"
    if [[ "$install_type" != "minimal" ]]; then
        if ! hb_skip_component "theme"; then
            setup_honey_badger_theme
            install_assets
        fi
    fi
    if [[ "$install_type" == "full" || "$install_type" == "developer" ]]; then
        setup_development_environment
    fi
    show_post_install
}

main "$@"
