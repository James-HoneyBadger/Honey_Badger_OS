#!/bin/bash
#
# Honey Badger OS - Arch Linux Post-Install Script
# Transform your Arch installation into a fearless development environment
#
# Author: James-HoneyBadger
# Version: 1.0.0
# Description: Comprehensive post-installation script for Arch Linux
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
readonly SCRIPT_NAME="Honey Badger OS - Arch Linux Installer"
readonly VERSION="1.0.0"
readonly REPO_URL="https://github.com/James-HoneyBadger/Honey_Badger_OS"

# Installation types
readonly FULL="full"
readonly DEVELOPER="developer"
readonly MINIMAL="minimal"
readonly DESKTOP="desktop"

# Default installation type
INSTALL_TYPE="${FULL}"

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
█  🦡 HONEY BADGER OS - ARCH LINUX POST-INSTALL SCRIPT 🦡          █
█                                                                  █
█  Fearless • Determined • Uncompromising                          █
█  Transform your Arch installation into a development powerhouse  █
█                                                                  █
████████████████████████████████████████████████████████████████████
"
    print_colored "${CYAN}" "Version: ${VERSION}"
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
# Check if running on Arch Linux
#######################################
check_arch_linux() {
    if ! command -v pacman &> /dev/null; then
        print_error "This script is designed for Arch Linux systems"
        print_error "pacman package manager not found"
        exit 1
    fi
    
    if ! grep -qi "arch" /etc/os-release; then
        print_warning "This doesn't appear to be an Arch Linux system"
        read -p "Do you want to continue anyway? [y/N]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

#######################################
# Update system packages
#######################################
update_system() {
    print_status "Updating system packages..."
    
    sudo pacman -Sy --noconfirm
    
    # Update keyring first if needed
    if pacman -Qu | grep -q archlinux-keyring; then
        print_status "Updating archlinux-keyring..."
        sudo pacman -S --noconfirm archlinux-keyring
    fi
    
    # Full system upgrade
    sudo pacman -Syu --noconfirm
    
    print_success "System updated successfully"
}

#######################################
# Install essential packages
#######################################
install_essential_packages() {
    print_status "Installing essential packages..."
    
    local essential_packages=(
        # Base system utilities
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
        "networkmanager"
        "networkmanager-applet"
        "wireless_tools"
        "wpa_supplicant"
        
        # Audio
        "pulseaudio"
        "pulseaudio-alsa"
        "pavucontrol"
        
        # Fonts
        "ttf-dejavu"
        "ttf-liberation"
        "noto-fonts"
        "noto-fonts-emoji"
        
        # File system utilities
        "dosfstools"
        "ntfs-3g"
        "exfat-utils"
    )
    
    for package in "${essential_packages[@]}"; do
        if ! pacman -Q "$package" &>/dev/null; then
            print_status "Installing $package..."
            sudo pacman -S --noconfirm "$package" || print_warning "Failed to install $package"
        fi
    done
    
    print_success "Essential packages installed"
}

#######################################
# Install AUR helper (yay)
#######################################
install_aur_helper() {
    if command -v yay &> /dev/null; then
        print_success "yay AUR helper already installed"
        # Test yay functionality
        print_status "Testing yay functionality..."
        if yay --version &> /dev/null; then
            print_success "yay is working correctly"
        else
            print_warning "yay exists but may have issues"
        fi
        return
    fi
    
    print_status "Installing yay AUR helper..."
    
    local temp_dir="/tmp/yay-install"
    rm -rf "$temp_dir"
    mkdir -p "$temp_dir"
    cd "$temp_dir"
    
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    
    cd - > /dev/null
    rm -rf "$temp_dir"
    
    print_success "yay AUR helper installed"
}

#######################################
# Install development tools
#######################################
install_development_tools() {
    print_status "Installing development tools..."
    
    local dev_packages=(
        # Programming languages
        "python"
        "python-pip"
        "nodejs"
        "npm"
        "go"
        "rust"
        "gcc"
        "clang"
        "jdk-openjdk"
        "ruby"
        "php"
        
        # Version control
        "git"
        "github-cli"
        "git-lfs"
        
        # Editors and IDEs
        "neovim"
        "visual-studio-code-bin"  # VSCode from AUR via yay
        
        # Build tools
        "make"
        "cmake"
        "autoconf"
        "automake"
        "ninja"
        "meson"
        
        # Debugging and profiling
        "gdb"
        "valgrind"
        "strace"
        "ltrace"
        
        # Container tools
        "docker"
        "docker-compose"
        
        # Database tools
        "postgresql"
        "mysql"
        "sqlite"
        "redis"
        
        # Network tools
        "nmap"
        "wireshark-qt"
        "curl"
        "wget"
        "httpie"
    )
    
    # Install packages from official repos first
    local official_packages=()
    local aur_packages=()
    
    for package in "${dev_packages[@]}"; do
        if pacman -Si "$package" &>/dev/null; then
            official_packages+=("$package")
        else
            aur_packages+=("$package")
        fi
    done
    
    # Install official packages
    if [[ ${#official_packages[@]} -gt 0 ]]; then
        print_status "Installing development packages from official repos..."
        sudo pacman -S --noconfirm "${official_packages[@]}" || print_warning "Some official packages failed to install"
    fi
    
    # Install AUR packages
    if [[ ${#aur_packages[@]} -gt 0 ]]; then
        print_status "Installing development packages from AUR..."
        print_status "AUR packages to install: ${aur_packages[*]}"
        
        # Install packages individually to avoid dependency loops
        for package in "${aur_packages[@]}"; do
            print_status "Installing AUR package: $package"
            if ! yay -S --noconfirm --needed "$package"; then
                print_warning "Failed to install AUR package: $package"
                print_warning "Continuing with remaining packages..."
            fi
        done
    fi
    
    print_success "Development tools installed"
}

#######################################
# Install XFCE desktop environment
#######################################
install_xfce_desktop() {
    print_status "Installing XFCE desktop environment..."
    
    local xfce_packages=(
        # Core XFCE
        "xfce4"
        "xfce4-goodies"
        
        # Display manager
        "lightdm"
        "lightdm-gtk-greeter"
        
        # X server
        "xorg-server"
        "xorg-xinit"
        "xorg-apps"
        
        # Graphics drivers (basic)
        "xf86-video-vesa"
        "xf86-video-fbdev"
        
        # Audio
        "pulseaudio"
        "pulseaudio-alsa"
        "pavucontrol"
        "xfce4-pulseaudio-plugin"
        
        # Network manager applet
        "network-manager-applet"
        
        # File manager enhancements
        "thunar-archive-plugin"
        "thunar-media-tags-plugin"
        "thunar-volman"
        
        # Additional applications
        "firefox"
        "thunderbird"
        "libreoffice-fresh"
        "gimp"
        "vlc"
        "file-roller"
        "galculator"
        "ristretto"  # Image viewer
        "mousepad"   # Text editor
    )
    
    sudo pacman -S --noconfirm "${xfce_packages[@]}" || print_warning "Some XFCE packages failed to install"
    
    # Enable display manager
    sudo systemctl enable lightdm
    
    print_success "XFCE desktop environment installed"
}

#######################################
# Install productivity applications
#######################################
install_productivity_apps() {
    print_status "Installing productivity applications..."
    
    local productivity_packages=(
        # Office suite
        "libreoffice-fresh"
        
        # Web browsers
        "firefox"
        "chromium"
        
        # Communication
        "thunderbird"
        # "discord"  # Moved to optional AUR packages to avoid dependency issues
        
        # Multimedia
        "vlc"
        "audacity"
        "gimp"
        "inkscape"
        "blender"
        
        # System tools
        "gparted"
        # "timeshift"  # Moved to optional AUR packages to avoid dependency issues
        "bleachbit"
        "sysbench"
        "stress"
        
        # Archive tools
        "file-roller"
        "unrar"
        "p7zip"
        
        # PDF tools
        "evince"  # PDF viewer
        "pdftk"   # PDF toolkit
    )
    
    # Separate official and AUR packages
    local official_packages=()
    local aur_packages=()
    
    for package in "${productivity_packages[@]}"; do
        if pacman -Si "$package" &>/dev/null; then
            official_packages+=("$package")
        else
            aur_packages+=("$package")
        fi
    done
    
    # Install official packages
    if [[ ${#official_packages[@]} -gt 0 ]]; then
        sudo pacman -S --noconfirm "${official_packages[@]}" || print_warning "Some productivity packages failed to install"
    fi
    
    # Install AUR packages
    if [[ ${#aur_packages[@]} -gt 0 ]]; then
        print_status "Installing productivity packages from AUR..."
        print_status "AUR packages to install: ${aur_packages[*]}"
        
        # Install packages individually to avoid dependency loops
        for package in "${aur_packages[@]}"; do
            print_status "Installing AUR package: $package"
            if ! yay -S --noconfirm --needed "$package"; then
                print_warning "Failed to install AUR package: $package"
                print_warning "Continuing with remaining packages..."
            fi
        done
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
    mkdir -p "$HOME/.themes/HoneyBadger"
    mkdir -p "$HOME/.local/share/honey-badger"
    mkdir -p "$HOME/.config/gtk-3.0"
    mkdir -p "$HOME/.config/xfce4"
    
    # Create GTK theme
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

    # Download and set up honey badger icon if hb.jpg exists
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
    
    # Wait for XFCE to be available
    sleep 2
    
    # Set theme
    xfconf-query -c xsettings -p /Net/ThemeName -s "HoneyBadger" 2>/dev/null || true
    xfconf-query -c xfwm4 -p /general/theme -s "HoneyBadger" 2>/dev/null || true
    
    # Set wallpaper if available
    if [[ -f "$HOME/.local/share/honey-badger/hb.jpg" ]]; then
        xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVGA1/workspace0/last-image -s "$HOME/.local/share/honey-badger/hb.jpg" 2>/dev/null || true
    fi
    
    # Panel configuration
    xfconf-query -c xfce4-panel -p /panels/panel-1/background-style -s 1 2>/dev/null || true
    xfconf-query -c xfce4-panel -p /panels/panel-1/background-color -t uint -s 2868903935 2>/dev/null || true  # Brown color
    
    # Window manager settings
    xfconf-query -c xfwm4 -p /general/button_layout -s "O|SHMC" 2>/dev/null || true
    xfconf-query -c xfwm4 -p /general/title_font -s "DejaVu Sans Bold 10" 2>/dev/null || true
    
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
        "docker"
    )
    
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
neofetch --config off --ascii_distro arch_small --colors 3 6 7 4 5 2
echo
echo "📦 Development Tools Installed:"
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
echo "🎨 Current Theme: $(xfconf-query -c xsettings -p /Net/ThemeName 2>/dev/null || echo 'Not in X session')"
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

# Update official packages
echo "📦 Updating official packages..."
sudo pacman -Syu --noconfirm

echo
echo "📦 Updating AUR packages..."
if command -v yay &> /dev/null; then
    yay -Sua --noconfirm
else
    echo "yay not installed, skipping AUR updates"
fi

echo
echo "🧹 Cleaning package cache..."
sudo pacman -Sc --noconfirm
yay -Sc --noconfirm 2>/dev/null || true

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
            install_essential_packages
            install_aur_helper
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
            install_aur_helper
            install_development_tools
            install_xfce_desktop  # Minimal XFCE
            configure_nano
            configure_honey_badger_theme
            configure_xfce
            enable_services
            create_utility_scripts
            ;;
        "$MINIMAL")
            install_essential_packages
            configure_nano
            # Skip desktop environment
            enable_services
            create_utility_scripts
            ;;
        "$DESKTOP")
            install_essential_packages
            install_aur_helper
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
            print_colored "${CYAN}" "✅ Minimal XFCE desktop environment"
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
    print_colored "${CYAN}" "   • Minimal desktop environment"
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
    check_arch_linux
    
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