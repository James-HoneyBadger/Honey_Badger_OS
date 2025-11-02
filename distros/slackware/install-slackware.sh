#!/bin/bash
#
# Honey Badger OS - Slackware Post-Install Script
# Transform your Slackware installation into a fearless development environment
#
# Author: James-HoneyBadger
# Version: 1.0.0
# Description: Comprehensive post-installation script for Slackware systems
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
readonly SCRIPT_NAME="Honey Badger OS - Slackware Installer"
readonly VERSION="1.0.0"
readonly REPO_URL="https://github.com/James-HoneyBadger/Honey_Badger_OS"

# Installation types
readonly FULL="full"
readonly DEVELOPER="developer"
readonly MINIMAL="minimal"
readonly DESKTOP="desktop"

# Default installation type
INSTALL_TYPE="${FULL}"

# Non-interactive and unattended flags from environment
if [[ ! -t 0 ]]; then
    NONINTERACTIVE=true
else
    NONINTERACTIVE=false
fi
AUTO_CONFIRM="${HONEY_BADGER_AUTO_CONFIRM:-0}"
DRY_RUN_ENV="${HONEY_BADGER_DRY_RUN:-0}"

# Allow pre-setting installation type via environment
if [[ -n "${HONEY_BADGER_INSTALL_TYPE:-}" ]]; then
    INSTALL_TYPE="$(echo "$HONEY_BADGER_INSTALL_TYPE" | tr '[:upper:]' '[:lower:]')"
fi

# Slackware version detection
SLACK_VERSION=$(grep VERSION /etc/slackware-version 2>/dev/null | cut -d' ' -f2 || echo "15.0")

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
█  🦡 HONEY BADGER OS - SLACKWARE POST-INSTALL SCRIPT 🦡           █
█                                                                  █
█  Fearless • Determined • Uncompromising                          █
█  Transform your Slackware into a development powerhouse          █
█                                                                  █
████████████████████████████████████████████████████████████████████
"
    print_colored "${CYAN}" "Version: ${VERSION}"
    print_colored "${CYAN}" "Slackware Version: ${SLACK_VERSION}"
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
# Check if running on Slackware
#######################################
check_slackware() {
    if [[ ! -f /etc/slackware-version ]]; then
        print_warning "This doesn't appear to be a Slackware system (/etc/slackware-version not found)"
        if [[ "$DRY_RUN_ENV" == "1" ]]; then
            print_status "[dry-run] Would prompt to continue; proceeding in dry-run."
        elif [[ "$NONINTERACTIVE" == "true" ]]; then
            if [[ "$AUTO_CONFIRM" == "1" ]]; then
                print_status "Non-interactive auto-confirm enabled; continuing."
            else
                print_error "Non-interactive and not auto-confirmed. Aborting. Set HONEY_BADGER_AUTO_CONFIRM=1 to proceed."
                exit 1
            fi
        else
            read -p "Do you want to continue anyway? [y/N]: " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi
    else
        print_status "Detected Slackware $(cat /etc/slackware-version)"
    fi
}

#######################################
# Setup SlackBuilds.org repository
#######################################
setup_slackbuilds() {
    print_status "Setting up SlackBuilds.org repository..."
    if [[ "$DRY_RUN_ENV" == "1" ]]; then
        print_status "[dry-run] Would install sbopkg and sync SlackBuilds repository"
        return 0
    fi
    
    # Install sbopkg if not present
    if ! command -v sbopkg &> /dev/null; then
        local sbopkg_url="https://github.com/sbopkg/sbopkg/releases/download/0.38.2/sbopkg-0.38.2-noarch-1_wsr.tgz"
        cd /tmp
        wget "$sbopkg_url" -O sbopkg.tgz
        su - -c "installpkg sbopkg.tgz" || print_warning "Failed to install sbopkg"
        rm -f sbopkg.tgz
    fi
    
    # Sync SlackBuilds repository
    if command -v sbopkg &> /dev/null; then
        su - -c "sbopkg -r" || print_warning "Failed to sync SlackBuilds repository"
    fi
    
    print_success "SlackBuilds.org repository configured"
}

#######################################
# Update system packages
#######################################
update_system() {
    print_status "Updating system packages..."
    if [[ "$DRY_RUN_ENV" == "1" ]]; then
        print_status "[dry-run] Would run: slackpkg update && slackpkg upgrade-all"
        return 0
    fi
    
    # Update package database if slackpkg is configured
    if command -v slackpkg &> /dev/null && [[ -f /etc/slackpkg/mirrors ]]; then
        su - -c "slackpkg update" || print_warning "Failed to update package database"
        su - -c "slackpkg upgrade-all" || print_warning "Failed to upgrade packages"
    else
        print_warning "slackpkg not configured, skipping system updates"
        print_warning "Please configure slackpkg manually for package management"
    fi
    
    print_success "System update completed"
}

#######################################
# Install essential packages
#######################################
install_essential_packages() {
    print_status "Installing essential packages..."
    if [[ "$DRY_RUN_ENV" == "1" ]]; then
        print_status "[dry-run] Would check/install essential packages via slackpkg"
        return 0
    fi
    
    local essential_packages=(
        # Development tools (usually included in Slackware full install)
        "git"
        "curl"
        "wget"
        "nano"
        "vim"
        
        # Network tools
        "NetworkManager"
        "wireless-tools"
        "wpa_supplicant"
    )
    
    # Most essential packages are included in full Slackware install
    # Check for missing packages and install via slackpkg if available
    for package in "${essential_packages[@]}"; do
        if ! ls /var/log/packages/"$package"-* &>/dev/null; then
            if command -v slackpkg &> /dev/null; then
                su - -c "slackpkg install $package" || print_warning "Failed to install $package"
            else
                print_warning "$package not found and slackpkg not available"
            fi
        fi
    done
    
    print_success "Essential packages checked"
}

#######################################
# Install development tools via SlackBuilds
#######################################
install_development_tools() {
    print_status "Installing development tools..."
    if [[ "$DRY_RUN_ENV" == "1" ]]; then
        print_status "[dry-run] Would attempt to install development tools via sbopkg/SlackBuilds"
        print_status "[dry-run] Would also call install_manual_dev_tools for languages"
        return 0
    fi
    
    # Programming languages and tools available via SlackBuilds
    local slackbuild_packages=(
        "nodejs"
        "go" 
        "rust"
        "python3"
        "python-pip"
        "docker"
        "docker-compose"
        "code"  # VS Code
        "github-cli"
    )
    
    # Install packages via sbopkg/SlackBuilds if available
    for package in "${slackbuild_packages[@]}"; do
        print_status "Attempting to install $package via SlackBuilds..."
        if command -v sbopkg &> /dev/null; then
            # Use sbopkg to build and install
            su - -c "sbopkg -B -i $package" || print_warning "Failed to install $package via SlackBuilds"
        else
            print_warning "sbopkg not available, cannot install $package"
        fi
    done
    
    # Install additional tools manually
    install_manual_dev_tools
    
    print_success "Development tools installation attempted"
}

#######################################
# Install development tools manually
#######################################
install_manual_dev_tools() {
    print_status "Installing additional development tools manually..."
    if [[ "$DRY_RUN_ENV" == "1" ]]; then
        print_status "[dry-run] Would download and install Go, Rust, Node.js where missing"
        return 0
    fi
    
    # Install Go if not available
    if ! command -v go &> /dev/null; then
        print_status "Installing Go..."
        GO_VERSION="1.21.3"
        cd /tmp
        wget "https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz" -O go.tar.gz
        su - -c "tar -C /usr/local -xzf /tmp/go.tar.gz"
        echo 'export PATH=/usr/local/go/bin:$PATH' >> "$HOME/.bashrc"
        rm -f go.tar.gz
    fi
    
    # Install Rust if not available  
    if ! command -v rustc &> /dev/null; then
        print_status "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    fi
    
    # Install Node.js via NodeSource if not available
    if ! command -v node &> /dev/null; then
        print_status "Installing Node.js..."
        curl -fsSL https://deb.nodesource.com/setup_lts.x > /tmp/node_setup.sh
        chmod +x /tmp/node_setup.sh
        su - -c "bash /tmp/node_setup.sh"
        rm -f /tmp/node_setup.sh
    fi
    
    print_success "Manual development tools installation completed"
}

#######################################
# Install XFCE desktop environment
#######################################
install_xfce_desktop() {
    print_status "Configuring XFCE desktop environment..."
    if [[ "$DRY_RUN_ENV" == "1" ]]; then
        print_status "[dry-run] Would check/install XFCE via slackpkg and write ~/.xinitrc"
        return 0
    fi
    
    # XFCE is usually included in Slackware full install
    # Check if XFCE packages are installed
    local xfce_packages=(
        "xfce"
        "xfce4-*"
    )
    
    local xfce_found=false
    if ls /var/log/packages/xfce* &>/dev/null; then
        xfce_found=true
        print_success "XFCE desktop environment already installed"
    fi
    
    if [[ "$xfce_found" == "false" ]]; then
        print_warning "XFCE not found. Please install XFCE desktop environment:"
        print_warning "Run as root: slackpkg install xfce"
        return
    fi
    
    # Configure XFCE as default desktop
    if [[ ! -f "$HOME/.xinitrc" ]]; then
        echo "exec startxfce4" > "$HOME/.xinitrc"
        chmod +x "$HOME/.xinitrc"
    fi
    
    # Install additional applications if available
    local extra_apps=(
        "firefox"
        "thunderbird" 
        "libreoffice"
        "gimp"
        "vlc"
    )
    
    for app in "${extra_apps[@]}"; do
        if ! ls /var/log/packages/"$app"* &>/dev/null; then
            if command -v slackpkg &> /dev/null; then
                su - -c "slackpkg install $app" || print_warning "Failed to install $app"
            fi
        fi
    done
    
    print_success "XFCE desktop environment configured"
}

#######################################
# Configure nano editor
#######################################
configure_nano() {
    print_status "Configuring nano editor..."
    if [[ "$DRY_RUN_ENV" == "1" ]]; then
        print_status "[dry-run] Would write ~/.nanorc, backups dir, and set editor defaults"
        return 0
    fi
    
    # Create user nano configuration
    cat > "$HOME/.nanorc" << 'EOF'
# Honey Badger OS - Enhanced nano configuration for Slackware

# Enable syntax highlighting (Slackware includes nano syntax files)
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

    # Set nano as default editor in shell profiles
    for profile in "$HOME/.bashrc" "$HOME/.profile"; do
        if [[ -f "$profile" ]] && ! grep -q "EDITOR=nano" "$profile" 2>/dev/null; then
            echo 'export EDITOR=nano' >> "$profile"
            echo 'export VISUAL=nano' >> "$profile"
        fi
    done

    # Set as default for git
    git config --global core.editor nano 2>/dev/null || true

    print_success "nano editor configured"
}

#######################################
# Install and configure Honey Badger theme
#######################################
configure_honey_badger_theme() {
    print_status "Installing Honey Badger theme..."
    if [[ "$DRY_RUN_ENV" == "1" ]]; then
        print_status "[dry-run] Would create theme directories and GTK settings"
        return 0
    fi
    
    # Create theme directories
    mkdir -p "$HOME/.themes/HoneyBadger/gtk-3.0"
    mkdir -p "$HOME/.local/share/honey-badger"
    mkdir -p "$HOME/.config/gtk-3.0"
    mkdir -p "$HOME/.config/xfce4"
    
    # Create GTK theme (same as other distributions)
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

    # Create GTK3 theme CSS
    cat > "$HOME/.themes/HoneyBadger/gtk-3.0/gtk.css" << 'EOF'
/* Honey Badger OS GTK3 Theme for Slackware */

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
    if [[ "$DRY_RUN_ENV" == "1" ]]; then
        print_status "[dry-run] Would create XFCE per-channel XML config with Honey Badger theme"
        return 0
    fi
    
    # XFCE configuration for Slackware
    # Note: These commands may need X11 running to work properly
    
    # Create XFCE configuration files
    mkdir -p "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml"
    
    # Set theme via configuration files (works without X11)
    cat > "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="HoneyBadger"/>
    <property name="IconThemeName" type="string" value="Adwaita"/>
    <property name="DoubleClickTime" type="int" value="400"/>
    <property name="DoubleClickDistance" type="int" value="5"/>
    <property name="DndDragThreshold" type="int" value="8"/>
    <property name="CursorBlink" type="bool" value="true"/>
    <property name="CursorBlinkTime" type="int" value="1200"/>
    <property name="SoundThemeName" type="string" value="default"/>
    <property name="EnableEventSounds" type="bool" value="true"/>
    <property name="EnableInputFeedbackSounds" type="bool" value="true"/>
  </property>
  <property name="Xft" type="empty">
    <property name="DPI" type="int" value="-1"/>
    <property name="Antialias" type="int" value="1"/>
    <property name="Hinting" type="int" value="1"/>
    <property name="HintStyle" type="string" value="hintfull"/>
    <property name="RGBA" type="string" value="rgb"/>
  </property>
</channel>
EOF
    
    print_success "XFCE desktop configured"
}

#######################################
# Enable essential services
#######################################
enable_services() {
    print_status "Configuring essential services..."
    if [[ "$DRY_RUN_ENV" == "1" ]]; then
        print_status "[dry-run] Would enable rc.networkmanager, rc.docker, and add user to docker group if present"
        return 0
    fi
    
    # Slackware uses traditional init system
    # Configure services via /etc/rc.d/ scripts
    
    # Enable NetworkManager if available
    if [[ -f /etc/rc.d/rc.networkmanager ]]; then
        su - -c "chmod +x /etc/rc.d/rc.networkmanager"
    fi
    
    # Enable Docker if installed
    if [[ -f /etc/rc.d/rc.docker ]]; then
        su - -c "chmod +x /etc/rc.d/rc.docker"
        # Add user to docker group
        su - -c "groupadd -g 281 docker" 2>/dev/null || true
        su - -c "usermod -aG docker $USER" 2>/dev/null || true
    fi
    
    print_success "Services configured"
}

#######################################
# Create utility scripts
#######################################
create_utility_scripts() {
    print_status "Creating Honey Badger utility scripts..."
    if [[ "$DRY_RUN_ENV" == "1" ]]; then
        print_status "[dry-run] Would create honey-badger-* utilities and update PATH in profiles"
        return 0
    fi
    
    mkdir -p "$HOME/.local/bin"
    
    # System info script
    cat > "$HOME/.local/bin/honey-badger-info" << 'EOF'
#!/bin/bash
# Honey Badger OS system information script for Slackware

echo "🦡 HONEY BADGER OS SYSTEM INFORMATION"
echo "===================================="
echo
echo "🖥️  System:"
echo "OS: $(cat /etc/slackware-version)"
echo "Kernel: $(uname -r)"
echo "Architecture: $(uname -m)"
echo "Hostname: $(hostname)"
echo
echo "📦 Development Tools Installed:"
command -v python3 && python3 --version
command -v python && python --version
command -v node && node --version
command -v npm && npm --version  
command -v go && go version
command -v rustc && rustc --version
command -v gcc && gcc --version | head -n1
command -v git && git --version
command -v docker && docker --version
echo
echo "📝 Default Editor: $EDITOR"
echo
echo "🦡 Fearless • Determined • Uncompromising"
EOF

    # System update script  
    cat > "$HOME/.local/bin/honey-badger-update" << 'EOF'
#!/bin/bash
# Honey Badger OS system update script for Slackware

echo "🦡 HONEY BADGER OS SYSTEM UPDATE"
echo "==============================="
echo

if command -v slackpkg &> /dev/null && [[ -f /etc/slackpkg/mirrors ]]; then
    echo "📦 Updating Slackware packages..."
    su - -c "slackpkg update"
    su - -c "slackpkg upgrade-all"
else
    echo "⚠️  slackpkg not configured"
    echo "Please configure slackpkg manually:"
    echo "1. Edit /etc/slackpkg/mirrors"
    echo "2. Uncomment a mirror close to you"
    echo "3. Run: slackpkg update"
fi

if command -v sbopkg &> /dev/null; then
    echo
    echo "📦 Updating SlackBuilds repository..."
    su - -c "sbopkg -r"
fi

echo
echo "✅ System update completed!"
echo "🦡 Your Honey Badger system is up to date!"
EOF

    # Package management helper
    cat > "$HOME/.local/bin/honey-badger-install" << 'EOF'
#!/bin/bash
# Honey Badger OS package installation helper for Slackware

if [[ $# -eq 0 ]]; then
    echo "Usage: honey-badger-install <package_name>"
    echo "This script attempts to install packages via slackpkg or sbopkg"
    exit 1
fi

PACKAGE="$1"

echo "🦡 Installing package: $PACKAGE"

# Try slackpkg first
if command -v slackpkg &> /dev/null && [[ -f /etc/slackpkg/mirrors ]]; then
    echo "Trying slackpkg..."
    if su - -c "slackpkg install $PACKAGE"; then
        echo "✅ Successfully installed $PACKAGE via slackpkg"
        exit 0
    fi
fi

# Try sbopkg/SlackBuilds
if command -v sbopkg &> /dev/null; then
    echo "Trying SlackBuilds..."
    if su - -c "sbopkg -B -i $PACKAGE"; then
        echo "✅ Successfully installed $PACKAGE via SlackBuilds"
        exit 0
    fi
fi

echo "❌ Failed to install $PACKAGE"
echo "Please install manually or check package name"
exit 1
EOF

    # Make scripts executable
    chmod +x "$HOME/.local/bin/honey-badger-info"
    chmod +x "$HOME/.local/bin/honey-badger-update"
    chmod +x "$HOME/.local/bin/honey-badger-install"
    
    # Add to PATH if not already there
    for profile in "$HOME/.bashrc" "$HOME/.profile"; do
        if [[ -f "$profile" ]] && ! grep -q "$HOME/.local/bin" "$profile"; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$profile"
        fi
    done
    
    print_success "Utility scripts created"
}

#######################################
# Main installation function
#######################################
install_honey_badger() {
    case "$INSTALL_TYPE" in
        "$FULL")
            setup_slackbuilds
            install_essential_packages
            install_development_tools
            install_xfce_desktop
            configure_nano
            configure_honey_badger_theme
            configure_xfce
            enable_services
            create_utility_scripts
            ;;
        "$DEVELOPER")
            setup_slackbuilds
            install_essential_packages
            install_development_tools
            configure_nano
            configure_honey_badger_theme
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
            setup_slackbuilds
            install_essential_packages
            install_xfce_desktop
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
    print_colored "${YELLOW}" "Slackware Version: ${SLACK_VERSION}"
    
    case "$INSTALL_TYPE" in
        "$FULL")
            print_colored "${CYAN}" "✅ XFCE desktop environment configured"
            print_colored "${CYAN}" "✅ Development tools installation attempted"
            print_colored "${CYAN}" "✅ SlackBuilds.org repository configured"
            print_colored "${CYAN}" "✅ Enhanced nano editor configured as default"
            print_colored "${CYAN}" "✅ Custom Honey Badger theme applied"
            ;;
        "$DEVELOPER")
            print_colored "${CYAN}" "✅ Development tools installation attempted"
            print_colored "${CYAN}" "✅ SlackBuilds.org repository configured"
            print_colored "${CYAN}" "✅ Enhanced nano editor configured as default"
            print_colored "${CYAN}" "✅ Custom Honey Badger theme applied"
            ;;
        "$MINIMAL")
            print_colored "${CYAN}" "✅ Essential system tools configured"
            print_colored "${CYAN}" "✅ Enhanced nano editor configured as default"
            print_colored "${CYAN}" "✅ Command-line environment ready"
            ;;
        "$DESKTOP")
            print_colored "${CYAN}" "✅ XFCE desktop environment configured"
            print_colored "${CYAN}" "✅ Enhanced nano editor configured as default"
            print_colored "${CYAN}" "✅ Custom Honey Badger theme applied"
            ;;
    esac
    
    echo
    print_colored "${YELLOW}" "🔧 Utility Commands:"
    print_colored "${WHITE}" "  honey-badger-info     - Display system information"
    print_colored "${WHITE}" "  honey-badger-update   - Update system packages"
    print_colored "${WHITE}" "  honey-badger-install  - Install packages via slackpkg/sbopkg"
    
    echo
    print_colored "${YELLOW}" "📝 Default Editor:"
    print_colored "${WHITE}" "  nano is now your default editor with enhanced configuration"
    print_colored "${WHITE}" "  Custom key bindings: Ctrl+S (save), Ctrl+Q (quit)"
    
    if [[ "$INSTALL_TYPE" != "$MINIMAL" ]]; then
        echo
        print_colored "${YELLOW}" "🖥️ Desktop Environment:"
        print_colored "${WHITE}" "  Start XFCE with: startx (if not using display manager)"
        print_colored "${WHITE}" "  Or reboot if using graphical login"
        print_colored "${WHITE}" "  Desktop: XFCE4 with Honey Badger theme"
    fi
    
    echo
    print_colored "${YELLOW}" "⚙️  Slackware Specific Notes:"
    print_colored "${WHITE}" "  • Configure slackpkg mirrors: /etc/slackpkg/mirrors"
    print_colored "${WHITE}" "  • Use sbopkg for additional packages from SlackBuilds.org"
    print_colored "${WHITE}" "  • Some development tools may need manual compilation"
    
    echo
    print_colored "${YELLOW}" "📋 Installation Log:"
    print_colored "${WHITE}" "  Full log available at: ${LOG_FILE}"
    
    echo
    print_colored "${PURPLE}" "🦡 Like the honey badger, your Slackware system is now fearless and ready!"
    print_colored "${PURPLE}" "🦡 Welcome to the Honey Badger OS family!"
    
    echo
}

#######################################
# Installation type selection
#######################################
select_install_type() {
    # Non-interactive selection via env
    case "$INSTALL_TYPE" in
        "$FULL"|"$DEVELOPER"|"$MINIMAL"|"$DESKTOP")
            if [[ -n "${HONEY_BADGER_INSTALL_TYPE:-}" ]]; then
                print_success "Selected (pre-set): $(echo "$INSTALL_TYPE" | tr '[:lower:]' '[:upper:]') installation"
                return
            fi
            ;;
        *) : ;;
    esac

    if [[ "$NONINTERACTIVE" == "true" ]]; then
        if [[ "$AUTO_CONFIRM" == "1" ]]; then
            INSTALL_TYPE="${INSTALL_TYPE:-$FULL}"
            case "$INSTALL_TYPE" in
                "$FULL"|"$DEVELOPER"|"$MINIMAL"|"$DESKTOP") : ;;
                *) INSTALL_TYPE="$FULL" ;;
            esac
            print_status "Non-interactive: selected $(echo "$INSTALL_TYPE" | tr '[:lower:]' '[:upper:]') installation"
            return
        else
            print_error "Non-interactive session without auto-confirm; cannot show selection menu."
            print_colored "${WHITE}" "Set HONEY_BADGER_AUTO_CONFIRM=1 and optionally HONEY_BADGER_INSTALL_TYPE."
            exit 1
        fi
    fi

    print_colored "${YELLOW}" "🛠️  Select Installation Type:"
    echo
    print_colored "${WHITE}" "1) Full Installation (Recommended)"
    print_colored "${CYAN}" "   • XFCE desktop environment configuration"
    print_colored "${CYAN}" "   • Development tools via SlackBuilds"  
    print_colored "${CYAN}" "   • Additional applications"
    print_colored "${CYAN}" "   • Note: May require manual compilation"
    echo
    print_colored "${WHITE}" "2) Developer Focus"
    print_colored "${CYAN}" "   • Programming languages and development tools"
    print_colored "${CYAN}" "   • SlackBuilds repository setup"
    print_colored "${CYAN}" "   • Command-line focused"
    echo
    print_colored "${WHITE}" "3) Minimal Installation"
    print_colored "${CYAN}" "   • Essential configuration only"
    print_colored "${CYAN}" "   • Enhanced nano setup"
    print_colored "${CYAN}" "   • Command-line interface"
    echo
    print_colored "${WHITE}" "4) Desktop Focus"
    print_colored "${CYAN}" "   • XFCE desktop environment"
    print_colored "${CYAN}" "   • Basic productivity setup"
    print_colored "${CYAN}" "   • Minimal development tools"
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
    check_slackware
    
    # Installation type selection
    select_install_type
    
    # Confirmation
    echo
    print_colored "${YELLOW}" "⚠️  Ready to install Honey Badger OS (${INSTALL_TYPE} installation)"
    print_colored "${YELLOW}" "   This will modify your Slackware system configuration."
    print_colored "${YELLOW}" "   Some operations may require root privileges."
    if [[ "$DRY_RUN_ENV" == "1" ]]; then
        print_status "[dry-run] Would prompt to continue; auto-continue in dry-run."
    elif [[ "$NONINTERACTIVE" == "true" ]]; then
        if [[ "$AUTO_CONFIRM" == "1" ]]; then
            print_status "Non-interactive: auto-confirm enabled, proceeding."
        else
            print_error "Non-interactive and not auto-confirmed. Aborting. Set HONEY_BADGER_AUTO_CONFIRM=1 to proceed."
            exit 1
        fi
    else
        read -p "Do you want to continue? [y/N]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_colored "${RED}" "Installation cancelled."
            exit 0
        fi
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
    
    # Final reboot/startx prompt for desktop installations
    if [[ "$INSTALL_TYPE" != "$MINIMAL" ]]; then
        echo
        if [[ "$DRY_RUN_ENV" == "1" ]]; then
            print_status "[dry-run] Would prompt to start desktop (startx); skipping in dry-run."
        elif [[ "$NONINTERACTIVE" == "true" ]]; then
            if [[ "$AUTO_CONFIRM" == "1" ]]; then
                print_colored "${YELLOW}" "Non-interactive unattended: not starting X automatically. Please run 'startx' manually."
            else
                print_colored "${YELLOW}" "Non-interactive session: skipping desktop start prompt."
            fi
        else
            read -p "Would you like to start the desktop environment now? [y/N]: " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                print_success "Starting desktop environment... 🦡"
                startx
            fi
        fi
    fi
}

# Run main function
main "$@"