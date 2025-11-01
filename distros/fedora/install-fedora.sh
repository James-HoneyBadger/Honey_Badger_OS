#!/bin/bash
#
# Honey Badger OS - Fedora/RHEL Post-Install Script
# Transform your Fedora/RHEL installation into a fearless development environment
#
# Author: James-HoneyBadger
# Version: 1.0.0
# Description: Comprehensive post-installation script for Fedora/RHEL systems
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
readonly SCRIPT_NAME="Honey Badger OS - Fedora/RHEL Installer"
readonly VERSION="1.0.0"
readonly REPO_URL="https://github.com/James-HoneyBadger/Honey_Badger_OS"

# Installation types
readonly FULL="full"
readonly DEVELOPER="developer"
readonly MINIMAL="minimal"
readonly DESKTOP="desktop"

# Default installation type
INSTALL_TYPE="${FULL}"

# Detect distribution
if grep -qi "fedora" /etc/os-release; then
    DISTRO="fedora"
    PKG_MGR="dnf"
elif grep -qi "rhel\|red.*hat\|centos" /etc/os-release; then
    DISTRO="rhel"
    PKG_MGR="dnf"
    # Check for older RHEL/CentOS with yum
    if ! command -v dnf &> /dev/null && command -v yum &> /dev/null; then
        PKG_MGR="yum"
    fi
else
    DISTRO="unknown"
    PKG_MGR="dnf"
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
█  🦡 HONEY BADGER OS - FEDORA/RHEL POST-INSTALL SCRIPT 🦡         █
█                                                                  █
█  Fearless • Determined • Uncompromising                          █
█  Transform your Fedora/RHEL into a development powerhouse        █
█                                                                  █
████████████████████████████████████████████████████████████████████
"
    print_colored "${CYAN}" "Version: ${VERSION}"
    print_colored "${CYAN}" "Distribution: ${DISTRO}"
    print_colored "${CYAN}" "Package Manager: ${PKG_MGR}"
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
# Check if running on Fedora/RHEL
#######################################
check_fedora_rhel() {
    if ! command -v "$PKG_MGR" &> /dev/null; then
        print_error "This script is designed for Fedora/RHEL systems"
        print_error "Neither dnf nor yum package manager found"
        exit 1
    fi
    
    print_status "Detected $(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)"
    print_status "Using package manager: ${PKG_MGR}"
}

#######################################
# Configure SELinux
#######################################
configure_selinux() {
    print_status "Checking SELinux configuration..."
    
    if command -v getenforce &> /dev/null; then
        local selinux_status=$(getenforce)
        print_status "SELinux status: $selinux_status"
        
        if [[ "$selinux_status" == "Enforcing" ]]; then
            print_warning "SELinux is enforcing. Some development tools may need additional configuration."
            print_status "Consider learning SELinux or setting to permissive mode for development."
        fi
    fi
    
    # Install SELinux tools for development
    sudo "$PKG_MGR" install -y \
        policycoreutils-python-utils \
        selinux-policy-devel \
        setroubleshoot-server \
    || print_warning "Failed to install some SELinux tools"
    
    print_success "SELinux configuration checked"
}

#######################################
# Enable additional repositories
#######################################
enable_repositories() {
    print_status "Enabling additional repositories..."
    
    if [[ "$DISTRO" == "fedora" ]]; then
        # Enable RPM Fusion repositories
        sudo "$PKG_MGR" install -y \
            "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
            "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm" \
        || print_warning "Failed to install RPM Fusion repositories"
        
        # Enable Flathub
        if command -v flatpak &> /dev/null; then
            flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || print_warning "Failed to add Flathub repository"
        fi
        
    elif [[ "$DISTRO" == "rhel" ]]; then
        # Enable EPEL repository for RHEL/CentOS
        sudo "$PKG_MGR" install -y epel-release || print_warning "Failed to install EPEL repository"
        
        # Enable PowerTools/CRB repository for development packages
        if command -v dnf &> /dev/null; then
            sudo dnf config-manager --enable powertools || sudo dnf config-manager --enable crb || print_warning "Failed to enable PowerTools/CRB repository"
        fi
    fi
    
    print_success "Additional repositories configured"
}

#######################################
# Update system packages
#######################################
update_system() {
    print_status "Updating system packages..."
    
    # Update package cache and system
    sudo "$PKG_MGR" makecache
    sudo "$PKG_MGR" upgrade -y
    
    print_success "System updated successfully"
}

#######################################
# Install essential packages
#######################################
install_essential_packages() {
    print_status "Installing essential packages..."
    
    local essential_packages=(
        # Development tools
        "gcc"
        "gcc-c++"
        "make" 
        "cmake"
        "autoconf"
        "automake"
        "libtool"
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
        "NetworkManager-wifi"
        "wireless-tools"
        "wpa_supplicant"
        
        # Audio
        "pulseaudio"
        "pulseaudio-utils"
        "pavucontrol"
        
        # Fonts
        "dejavu-fonts"
        "liberation-fonts"
        "google-noto-fonts"
        "google-noto-emoji-fonts"
        
        # File system utilities
        "dosfstools"
        "ntfs-3g"
        "exfat-utils"
        
        # System utilities
        "dnf-plugins-core"
        "dnf-utils"
    )
    
    sudo "$PKG_MGR" install -y "${essential_packages[@]}" || print_warning "Some essential packages failed to install"
    
    print_success "Essential packages installed"
}

#######################################
# Install development tools
#######################################
install_development_tools() {
    print_status "Installing development tools..."
    
    # Install development group packages
    sudo "$PKG_MGR" group install -y "Development Tools" "C Development Tools and Libraries" || print_warning "Failed to install development groups"
    
    local dev_packages=(
        # Programming languages
        "python3"
        "python3-pip"
        "python3-devel"
        "nodejs"
        "npm"
        "java-latest-openjdk-devel"
        "ruby"
        "ruby-devel"
        "php"
        "php-cli"
        
        # Version control
        "git"
        "git-lfs"
        
        # Build tools
        "ninja-build"
        "meson"
        
        # Debugging and profiling
        "gdb"
        "valgrind"
        "strace"
        "ltrace"
        
        # Container tools
        "podman"
        "buildah"
        "skopeo"
        
        # Database tools
        "postgresql"
        "mysql"
        "sqlite"
        "redis"
        
        # Network tools
        "nmap"
        "wireshark"
        "curl"
        "wget"
        "httpie"
    )
    
    sudo "$PKG_MGR" install -y "${dev_packages[@]}" || print_warning "Some development packages failed to install"
    
    # Install additional development tools
    install_additional_dev_tools
    
    print_success "Development tools installed"
}

#######################################
# Install additional development tools
#######################################
install_additional_dev_tools() {
    print_status "Installing additional development tools..."
    
    # Install Go
    if ! command -v go &> /dev/null; then
        sudo "$PKG_MGR" install -y golang || print_warning "Failed to install Go via package manager"
        
        # If package manager fails, install manually
        if ! command -v go &> /dev/null; then
            GO_VERSION="1.21.3"
            cd /tmp
            wget "https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz" -O go.tar.gz
            sudo tar -C /usr/local -xzf go.tar.gz
            echo 'export PATH=/usr/local/go/bin:$PATH' >> "$HOME/.bashrc"
            rm go.tar.gz
        fi
    fi
    
    # Install Rust
    if ! command -v rustc &> /dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    fi
    
    # Install VS Code
    if ! command -v code &> /dev/null; then
        print_status "Installing Visual Studio Code..."
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
        sudo "$PKG_MGR" check-update
        sudo "$PKG_MGR" install -y code || print_warning "Failed to install VS Code"
    fi
    
    # Install Docker (Fedora) or Podman setup
    if [[ "$DISTRO" == "fedora" ]]; then
        if ! command -v docker &> /dev/null; then
            sudo "$PKG_MGR" config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
            sudo "$PKG_MGR" install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin || print_warning "Failed to install Docker"
        fi
    fi
    
    # Install GitHub CLI
    if ! command -v gh &> /dev/null; then
        sudo "$PKG_MGR" config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
        sudo "$PKG_MGR" install -y gh || print_warning "Failed to install GitHub CLI"
    fi
    
    print_success "Additional development tools installed"
}

#######################################
# Install XFCE desktop environment
#######################################
install_xfce_desktop() {
    print_status "Installing XFCE desktop environment..."
    
    # Install XFCE group
    sudo "$PKG_MGR" group install -y "Xfce Desktop" || print_warning "Failed to install XFCE group"
    
    local xfce_packages=(
        # Core XFCE components
        "xfce4-panel"
        "xfce4-session"
        "xfce4-settings"
        "xfdesktop"
        "xfwm4"
        "thunar"
        
        # Additional XFCE applications
        "xfce4-terminal"
        "xfce4-appfinder"
        "xfce4-power-manager"
        "xfce4-screensaver"
        "xfce4-taskmanager"
        
        # Display manager
        "lightdm"
        "lightdm-gtk"
        
        # Audio plugins
        "xfce4-pulseaudio-plugin"
        
        # File manager plugins
        "thunar-archive-plugin"
        "thunar-volman"
        
        # Applications
        "firefox"
        "thunderbird"
        "libreoffice"
        "gimp"
        "vlc"
        "file-roller"
        "galculator"
        "ristretto"
        "mousepad"
        "atril"
    )
    
    sudo "$PKG_MGR" install -y "${xfce_packages[@]}" || print_warning "Some XFCE packages failed to install"
    
    # Enable display manager
    sudo systemctl enable lightdm || print_warning "Failed to enable lightdm"
    
    # Set default desktop session
    sudo update-alternatives --install /usr/bin/x-session-manager x-session-manager /usr/bin/xfce4-session 60 || true
    
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
        "bleachbit"
        "stress"
        
        # Archive tools
        "file-roller"
        "unrar"
        "p7zip"
        "p7zip-plugins"
        
        # PDF tools
        "atril"
        "pdftk-java"
    )
    
    sudo "$PKG_MGR" install -y "${productivity_packages[@]}" || print_warning "Some productivity packages failed to install"
    
    # Install Flatpak applications if Flatpak is available
    if command -v flatpak &> /dev/null; then
        print_status "Installing additional applications via Flatpak..."
        flatpak install -y flathub org.mozilla.Thunderbird || print_warning "Failed to install Thunderbird via Flatpak"
        flatpak install -y flathub com.discordapp.Discord || print_warning "Failed to install Discord via Flatpak"
        flatpak install -y flathub com.getpostman.Postman || print_warning "Failed to install Postman via Flatpak"
    fi
    
    print_success "Productivity applications installed"
}

#######################################
# Configure nano editor
#######################################
configure_nano() {
    print_status "Configuring nano editor..."
    
    # Create user nano configuration
    cat > "$HOME/.nanorc" << 'EOF'
# Honey Badger OS - Enhanced nano configuration

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
/* Honey Badger OS GTK3 Theme */

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
    
    # Set theme using gsettings and xfconf-query
    if command -v gsettings &> /dev/null; then
        gsettings set org.gnome.desktop.interface gtk-theme "HoneyBadger" 2>/dev/null || true
    fi
    
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
# Enable essential services
#######################################
enable_services() {
    print_status "Enabling essential services..."
    
    local services=(
        "NetworkManager"
        "bluetooth"
    )
    
    # Add Docker or Podman service depending on what's installed
    if command -v docker &> /dev/null; then
        services+=("docker")
    elif command -v podman &> /dev/null; then
        # Podman doesn't need a service by default, but enable socket if available
        sudo systemctl enable podman.socket 2>/dev/null || true
    fi
    
    for service in "${services[@]}"; do
        if systemctl list-unit-files | grep -q "^${service}.service"; then
            sudo systemctl enable "$service" 2>/dev/null || print_warning "Failed to enable $service"
        fi
    done
    
    # Add user to docker group if docker is installed
    if command -v docker &> /dev/null; then
        sudo usermod -aG docker "$USER" || print_warning "Failed to add user to docker group"
    fi
    
    print_success "Services enabled"
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
# Honey Badger OS system information script

echo "🦡 HONEY BADGER OS SYSTEM INFORMATION"
echo "===================================="
echo
echo "🖥️  System:"
neofetch --config off --ascii_distro fedora_small --colors 3 6 7 4 5 2
echo
echo "📦 Development Tools Installed:"
command -v python3 && python3 --version
command -v node && node --version
command -v npm && npm --version
command -v go && go version
command -v rustc && rustc --version
command -v gcc && gcc --version | head -n1
command -v git && git --version
command -v docker && docker --version
command -v podman && podman --version
echo
echo "📝 Default Editor: $EDITOR"
echo "🎨 Current Theme: $(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null || echo 'Not in desktop session')"
echo
echo "🔒 SELinux Status: $(getenforce 2>/dev/null || echo 'Not available')"
echo
echo "🦡 Fearless • Determined • Uncompromising"
EOF

    # System update script  
    cat > "$HOME/.local/bin/honey-badger-update" << 'EOF'
#!/bin/bash
# Honey Badger OS system update script

echo "🦡 HONEY BADGER OS SYSTEM UPDATE"
echo "==============================="
echo

# Detect package manager
PKG_MGR="dnf"
if ! command -v dnf &> /dev/null && command -v yum &> /dev/null; then
    PKG_MGR="yum"
fi

echo "📦 Updating system packages..."
sudo "$PKG_MGR" makecache
sudo "$PKG_MGR" upgrade -y

echo
echo "📦 Updating Flatpak applications..."
if command -v flatpak &> /dev/null; then
    flatpak update -y
else
    echo "Flatpak not installed, skipping..."
fi

echo
echo "🧹 Cleaning package cache..."
sudo "$PKG_MGR" autoremove -y
sudo "$PKG_MGR" clean all

echo
echo "✅ System update completed!"
echo "🦡 Your Honey Badger system is up to date!"
EOF

    # Make scripts executable
    chmod +x "$HOME/.local/bin/honey-badger-info"
    chmod +x "$HOME/.local/bin/honey-badger-update"
    
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
            enable_repositories
            install_essential_packages
            install_development_tools
            install_xfce_desktop
            install_productivity_apps
            configure_nano
            configure_honey_badger_theme
            configure_xfce
            configure_selinux
            enable_services
            create_utility_scripts
            ;;
        "$DEVELOPER")
            enable_repositories
            install_essential_packages
            install_development_tools
            install_xfce_desktop  # Basic XFCE
            configure_nano
            configure_honey_badger_theme
            configure_xfce
            configure_selinux
            enable_services
            create_utility_scripts
            ;;
        "$MINIMAL")
            install_essential_packages
            configure_nano
            configure_selinux
            enable_services
            create_utility_scripts
            ;;
        "$DESKTOP")
            enable_repositories
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
    print_colored "${YELLOW}" "Distribution: $(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)"
    
    case "$INSTALL_TYPE" in
        "$FULL")
            print_colored "${CYAN}" "✅ Complete XFCE desktop environment installed"
            print_colored "${CYAN}" "✅ Full development stack (Python, Node.js, Go, Rust, C/C++, Java)"
            print_colored "${CYAN}" "✅ Productivity applications (LibreOffice, GIMP, VLC)"
            print_colored "${CYAN}" "✅ Enhanced nano editor configured as default"
            print_colored "${CYAN}" "✅ Custom Honey Badger theme applied"
            print_colored "${CYAN}" "✅ SELinux configuration checked"
            ;;
        "$DEVELOPER")
            print_colored "${CYAN}" "✅ Development tools and languages installed"
            print_colored "${CYAN}" "✅ Basic XFCE desktop environment"
            print_colored "${CYAN}" "✅ Enhanced nano editor configured as default"
            print_colored "${CYAN}" "✅ Custom Honey Badger theme applied"
            print_colored "${CYAN}" "✅ SELinux configuration checked"
            ;;
        "$MINIMAL")
            print_colored "${CYAN}" "✅ Essential system tools installed"
            print_colored "${CYAN}" "✅ Enhanced nano editor configured as default"
            print_colored "${CYAN}" "✅ Command-line environment ready"
            print_colored "${CYAN}" "✅ SELinux configuration checked"
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
    print_colored "${YELLOW}" "🔒 SELinux Notes:"
    print_colored "${WHITE}" "  SELinux status: $(getenforce 2>/dev/null || echo 'Not available')"
    print_colored "${WHITE}" "  Development with SELinux enforcing may require additional configuration"
    
    echo
    print_colored "${YELLOW}" "📋 Installation Log:"
    print_colored "${WHITE}" "  Full log available at: ${LOG_FILE}"
    
    echo
    print_colored "${PURPLE}" "🦡 Like the honey badger, your system is now fearless and ready for anything!"
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
    print_colored "${CYAN}" "   • SELinux development tools"
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
    check_fedora_rhel
    
    # Installation type selection
    select_install_type
    
    # Confirmation
    echo
    print_colored "${YELLOW}" "⚠️  Ready to install Honey Badger OS (${INSTALL_TYPE} installation)"
    print_colored "${YELLOW}" "   This will modify your system and install packages."
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