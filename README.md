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

- Complete XFCE desktop environment
- Office and productivity applications
- Media applications and utilities
- Basic development tools
- **Size**: ~2-3GB depending on distribution

## 🔧 Customization

### Theme Customization

```bash
# Edit GTK theme
nano ~/.config/gtk-3.0/gtk.css

# Modify XFCE settings
xfce4-settings-manager

# Change wallpaper
cp your-wallpaper.jpg ~/.local/share/honey-badger/wallpapers/
```

### nano Configuration

```bash
# Edit user nano config
nano ~/.nanorc

# System-wide nano config (requires sudo)
sudo nano /etc/nanorc
```

### Package Management

```bash
# Add additional software (examples for each distro)
# Arch: sudo pacman -S package-name
# Debian: sudo apt install package-name  
# Slackware: sudo slackpkg install package-name
# Fedora: sudo dnf install package-name
# Void: sudo xbps-install package-name
```

## 📖 Documentation

- **[Installation Guide](docs/INSTALLATION.md)** - Detailed installation instructions
- **[Customization Guide](docs/CUSTOMIZATION.md)** - How to customize your setup
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues and solutions
- **[Developer Guide](docs/DEVELOPER.md)** - Adding support for new distributions

## 🤝 Contributing

We welcome contributions! Here's how you can help:

1. **Add New Distributions** - Create post-install scripts for additional Linux distributions
2. **Improve Existing Scripts** - Enhance functionality and compatibility
3. **Update Themes** - Improve visual design and branding
4. **Documentation** - Help improve guides and documentation
5. **Testing** - Test scripts on different systems and report issues

### Adding a New Distribution

1. Create directory: `distros/your-distro/`
2. Create installer script: `install-your-distro.sh`
3. Add package list: `packages.txt`
4. Update distribution detection in `scripts/detect-distro.sh`
5. Update documentation and README

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🦡 About Honey Badger OS

Inspired by the fearless and determined honey badger, this project aims to create uncompromising, robust development environments that "just work" across different Linux distributions. No matter which Linux distribution you prefer, Honey Badger OS post-install scripts transform your system into a powerful, developer-focused environment.

### Philosophy

- **Fearless**: Comprehensive feature set that doesn't compromise on functionality
- **Determined**: Robust installation process with error handling and recovery
- **Uncompromising**: Professional quality with attention to every detail
- **Versatile**: Works across multiple Linux distributions and use cases

## 🔗 Links

- **GitHub Repository**: [Honey_Badger_OS](https://github.com/James-HoneyBadger/Honey_Badger_OS)
- **Issues & Support**: [GitHub Issues](https://github.com/James-HoneyBadger/Honey_Badger_OS/issues)
- **Discussions**: [GitHub Discussions](https://github.com/James-HoneyBadger/Honey_Badger_OS/discussions)

---

**Transform your Linux installation into a fearless development environment! 🦡**

### Minimal Installation

- Essential system tools only
- Enhanced nano configuration
- Basic development utilities  
- Command-line only (no desktop)
- **Size**: ~500MB-1GB depending on distribution

### Desktop Focus
