#!/bin/bash
#
# Honey Badger OS - Void Linux Post-Install Script
# Transform your Void Linux installation into a fearless development environment
#
# Author: James-HoneyBadger
# Version: 1.0.0
# Description: Comprehensive post-installation script for Void Linux systems
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
readonly SCRIPT_NAME="Honey Badger OS - Void Linux Installer"
readonly VERSION="1.0.0"
readonly REPO_URL="https://github.com/James-HoneyBadger/Honey_Badger_OS"

# Installation types
readonly FULL="full"
readonly DEVELOPER="developer"
readonly MINIMAL="minimal"
readonly DESKTOP="desktop"

# Default installation type
INSTALL_TYPE="${FULL}"

# Void Linux architecture detection
ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
    VOID_ARCH="x86_64"
elif [[ "$ARCH" == "aarch64" ]]; then
    VOID_ARCH="aarch64"
else
    VOID_ARCH="$ARCH"
fi

# Logging
readonly LOG_FILE="/tmp/honeybadger-install.log"
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
# Print error message
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
████████████████████████████████████████████████████████████████████
█                                                                  █
█  🦡 HONEY BADGER OS - VOID LINUX POST-INSTALL SCRIPT 🦡          █
█                                                                  █
█  Fearless • Determined • Uncompromising                          █
█  Transform your Void Linux into a development powerhouse         █
█                                                                  █
████████████████████████████████████████████████████████████████████
"
    print_colored "${CYAN}" "Version: ${VERSION}"
    print_colored "${CYAN}" "Architecture: ${VOID_ARCH}"
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
# Check if running on Void Linux
#######################################
check_void_linux() {
    if ! command -v xbps-install &> /dev/null; then
        print_error "This script is designed for Void Linux systems"
        print_error "xbps package manager not found"
        exit 1
    fi
    
    if [[ ! -f /etc/void-release ]]; then
        print_warning "This doesn't appear to be a Void Linux system"
        read -p "Do you want to continue anyway? [y/N]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    print_status "Detected Void Linux (${VOID_ARCH})"
}

#######################################
# Update system packages
#######################################
update_system() {
    print_status "Updating system packages..."
    
    # Update package database
    sudo xbps-install -S
    
    # Update system
    sudo xbps-install -u
    
    print_success "System updated successfully"
}

#######################################
# Install essential packages
#######################################
install_essential_packages() {
    print_status "Installing essential packages..."
    
    local essential_packages=(
        # Build tools
        "base-devel"
        "git"
        "curl"
        "wget"
        "unzip"
        "tar"
        "gzip"
        "nano"
        "vim"
        "htop"
        "neofetch"
        
        # Network tools
        "NetworkManager"
        "wireless_tools"
        "wpa_supplicant"
        
        # Audio (Void Linux uses different audio systems)
        "pulseaudio"
        "pavucontrol"
        "alsa-utils"
        
        # Fonts
        "dejavu-fonts-ttf"
        "liberation-fonts-ttf"
        "noto-fonts-ttf"
        "noto-fonts-emoji"
        
        # File system utilities
        "dosfstools"
        "ntfs-3g"
        "exfat-utils"
        
        # System utilities
        "void-repo-nonfree"  # Enable nonfree repository
        "void-repo-multilib" # Enable multilib repository
    )
    
    sudo xbps-install -y "${essential_packages[@]}" || print_warning "Some essential packages failed to install"
    
    print_success "Essential packages installed"
}

#######################################
# Install development tools
#######################################
install_development_tools() {
    print_status "Installing development tools..."
    
    local dev_packages=(
        # Programming languages
        "python3"
        "python3-pip"
        "nodejs"
        "npm"
        "go"
        "rust"
        "cargo"
        "gcc"
        "clang"
        "openjdk"
        "ruby"
        "ruby-devel"
        "php"
        
        # Version control
        "git"
        "git-lfs"
        
        # Code editors
        "neovim"
        
        # Build tools
        "make"
        "cmake"
        "autoconf"
        "automake"
        "libtool"
        "ninja"
        "meson"
        
        # Debugging and profiling
        "gdb"
        "valgrind"
        "strace"
        
        # Container tools (Void Linux has podman)
        "podman"
        "buildah"
        "skopeo"
        
        # Database tools
        "postgresql-client"
        "mysql-client"
        "sqlite"
        "redis"
        
        # Network tools
        "nmap"
        "wireshark"
        "curl"
        "wget"
        "httpie"
    )
    
    sudo xbps-install -y "${dev_packages[@]}" || print_warning "Some development packages failed to install"
    
    # Install additional development tools
    install_additional_dev_tools
    
    print_success "Development tools installed"
}

#######################################
# Install additional development tools
#######################################
install_additional_dev_tools() {
    print_status "Installing additional development tools..."
    
    # Install VS Code if available in repositories
    if xbps-query -R vscode &>/dev/null; then
        sudo xbps-install -y vscode || print_warning "Failed to install VS Code from repositories"
    else
        print_warning "VS Code not available in Void repositories"
        print_status "You can install VS Code manually from https://code.visualstudio.com/"
    fi
    
    # Install GitHub CLI if available
    if xbps-query -R github-cli &>/dev/null; then
        sudo xbps-install -y github-cli || print_warning "Failed to install GitHub CLI"
    fi
    
    # Docker is not available in Void Linux by default, Podman is the alternative
    print_status "Note: Void Linux uses Podman instead of Docker for containers"
    
    print_success "Additional development tools installed"
}

#######################################
# Install XFCE desktop environment
#######################################
install_xfce_desktop() {
    print_status "Installing XFCE desktop environment..."
    
    local xfce_packages=(
        # Core XFCE
        "xfce4"
        
        # Display manager
        "lightdm"
        "lightdm-gtk3-greeter"
        
        # X server
        "xorg-server"
        "xinit"
        
        # Graphics drivers (basic)
        "xf86-video-vesa"
        "mesa-dri"
        
        # Audio plugin for XFCE
        "xfce4-pulseaudio-plugin"
        
        # File manager plugins
        "thunar-archive-plugin"
        "thunar-media-tags-plugin"
        "thunar-volman"
        
        # Additional XFCE applications
        "xfce4-terminal"
        "xfce4-screenshooter"
        "xfce4-taskmanager"
        "xfce4-power-manager"
        
        # Applications
        "firefox"
        "libreoffice"
        "gimp"
        "vlc"
        "file-roller"
        "galculator"
        "ristretto"
        "mousepad"
        "atril"  # PDF viewer
    )
    
    sudo xbps-install -y "${xfce_packages[@]}" || print_warning "Some XFCE packages failed to install"
    
    # Enable display manager service (Void Linux uses runit)
    sudo ln -sf /etc/sv/lightdm /var/service/ 2>/dev/null || print_warning "Failed to enable lightdm service"
    
    print_success "XFCE desktop environment installed"
}

#######################################
# Install productivity applications
#######################################
install_productivity_apps() {
    print_status "Installing productivity applications..."
    
    local productivity_packages=(
        # Office suite
        "libreoffice"
        
        # Web browsers
        "firefox"
        "chromium"
        
        # Communication
        "thunderbird"
        
        # Multimedia
        "vlc"
        "audacity"
        "gimp"
        "inkscape"
        
        # System tools
        "gparted"
        "stress"
        
        # Archive tools
        "file-roller"
        "unrar"
        "p7zip"
        
        # PDF tools
        "atril"
        "pdftk"
    )
    
    sudo xbps-install -y "${productivity_packages[@]}" || print_warning "Some productivity packages failed to install"
    
    print_success "Productivity applications installed"
}

#######################################
# Configure nano editor
#######################################
configure_nano() {
    print_status "Configuring nano editor..."
    
    # Create user nano configuration
    cat > "$HOME/.nanorc" << 'EOF'
# Honey Badger OS - Enhanced nano configuration for Void Linux

# Enable syntax highlighting
include "/usr/share/nano/*.nanorc"

# Interface settings
set titlecolor brightwhite,brown
set statuscolor brightwhite,green
set keycolor cyan
set functioncolor green

# Display line numbers
set linenumbers

# Enable mouse support
set mouse

# Set tab size to 4 spaces
set tabsize 4
set tabstospaces

# Auto-indent new lines
set autoindent

# Enable soft line wrapping
set softwrap

# Show whitespace
set whitespace "»·"

# Backup files
set backup
set backupdir "~/.nano/backups/"

# Search settings
set casesensitive
set regexp

# Key bindings
bind ^S writeout main
bind ^Q exit main
bind ^R replace main
bind ^X cut main
bind ^C copy main
bind ^V paste main
bind ^Z undo main
bind ^Y redo main
bind ^A selectall main
bind ^F whereis main
bind ^G findnext main
bind ^B gotoline main

# Additional useful bindings
bind M-U undo main
bind M-R redo main
bind ^T gotoline main
bind M-A selectall main
EOF

    # Create backup directory
    mkdir -p "$HOME/.nano/backups/"

    # Set nano as default editor in shell profile
    if ! grep -q "EDITOR=nano" "$HOME/.bashrc" 2>/dev/null; then
        echo 'export EDITOR=nano' >> "$HOME/.bashrc"
        echo 'export VISUAL=nano' >> "$HOME/.bashrc"
    fi

    # Set as default for git
    git config --global core.editor nano

    print_success "nano editor configured"
}

#######################################
# Install and configure Honey Badger theme
#######################################
configure_honey_badger_theme() {
    print_status "Installing Honey Badger theme..."
    
    # Create theme directories
    mkdir -p "$HOME/.themes/HoneyBadger/gtk-3.0"
    mkdir -p "$HOME/.local/share/honey-badger"
    mkdir -p "$HOME/.config/gtk-3.0"
    mkdir -p "$HOME/.config/xfce4"
    
    # Create GTK theme index
    cat > "$HOME/.themes/HoneyBadger/index.theme" << 'EOF'
[Desktop Entry]
Type=X-GNOME-Metatheme
Name=Honey Badger
Comment=Honey Badger OS custom theme
Encoding=UTF-8

[X-GNOME-Metatheme]
GtkTheme=HoneyBadger
MetacityTheme=HoneyBadger
IconTheme=Adwaita
CursorTheme=default
ButtonLayout=close,minimize,maximize:menu
EOF

    # Create GTK3 theme CSS (same as other distributions)
    cat > "$HOME/.themes/HoneyBadger/gtk-3.0/gtk.css" << 'EOF'
/* Honey Badger OS GTK3 Theme for Void Linux */

/* Color definitions */
@define-color honey_gold #ffb347;
@define-color honey_brown #8b4513;
@define-color dark_brown #654321;
@define-color light_brown #a0522d;
@define-color cream #fffdd0;
@define-color dark_bg #1a1a1a;
@define-color medium_bg #2a2a2a;

/* Base colors */
* {
    background-color: @dark_bg;
    color: @cream;
}

/* Window backgrounds */
window {
    background-color: @dark_bg;
    color: @cream;
}

/* Headers and titlebars */
headerbar {
    background: linear-gradient(to bottom, @honey_brown, @dark_brown);
    color: @cream;
    border-bottom: 1px solid @dark_brown;
}

/* Buttons */
button {
    background: linear-gradient(to bottom, @light_brown, @honey_brown);
    color: @cream;
    border: 1px solid @dark_brown;
    border-radius: 3px;
    padding: 6px 12px;
}

button:hover {
    background: linear-gradient(to bottom, @honey_gold, @light_brown);
}

button:active {
    background: @dark_brown;
    color: @honey_gold;
}

/* Menu and navigation */
menubar {
    background-color: @honey_brown;
    color: @cream;
}

menu {
    background-color: @medium_bg;
    color: @cream;
    border: 1px solid @dark_brown;
}

menuitem:hover {
    background-color: @honey_gold;
    color: @dark_brown;
}

/* Text entries */
entry {
    background-color: @medium_bg;
    color: @cream;
    border: 1px solid @honey_brown;
    border-radius: 3px;
}

entry:focus {
    border-color: @honey_gold;
    box-shadow: 0 0 3px @honey_gold;
}

/* Scrollbars */
scrollbar {
    background-color: @dark_bg;
}

scrollbar slider {
    background-color: @honey_brown;
    border-radius: 10px;
}

scrollbar slider:hover {
    background-color: @honey_gold;
}

/* Notebooks/Tabs */
notebook {
    background-color: @dark_bg;
}

notebook tab {
    background-color: @medium_bg;
    color: @cream;
    border: 1px solid @dark_brown;
    padding: 6px 12px;
}

notebook tab:checked {
    background-color: @honey_brown;
    color: @cream;
}

/* Treeview */
treeview {
    background-color: @dark_bg;
    color: @cream;
}

treeview:selected {
    background-color: @honey_brown;
    color: @cream;
}

/* Toolbars */
toolbar {
    background: linear-gradient(to bottom, @honey_brown, @dark_brown);
    color: @cream;
    border-bottom: 1px solid @dark_brown;
}
EOF

    # Create GTK3 settings
    cat > "$HOME/.config/gtk-3.0/settings.ini" << 'EOF'
[Settings]
gtk-theme-name=HoneyBadger
gtk-icon-theme-name=Adwaita
gtk-font-name=DejaVu Sans 10
gtk-cursor-theme-name=default
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintfull
gtk-xft-rgba=rgb
EOF

    # Set up honey badger icon if available
    if [[ -f "../../assets/hb.jpg" ]]; then
        cp "../../assets/hb.jpg" "$HOME/.local/share/honey-badger/"
        
        # Convert to different sizes using ImageMagick if available
        if command -v convert &> /dev/null; then
            mkdir -p "$HOME/.local/share/honey-badger/icons"
            for size in 16 22 24 32 48 64 96 128 256; do
                convert "$HOME/.local/share/honey-badger/hb.jpg" -resize "${size}x${size}" "$HOME/.local/share/honey-badger/icons/honey-badger-${size}.png" 2>/dev/null || true
            done
        fi
    fi
    
    print_success "Honey Badger theme configured"
}

#######################################
# Configure XFCE settings
#######################################
configure_xfce() {
    if [[ "$INSTALL_TYPE" == "$MINIMAL" ]]; then
        return
    fi
    
    print_status "Configuring XFCE desktop..."
    
    # XFCE configuration for Void Linux
    if command -v xfconf-query &> /dev/null; then
        xfconf-query -c xsettings -p /Net/ThemeName -s "HoneyBadger" 2>/dev/null || true
        xfconf-query -c xfwm4 -p /general/theme -s "HoneyBadger" 2>/dev/null || true
        
        # Set wallpaper if available
        if [[ -f "$HOME/.local/share/honey-badger/hb.jpg" ]]; then
            xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVGA1/workspace0/last-image -s "$HOME/.local/share/honey-badger/hb.jpg" 2>/dev/null || true
        fi
        
        # Panel configuration
        xfconf-query -c xfce4-panel -p /panels/panel-1/background-style -s 1 2>/dev/null || true
        xfconf-query -c xfce4-panel -p /panels/panel-1/background-color -t uint -s 2868903935 2>/dev/null || true
    fi
    
    print_success "XFCE desktop configured"
}

#######################################
# Enable essential services (runit style)
#######################################
enable_services() {
    print_status "Enabling essential services (runit)..."
    
    # Void Linux uses runit instead of systemd
    local services=(
        "NetworkManager"
        "bluetoothd"
        "dbus"
    )
    
    for service in "${services[@]}"; do
        if [[ -d "/etc/sv/$service" ]]; then
            sudo ln -sf "/etc/sv/$service" /var/service/ 2>/dev/null || print_warning "Failed to enable $service"
            print_status "Enabled $service"
        else
            print_warning "$service service directory not found"
        fi
    done
    
    print_success "Services configured"
}

#######################################
# Create utility scripts
#######################################
create_utility_scripts() {
    print_status "Creating Honey Badger utility scripts..."
    
    mkdir -p "$HOME/.local/bin"
    
    # System info script
    cat > "$HOME/.local/bin/honey-badger-info" << 'EOF'
#!/bin/bash
# Honey Badger OS system information script for Void Linux

echo "🦡 HONEY BADGER OS SYSTEM INFORMATION"
echo "===================================="
echo
echo "🖥️  System:"
neofetch --config off --ascii_distro void_small --colors 3 6 7 4 5 2
echo
echo "📦 Development Tools Installed:"
command -v python3 && python3 --version
command -v node && node --version
command -v npm && npm --version
command -v go && go version
command -v rustc && rustc --version
command -v gcc && gcc --version | head -n1
command -v git && git --version
command -v podman && podman --version
echo
echo "📝 Default Editor: $EDITOR"
echo "🎨 Current Theme: $(xfconf-query -c xsettings -p /Net/ThemeName 2>/dev/null || echo 'Not in X session')"
echo
echo "🔧 Init System: runit"
echo "📦 Package Manager: xbps"
echo
echo "🦡 Fearless • Determined • Uncompromising"
EOF

    # System update script  
    cat > "$HOME/.local/bin/honey-badger-update" << 'EOF'
#!/bin/bash
# Honey Badger OS system update script for Void Linux

echo "🦡 HONEY BADGER OS SYSTEM UPDATE"
echo "==============================="
echo

echo "📦 Updating package database..."
sudo xbps-install -S

echo
echo "📦 Upgrading packages..."
sudo xbps-install -u

echo
echo "🧹 Cleaning package cache..."
sudo xbps-remove -O

echo
echo "✅ System update completed!"
echo "🦡 Your Honey Badger system is up to date!"
EOF

    # Package search and install helper
    cat > "$HOME/.local/bin/honey-badger-install" << 'EOF'
#!/bin/bash
# Honey Badger OS package installation helper for Void Linux

if [[ $# -eq 0 ]]; then
    echo "Usage: honey-badger-install <package_name>"
    echo "This script installs packages via xbps-install"
    exit 1
fi

PACKAGE="$1"

echo "🦡 Installing package: $PACKAGE"

if sudo xbps-install -y "$PACKAGE"; then
    echo "✅ Successfully installed $PACKAGE"
else
    echo "❌ Failed to install $PACKAGE"
    echo "Searching for similar packages..."
    xbps-query -Rs "$PACKAGE" | head -10
fi
EOF

    # Service management helper
    cat > "$HOME/.local/bin/honey-badger-service" << 'EOF'
#!/bin/bash
# Honey Badger OS service management helper for Void Linux (runit)

if [[ $# -lt 2 ]]; then
    echo "Usage: honey-badger-service <enable|disable|status> <service_name>"
    echo "Manages runit services in Void Linux"
    exit 1
fi

ACTION="$1"
SERVICE="$2"

case "$ACTION" in
    enable)
        if [[ -d "/etc/sv/$SERVICE" ]]; then
            sudo ln -sf "/etc/sv/$SERVICE" /var/service/
            echo "✅ Enabled $SERVICE"
        else
            echo "❌ Service $SERVICE not found in /etc/sv/"
        fi
        ;;
    disable)
        if [[ -L "/var/service/$SERVICE" ]]; then
            sudo rm "/var/service/$SERVICE"
            echo "✅ Disabled $SERVICE"
        else
            echo "ℹ️ Service $SERVICE not currently enabled"
        fi
        ;;
    status)
        if [[ -L "/var/service/$SERVICE" ]]; then
            echo "✅ $SERVICE is enabled"
            sudo sv status "$SERVICE"
        else
            echo "❌ $SERVICE is not enabled"
        fi
        ;;
    *)
        echo "❌ Invalid action: $ACTION"
        echo "Use: enable, disable, or status"
        exit 1
        ;;
esac
EOF

    # Make scripts executable
    chmod +x "$HOME/.local/bin/honey-badger-info"
    chmod +x "$HOME/.local/bin/honey-badger-update"
    chmod +x "$HOME/.local/bin/honey-badger-install"
    chmod +x "$HOME/.local/bin/honey-badger-service"
    
    # Add to PATH if not already there
    if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    fi
    
    print_success "Utility scripts created"
}

#######################################
# Main installation function
#######################################
install_honey_badger() {
    case "$INSTALL_TYPE" in
        "$FULL")
            install_essential_packages
            install_development_tools
            install_xfce_desktop
            install_productivity_apps
            configure_nano
            configure_honey_badger_theme
            configure_xfce
            enable_services
            create_utility_scripts
            ;;
        "$DEVELOPER")
            install_essential_packages
            install_development_tools
            install_xfce_desktop  # Basic XFCE
            configure_nano
            configure_honey_badger_theme
            configure_xfce
            enable_services
            create_utility_scripts
            ;;
        "$MINIMAL")
            install_essential_packages
            configure_nano
            enable_services
            create_utility_scripts
            ;;
        "$DESKTOP")
            install_essential_packages
            install_xfce_desktop
            install_productivity_apps
            configure_nano
            configure_honey_badger_theme
            configure_xfce
            enable_services
            create_utility_scripts
            ;;
    esac
}

#######################################
# Show installation summary
#######################################
show_summary() {
    print_colored "${GREEN}" "
🦡 HONEY BADGER OS INSTALLATION COMPLETE! 🦡
============================================="
    
    echo
    print_colored "${YELLOW}" "Installation Type: $(echo "$INSTALL_TYPE" | tr '[:lower:]' '[:upper:]')"
    print_colored "${YELLOW}" "Void Linux Architecture: ${VOID_ARCH}"
    
    case "$INSTALL_TYPE" in
        "$FULL")
            print_colored "${CYAN}" "✅ Complete XFCE desktop environment installed"
            print_colored "${CYAN}" "✅ Full development stack (Python, Node.js, Go, Rust, C/C++, Java)"
            print_colored "${CYAN}" "✅ Productivity applications (LibreOffice, GIMP, VLC)"
            print_colored "${CYAN}" "✅ Enhanced nano editor configured as default"
            print_colored "${CYAN}" "✅ Custom Honey Badger theme applied"
            ;;
        "$DEVELOPER")
            print_colored "${CYAN}" "✅ Development tools and languages installed"
            print_colored "${CYAN}" "✅ Basic XFCE desktop environment"
            print_colored "${CYAN}" "✅ Enhanced nano editor configured as default"
            print_colored "${CYAN}" "✅ Custom Honey Badger theme applied"
            ;;
        "$MINIMAL")
            print_colored "${CYAN}" "✅ Essential system tools installed"
            print_colored "${CYAN}" "✅ Enhanced nano editor configured as default"
            print_colored "${CYAN}" "✅ Command-line environment ready"
            ;;
        "$DESKTOP")
            print_colored "${CYAN}" "✅ Complete XFCE desktop environment installed"
            print_colored "${CYAN}" "✅ Productivity applications installed"
            print_colored "${CYAN}" "✅ Enhanced nano editor configured as default"
            print_colored "${CYAN}" "✅ Custom Honey Badger theme applied"
            ;;
    esac
    
    echo
    print_colored "${YELLOW}" "🔧 Utility Commands:"
    print_colored "${WHITE}" "  honey-badger-info     - Display system information"
    print_colored "${WHITE}" "  honey-badger-update   - Update system and packages"
    print_colored "${WHITE}" "  honey-badger-install  - Install packages via xbps"
    print_colored "${WHITE}" "  honey-badger-service  - Manage runit services"
    
    echo
    print_colored "${YELLOW}" "📝 Default Editor:"
    print_colored "${WHITE}" "  nano is now your default editor with enhanced configuration"
    print_colored "${WHITE}" "  Custom key bindings: Ctrl+S (save), Ctrl+Q (quit)"
    
    if [[ "$INSTALL_TYPE" != "$MINIMAL" ]]; then
        echo
        print_colored "${YELLOW}" "🖥️ Desktop Environment:"
        print_colored "${WHITE}" "  Reboot to start using your new Honey Badger desktop!"
        print_colored "${WHITE}" "  Display manager: LightDM"
        print_colored "${WHITE}" "  Desktop: XFCE4 with Honey Badger theme"
    fi
    
    echo
    print_colored "${YELLOW}" "🔧 Void Linux Specific Notes:"
    print_colored "${WHITE}" "  • Init system: runit (not systemd)"
    print_colored "${WHITE}" "  • Package manager: xbps-install, xbps-query, xbps-remove"
    print_colored "${WHITE}" "  • Services managed via /var/service/ and sv command"
    print_colored "${WHITE}" "  • Container platform: Podman (Docker not available)"
    
    echo
    print_colored "${YELLOW}" "📋 Installation Log:"
    print_colored "${WHITE}" "  Full log available at: ${LOG_FILE}"
    
    echo
    print_colored "${PURPLE}" "🦡 Like the honey badger, your Void Linux system is now fearless and ready!"
    print_colored "${PURPLE}" "🦡 Welcome to the Honey Badger OS family!"
    
    echo
}

#######################################
# Installation type selection
#######################################
select_install_type() {
    print_colored "${YELLOW}" "🛠️  Select Installation Type:"
    echo
    print_colored "${WHITE}" "1) Full Installation (Recommended)"
    print_colored "${CYAN}" "   • Complete XFCE desktop environment"
    print_colored "${CYAN}" "   • All development tools and languages"  
    print_colored "${CYAN}" "   • Full application suite"
    print_colored "${CYAN}" "   • Size: ~3-5GB"
    echo
    print_colored "${WHITE}" "2) Developer Focus"
    print_colored "${CYAN}" "   • Programming languages and development tools"
    print_colored "${CYAN}" "   • Basic desktop environment"
    print_colored "${CYAN}" "   • Podman containers"
    print_colored "${CYAN}" "   • Size: ~2-3GB"
    echo
    print_colored "${WHITE}" "3) Minimal Installation"
    print_colored "${CYAN}" "   • Essential tools only"
    print_colored "${CYAN}" "   • Command-line interface"
    print_colored "${CYAN}" "   • Size: ~500MB-1GB"
    echo
    print_colored "${WHITE}" "4) Desktop Focus"
    print_colored "${CYAN}" "   • Complete desktop environment"
    print_colored "${CYAN}" "   • Productivity applications"
    print_colored "${CYAN}" "   • Basic development tools"
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
# Main function
#######################################
main() {
    # Clear screen and show banner
    clear
    print_banner
    
    # Pre-flight checks
    check_root
    check_void_linux
    
    # Installation type selection
    select_install_type
    
    # Confirmation
    echo
    print_colored "${YELLOW}" "⚠️  Ready to install Honey Badger OS (${INSTALL_TYPE} installation)"
    print_colored "${YELLOW}" "   This will modify your Void Linux system configuration."
    read -p "Do you want to continue? [y/N]: " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_colored "${RED}" "Installation cancelled."
        exit 0
    fi
    
    # Start installation
    print_status "Starting Honey Badger OS installation..."
    print_status "Installation type: $INSTALL_TYPE"
    print_status "Log file: $LOG_FILE"
    
    # Update system first
    update_system
    
    # Run main installation
    install_honey_badger
    
    # Show completion summary
    show_summary
    
    # Final reboot prompt for desktop installations
    if [[ "$INSTALL_TYPE" != "$MINIMAL" ]]; then
        echo
        read -p "Would you like to reboot now to start using your new desktop? [y/N]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_success "Rebooting in 5 seconds... 🦡"
            sleep 5
            sudo reboot
        fi
    fi
}

# Run main function
main "$@"