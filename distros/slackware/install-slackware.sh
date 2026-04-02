#!/bin/bash
# Honey Badger OS - Slackware Post-Install Script
# Supports: Slackware Linux (14.2+, 15.0+, -current)

set -euo pipefail

# Source shared library
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

LOG_FILE="/tmp/honeybadger-slackware-install.log"

# ── Package lists (slackpkg names) ──────────────────────────────────────────
# Slackware has disk sets rather than individual packages; we install sets and extras
declare -a BASE_SETS=(
    "a" "ap" "l" "n"
)

declare -a DEVELOPER_SETS=(
    "d" "tcl"
)

declare -a XFCE_SET=(
    "xfce"
)

declare -a X_SET=(
    "x"
)

# Extra packages beyond sets (via slackpkg or sbopkg)
declare -a BASE_PACKAGES=(
    "curl" "wget" "git" "unzip" "p7zip"
    "htop" "tmux" "screen" "mc"
    "ntfs-3g" "dosfstools" "gparted"
    "rsync" "nmap" "openssh"
    "inxi" "neofetch"
)

declare -a DEVELOPER_PACKAGES=(
    "python3" "python-pip"
    "nodejs" "npm"
    "cmake" "ninja" "meson"
    "gcc" "g++" "make" "gdb"
    "autoconf" "automake" "libtool" "pkg-config"
    "sqlite" "subversion"
)

declare -a DESKTOP_PACKAGES=(
    "xfce4-terminal" "xfce4-screenshooter" "xfce4-taskmanager"
    "xfce4-notifyd" "xfce4-power-manager"
    "thunar" "thunar-volman"
    "mousepad" "galculator" "xarchiver"
    "network-manager-applet"
    "ImageMagick" "ffmpeg"
    "dejavu-fonts-ttf" "liberation-fonts-ttf"
)

declare -a APPLICATIONS_PACKAGES=(
    "firefox" "chromium"
    "libreoffice"
    "gimp" "inkscape" "vlc" "audacity"
    "thunderbird"
)

# ── Banner ──────────────────────────────────────────────────────────────────
show_banner() {
    echo -e "${YELLOW}${BOLD}" | tee -a "$LOG_FILE"
    echo "  🦡 ================================================== 🦡" | tee -a "$LOG_FILE"
    echo "     HONEY BADGER OS - SLACKWARE INSTALLER" | tee -a "$LOG_FILE"
    echo "     Fearless Slackware Linux Setup" | tee -a "$LOG_FILE"
    echo "  🦡 ================================================== 🦡" | tee -a "$LOG_FILE"
    echo -e "${NC}" | tee -a "$LOG_FILE"
}

# ── System check ────────────────────────────────────────────────────────────
check_slackware_system() {
    if ! command -v slackpkg >/dev/null 2>&1; then
        log_error "This script requires slackpkg"
        exit 1
    fi
    if [[ -f /etc/slackware-version ]]; then
        log_info "Detected: $(cat /etc/slackware-version)"
    fi
}

# ── slackpkg setup ──────────────────────────────────────────────────────────
setup_slackpkg() {
    hb_next_step "Configuring slackpkg mirrors..."
    # Ensure at least one mirror is uncommented in /etc/slackpkg/mirrors
    if ! grep -q '^[^#]' /etc/slackpkg/mirrors 2>/dev/null; then
        log_warning "No active mirrors in /etc/slackpkg/mirrors"
        if is_noninteractive; then
            # Auto-enable the first commented mirror for the detected version
            local slack_ver
            slack_ver=$(sed -n 's/.*Slackware \([0-9.]*\).*/\1/p' /etc/slackware-version 2>/dev/null || echo "current")
            log_info "Non-interactive: attempting to auto-enable a mirror for Slackware ${slack_ver}"
            hb_sudo sed -i "0,/^#.*mirrors.slackware.com.*${slack_ver}/s/^#//" /etc/slackpkg/mirrors 2>/dev/null || \
            hb_sudo sed -i '0,/^#.*http/s/^#//' /etc/slackpkg/mirrors 2>/dev/null || \
            log_warning "Could not auto-enable a mirror; slackpkg may fail"
        else
            log_info "Please uncomment a mirror in /etc/slackpkg/mirrors before continuing"
            read -rp "Press Enter after configuring a mirror, or Ctrl-C to abort..."
        fi
    fi
    hb_sudo slackpkg update gpg 2>/dev/null || true
    hb_sudo slackpkg update
    log_success "slackpkg configured"
}

# ── System update ───────────────────────────────────────────────────────────
update_system() {
    hb_next_step "Updating system packages..."
    if is_noninteractive; then
        # batch mode: auto-accept
        echo "Y" | hb_sudo slackpkg upgrade-all || true
    else
        hb_sudo slackpkg upgrade-all || true
    fi
    log_success "System updated"
}

# ── Disk set installation ───────────────────────────────────────────────────
install_disk_sets() {
    local -n sets_ref=$1
    local set_type="$2"
    hb_next_step "Installing $set_type disk sets..."
    for disk_set in "${sets_ref[@]}"; do
        log_info "Installing disk set: $disk_set"
        if is_noninteractive; then
            echo "Y" | hb_sudo slackpkg install-new "$disk_set" 2>/dev/null || true
        else
            hb_sudo slackpkg install-new "$disk_set" || true
        fi
    done
    log_success "Installed $set_type disk sets"
}

# ── Package installation ───────────────────────────────────────────────────
install_slack_packages() {
    local -n packages_ref=$1
    local package_type="$2"
    if [[ ${#packages_ref[@]} -eq 0 ]]; then
        log_info "No $package_type packages to install"
        return 0
    fi
    hb_next_step "Installing $package_type packages..."
    local installed=0
    local failed=0
    for package in "${packages_ref[@]}"; do
        # Check if already installed
        if ls /var/log/packages/"${package}"-* >/dev/null 2>&1; then
            log_info "$package already installed"
            continue
        fi
        # Try slackpkg first
        if is_noninteractive; then
            if echo "Y" | hb_sudo slackpkg install "$package" 2>/dev/null; then
                hb_json_add_package "$package"
                ((installed++))
            else
                # Try sbopkg if available
                if command -v sbopkg >/dev/null 2>&1; then
                    if hb_sudo sbopkg -i "$package" -B 2>/dev/null; then
                        hb_json_add_package "$package"
                        ((installed++))
                    else
                        log_warning "Failed to install: $package"
                        ((failed++))
                    fi
                else
                    log_warning "Failed to install: $package (sbopkg not available)"
                    ((failed++))
                fi
            fi
        else
            if hb_sudo slackpkg install "$package" 2>/dev/null; then
                hb_json_add_package "$package"
                ((installed++))
            else
                log_warning "Failed to install: $package"
                ((failed++))
            fi
        fi
    done
    if [[ $failed -gt 0 ]]; then
        log_warning "Installed $installed $package_type packages ($failed failed)"
        hb_json_add_error "$failed $package_type packages failed"
    else
        log_success "Installed $installed $package_type packages"
    fi
}

# ── sbopkg setup ────────────────────────────────────────────────────────────
setup_sbopkg() {
    hb_next_step "Setting up sbopkg (SlackBuilds.org package tool)..."
    if command -v sbopkg >/dev/null 2>&1; then
        log_info "sbopkg already installed"
        hb_sudo sbopkg -r 2>/dev/null || true
        return 0
    fi
    # Resolve latest sbopkg release dynamically; fall back to known version
    local sbopkg_url
    sbopkg_url=$(curl -fsSL --connect-timeout 5 -o /dev/null -w '%{redirect_url}' \
        https://github.com/sbopkg/sbopkg/releases/latest 2>/dev/null || true)
    if [[ -n "$sbopkg_url" ]]; then
        local tag="${sbopkg_url##*/}"
        sbopkg_url="https://github.com/sbopkg/sbopkg/releases/download/${tag}/sbopkg-${tag}-noarch-1_wsr.tgz"
    else
        sbopkg_url="https://github.com/sbopkg/sbopkg/releases/latest/download/sbopkg-0.38.2-noarch-1_wsr.tgz"
    fi
    local tmp_pkg
    tmp_pkg=$(mktemp /tmp/sbopkg.XXXXXX.tgz)
    hb_register_temp "$tmp_pkg"
    if curl -fsSL "$sbopkg_url" -o "$tmp_pkg"; then
        hb_sudo installpkg "$tmp_pkg"
        rm -f "$tmp_pkg"
        hb_sudo sbopkg -r 2>/dev/null || true
        log_success "sbopkg installed and repository synced"
    else
        rm -f "$tmp_pkg"
        log_warning "Could not download sbopkg; some packages may not be available"
    fi
}

# ── XFCE setup (Slackware-specific) ────────────────────────────────────────
setup_xfce_slackware() {
    hb_next_step "Configuring XFCE desktop for Slackware..."
    # Install X11 and XFCE sets
    install_disk_sets X_SET "X Window System"
    install_disk_sets XFCE_SET "XFCE desktop"
    # Set default runlevel to 4 (graphical) in inittab
    if [[ -f /etc/inittab ]] && grep -q "id:3:initdefault" /etc/inittab; then
        hb_backup_file /etc/inittab
        hb_sudo sed -i 's/id:3:initdefault/id:4:initdefault/' /etc/inittab
        log_success "Default runlevel set to 4 (graphical)"
    fi
    # Configure xinitrc for XFCE
    if [[ -d "$HOME" ]]; then
        if [[ ! -f "$HOME/.xinitrc" ]] || ! grep -q "xfce4-session" "$HOME/.xinitrc"; then
            hb_backup_file "$HOME/.xinitrc"
            echo "exec startxfce4" > "$HOME/.xinitrc"
            log_success "XFCE set as default session"
        fi
    fi
    setup_xfce
}

# ── Main installation by type ──────────────────────────────────────────────
install_packages_by_type() {
    local install_type="${HONEY_BADGER_INSTALL_TYPE:-full}"
    log_info "Installation type: $install_type"
    install_disk_sets BASE_SETS "base system"
    install_slack_packages BASE_PACKAGES "base utilities"
    case "$install_type" in
        "full")
            install_disk_sets DEVELOPER_SETS "development"
            install_slack_packages DEVELOPER_PACKAGES "developer"
            setup_xfce_slackware
            install_slack_packages DESKTOP_PACKAGES "desktop utilities"
            install_slack_packages APPLICATIONS_PACKAGES "applications"
            ;;
        "developer")
            install_disk_sets DEVELOPER_SETS "development"
            install_slack_packages DEVELOPER_PACKAGES "developer"
            setup_xfce_slackware
            install_slack_packages DESKTOP_PACKAGES "desktop utilities"
            ;;
        "desktop")
            setup_xfce_slackware
            install_slack_packages DESKTOP_PACKAGES "desktop utilities"
            install_slack_packages APPLICATIONS_PACKAGES "applications"
            local -a basic_dev=("python3" "git" "make")
            install_slack_packages basic_dev "basic development"
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

# ── Docker setup (Slackware-specific) ──────────────────────────────────────
setup_docker_slackware() {
    hb_next_step "Setting up Docker for Slackware..."
    if ! command -v docker >/dev/null 2>&1; then
        log_info "Docker not found; attempting sbopkg install..."
        if command -v sbopkg >/dev/null 2>&1; then
            hb_sudo sbopkg -i docker -B 2>/dev/null || {
                log_warning "Docker installation via sbopkg failed"
                return 0
            }
        else
            log_warning "Docker not available and sbopkg not installed"
            return 0
        fi
    fi
    # Start docker daemon
    if [[ -x /etc/rc.d/rc.docker ]]; then
        hb_sudo chmod +x /etc/rc.d/rc.docker
        hb_sudo /etc/rc.d/rc.docker start 2>/dev/null || true
    fi
    setup_development_environment
}

# ── Main ────────────────────────────────────────────────────────────────────
main() {
    echo "Honey Badger OS - Slackware Installation Log" > "$LOG_FILE"
    echo "Started: $(date)" >> "$LOG_FILE"
    hb_json_init
    export HONEY_BADGER_DISTRO="slackware"
    local install_type="${HONEY_BADGER_INSTALL_TYPE:-full}"
    case "$install_type" in
        full)    hb_set_total_steps 14 ;;
        developer) hb_set_total_steps 12 ;;
        desktop) hb_set_total_steps 10 ;;
        minimal) hb_set_total_steps 6 ;;
    esac
    show_banner
    check_slackware_system
    setup_slackpkg
    setup_sbopkg
    update_system
    install_packages_by_type
    setup_nano
    create_utility_scripts \
        "sudo slackpkg update && sudo slackpkg upgrade-all" \
        "sudo slackpkg install" \
        "echo 'Manual cleanup recommended on Slackware'"
    if [[ "$install_type" != "minimal" ]]; then
        setup_honey_badger_theme
        install_assets
    fi
    if [[ "$install_type" == "full" || "$install_type" == "developer" ]]; then
        setup_docker_slackware
    fi
    show_post_install
}

trap 'echo -e "\n${RED}Installation interrupted${NC}"; exit 1' INT TERM
main "$@"
