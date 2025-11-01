#!/bin/bash
#
# Honey Badger OS Post-Install Setup Script
# This script configures a fresh Arch Linux installation with the complete 
# Honey Badger environment including theme, applications, and developer tools
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    error "This script should not be run as root. Please run as regular user with sudo access."
    exit 1
fi

# Ensure we have sudo access
if ! sudo -n true 2>/dev/null; then
    log "Please enter your password for sudo access:"
    sudo -v
fi

log "Starting Honey Badger OS environment setup..."

# Update system first
log "Updating system packages..."
sudo pacman -Syu --noconfirm

# Install base development tools
log "Installing base development tools..."
sudo pacman -S --noconfirm --needed \
    base-devel \
    git \
    curl \
    wget \
    vim \
    nano \
    htop \
    tree \
    unzip \
    zip \
    tar \
    gzip \
    which \
    file \
    grep \
    sed \
    awk \
    less \
    man-db \
    man-pages

# Install XFCE desktop environment and applications
log "Installing XFCE desktop environment..."
sudo pacman -S --noconfirm --needed \
    xfce4 \
    xfce4-goodies \
    xorg-server \
    xorg-xinit \
    xorg-xrandr \
    xorg-xsetroot \
    lightdm \
    lightdm-gtk-greeter \
    lightdm-gtk-greeter-settings

# Install essential XFCE applications
log "Installing XFCE applications and utilities..."
sudo pacman -S --noconfirm --needed \
    thunar \
    thunar-volman \
    thunar-archive-plugin \
    thunar-media-tags-plugin \
    xfce4-terminal \
    xfce4-screenshooter \
    xfce4-taskmanager \
    xfce4-power-manager \
    xfce4-battery-plugin \
    xfce4-datetime-plugin \
    xfce4-diskperf-plugin \
    xfce4-fsguard-plugin \
    xfce4-genmon-plugin \
    xfce4-mailwatch-plugin \
    xfce4-mount-plugin \
    xfce4-netload-plugin \
    xfce4-notes-plugin \
    xfce4-places-plugin \
    xfce4-sensors-plugin \
    xfce4-smartbookmark-plugin \
    xfce4-systemload-plugin \
    xfce4-timer-plugin \
    xfce4-verve-plugin \
    xfce4-wavelan-plugin \
    xfce4-weather-plugin \
    xfce4-whiskermenu-plugin \
    xfce4-xkb-plugin

# Install multimedia and graphics support
log "Installing multimedia and graphics packages..."
sudo pacman -S --noconfirm --needed \
    firefox \
    vlc \
    gimp \
    libreoffice-fresh \
    evince \
    ristretto \
    parole \
    pavucontrol \
    pulseaudio \
    pulseaudio-alsa \
    alsa-utils \
    gstreamer \
    gstreamer-vaapi \
    gst-plugins-base \
    gst-plugins-good \
    gst-plugins-ugly \
    gst-plugins-bad \
    gst-libav

# Install development tools
log "Installing comprehensive developer utilities..."
sudo pacman -S --noconfirm --needed \
    python \
    python-pip \
    nodejs \
    npm \
    go \
    rust \
    gcc \
    clang \
    make \
    cmake \
    autoconf \
    automake \
    pkg-config \
    gdb \
    valgrind \
    strace \
    ltrace \
    lsof \
    netstat-nat \
    tcpdump \
    wireshark-qt \
    nmap \
    docker \
    docker-compose \
    kubectl \
    helm \
    terraform \
    vagrant \
    virtualbox \
    qemu \
    libvirt \
    virt-manager \
    code \
    neovim \
    tmux \
    screen \
    zsh \
    fish \
    bash-completion \
    zsh-completions \
    git-lfs \
    github-cli \
    jq \
    yq \
    ripgrep \
    fd \
    bat \
    exa \
    fzf \
    tokei \
    hyperfine

# Install additional useful tools
log "Installing system utilities and tools..."
sudo pacman -S --noconfirm --needed \
    firefox-developer-edition \
    chromium \
    thunderbird \
    keepassxc \
    filezilla \
    transmission-gtk \
    bleachbit \
    gparted \
    timeshift \
    rsync \
    rclone \
    neofetch \
    screenfetch \
    inxi \
    hwinfo \
    lshw \
    dmidecode \
    smartmontools \
    hdparm \
    iotop \
    iftop \
    nethogs \
    ncdu \
    duf \
    btop \
    glances

# Install fonts
log "Installing fonts..."
sudo pacman -S --noconfirm --needed \
    ttf-dejavu \
    ttf-liberation \
    ttf-opensans \
    ttf-roboto \
    ttf-noto-fonts \
    noto-fonts-emoji \
    ttf-font-awesome \
    ttf-fira-code \
    ttf-hack \
    adobe-source-code-pro-fonts

# Enable services
log "Enabling essential services..."
sudo systemctl enable lightdm
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth
sudo systemctl enable docker

# Set nano as default editor
log "Configuring nano as default editor..."
echo 'export EDITOR=nano' | sudo tee -a /etc/environment
echo 'export VISUAL=nano' | sudo tee -a /etc/environment

# Add user to necessary groups
log "Adding user to necessary groups..."
sudo usermod -aG wheel,audio,video,optical,storage,docker "$USER"

# Create Honey Badger directories
log "Creating Honey Badger directory structure..."
mkdir -p "$HOME/.config/honey-badger"
mkdir -p "$HOME/.local/share/honey-badger"
mkdir -p "$HOME/Pictures/honey-badger"
mkdir -p "$HOME/Documents/honey-badger"

# Set up Honey Badger theme and assets
log "Setting up Honey Badger theme..."

# Copy hb.jpg as distro icon to multiple locations
if [ -f "/tmp/honey-badger-setup/hb.jpg" ]; then
    # System icon locations
    sudo cp /tmp/honey-badger-setup/hb.jpg /usr/share/pixmaps/honey-badger.jpg
    sudo cp /tmp/honey-badger-setup/hb.jpg /usr/share/icons/honey-badger.jpg
    
    # User icon locations
    cp /tmp/honey-badger-setup/hb.jpg "$HOME/.local/share/honey-badger/honey-badger-icon.jpg"
    cp /tmp/honey-badger-setup/hb.jpg "$HOME/Pictures/honey-badger/"
    
    # Create various sizes for different uses
    if command -v convert >/dev/null 2>&1; then
        log "Creating different icon sizes..."
        convert /tmp/honey-badger-setup/hb.jpg -resize 16x16 "$HOME/.local/share/honey-badger/honey-badger-16.png"
        convert /tmp/honey-badger-setup/hb.jpg -resize 32x32 "$HOME/.local/share/honey-badger/honey-badger-32.png"
        convert /tmp/honey-badger-setup/hb.jpg -resize 48x48 "$HOME/.local/share/honey-badger/honey-badger-48.png"
        convert /tmp/honey-badger-setup/hb.jpg -resize 64x64 "$HOME/.local/share/honey-badger/honey-badger-64.png"
        convert /tmp/honey-badger-setup/hb.jpg -resize 128x128 "$HOME/.local/share/honey-badger/honey-badger-128.png"
        convert /tmp/honey-badger-setup/hb.jpg -resize 256x256 "$HOME/.local/share/honey-badger/honey-badger-256.png"
    else
        warning "ImageMagick not available, installing for icon conversion..."
        sudo pacman -S --noconfirm imagemagick
        convert /tmp/honey-badger-setup/hb.jpg -resize 16x16 "$HOME/.local/share/honey-badger/honey-badger-16.png"
        convert /tmp/honey-badger-setup/hb.jpg -resize 32x32 "$HOME/.local/share/honey-badger/honey-badger-32.png"
        convert /tmp/honey-badger-setup/hb.jpg -resize 48x48 "$HOME/.local/share/honey-badger/honey-badger-48.png"
        convert /tmp/honey-badger-setup/hb.jpg -resize 64x64 "$HOME/.local/share/honey-badger/honey-badger-64.png"
        convert /tmp/honey-badger-setup/hb.jpg -resize 128x128 "$HOME/.local/share/honey-badger/honey-badger-128.png"
        convert /tmp/honey-badger-setup/hb.jpg -resize 256x256 "$HOME/.local/share/honey-badger/honey-badger-256.png"
    fi
else
    warning "hb.jpg not found in /tmp/honey-badger-setup/, skipping icon setup"
fi

# Configure XFCE with Honey Badger theme
log "Configuring XFCE desktop environment..."

# Create XFCE config directory
mkdir -p "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml"

# Set wallpaper to honey badger image if available
if [ -f "$HOME/Pictures/honey-badger/hb.jpg" ]; then
    cat > "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitorVGA1" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value=""/>
        </property>
      </property>
      <property name="monitor0" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value=""/>
        </property>
      </property>
    </property>
  </property>
</channel>
EOF

    # Set the wallpaper using xfconf-query if available
    if command -v xfconf-query >/dev/null 2>&1; then
        xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s "$HOME/Pictures/honey-badger/hb.jpg"
    fi
fi

# Configure panel with Honey Badger theme colors
cat > "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-panel" version="1.0">
  <property name="configver" type="int" value="2"/>
  <property name="panels" type="array">
    <value type="int" value="1"/>
    <property name="panel-1" type="empty">
      <property name="position" type="string" value="p=6;x=0;y=0"/>
      <property name="length" type="uint" value="100"/>
      <property name="position-locked" type="bool" value="true"/>
      <property name="size" type="uint" value="28"/>
      <property name="plugin-ids" type="array">
        <value type="int" value="1"/>
        <value type="int" value="2"/>
        <value type="int" value="3"/>
        <value type="int" value="4"/>
        <value type="int" value="5"/>
        <value type="int" value="6"/>
        <value type="int" value="7"/>
      </property>
      <property name="background-style" type="uint" value="1"/>
      <property name="background-rgba" type="array">
        <value type="double" value="0.200000"/>
        <value type="double" value="0.200000"/>
        <value type="double" value="0.200000"/>
        <value type="double" value="0.900000"/>
      </property>
    </property>
  </property>
  <property name="plugins" type="empty">
    <property name="plugin-1" type="string" value="whiskermenu"/>
    <property name="plugin-2" type="string" value="tasklist"/>
    <property name="plugin-3" type="string" value="separator"/>
    <property name="plugin-4" type="string" value="systray"/>
    <property name="plugin-5" type="string" value="pulseaudio"/>
    <property name="plugin-6" type="string" value="power-manager-plugin"/>
    <property name="plugin-7" type="string" value="clock"/>
  </property>
</channel>
EOF

# Configure window manager theme
cat > "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="activate_action" type="string" value="bring"/>
    <property name="borderless_maximize" type="bool" value="true"/>
    <property name="box_move" type="bool" value="false"/>
    <property name="box_resize" type="bool" value="false"/>
    <property name="button_layout" type="string" value="O|SHMC"/>
    <property name="click_to_focus" type="bool" value="true"/>
    <property name="focus_delay" type="int" value="250"/>
    <property name="focus_hint" type="bool" value="true"/>
    <property name="focus_new" type="bool" value="true"/>
    <property name="raise_delay" type="int" value="250"/>
    <property name="raise_on_click" type="bool" value="true"/>
    <property name="raise_on_focus" type="bool" value="false"/>
    <property name="raise_with_any_button" type="bool" value="true"/>
    <property name="repeat_urgent_blink" type="bool" value="false"/>
    <property name="scroll_workspaces" type="bool" value="true"/>
    <property name="shadow_delta_height" type="int" value="0"/>
    <property name="shadow_delta_width" type="int" value="0"/>
    <property name="shadow_delta_x" type="int" value="0"/>
    <property name="shadow_delta_y" type="int" value="-3"/>
    <property name="shadow_opacity" type="int" value="50"/>
    <property name="show_app_icon" type="bool" value="false"/>
    <property name="show_dock_shadow" type="bool" value="true"/>
    <property name="show_frame_shadow" type="bool" value="true"/>
    <property name="show_popup_shadow" type="bool" value="false"/>
    <property name="snap_resist" type="bool" value="false"/>
    <property name="snap_to_border" type="bool" value="true"/>
    <property name="snap_to_windows" type="bool" value="false"/>
    <property name="snap_width" type="int" value="10"/>
    <property name="theme" type="string" value="Default"/>
    <property name="title_alignment" type="string" value="center"/>
    <property name="title_font" type="string" value="Sans Bold 9"/>
    <property name="title_horizontal_offset" type="int" value="0"/>
    <property name="title_shadow_active" type="string" value="false"/>
    <property name="title_shadow_inactive" type="string" value="false"/>
    <property name="title_vertical_offset_active" type="int" value="0"/>
    <property name="title_vertical_offset_inactive" type="int" value="0"/>
    <property name="toggle_workspaces" type="bool" value="false"/>
    <property name="unredirect_overlays" type="bool" value="true"/>
    <property name="urgent_blink" type="bool" value="false"/>
    <property name="use_compositing" type="bool" value="true"/>
    <property name="workspace_count" type="int" value="4"/>
    <property name="wrap_cycle" type="bool" value="true"/>
    <property name="wrap_layout" type="bool" value="true"/>
    <property name="wrap_resistance" type="int" value="10"/>
    <property name="wrap_windows" type="bool" value="true"/>
    <property name="wrap_workspaces" type="bool" value="false"/>
    <property name="zoom_desktop" type="bool" value="true"/>
  </property>
</channel>
EOF

# Configure terminal with custom theme
mkdir -p "$HOME/.config/xfce4/terminal"
cat > "$HOME/.config/xfce4/terminal/terminalrc" << 'EOF'
[Configuration]
ColorForeground=#ffffff
ColorBackground=#1a1a1a
ColorCursor=#ffffff
ColorBold=#ffffff
ColorBoldUseDefault=FALSE
ColorPalette=#000000;#cc0000;#4e9a06;#c4a000;#3465a4;#75507b;#06989a;#d3d7cf;#555753;#ef2929;#8ae234;#fce94f;#729fcf;#ad7fa8;#34e2e2;#eeeeec
TabActivityColor=#dc322f
FontName=Hack 10
MiscAlwaysShowTabs=FALSE
MiscBell=FALSE
MiscBellUrgent=FALSE
MiscBordersDefault=TRUE
MiscCursorBlinks=FALSE
MiscCursorShape=TERMINAL_CURSOR_SHAPE_BLOCK
MiscDefaultGeometry=80x24
MiscInheritGeometry=FALSE
MiscMenubarDefault=TRUE
MiscMouseAutohide=FALSE
MiscMouseWheelZoom=TRUE
MiscToolbarDefault=FALSE
MiscConfirmClose=TRUE
MiscCycleTabs=TRUE
MiscTabCloseButtons=TRUE
MiscTabCloseMiddleClick=TRUE
MiscTabPosition=GTK_POS_TOP
MiscHighlightUrls=TRUE
MiscMiddleClickOpensUri=FALSE
MiscCopyOnSelect=FALSE
MiscShowRelaunchDialog=TRUE
MiscRewrapOnResize=TRUE
MiscUseShiftArrowsToScroll=FALSE
MiscSlimTabs=FALSE
MiscNewTabAdjacent=FALSE
ScrollingBar=TERMINAL_SCROLLBAR_RIGHT
ScrollingLines=1000
EOF

# Create custom nano configuration
log "Configuring nano editor..."
cat > "$HOME/.nanorc" << 'EOF'
# Honey Badger OS Nano Configuration

# Enable syntax highlighting
include "/usr/share/nano/*.nanorc"

# Use auto-indentation
set autoindent

# Enable line numbers
set linenumbers

# Enable mouse support
set mouse

# Set tab size to 4
set tabsize 4

# Convert tabs to spaces
set tabstospaces

# Show whitespace characters
# set whitespace

# Enable soft wrapping
set softwrap

# Show current position
set constantshow

# Enable smooth scrolling
set smooth

# Enable bold text
set boldtext

# Set color scheme (dark theme friendly)
set titlecolor brightwhite,blue
set statuscolor brightwhite,green
set errorcolor brightwhite,red
set selectedcolor brightwhite,magenta
set stripecolor ,yellow
set numbercolor cyan
set keycolor cyan
set functioncolor green

# Backup settings
# set backup
# set backupdir "~/.nano/backups"

# Enable spell checking
# set speller "aspell -x -c"

# Key bindings
bind ^Q exit all
bind ^S savefile main
bind ^W writeout main
bind ^R insert main
bind ^X cut main
bind ^C copy main
bind ^V paste main
bind ^P location main
bind ^T gotoline main
bind ^_ gotoline main
bind M-U undo main
bind M-R redo main
bind ^F whereis main
bind ^H replace main
bind ^Z suspend main
bind ^O writeout main

# Enable undo
set undo
EOF

# Create .profile to set nano as default editor for user
cat >> "$HOME/.profile" << 'EOF'

# Honey Badger OS Environment Configuration
export EDITOR=nano
export VISUAL=nano
export BROWSER=firefox

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# Honey Badger OS banner
if [ -f "$HOME/.local/share/honey-badger/banner.txt" ]; then
    cat "$HOME/.local/share/honey-badger/banner.txt"
fi
EOF

# Create Honey Badger banner
cat > "$HOME/.local/share/honey-badger/banner.txt" << 'EOF'
 _   _                        ____            _                   ___  ____  
| | | | ___  _ __   ___ _   _ | __ )  __ _  __| | __ _  ___ _ __  / _ \/ ___| 
| |_| |/ _ \| '_ \ / _ \ | | ||  _ \ / _` |/ _` |/ _` |/ _ \ '__|| | | \___ \ 
|  _  | (_) | | | |  __/ |_| || |_) | (_| | (_| | (_| |  __/ |   | |_| |___) |
|_| |_|\___/|_| |_|\___|\__, ||____/ \__,_|\__,_|\__, |\___|_|    \___/|____/ 
                       |___/                    |___/                        

Welcome to Honey Badger OS - A developer-focused Linux distribution
Type 'honey-badger-info' for system information and available tools.
EOF

# Create system info script
cat > "$HOME/.local/bin/honey-badger-info" << 'EOF'
#!/bin/bash
echo "=== Honey Badger OS System Information ==="
echo ""
echo "System:"
neofetch --config none --ascii_distro arch_small
echo ""
echo "Development Tools Installed:"
echo "• Languages: Python, Node.js, Go, Rust, C/C++"
echo "• Editors: nano (default), vim, neovim, VS Code"
echo "• Version Control: Git, GitHub CLI"
echo "• Containers: Docker, Docker Compose"
echo "• Cloud: kubectl, helm, terraform"
echo "• Virtualization: VirtualBox, QEMU, libvirt"
echo ""
echo "Desktop Environment:"
echo "• XFCE4 with full goodies package"
echo "• Applications: Firefox, LibreOffice, GIMP, VLC"
echo "• Theme: Custom Honey Badger theme"
echo ""
echo "Useful Commands:"
echo "• honey-badger-info - Show this information"
echo "• honey-badger-update - Update system and tools"
echo "• honey-badger-backup - Backup user configurations"
echo ""
EOF

# Create update script
cat > "$HOME/.local/bin/honey-badger-update" << 'EOF'
#!/bin/bash
echo "Updating Honey Badger OS..."
sudo pacman -Syu --noconfirm
echo "System updated successfully!"
EOF

# Create backup script
cat > "$HOME/.local/bin/honey-badger-backup" << 'EOF'
#!/bin/bash
BACKUP_DIR="$HOME/Documents/honey-badger-backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "Creating Honey Badger OS configuration backup..."
cp -r ~/.config "$BACKUP_DIR/"
cp -r ~/.local/share/honey-badger "$BACKUP_DIR/"
cp ~/.nanorc "$BACKUP_DIR/" 2>/dev/null || true
cp ~/.profile "$BACKUP_DIR/" 2>/dev/null || true
cp ~/.bashrc "$BACKUP_DIR/" 2>/dev/null || true
cp ~/.zshrc "$BACKUP_DIR/" 2>/dev/null || true

echo "Backup created in: $BACKUP_DIR"
EOF

# Make scripts executable
chmod +x "$HOME/.local/bin/honey-badger-info"
chmod +x "$HOME/.local/bin/honey-badger-update"
chmod +x "$HOME/.local/bin/honey-badger-backup"

# Install AUR helper (yay) for additional packages
log "Installing AUR helper (yay)..."
if ! command -v yay >/dev/null 2>&1; then
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
fi

# Install some useful AUR packages
log "Installing additional tools from AUR..."
yay -S --noconfirm --needed \
    visual-studio-code-bin \
    google-chrome \
    slack-desktop \
    discord \
    spotify \
    zoom \
    notion-app \
    postman-bin \
    insomnia \
    dbeaver \
    beekeeper-studio \
    figma-linux || warning "Some AUR packages failed to install, continuing..."

# Create desktop entry for Honey Badger tools
mkdir -p "$HOME/.local/share/applications"
cat > "$HOME/.local/share/applications/honey-badger-info.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Honey Badger System Info
Comment=Show Honey Badger OS system information
Icon=/usr/share/pixmaps/honey-badger.jpg
Exec=xfce4-terminal -e "honey-badger-info; read -p 'Press Enter to close...'"
NoDisplay=false
Categories=System;
StartupNotify=true
EOF

# Set up Git with some sensible defaults
log "Configuring Git with sensible defaults..."
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global core.editor nano
git config --global color.ui auto

# Create development directory structure
log "Creating development directory structure..."
mkdir -p "$HOME/Development"
mkdir -p "$HOME/Development/projects"
mkdir -p "$HOME/Development/tools"
mkdir -p "$HOME/Development/scripts"
mkdir -p "$HOME/Development/repositories"

# Set up Docker for current user
log "Configuring Docker..."
sudo systemctl start docker
sudo systemctl enable docker

# Create completion for development setup
log "Setting up shell completions..."
# Bash completions
echo "source /usr/share/bash-completion/bash_completion" >> "$HOME/.bashrc"
# Zsh completions if zsh is available
if command -v zsh >/dev/null 2>&1; then
    echo "autoload -U compinit" >> "$HOME/.zshrc"
    echo "compinit" >> "$HOME/.zshrc"
fi

# Final system cleanup and optimization
log "Performing final system optimization..."
sudo pacman -Rns $(pacman -Qtdq) --noconfirm 2>/dev/null || true
sudo pacman -Sc --noconfirm

# Create system information file
cat > "$HOME/.local/share/honey-badger/system-info.txt" << EOF
Honey Badger OS Installation Information
=======================================
Installation Date: $(date)
Kernel: $(uname -r)
Desktop Environment: XFCE4
Default Editor: nano
Package Manager: pacman + yay (AUR)

Installed Development Tools:
- Python $(python --version 2>&1 | cut -d' ' -f2)
- Node.js $(node --version 2>/dev/null || echo "Not available")
- Go $(go version 2>/dev/null | cut -d' ' -f3 || echo "Not available")
- Rust $(rustc --version 2>/dev/null | cut -d' ' -f2 || echo "Not available")
- Git $(git --version | cut -d' ' -f3)
- Docker $(docker --version 2>/dev/null | cut -d' ' -f3 | sed 's/,//' || echo "Not available")

Desktop Applications:
- Firefox (default browser)
- LibreOffice (office suite)
- GIMP (image editor)
- VLC (media player)
- Thunar (file manager)
- VS Code (code editor)
- Terminal: XFCE4 Terminal

Theme: Custom Honey Badger theme with hb.jpg as distro icon
EOF

success "Honey Badger OS environment setup completed successfully!"
success "Your system is now configured with:"
echo "  ✓ XFCE desktop environment with full goodies"
echo "  ✓ Comprehensive developer tools and utilities"
echo "  ✓ nano as default system editor"
echo "  ✓ Custom Honey Badger theme and branding"
echo "  ✓ hb.jpg as distro icon in multiple sizes and locations"
echo "  ✓ Optimized system configuration"
echo ""
log "Please reboot your system to ensure all changes take effect."
log "After reboot, log into XFCE and run 'honey-badger-info' for system information."
echo ""
echo "Enjoy your new Honey Badger OS environment! 🦡"