#!/bin/bash
# Honey Badger OS - Gentoo Post-Install Script
# Supports: Gentoo Linux, Funtoo

set -euo pipefail

# Source shared library
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

hb_init_distro_log "gentoo"

# ── Package lists ────────────────────────────────────────────────────────────
# Gentoo uses category/package format
declare -a BASE_PACKAGES=(
    "net-misc/curl" "net-misc/wget" "dev-vcs/git" "app-arch/unzip" "app-arch/zip"
    "app-arch/p7zip"
    "sys-process/htop" "app-misc/neofetch" "app-text/tree" "app-misc/tmux"
    "app-misc/screen"
    "net-misc/networkmanager" "net-wireless/wpa_supplicant"
    "net-misc/openssh" "net-misc/rsync" "net-analyzer/nmap"
    "sys-block/gparted" "sys-fs/ntfs3g" "sys-fs/exfatprogs" "sys-fs/dosfstools"
    "media-sound/pulseaudio" "media-sound/pavucontrol" "media-sound/alsa-utils"
    "media-fonts/dejavu" "media-fonts/liberation-fonts" "media-fonts/noto"
    "media-fonts/noto-emoji" "media-fonts/roboto"
)

declare -a DEVELOPER_PACKAGES=(
    "dev-lang/python" "dev-python/pip" "dev-python/virtualenv"
    "net-libs/nodejs"
    "dev-lang/go" "dev-lang/rust"
    "virtual/jdk"
    "dev-lang/ruby" "dev-ruby/rubygems"
    "dev-lang/php"
    "dev-build/make" "dev-build/cmake" "dev-build/ninja" "dev-build/meson"
    "sys-devel/gcc" "sys-devel/clang" "dev-debug/gdb" "dev-debug/valgrind"
    "app-containers/docker" "app-containers/docker-compose"
    "dev-db/postgresql" "dev-db/mariadb" "dev-db/sqlite" "dev-db/redis"
    "app-editors/neovim"
    "dev-build/autoconf" "dev-build/automake" "dev-build/libtool"
)

declare -a DESKTOP_PACKAGES=(
    "xfce-base/xfce4-meta" "xfce-extra/xfce4-taskmanager"
    "xfce-extra/xfce4-screenshooter" "xfce-extra/xfce4-whiskermenu-plugin"
    "xfce-extra/xfce4-clipman-plugin" "xfce-extra/xfce4-notifyd"
    "xfce-extra/xfce4-pulseaudio-plugin" "xfce-extra/xfce4-power-manager"
    "xfce-extra/thunar-volman" "xfce-extra/thunar-archive-plugin"
    "x11-misc/lightdm" "x11-misc/lightdm-gtk-greeter"
    "app-arch/file-roller" "gnome-base/gvfs"
    "x11-misc/rofi" "x11-misc/dmenu"
    "net-wireless/blueman" "gnome-extra/nm-applet"
    "media-gfx/imagemagick"
)

declare -a APPLICATIONS_PACKAGES=(
    "www-client/firefox" "www-client/chromium"
    "app-office/libreoffice"
    "media-gfx/gimp" "media-gfx/inkscape" "media-video/vlc"
    "media-sound/audacity"
    "media-gfx/imagemagick" "media-video/ffmpeg"
    "mail-client/thunderbird"
    "sci-calculators/galculator" "app-editors/mousepad" "app-arch/xarchiver"
    "media-libs/gstreamer" "media-libs/gst-plugins-base" "media-libs/gst-plugins-good"
    "media-libs/gst-plugins-bad" "media-libs/gst-plugins-ugly" "media-plugins/gst-plugins-libav"
)

# ── Banner ───────────────────────────────────────────────────────────────────
show_banner() {
    hb_show_banner "Gentoo" "Fearless Gentoo-based Distribution Setup"
}

# ── System check ─────────────────────────────────────────────────────────────
check_gentoo_system() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        log_info "Detected: ${PRETTY_NAME:-Gentoo Linux}"
    fi
}

# ── System update ────────────────────────────────────────────────────────────
update_system() {
    hb_next_step "Syncing Portage tree and updating system..."
    hb_sudo emerge --sync --quiet
    hb_sudo emerge --update --deep --newuse @world --quiet || true
    log_success "System updated successfully"
}

# ── Package installation ────────────────────────────────────────────────────
install_emerge_packages() {
    local -n packages_ref=$1
    local package_type="$2"
    if [[ ${#packages_ref[@]} -eq 0 ]]; then
        log_info "No $package_type packages to install"
        return 0
    fi
    hb_next_step "Installing $package_type packages..."
    local -a available_packages=()
    for package in "${packages_ref[@]}"; do
        # Check if already installed (strip category for qlist check)
        local pkg_name="${package##*/}"
        if qlist -I "$pkg_name" >/dev/null 2>&1 || equery list "$package" >/dev/null 2>&1; then
            log_info "$package already installed"
        else
            available_packages+=("$package")
        fi
    done
    if [[ ${#available_packages[@]} -gt 0 ]]; then
        if hb_sudo emerge --ask=n --quiet "${available_packages[@]}"; then
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

# ── XFCE service setup (Gentoo-specific) ─────────────────────────────────────
setup_xfce_gentoo() {
    hb_next_step "Setting up XFCE desktop for Gentoo..."
    hb_enable_service dbus
    hb_enable_service elogind
    hb_enable_service lightdm
    if command -v systemctl >/dev/null 2>&1; then
        hb_sudo systemctl set-default graphical.target 2>/dev/null || true
    fi
    setup_xfce
}

# ── Main installation by type ───────────────────────────────────────────────
install_packages_by_type() {
    local install_type="${HONEY_BADGER_INSTALL_TYPE:-full}"
    log_info "Installation type: $install_type"
    install_emerge_packages BASE_PACKAGES "base"
    case "$install_type" in
        "full")
            install_emerge_packages DEVELOPER_PACKAGES "developer"
            install_emerge_packages DESKTOP_PACKAGES "desktop"
            install_emerge_packages APPLICATIONS_PACKAGES "applications"
            setup_xfce_gentoo
            ;;
        "developer")
            install_emerge_packages DEVELOPER_PACKAGES "developer"
            install_emerge_packages DESKTOP_PACKAGES "basic desktop"
            setup_xfce_gentoo
            ;;
        "desktop")
            install_emerge_packages DESKTOP_PACKAGES "desktop"
            install_emerge_packages APPLICATIONS_PACKAGES "applications"
            local -a basic_dev=("dev-lang/python" "dev-python/pip" "net-libs/nodejs" "dev-vcs/git")
            install_emerge_packages basic_dev "basic development"
            setup_xfce_gentoo
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

# ── Development tools (Gentoo-specific) ──────────────────────────────────────
setup_dev_gentoo() {
    hb_next_step "Installing Gentoo development tools..."
    setup_development_environment
}

# ── Main ─────────────────────────────────────────────────────────────────────
main() {
    echo "Honey Badger OS - Gentoo Installation Log" > "$LOG_FILE"
    echo "Started: $(date)" >> "$LOG_FILE"
    hb_json_init
    hb_rollback_init
    export HONEY_BADGER_DISTRO="gentoo"
    local install_type="${HONEY_BADGER_INSTALL_TYPE:-full}"
    case "$install_type" in
        full)    hb_set_total_steps 12 ;;
        developer) hb_set_total_steps 10 ;;
        desktop) hb_set_total_steps 9 ;;
        minimal) hb_set_total_steps 5 ;;
    esac
    show_banner
    check_gentoo_system
    update_system
    install_packages_by_type
    setup_nano
    create_utility_scripts \
        "sudo emerge --sync && sudo emerge --update --deep @world" \
        "sudo emerge --ask" \
        "sudo emerge --depclean && sudo eclean-dist --deep"
    if [[ "$install_type" != "minimal" ]]; then
        if ! hb_skip_component "theme"; then
            setup_honey_badger_theme
            install_assets
        fi
    fi
    if [[ "$install_type" == "full" || "$install_type" == "developer" ]]; then
        setup_dev_gentoo
    fi
    show_post_install
}

main "$@"
