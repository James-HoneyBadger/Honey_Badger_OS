#!/bin/bash
# Honey Badger OS - Arch Linux Post-Install Script
# Supports: Arch Linux, Manjaro, EndeavourOS, ArcoLinux, Artix

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
readonly SCRIPT_NAME="Honey Badger OS - Arch Linux Installer"
readonly LOG_FILE="/tmp/honeybadger-arch-install.log"

# Package lists for different installation types
declare -a BASE_PACKAGES=(
    # System essentials
    "base-devel" "curl" "wget" "git" "git-lfs" "unzip" "zip" "p7zip"
    "htop" "neofetch" "tree" "tmux" "screen"
    
    # Network tools
    "networkmanager" "network-manager-applet" "wireless_tools" "wpa_supplicant"
    "openssh" "rsync" "nmap" "wireshark-qt"
    
    # File system and storage
    "gparted" "ntfs-3g" "exfat-utils" "dosfstools"
    
    # Audio system
    "pulseaudio" "pulseaudio-alsa" "pavucontrol" "alsa-utils"
    
    # Fonts
    "ttf-dejavu" "ttf-liberation" "noto-fonts" "noto-fonts-emoji"
    "ttf-roboto" "ttf-opensans"
)

declare -a DEVELOPER_PACKAGES=(
    # Programming languages
    "python" "python-pip" "python-virtualenv" "python-poetry"
    "nodejs" "npm" "yarn"
    "go" "rust" "cargo"
    "jdk-openjdk" "openjdk-doc"
    "ruby" "rubygems"
    "php" "composer"
    
    # Development tools
    "make" "cmake" "ninja" "meson"
    "gcc" "clang" "gdb" "valgrind"
    "docker" "docker-compose"
    
    # Databases
    "postgresql" "mariadb" "sqlite" "redis"
    
    # Code editors
    "neovim" "code" "atom"
    
    # Version control
    "github-cli" "git-delta"
)

declare -a DESKTOP_PACKAGES=(
    # XFCE Desktop Environment
    "xfce4" "xfce4-goodies" "lightdm" "lightdm-gtk-greeter"
    "lightdm-gtk-greeter-settings"
    
    # File manager and plugins
    "thunar" "thunar-volman" "thunar-archive-plugin" "thunar-media-tags-plugin"
    "file-roller" "gvfs" "gvfs-smb" "gvfs-mtp"
    
    # System utilities
    "xfce4-taskmanager" "xfce4-systemload-plugin" "xfce4-cpugraph-plugin"
    "xfce4-netload-plugin" "xfce4-diskperf-plugin"
    
    # Applications launcher
    "rofi" "dmenu"
    
    # System tray and notifications
    "xfce4-notifyd" "network-manager-applet" "blueman"
)

declare -a APPLICATIONS_PACKAGES=(
    # Web browsers
    "firefox" "chromium"
    
    # Office suite
    "libreoffice-fresh" "hunspell" "hunspell-en_us"
    
    # Graphics and multimedia
    "gimp" "inkscape" "vlc" "audacity" "obs-studio"
    "imagemagick" "ffmpeg"
    
    # Communication
    "thunderbird" "telegram-desktop" "discord"
    
    # Utilities
    "calculator" "galculator" "xarchiver" "mousepad"
    "screenshot" "xfce4-screenshooter"
)

declare -a AUR_PACKAGES=(
    "yay"  # AUR helper - installed first
    "visual-studio-code-bin"
    "postman-bin"
    "slack-desktop"
    "zoom"
    "dropbox"
    "spotify"
    "google-chrome"
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
    echo "     HONEY BADGER OS - ARCH LINUX INSTALLER" | tee -a "$LOG_FILE"
    echo "     Fearless Arch-based Distribution Setup" | tee -a "$LOG_FILE"
    echo "  🦡 ================================================== 🦡" | tee -a "$LOG_FILE"
    echo -e "${NC}" | tee -a "$LOG_FILE"
}

# Check if running on Arch-based system
check_arch_system() {
    if ! command -v pacman >/dev/null 2>&1; then
        log_error "This script is for Arch-based systems only!"
        log_info "Detected system does not have pacman package manager."
        exit 1
    fi
    
    # Detect specific Arch variant
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        log_info "Detected: $PRETTY_NAME"
        
        # Special handling for different Arch variants
        case "$ID" in
            arch)
                log_info "Running on Arch Linux"
                ;;
            manjaro)
                log_info "Running on Manjaro Linux"
                ;;
            endeavouros)
                log_info "Running on EndeavourOS"
                ;;
            arcolinux)
                log_info "Running on ArcoLinux"
                ;;
            artix)
                log_info "Running on Artix Linux (systemd-free)"
                # Note: Some packages may need different handling
                ;;
            *)
                log_warning "Unknown Arch variant: $ID"
                log_info "Proceeding with standard Arch configuration..."
                ;;
        esac
    fi
}

# Update system packages
update_system() {
    log_step "Updating system packages..."
    
    # Update package databases
    sudo pacman -Sy --noconfirm
    
    # Upgrade system
    sudo pacman -Su --noconfirm
    
    log_success "System updated successfully"
}

# Install AUR helper (yay)
install_yay() {
    if command -v yay >/dev/null 2>&1; then
        log_info "yay AUR helper already installed"
        return 0
    fi
    
    log_step "Installing yay AUR helper..."
    
    # Install dependencies
    sudo pacman -S --noconfirm --needed base-devel git
    
    # Clone yay repository
    local temp_dir="/tmp/yay-install"
    rm -rf "$temp_dir"
    git clone https://aur.archlinux.org/yay.git "$temp_dir"
    
    # Build and install yay
    cd "$temp_dir"
    makepkg -si --noconfirm
    cd -
    
    # Clean up
    rm -rf "$temp_dir"
    
    log_success "yay AUR helper installed"
}

# Install packages using pacman
install_pacman_packages() {
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
        if pacman -Qi "$package" >/dev/null 2>&1; then
            log_info "$package already installed"
        elif pacman -Si "$package" >/dev/null 2>&1; then
            available_packages+=("$package")
        else
            log_warning "$package not available in repositories"
        fi
    done
    
    # Install available packages
    if [[ ${#available_packages[@]} -gt 0 ]]; then
        if sudo pacman -S --noconfirm --needed "${available_packages[@]}"; then
            log_success "Installed $package_type packages: ${available_packages[*]}"
        else
            log_warning "Some $package_type packages failed to install"
        fi
    else
        log_info "All $package_type packages already installed or unavailable"
    fi
}

# Install AUR packages using yay
install_aur_packages() {
    local -n packages_ref=$1
    local package_type="$2"
    
    if [[ ${#packages_ref[@]} -eq 0 ]]; then
        log_info "No $package_type packages to install"
        return 0
    fi
    
    log_step "Installing $package_type packages from AUR..."
    
    # Filter out packages that are already installed or unavailable
    local -a available_packages=()
    for package in "${packages_ref[@]}"; do
        if pacman -Qi "$package" >/dev/null 2>&1; then
            log_info "$package already installed"
        elif yay -Si "$package" >/dev/null 2>&1; then
            available_packages+=("$package")
        else
            log_warning "$package not available in AUR"
        fi
    done
    
    # Install available packages
    if [[ ${#available_packages[@]} -gt 0 ]]; then
        if yay -S --noconfirm --needed "${available_packages[@]}"; then
            log_success "Installed $package_type packages: ${available_packages[*]}"
        else
            log_warning "Some $package_type packages failed to install"
        fi
    else
        log_info "All $package_type packages already installed or unavailable"
    fi
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
    if command -v python >/dev/null 2>&1; then
        python -m pip install --user --upgrade pip setuptools wheel
        python -m pip install --user pipx
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

# Update pacman packages
echo "Updating official packages..."
sudo pacman -Syu --noconfirm

# Update AUR packages if yay is available
if command -v yay >/dev/null 2>&1; then
    echo "Updating AUR packages..."
    yay -Sua --noconfirm
fi

# Clean package cache
echo "Cleaning package cache..."
sudo pacman -Sc --noconfirm

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

# Try pacman first
if sudo pacman -S --noconfirm "$@" 2>/dev/null; then
    echo -e "\033[1;32m🦡 Packages installed successfully! 🦡\033[0m"
elif command -v yay >/dev/null 2>&1; then
    echo "Trying AUR..."
    yay -S --noconfirm "$@"
    echo -e "\033[1;32m🦡 Packages installed from AUR! 🦡\033[0m"
else
    echo -e "\033[1;31mFailed to install packages\033[0m"
    exit 1
fi
EOF
    
    # honey-badger-aur script (Arch-specific)
    cat > "$bin_dir/honey-badger-aur" << 'EOF'
#!/bin/bash
# Honey Badger OS AUR Package Manager

if [[ $# -eq 0 ]]; then
    echo "Usage: honey-badger-aur <package1> [package2] ..."
    echo "Install packages from the Arch User Repository (AUR)"
    exit 1
fi

if ! command -v yay >/dev/null 2>&1; then
    echo -e "\033[1;31mError: yay AUR helper not installed\033[0m"
    exit 1
fi

echo -e "\033[1;33m🦡 Installing AUR packages: $* 🦡\033[0m"
yay -S --noconfirm "$@"
echo -e "\033[1;32m🦡 AUR packages installed successfully! 🦡\033[0m"
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
    
    # Always install base packages
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
            # Install only essential AUR packages for development
            local -a dev_aur=("visual-studio-code-bin" "postman-bin")
            install_aur_packages dev_aur "development AUR"
            setup_xfce
            ;;
        "desktop")
            install_pacman_packages DESKTOP_PACKAGES "desktop"
            install_pacman_packages APPLICATIONS_PACKAGES "applications"
            # Install basic development tools
            local -a basic_dev=("python" "python-pip" "nodejs" "npm" "git")
            install_pacman_packages basic_dev "basic development"
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
    echo "Honey Badger OS - Arch Linux Installation Log" > "$LOG_FILE"
    echo "Started: $(date)" >> "$LOG_FILE"
    echo "========================================" >> "$LOG_FILE"
    
    show_banner
    
    # Pre-installation checks
    check_arch_system
    
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