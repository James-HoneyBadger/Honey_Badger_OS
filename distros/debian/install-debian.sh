#!/bin/bash
# Honey Badger OS - Debian/Ubuntu Post-Install Script
# Supports: Debian, Ubuntu, Linux Mint, Pop!_OS, Elementary, Zorin

set -euo pipefail

# Color definitions for consistent output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[0;37m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# Script configuration
readonly SCRIPT_NAME="Honey Badger OS - Debian/Ubuntu Installer"
readonly LOG_FILE="/tmp/honeybadger-debian-install.log"

# Package lists for different installation types
declare -a BASE_PACKAGES=(
    # System essentials
    "build-essential" "curl" "wget" "git" "git-lfs" "unzip" "zip" "p7zip-full"
    "htop" "neofetch" "tree" "tmux" "screen" "software-properties-common"
    
    # Network tools
    "network-manager" "network-manager-gnome" "wireless-tools" "wpasupplicant"
    "openssh-client" "openssh-server" "rsync" "nmap" "wireshark"
    
    # File system and storage
    "gparted" "ntfs-3g" "exfat-fuse" "exfat-utils" "dosfstools"
    
    # Audio system
    "pulseaudio" "pulseaudio-utils" "pavucontrol" "alsa-utils"
    
    # Fonts
    "fonts-dejavu" "fonts-liberation" "fonts-noto" "fonts-noto-color-emoji"
    "fonts-roboto" "fonts-opensans"
    
    # Archive support
    "rar" "unrar" "cabextract" "lzip" "lunzip"
    
    # System utilities
    "apt-transport-https" "ca-certificates" "gnupg" "lsb-release"
)

declare -a DEVELOPER_PACKAGES=(
    # Programming languages
    "python3" "python3-pip" "python3-venv" "python3-dev"
    "nodejs" "npm"
    "golang-go"
    "rustc" "cargo"
    "default-jdk" "default-jre"
    "ruby" "ruby-dev" "rubygems"
    "php" "composer"
    
    # Development tools
    "make" "cmake" "ninja-build" "meson"
    "gcc" "g++" "clang" "gdb" "valgrind"
    "docker.io" "docker-compose"
    
    # Databases
    "postgresql-client" "mysql-client" "sqlite3" "redis-tools"
    
    # Version control and tools
    "gh" "git-delta"
    
    # Build tools
    "autoconf" "automake" "libtool" "pkg-config"
)

declare -a DESKTOP_PACKAGES=(
    # XFCE Desktop Environment
    "xfce4" "xfce4-goodies" "lightdm" "lightdm-gtk-greeter"
    "lightdm-gtk-greeter-settings"
    
    # File manager and plugins
    "thunar" "thunar-volman" "thunar-archive-plugin" "thunar-media-tags-plugin"
    "file-roller" "gvfs" "gvfs-backends" "gvfs-fuse"
    
    # System utilities
    "xfce4-taskmanager" "xfce4-systemload-plugin" "xfce4-cpugraph-plugin"
    "xfce4-netload-plugin" "xfce4-diskperf-plugin" "xfce4-sensors-plugin"
    
    # Applications launcher and system tray
    "rofi" "dmenu" "xfce4-notifyd" "network-manager-gnome" "blueman"
    
    # Desktop utilities
    "xfce4-screenshooter" "xfce4-power-manager" "xfce4-clipman-plugin"
)

declare -a APPLICATIONS_PACKAGES=(
    # Web browsers
    "firefox" "chromium-browser"
    
    # Office suite
    "libreoffice" "hunspell-en-us"
    
    # Graphics and multimedia
    "gimp" "inkscape" "vlc" "audacity" "obs-studio"
    "imagemagick" "ffmpeg"
    
    # Communication
    "thunderbird" "telegram-desktop"
    
    # Utilities
    "galculator" "mousepad" "xarchiver"
    
    # System monitoring
    "synaptic" "gdebi"
)

declare -a SNAP_PACKAGES=(
    "code --classic"
    "postman"
    "discord"
    "spotify"
    "slack --classic"
)

declare -a FLATPAK_PACKAGES=(
    "org.mozilla.Thunderbird"
    "com.github.tchx84.Flatseal"
    "org.gnome.Calculator"
    "org.videolan.VLC"
)

# Logging functions
log_info() {
    echo -e "${CYAN}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

log_step() {
    echo -e "${BLUE}${BOLD}[STEP]${NC} $1" | tee -a "$LOG_FILE"
}

# Show banner
show_banner() {
    echo -e "${YELLOW}${BOLD}" | tee -a "$LOG_FILE"
    echo "  🦡 ================================================== 🦡" | tee -a "$LOG_FILE"
    echo "     HONEY BADGER OS - DEBIAN/UBUNTU INSTALLER" | tee -a "$LOG_FILE"
    echo "     Fearless Debian-based Distribution Setup" | tee -a "$LOG_FILE"
    echo "  🦡 ================================================== 🦡" | tee -a "$LOG_FILE"
    echo -e "${NC}" | tee -a "$LOG_FILE"
}

# Check if running on Debian-based system
check_debian_system() {
    if ! command -v apt-get >/dev/null 2>&1; then
        log_error "This script is for Debian-based systems only!"
        log_info "Detected system does not have apt package manager."
        exit 1
    fi
    
    # Detect specific Debian variant
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        log_info "Detected: $PRETTY_NAME"
        
        # Special handling for different Debian variants
        case "$ID" in
            debian)
                log_info "Running on Debian"
                ;;
            ubuntu)
                log_info "Running on Ubuntu"
                ;;
            linuxmint)
                log_info "Running on Linux Mint"
                ;;
            pop)
                log_info "Running on Pop!_OS"
                ;;
            elementary)
                log_info "Running on elementary OS"
                ;;
            zorin)
                log_info "Running on Zorin OS"
                ;;
            kali)
                log_info "Running on Kali Linux"
                ;;
            *)
                log_warning "Unknown Debian variant: $ID"
                log_info "Proceeding with standard Debian configuration..."
                ;;
        esac
    fi
}

# Update system packages
update_system() {
    log_step "Updating system packages..."
    
    # Update package databases
    sudo apt update
    
    # Upgrade system
    sudo apt upgrade -y
    
    # Install essential packages for adding repositories
    sudo apt install -y software-properties-common apt-transport-https ca-certificates gnupg lsb-release
    
    log_success "System updated successfully"
}

# Add additional repositories
add_repositories() {
    log_step "Adding additional repositories..."
    
    # Add universe repository for Ubuntu
    if command -v add-apt-repository >/dev/null 2>&1; then
        if lsb_release -i | grep -q Ubuntu; then
            sudo add-apt-repository universe -y
            log_info "Added Ubuntu universe repository"
        fi
    fi
    
    # Add Node.js repository
    if ! command -v nodejs >/dev/null 2>&1 || [[ $(nodejs --version | cut -d'v' -f2 | cut -d'.' -f1) -lt 16 ]]; then
        log_info "Adding Node.js repository..."
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        log_success "Node.js repository added"
    fi
    
    # Add Docker repository
    log_info "Adding Docker repository..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Add GitHub CLI repository
    log_info "Adding GitHub CLI repository..."
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    
    # Add VS Code repository (if not using Snap)
    if ! snap list code >/dev/null 2>&1; then
        log_info "Adding VS Code repository..."
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
        sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    fi
    
    # Update package list with new repositories
    sudo apt update
    
    log_success "Additional repositories added"
}

# Install packages using apt
install_apt_packages() {
    local -n packages_ref=$1
    local package_type="$2"
    
    if [[ ${#packages_ref[@]} -eq 0 ]]; then
        log_info "No $package_type packages to install"
        return 0
    fi
    
    log_step "Installing $package_type packages..."
    
    # Filter out packages that are already installed or unavailable
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
    
    # Install available packages
    if [[ ${#available_packages[@]} -gt 0 ]]; then
        if sudo apt install -y "${available_packages[@]}"; then
            log_success "Installed $package_type packages: ${available_packages[*]}"
        else
            log_warning "Some $package_type packages failed to install"
        fi
    else
        log_info "All $package_type packages already installed or unavailable"
    fi
}

# Install Snap packages
install_snap_packages() {
    local -n packages_ref=$1
    local package_type="$2"
    
    if ! command -v snap >/dev/null 2>&1; then
        log_info "Installing snapd..."
        sudo apt install -y snapd
        sudo systemctl enable --now snapd.socket
        log_success "Snapd installed"
    fi
    
    if [[ ${#packages_ref[@]} -eq 0 ]]; then
        log_info "No $package_type packages to install"
        return 0
    fi
    
    log_step "Installing $package_type packages..."
    
    for package in "${packages_ref[@]}"; do
        local package_name=$(echo "$package" | awk '{print $1}')
        if snap list "$package_name" >/dev/null 2>&1; then
            log_info "$package_name already installed"
        else
            if sudo snap install $package; then
                log_success "Installed $package"
            else
                log_warning "Failed to install $package"
            fi
        fi
    done
}

# Install Flatpak packages
install_flatpak_packages() {
    local -n packages_ref=$1
    local package_type="$2"
    
    if ! command -v flatpak >/dev/null 2>&1; then
        log_info "Installing Flatpak..."
        sudo apt install -y flatpak
        sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        log_success "Flatpak installed"
    fi
    
    if [[ ${#packages_ref[@]} -eq 0 ]]; then
        log_info "No $package_type packages to install"
        return 0
    fi
    
    log_step "Installing $package_type packages..."
    
    for package in "${packages_ref[@]}"; do
        if flatpak list | grep -q "$package"; then
            log_info "$package already installed"
        else
            if sudo flatpak install -y flathub "$package"; then
                log_success "Installed $package"
            else
                log_warning "Failed to install $package"
            fi
        fi
    done
}

# Configure nano editor
setup_nano() {
    log_step "Setting up enhanced nano configuration..."
    
    local nanorc_content='# Honey Badger OS - Enhanced nano configuration
# Key bindings
bind ^S savefile main
bind ^Q exit all
bind ^X cut main
bind ^C copy main
bind ^V paste main
bind ^Z undo main
bind ^Y redo main
bind ^F whereis main
bind ^R replace main
bind ^G gotoline main

# Display options
set linenumbers
set mouse
set softwrap
set tabstospaces
set tabsize 4
set autoindent
set backup
set backupdir "~/.nano/backups"
set historylog
set positionlog

# Appearance
set titlecolor brightwhite,blue
set statuscolor brightwhite,green
set keycolor cyan
set numbercolor yellow

# Syntax highlighting
include "/usr/share/nano/*.nanorc"

# Custom syntax highlighting for common files
syntax "default"
color brightwhite ".*"
'
    
    # Create backup directory
    mkdir -p ~/.nano/backups
    
    # Write nano configuration
    echo "$nanorc_content" > ~/.nanorc
    
    # Set nano as default editor
    echo 'export EDITOR=nano' >> ~/.bashrc
    echo 'export VISUAL=nano' >> ~/.bashrc
    
    log_success "Enhanced nano configuration installed"
}

# Install and configure Honey Badger theme
setup_honey_badger_theme() {
    log_step "Installing Honey Badger theme..."
    
    # Create theme directories
    local theme_dir="$HOME/.themes/HoneyBadger"
    local icon_dir="$HOME/.icons/HoneyBadger"
    
    mkdir -p "$theme_dir/gtk-2.0"
    mkdir -p "$theme_dir/gtk-3.0"
    mkdir -p "$icon_dir"
    
    # GTK2 theme
    local gtk2_theme='# Honey Badger GTK2 Theme
gtk-color-scheme = "base_color:#2d2006\nbg_color:#8b6914\ntooltip_bg_color:#f5deb3\nselected_bg_color:#daa520\ntext_color:#f5deb3\nfg_color:#f5deb3\ntooltip_fg_color:#2d2006\nselected_fg_color:#2d2006"

style "default" {
    GtkButton::default_border = {0,0,0,0}
    GtkButton::default_outside_border = {0,0,0,0}
    GtkButton::child_displacement_x = 1
    GtkButton::child_displacement_y = 1
    
    base[NORMAL] = @base_color
    base[PRELIGHT] = shade(1.1, @base_color)
    base[SELECTED] = @selected_bg_color
    base[INSENSITIVE] = shade(0.9, @base_color)
    
    bg[NORMAL] = @bg_color
    bg[PRELIGHT] = shade(1.1, @bg_color)
    bg[SELECTED] = @selected_bg_color
    bg[INSENSITIVE] = shade(0.9, @bg_color)
    
    fg[NORMAL] = @fg_color
    fg[PRELIGHT] = @fg_color
    fg[SELECTED] = @selected_fg_color
    fg[INSENSITIVE] = shade(0.7, @fg_color)
    
    text[NORMAL] = @text_color
    text[PRELIGHT] = @text_color
    text[SELECTED] = @selected_fg_color
    text[INSENSITIVE] = shade(0.7, @text_color)
}

class "GtkWidget" style "default"
'
    
    # GTK3 theme
    local gtk3_theme='/* Honey Badger GTK3 Theme */
@define-color theme_base_color #2d2006;
@define-color theme_bg_color #8b6914;
@define-color theme_fg_color #f5deb3;
@define-color theme_selected_bg_color #daa520;
@define-color theme_selected_fg_color #2d2006;
@define-color theme_tooltip_bg_color #f5deb3;
@define-color theme_tooltip_fg_color #2d2006;

* {
    background-color: @theme_bg_color;
    color: @theme_fg_color;
}

.window {
    background-color: @theme_bg_color;
}

.button {
    background: linear-gradient(to bottom, shade(@theme_bg_color, 1.2), @theme_bg_color);
    border: 1px solid shade(@theme_bg_color, 0.8);
    color: @theme_fg_color;
}

.button:hover {
    background: linear-gradient(to bottom, shade(@theme_bg_color, 1.3), shade(@theme_bg_color, 1.1));
}

.button:active {
    background: linear-gradient(to bottom, @theme_bg_color, shade(@theme_bg_color, 0.9));
}

.entry {
    background-color: @theme_base_color;
    color: @theme_fg_color;
    border: 1px solid shade(@theme_bg_color, 0.8);
}

.menubar {
    background-color: shade(@theme_bg_color, 0.9);
}

.menu {
    background-color: @theme_bg_color;
}

.tooltip {
    background-color: @theme_tooltip_bg_color;
    color: @theme_tooltip_fg_color;
}
'
    
    # Write theme files
    echo "$gtk2_theme" > "$theme_dir/gtk-2.0/gtkrc"
    echo "$gtk3_theme" > "$theme_dir/gtk-3.0/gtk.css"
    
    # Create theme index
    echo '[Desktop Entry]
Type=X-GNOME-Metatheme
Name=HoneyBadger
Comment=Honey Badger OS Theme
Encoding=UTF-8

[X-GNOME-Metatheme]
GtkTheme=HoneyBadger
MetacityTheme=HoneyBadger
IconTheme=HoneyBadger
' > "$theme_dir/index.theme"
    
    log_success "Honey Badger theme installed"
}

# Configure XFCE desktop
setup_xfce() {
    log_step "Configuring XFCE desktop environment..."
    
    # Enable and start display manager
    if systemctl is-enabled lightdm >/dev/null 2>&1; then
        log_info "LightDM already enabled"
    else
        sudo systemctl enable lightdm
        log_success "LightDM display manager enabled"
    fi
    
    # Configure LightDM greeter
    local lightdm_config="[Seat:*]
greeter-session=lightdm-gtk-greeter
user-session=xfce

[LightDM]
minimum-uid=1000
"
    
    echo "$lightdm_config" | sudo tee /etc/lightdm/lightdm.conf >/dev/null
    
    # Configure GTK greeter
    local greeter_config="[greeter]
theme-name=HoneyBadger
icon-theme-name=HoneyBadger
font-name=Sans 11
background=/usr/share/backgrounds/honeybadger.jpg
"
    
    echo "$greeter_config" | sudo tee /etc/lightdm/lightdm-gtk-greeter.conf >/dev/null
    
    log_success "XFCE desktop configured"
}

# Set up development environment
setup_development_environment() {
    log_step "Setting up development environment..."
    
    # Configure Git (if not already configured)
    if ! git config --global user.name >/dev/null 2>&1; then
        log_info "Git configuration needed. Please set up your Git identity:"
        echo -n "Enter your Git username: "
        read -r git_username
        echo -n "Enter your Git email: "
        read -r git_email
        
        git config --global user.name "$git_username"
        git config --global user.email "$git_email"
        git config --global init.defaultBranch main
        
        log_success "Git configured"
    fi
    
    # Enable Docker service
    if command -v docker >/dev/null 2>&1; then
        sudo systemctl enable docker
        sudo systemctl start docker
        
        # Add user to docker group
        sudo usermod -aG docker "$USER"
        log_success "Docker configured (restart required for group changes)"
    fi
    
    # Set up Python development environment
    if command -v python3 >/dev/null 2>&1; then
        python3 -m pip install --user --upgrade pip setuptools wheel
        python3 -m pip install --user pipx virtualenv
        log_success "Python development environment configured"
    fi
    
    # Set up Node.js global packages
    if command -v npm >/dev/null 2>&1; then
        # Set npm global directory to avoid permission issues
        mkdir -p ~/.npm-global
        npm config set prefix '~/.npm-global'
        echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
        
        # Install useful global packages
        npm install -g typescript ts-node nodemon eslint prettier
        log_success "Node.js development environment configured"
    fi
    
    log_success "Development environment setup completed"
}

# Create utility scripts
create_utility_scripts() {
    log_step "Creating Honey Badger utility scripts..."
    
    local bin_dir="$HOME/.local/bin"
    mkdir -p "$bin_dir"
    
    # Add bin directory to PATH
    if ! echo "$PATH" | grep -q "$bin_dir"; then
        echo "export PATH=\"$bin_dir:\$PATH\"" >> ~/.bashrc
    fi
    
    # honey-badger-info script
    cat > "$bin_dir/honey-badger-info" << 'EOF'
#!/bin/bash
# Honey Badger OS System Information

echo -e "\033[1;33m🦡 Honey Badger OS System Information 🦡\033[0m"
echo "=================================================="
echo "Hostname: $(hostname)"
echo "User: $(whoami)"
echo "OS: $(lsb_release -d 2>/dev/null | cut -f2 || echo "Unknown")"
echo "Kernel: $(uname -r)"
echo "Architecture: $(uname -m)"
echo "Uptime: $(uptime -p)"
echo "Memory: $(free -h | awk '/^Mem:/ {print $3"/"$2}')"
echo "Disk Usage: $(df -h / | awk 'NR==2 {print $3"/"$2" ("$5" used)"}')"
echo "Desktop Environment: ${XDG_CURRENT_DESKTOP:-None}"
echo "Shell: ${SHELL##*/}"
echo "Editor: ${EDITOR:-Not set}"
echo "=================================================="
echo -e "\033[1;32mHoney badger don't care, honey badger don't give a shit!\033[0m"
EOF
    
    # honey-badger-update script
    cat > "$bin_dir/honey-badger-update" << 'EOF'
#!/bin/bash
# Honey Badger OS System Update Script

echo -e "\033[1;33m🦡 Honey Badger OS System Update 🦡\033[0m"

# Update APT packages
echo "Updating APT packages..."
sudo apt update && sudo apt upgrade -y

# Update Snap packages
if command -v snap >/dev/null 2>&1; then
    echo "Updating Snap packages..."
    sudo snap refresh
fi

# Update Flatpak packages
if command -v flatpak >/dev/null 2>&1; then
    echo "Updating Flatpak packages..."
    sudo flatpak update -y
fi

# Clean package cache
echo "Cleaning package cache..."
sudo apt autoremove -y
sudo apt autoclean

echo -e "\033[1;32m🦡 System update completed! 🦡\033[0m"
EOF
    
    # honey-badger-install script
    cat > "$bin_dir/honey-badger-install" << 'EOF'
#!/bin/bash
# Honey Badger OS Package Install Script

if [[ $# -eq 0 ]]; then
    echo "Usage: honey-badger-install <package1> [package2] ..."
    exit 1
fi

echo -e "\033[1;33m🦡 Installing packages: $* 🦡\033[0m"

# Try APT first
if sudo apt install -y "$@"; then
    echo -e "\033[1;32m🦡 Packages installed successfully! 🦡\033[0m"
elif command -v snap >/dev/null 2>&1; then
    echo "Trying Snap..."
    for package in "$@"; do
        snap install "$package" 2>/dev/null || echo "Failed to install $package via Snap"
    done
else
    echo -e "\033[1;31mFailed to install packages\033[0m"
    exit 1
fi
EOF
    
    # Make scripts executable
    chmod +x "$bin_dir"/*
    
    log_success "Utility scripts created in $bin_dir"
}

# Install wallpapers and assets
install_assets() {
    log_step "Installing Honey Badger assets..."
    
    # Create directories
    local wallpaper_dir="/usr/share/backgrounds"
    local icon_dir="$HOME/.local/share/icons"
    
    sudo mkdir -p "$wallpaper_dir"
    mkdir -p "$icon_dir"
    
    # Create a simple honey badger wallpaper (placeholder)
    local wallpaper_script='#!/bin/bash
# Create a simple honey badger themed wallpaper
convert -size 1920x1080 gradient:#2d2006-#8b6914 \
    -font DejaVu-Sans-Bold -pointsize 72 -fill "#f5deb3" \
    -gravity center -annotate +0-100 "🦡 HONEY BADGER OS" \
    -pointsize 24 -annotate +0+50 "Fearless • Determined • Uncompromising" \
    /usr/share/backgrounds/honeybadger.jpg 2>/dev/null || true
'
    
    # Try to create wallpaper if ImageMagick is available
    if command -v convert >/dev/null 2>&1; then
        eval "$wallpaper_script"
        log_success "Generated Honey Badger wallpaper"
    else
        # Create a simple fallback
        echo "Creating fallback wallpaper configuration..."
        sudo touch "$wallpaper_dir/honeybadger.jpg"
    fi
    
    log_success "Assets installed"
}

# Main installation function
install_packages_by_type() {
    local install_type="${HONEY_BADGER_INSTALL_TYPE:-full}"
    
    log_info "Installation type: $install_type"
    
    # Add additional repositories first
    add_repositories
    
    # Always install base packages
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
            # Install only essential Snap packages for development
            local -a dev_snaps=("code --classic" "postman")
            install_snap_packages dev_snaps "development Snap"
            setup_xfce
            ;;
        "desktop")
            install_apt_packages DESKTOP_PACKAGES "desktop"
            install_apt_packages APPLICATIONS_PACKAGES "applications"
            # Install basic development tools
            local -a basic_dev=("python3" "python3-pip" "nodejs" "npm" "git")
            install_apt_packages basic_dev "basic development"
            setup_xfce
            ;;
        "minimal")
            # Only base packages for minimal installation
            log_info "Minimal installation - desktop environment skipped"
            ;;
        *)
            log_error "Unknown installation type: $install_type"
            exit 1
            ;;
    esac
}

# Main installation process
main() {
    # Initialize logging
    echo "Honey Badger OS - Debian/Ubuntu Installation Log" > "$LOG_FILE"
    echo "Started: $(date)" >> "$LOG_FILE"
    echo "========================================" >> "$LOG_FILE"
    
    show_banner
    
    # Pre-installation checks
    check_debian_system
    
    # Update system first
    update_system
    
    # Install packages based on type
    install_packages_by_type
    
    # Always set up nano and utilities
    setup_nano
    create_utility_scripts
    
    # Set up theme and assets for desktop installations
    local install_type="${HONEY_BADGER_INSTALL_TYPE:-full}"
    if [[ "$install_type" != "minimal" ]]; then
        setup_honey_badger_theme
        install_assets
    fi
    
    # Set up development environment for developer and full installations
    if [[ "$install_type" == "full" || "$install_type" == "developer" ]]; then
        setup_development_environment
    fi
    
    # Final message
    echo "" | tee -a "$LOG_FILE"
    log_success "Honey Badger OS installation completed!"
    echo -e "${BOLD}${YELLOW}🦡 Like the honey badger, you're now fearless and ready for anything! 🦡${NC}" | tee -a "$LOG_FILE"
    
    local install_type="${HONEY_BADGER_INSTALL_TYPE:-full}"
    if [[ "$install_type" != "minimal" ]]; then
        echo -e "${CYAN}Reboot your system to start using the new desktop environment:${NC}" | tee -a "$LOG_FILE"
        echo -e "${YELLOW}sudo reboot${NC}" | tee -a "$LOG_FILE"
    else
        echo -e "${CYAN}Restart your terminal or run: source ~/.bashrc${NC}" | tee -a "$LOG_FILE"
    fi
}

# Handle script interruption
trap 'echo -e "\n${RED}Installation interrupted${NC}"; exit 1' INT TERM

# Run main function
main "$@"