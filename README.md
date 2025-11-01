# 🦡 Honey Badger OS Post-Install Scripts

**Transform any Linux distribution into a powerful Honey Badger development environment**

## 🎯 Project Overview

Honey Badger OS Post-Install Scripts provide a comprehensive post-installation solution that transforms fresh Linux installations into fully-configured development environments. Just like the honey badger itself - fearless, determined, and uncompromising.

### ✨ Features

- **🎨 Custom Honey Badger Theme** - Distinctive earth-toned visual identity
- **� nano as Default Editor** - Enhanced configuration with syntax highlighting  
- **�️ Complete Developer Stack** - Programming languages, tools, and IDEs
- **�️ XFCE Desktop Environment** - Full desktop with productivity applications
- **📱 Multi-Distribution Support** - Works across major Linux distributions

## � Supported Distributions

| Distribution | Package Manager | Status | Script Location |
|-------------|----------------|--------|-----------------|
| **Arch Linux** | pacman | ✅ Ready | `distros/arch/` |
| **Debian/Ubuntu** | apt | ✅ Ready | `distros/debian/` |
| **Slackware** | slackpkg/sbopkg | ✅ Ready | `distros/slackware/` |
| **Fedora/RHEL** | dnf/yum | ✅ Ready | `distros/fedora/` |
| **Void Linux** | xbps | ✅ Ready | `distros/void/` |

## 🚀 Quick Start

### Automatic Detection & Installation

```bash
# Download and run the universal installer
curl -fsSL https://raw.githubusercontent.com/James-HoneyBadger/Honey_Badger_OS/main/install.sh | bash
```

### Manual Installation

```bash
# Clone the repository
git clone https://github.com/James-HoneyBadger/Honey_Badger_OS.git
cd Honey_Badger_OS

# Run the installer
./install.sh
```

### Distribution-Specific Installation

```bash
# For Arch Linux
./distros/arch/install-arch.sh

# For Debian/Ubuntu  
./distros/debian/install-debian.sh

# For Slackware
./distros/slackware/install-slackware.sh

# For Fedora/RHEL
./distros/fedora/install-fedora.sh

# For Void Linux
./distros/void/install-void.sh
```

## 🎨 What You Get

### Honey Badger Visual Theme

- **Custom GTK Theme** with earth-toned colors (browns, golds, dark backgrounds)
- **hb.jpg Integration** as system icon throughout the desktop
- **Coordinated Desktop** with matching wallpapers, panel, and window decorations
- **Terminal Theming** with custom color schemes

### Enhanced nano Editor

- **Syntax Highlighting** for 20+ programming languages
- **Custom Key Bindings** (Ctrl+S save, Ctrl+Q quit, etc.)
- **Line Numbers** and mouse support enabled
- **Auto-indentation** and smart tabbing
- **Dark Theme** matching Honey Badger colors

### Complete Development Environment

- **Programming Languages**: Python, Node.js, Go, Rust, C/C++, Java, Ruby, PHP
- **Development Tools**: Git, Docker, Kubernetes, VS Code, databases
- **Code Editors**: nano (default), Neovim, Vim, VS Code
- **Container Tools**: Docker, Podman, Docker Compose
- **Cloud Tools**: Terraform, Ansible, kubectl

### XFCE Desktop Environment

- **Complete Desktop**: Full XFCE4 with all components
- **Productivity Apps**: LibreOffice, Firefox, Thunderbird, GIMP
- **Developer Tools**: Terminals, file managers, system monitors
- **Panel Plugins**: Weather, system tray, volume control, workspace switcher
- **Graphics**: Any ARM64 compatible GPU with basic 2D acceleration

## 📁 Project Structure

```
Honey_Badger_OS/
├── assets/                    # Shared assets (icons, wallpapers, themes)
│   ├── hb.jpg                # Main Honey Badger icon
│   ├── wallpapers/           # Desktop wallpapers
│   └── icons/                # System icons in various sizes
├── config/                   # Shared configuration files  
│   ├── nanorc                # Enhanced nano configuration
│   ├── gtk-theme.css         # GTK theme CSS
│   └── xfce4/                # XFCE desktop configuration
├── scripts/                  # Utility scripts
│   ├── detect-distro.sh      # Distribution detection
│   ├── install-theme.sh      # Theme installation
│   └── setup-nano.sh         # nano configuration
├── distros/                  # Distribution-specific installers
│   ├── arch/                 # Arch Linux
│   │   ├── install-arch.sh   # Main installer script
│   │   ├── packages.txt      # Package list
│   │   └── config/           # Arch-specific configurations
│   ├── debian/               # Debian/Ubuntu
│   │   ├── install-debian.sh # Main installer script  
│   │   ├── packages.txt      # Package list
│   │   └── config/           # Debian-specific configurations
│   ├── slackware/            # Slackware
│   │   ├── install-slackware.sh
│   │   ├── packages.txt
│   │   └── config/
│   ├── fedora/               # Fedora/RHEL
│   │   ├── install-fedora.sh
│   │   ├── packages.txt  
│   │   └── config/
│   └── void/                 # Void Linux
│       ├── install-void.sh
│       ├── packages.txt
│       └── config/
├── install.sh                # Universal installer script
├── README.md                 # This file
└── docs/                     # Documentation
    ├── INSTALLATION.md       # Detailed installation guide
    ├── CUSTOMIZATION.md      # Customization options
    └── TROUBLESHOOTING.md    # Common issues and solutions
```

## 🛠️ Installation Types

### Full Installation (Recommended)

- Complete XFCE desktop environment
- All development tools and languages
- Full application suite (LibreOffice, GIMP, etc.)
- Multimedia support and tools
- **Size**: ~3-5GB depending on distribution

### Developer Focus

- Programming languages and development tools
- Code editors and IDEs  
- Version control and container tools
- Minimal desktop (basic XFCE)
- **Size**: ~2-3GB depending on distribution

### Minimal Installation

- Essential system tools only
- Enhanced nano configuration
- Basic development utilities  
- Command-line only (no desktop)
- **Size**: ~500MB-1GB depending on distribution

### Desktop Focus
