# 🦡 Honey Badger OS# 🦡 Honey Badger OS

## Fearless Multi-Distribution Post-Install Scripts## Fearless Multi-Distribution Post-Install Scripts

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

[![GitHub stars](https://img.shields.io/github/stars/James-HoneyBadger/Honey_Badger_OS.svg)](https://github.com/James-HoneyBadger/Honey_Badger_OS/stargazers)[![GitHub stars](https://img.shields.io/github/stars/James-HoneyBadger/Honey_Badger_OS.svg)](https://github.com/James-HoneyBadger/Honey_Badger_OS/stargazers)

[![GitHub forks](https://img.shields.io/github/forks/James-HoneyBadger/Honey_Badger_OS.svg)](https://github.com/James-HoneyBadger/Honey_Badger_OS/network)[![GitHub forks](https://img.shields.io/github/forks/James-HoneyBadger/Honey_Badger_OS.svg)](https://github.com/James-HoneyBadger/Honey_Badger_OS/network)

Transform any supported Linux distribution into a **fearless development powerhouse** with the Honey Badger attitude - determined, uncompromising, and ready for anything!Transform any supported Linux distribution into a **fearless development powerhouse** with the Honey Badger attitude - determined, uncompromising, and ready for anything!

## 📖 Table of Contents## 🎯 Project Overview

- [Overview](#-overview)Honey Badger OS Post-Install Scripts provide a comprehensive post-installation solution that transforms fresh Linux installations into fully-configured development environments. Just like the honey badger itself - fearless, determined, and uncompromising.

- [Supported Distributions](#-supported-distributions)

- [Features](#-features)### ✨ Features

- [Quick Start](#-quick-start)

- [Installation Types](#-installation-types)- **🎨 Custom Honey Badger Theme** - Distinctive earth-toned visual identity

- [What Gets Installed](#-what-gets-installed)- **� nano as Default Editor** - Enhanced configuration with syntax highlighting  

- [Advanced Usage](#-advanced-usage)- **�️ Complete Developer Stack** - Programming languages, tools, and IDEs

- [Utility Scripts](#-utility-scripts)- **�️ XFCE Desktop Environment** - Full desktop with productivity applications

- [Troubleshooting](#-troubleshooting)- **📱 Multi-Distribution Support** - Works across major Linux distributions

- [Contributing](#-contributing)

- [License](#-license)## � Supported Distributions

## 🌟 Overview| Distribution | Package Manager | Status | Script Location |

|-------------|----------------|--------|-----------------|

Honey Badger OS is a collection of comprehensive post-installation scripts that transform fresh Linux installations into fully-configured development environments. Like the honey badger, these scripts are fearless and determined - they'll get your system set up no matter what distribution you're running.| **Arch Linux** | pacman | ✅ Ready | `distros/arch/` |

| **Debian/Ubuntu** | apt | ✅ Ready | `distros/debian/` |

### Why Honey Badger OS?| **Slackware** | slackpkg/sbopkg | ✅ Ready | `distros/slackware/` |

| **Fedora/RHEL** | dnf/yum | ✅ Ready | `distros/fedora/` |

- 🦡 **Fearless** - Works across multiple Linux distributions| **Void Linux** | xbps | ✅ Ready | `distros/void/` |

- 💪 **Determined** - Comprehensive setup that doesn't give up

- 🎯 **Uncompromising** - No shortcuts, full-featured installations## 🚀 Quick Start

- 🚀 **Ready for Anything** - Complete development environment in one script

### Automatic Detection & Installation

## 🐧 Supported Distributions

```bash

| Distribution Family | Supported Distributions | Package Manager | Init System |# Download and run the universal installer

|---|---|---|---|curl -fsSL https://raw.githubusercontent.com/James-HoneyBadger/Honey_Badger_OS/main/install.sh | bash

| **Arch Linux** | Arch Linux, Manjaro, EndeavourOS, ArcoLinux, Artix | pacman + yay (AUR) | systemd |```

| **Debian** | Debian, Ubuntu, Linux Mint, Pop!_OS, Elementary, Zorin | apt + additional repos | systemd |

| **Red Hat** | Fedora, RHEL, CentOS, AlmaLinux, Rocky Linux | dnf/yum + RPM Fusion | systemd |### Manual Installation

| **Slackware** | Slackware, Salix | slackpkg + SlackBuilds | traditional init |

| **Void Linux** | Void Linux | xbps | runit |```bash

# Clone the repository

### Architecture Supportgit clone https://github.com/James-HoneyBadger/Honey_Badger_OS.git

cd Honey_Badger_OS

- **x86_64** (Intel/AMD 64-bit)

- **aarch64** (ARM 64-bit)# Run the installer

./install.sh

## ✨ Features```



### 🖥️ Desktop Environment### Distribution-Specific Installation



- **XFCE4** desktop with complete application suite```bash

- **Custom Honey Badger theme** with brown/gold color scheme# For Arch Linux

- **LightDM** display manager with themed greeter./distros/arch/install-arch.sh

- **Enhanced wallpapers and icons**

# For Debian/Ubuntu  

### 📝 Enhanced Editor Configuration./distros/debian/install-debian.sh



- **nano** configured as default editor with:# For Slackware

  - Syntax highlighting for all major languages./distros/slackware/install-slackware.sh

  - Custom key bindings (Ctrl+S save, Ctrl+Q quit, etc.)

  - Line numbers and mouse support# For Fedora/RHEL

  - Automatic indentation and soft wrapping./distros/fedora/install-fedora.sh

  - Backup system

# For Void Linux

### 🛠️ Development Stack./distros/void/install-void.sh

```

- **Programming Languages:** Python, Node.js, Go, Rust, C/C++, Java, Ruby, PHP

- **Version Control:** Git with LFS support## 🎨 What You Get

- **Containers:** Docker (where available) or Podman

- **Databases:** PostgreSQL, MySQL, SQLite, Redis clients### Honey Badger Visual Theme

- **Code Editors:** VS Code (where available), Neovim

- **Build Tools:** Make, CMake, Ninja, Meson- **Custom GTK Theme** with earth-toned colors (browns, golds, dark backgrounds)

- **hb.jpg Integration** as system icon throughout the desktop

### 📦 Productivity Applications- **Coordinated Desktop** with matching wallpapers, panel, and window decorations

- **Terminal Theming** with custom color schemes

- **Office Suite:** LibreOffice

- **Web Browsers:** Firefox, Chromium### Enhanced nano Editor

- **Graphics:** GIMP, Inkscape

- **Media:** VLC, Audacity- **Syntax Highlighting** for 20+ programming languages

- **System Tools:** GParted, file compression utilities- **Custom Key Bindings** (Ctrl+S save, Ctrl+Q quit, etc.)

- **Line Numbers** and mouse support enabled

### 🔧 System Utilities- **Auto-indentation** and smart tabbing

- **Dark Theme** matching Honey Badger colors

- **Network Tools:** NetworkManager, Wireshark, nmap

- **System Monitoring:** htop, neofetch### Complete Development Environment

- **File Management:** Enhanced file manager plugins

- **Archive Support:** Full compression format support- **Programming Languages**: Python, Node.js, Go, Rust, C/C++, Java, Ruby, PHP

- **Development Tools**: Git, Docker, Kubernetes, VS Code, databases

## 🚀 Quick Start- **Code Editors**: nano (default), Neovim, Vim, VS Code

- **Container Tools**: Docker, Podman, Docker Compose

### One-Line Installation- **Cloud Tools**: Terraform, Ansible, kubectl

```bash### XFCE Desktop Environment

# Clone and install in one command

git clone https://github.com/James-HoneyBadger/Honey_Badger_OS.git && cd Honey_Badger_OS && ./install.sh- **Complete Desktop**: Full XFCE4 with all components

```- **Productivity Apps**: LibreOffice, Firefox, Thunderbird, GIMP

- **Developer Tools**: Terminals, file managers, system monitors

### Step-by-Step Installation- **Panel Plugins**: Weather, system tray, volume control, workspace switcher

- **Graphics**: Any ARM64 compatible GPU with basic 2D acceleration

1. **Clone the repository:**

   ```bash## 📁 Project Structure

   git clone https://github.com/James-HoneyBadger/Honey_Badger_OS.git

   cd Honey_Badger_OS```

   ```Honey_Badger_OS/

├── assets/                    # Shared assets (icons, wallpapers, themes)

2. **Run the universal installer:**│   ├── hb.jpg                # Main Honey Badger icon

   ```bash│   ├── wallpapers/           # Desktop wallpapers

   ./install.sh│   └── icons/                # System icons in various sizes

   ```├── config/                   # Shared configuration files  

│   ├── nanorc                # Enhanced nano configuration

3. **Follow the prompts:**│   ├── gtk-theme.css         # GTK theme CSS

   - The script will automatically detect your distribution│   └── xfce4/                # XFCE desktop configuration

   - Select your preferred installation type├── scripts/                  # Utility scripts

   - Confirm the installation│   ├── detect-distro.sh      # Distribution detection

│   ├── install-theme.sh      # Theme installation

4. **Reboot (for desktop installations):**│   └── setup-nano.sh         # nano configuration

   ```bash├── distros/                  # Distribution-specific installers

   sudo reboot│   ├── arch/                 # Arch Linux

   ```│   │   ├── install-arch.sh   # Main installer script

│   │   ├── packages.txt      # Package list

### Requirements│   │   └── config/           # Arch-specific configurations

│   ├── debian/               # Debian/Ubuntu

- **Supported Linux distribution** (see table above)│   │   ├── install-debian.sh # Main installer script  

- **Internet connection** for downloading packages│   │   ├── packages.txt      # Package list

- **Sudo privileges** for system modifications│   │   └── config/           # Debian-specific configurations

- **Minimum disk space:**│   ├── slackware/            # Slackware

  - Full: 5GB free space│   │   ├── install-slackware.sh

  - Developer/Desktop: 3GB free space  │   │   ├── packages.txt

  - Minimal: 1GB free space│   │   └── config/

│   ├── fedora/               # Fedora/RHEL

## 📋 Installation Types│   │   ├── install-fedora.sh

│   │   ├── packages.txt  

### 1. Full Installation (Recommended)│   │   └── config/

│   └── void/                 # Void Linux

**Perfect for:** Complete workstation setup│       ├── install-void.sh

│       ├── packages.txt

**Includes:**│       └── config/

├── install.sh                # Universal installer script

- ✅ Complete XFCE desktop environment├── README.md                 # This file

- ✅ Full development stack (all languages and tools)└── docs/                     # Documentation

- ✅ Productivity suite (LibreOffice, GIMP, VLC, Firefox)    ├── INSTALLATION.md       # Detailed installation guide

- ✅ Enhanced nano editor with custom configuration    ├── CUSTOMIZATION.md      # Customization options

- ✅ Custom Honey Badger theme and branding    └── TROUBLESHOOTING.md    # Common issues and solutions

- ✅ All utilities and system tools```



**Size:** ~3-5GB depending on distribution## 🛠️ Installation Types



### 2. Developer Focus### Full Installation (Recommended)



**Perfect for:** Programming and development work- Complete XFCE desktop environment

- All development tools and languages

**Includes:**- Full application suite (LibreOffice, GIMP, etc.)

- Multimedia support and tools

- ✅ Programming languages and development tools- **Size**: ~3-5GB depending on distribution

- ✅ Basic desktop environment (XFCE core)

- ✅ Container tools (Docker/Podman)### Developer Focus

- ✅ Code editors and IDEs

- ✅ Enhanced nano configuration- Programming languages and development tools

- ✅ Version control tools- Code editors and IDEs  

- Version control and container tools

**Size:** ~2-3GB- Minimal desktop (basic XFCE)

- **Size**: ~2-3GB depending on distribution

### 3. Minimal Installation

### Minimal Installation

**Perfect for:** Servers or minimal setups

- Essential system tools only

**Includes:**- Enhanced nano configuration

- Basic development utilities  

- ✅ Essential command-line tools- Command-line only (no desktop)

- ✅ Enhanced nano editor- **Size**: ~500MB-1GB depending on distribution

- ✅ Basic development utilities

- ✅ System monitoring tools### Desktop Focus

- ❌ No desktop environment

- Complete XFCE desktop environment

**Size:** ~500MB-1GB- Office and productivity applications

- Media applications and utilities

### 4. Desktop Focus- Basic development tools

- **Size**: ~2-3GB depending on distribution

**Perfect for:** General desktop usage

## 🔧 Customization

**Includes:**

### Theme Customization

- ✅ Complete XFCE desktop environment

- ✅ Productivity applications (office, media, graphics)```bash

- ✅ Basic development tools# Edit GTK theme

- ✅ Enhanced nano editornano ~/.config/gtk-3.0/gtk.css

- ✅ Custom theming

# Modify XFCE settings

**Size:** ~2-3GBxfce4-settings-manager



## 🎁 What Gets Installed# Change wallpaper

cp your-wallpaper.jpg ~/.local/share/honey-badger/wallpapers/

### Programming Languages & Runtimes```



```text### nano Configuration

Python 3.x + pip          Node.js + npm           Go

Rust + Cargo             GCC + Clang             OpenJDK```bash

Ruby + Gems              PHP                     # Edit user nano config

```nano ~/.nanorc



### Development Tools# System-wide nano config (requires sudo)

sudo nano /etc/nanorc

```text```

Git + Git LFS            VS Code*                Neovim

Docker/Podman            GitHub CLI*             Build tools (make, cmake, ninja)### Package Management

Database clients         Debugging tools         Container tools

``````bash

# Add additional software (examples for each distro)

*Where available in distribution repositories# Arch: sudo pacman -S package-name

# Debian: sudo apt install package-name  

### Desktop Applications# Slackware: sudo slackpkg install package-name

# Fedora: sudo dnf install package-name

```text# Void: sudo xbps-install package-name

Firefox                  LibreOffice             GIMP```

VLC Media Player         Thunderbird*            File Manager

Archive Manager          Calculator              Screenshot tool## 📖 Documentation

System Monitor           Power Manager           Network Manager

```- **[Installation Guide](docs/INSTALLATION.md)** - Detailed installation instructions

- **[Customization Guide](docs/CUSTOMIZATION.md)** - How to customize your setup

*Included in full installation only- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues and solutions

- **[Developer Guide](docs/DEVELOPER.md)** - Adding support for new distributions

### System Utilities

## 🤝 Contributing

```text

htop                     neofetch                NetworkManagerWe welcome contributions! Here's how you can help:

Wireshark               nmap                    GParted

Compression tools       Font packages           Audio system1. **Add New Distributions** - Create post-install scripts for additional Linux distributions

```2. **Improve Existing Scripts** - Enhance functionality and compatibility

3. **Update Themes** - Improve visual design and branding

### Custom Honey Badger Features4. **Documentation** - Help improve guides and documentation

5. **Testing** - Test scripts on different systems and report issues

```text

🎨 Custom GTK theme (brown/gold honey badger colors)### Adding a New Distribution

📝 Enhanced nano configuration with syntax highlighting

🖼️ Honey badger wallpapers and icons  1. Create directory: `distros/your-distro/`

🔧 Utility scripts for system management2. Create installer script: `install-your-distro.sh`

⚡ Optimized shell configuration3. Add package list: `packages.txt`

```4. Update distribution detection in `scripts/detect-distro.sh`

5. Update documentation and README

## ⚙️ Advanced Usage

## 📄 License

### Running Distribution-Specific Scripts

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

You can run scripts for specific distributions directly:

## 🦡 About Honey Badger OS

```bash

# Arch LinuxInspired by the fearless and determined honey badger, this project aims to create uncompromising, robust development environments that "just work" across different Linux distributions. No matter which Linux distribution you prefer, Honey Badger OS post-install scripts transform your system into a powerful, developer-focused environment.

./distros/arch/install-arch.sh

### Philosophy

# Debian/Ubuntu

./distros/debian/install-debian.sh- **Fearless**: Comprehensive feature set that doesn't compromise on functionality

- **Determined**: Robust installation process with error handling and recovery

# Fedora/RHEL- **Uncompromising**: Professional quality with attention to every detail

./distros/fedora/install-fedora.sh- **Versatile**: Works across multiple Linux distributions and use cases



# Slackware## 🔗 Links

./distros/slackware/install-slackware.sh

- **GitHub Repository**: [Honey_Badger_OS](https://github.com/James-HoneyBadger/Honey_Badger_OS)

# Void Linux- **Issues & Support**: [GitHub Issues](https://github.com/James-HoneyBadger/Honey_Badger_OS/issues)

./distros/void/install-void.sh- **Discussions**: [GitHub Discussions](https://github.com/James-HoneyBadger/Honey_Badger_OS/discussions)

```

---

### Environment Variables

**Transform your Linux installation into a fearless development environment! 🦡**

Set installation type without prompts:

### Minimal Installation

```bash

# Set installation type- Essential system tools only

export HONEY_BADGER_INSTALL_TYPE="developer"- Enhanced nano configuration

./install.sh- Basic development utilities  

- Command-line only (no desktop)

# Available types: full, developer, minimal, desktop- **Size**: ~500MB-1GB depending on distribution

```

### Desktop Focus

### Custom Configuration

After installation, you can customize:

1. **nano configuration:** Edit `~/.nanorc`
2. **Theme settings:** Modify `~/.themes/HoneyBadger/`
3. **XFCE settings:** Use `xfce4-settings-manager`

## 🔧 Utility Scripts

After installation, these commands become available:

### Universal Commands (All Distributions)

```bash
honey-badger-info        # Display system information
honey-badger-update      # Update system and packages  
honey-badger-install     # Install packages
```

### Distribution-Specific Commands

**Arch Linux:**

```bash
honey-badger-aur <package>      # Install AUR packages
```

**Fedora/RHEL:**

```bash
honey-badger-rpm <package>      # Manage RPM packages
```

**Slackware:**

```bash
honey-badger-slackbuild <pkg>   # Install SlackBuilds packages
```

**Void Linux:**

```bash
honey-badger-service <action> <service>  # Manage runit services
```

## 🔍 Troubleshooting

### Common Issues

#### "Distribution not supported"

**Cause:** Your distribution isn't detected or supported.  
**Solution:**

1. Check if your distribution is based on a supported family
2. Try running the appropriate family script directly
3. Open an issue if you believe it should be supported

#### "Script not found"

**Cause:** Incomplete repository download.  
**Solution:**

```bash
# Re-clone the repository completely
rm -rf Honey_Badger_OS
git clone https://github.com/James-HoneyBadger/Honey_Badger_OS.git
cd Honey_Badger_OS
./install.sh
```

#### "Permission denied"

**Cause:** Script isn't executable.  
**Solution:**

```bash
chmod +x install.sh
chmod +x distros/*/install-*.sh
```

#### Package installation failures

**Cause:** Repository issues or package unavailability.  
**Solution:**

1. Update package databases first
2. Check internet connectivity
3. Try running the script again
4. Check the log file for specific errors

### Installation Logs

All installations create detailed logs:

```bash
# View installation log
cat /tmp/honeybadger-install.log

# Or distribution-specific logs
cat /tmp/honeybadger-universal-install.log
```

### Getting Help

1. **Check the log files** for specific error messages
2. **Search existing issues** on GitHub
3. **Open a new issue** with:
   - Your distribution and version
   - Installation type attempted
   - Full error message
   - Log file contents

### Recovery

If installation fails partway through:

1. **Check what was installed:**

   ```bash
   honey-badger-info  # If available
   ```

2. **Clean up if needed:**

   ```bash
   # Remove incomplete theme
   rm -rf ~/.themes/HoneyBadger
   
   # Reset nano config
   rm ~/.nanorc
   ```

3. **Try again:**

   ```bash
   ./install.sh
   ```

## 🤝 Contributing

We welcome contributions! Here's how you can help:

### Adding Distribution Support

1. **Fork the repository**
2. **Create a new script** in `distros/newdistro/install-newdistro.sh`
3. **Follow the existing pattern:**
   - Use the same installation types
   - Maintain feature parity
   - Include proper error handling
   - Add logging
4. **Update the universal installer** to detect your distribution
5. **Test thoroughly** on the target distribution
6. **Submit a pull request**

### Improving Existing Scripts

- Fix bugs or improve package selection
- Add new features while maintaining compatibility
- Improve error handling or user experience
- Update documentation

### Documentation

- Fix typos or improve clarity
- Add troubleshooting information
- Create guides for specific use cases
- Translate to other languages

### Distribution Script Template

```bash
#!/bin/bash
# Honey Badger OS - [Distribution] Post-Install Script

set -euo pipefail

# Use consistent color definitions
# Follow the established function structure
# Include all installation types
# Maintain feature parity with other scripts
# Add comprehensive error handling
```

### Code Style Guidelines

- Use `bash` with `set -euo pipefail`
- Follow the established color coding system
- Include comprehensive comments
- Use consistent function naming
- Add progress indicators
- Handle errors gracefully

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **The Honey Badger** - For being fearless and inspiring this project
- **Linux Distribution Maintainers** - For creating amazing operating systems
- **Open Source Community** - For the tools and applications we install
- **Contributors** - For making this project better

## 📞 Support

- **GitHub Issues:** [Report bugs or request features](https://github.com/James-HoneyBadger/Honey_Badger_OS/issues)
- **Discussions:** [Community discussions and help](https://github.com/James-HoneyBadger/Honey_Badger_OS/discussions)
- **Documentation:** [Full documentation and guides](https://github.com/James-HoneyBadger/Honey_Badger_OS/wiki)

---

## 🦡 Like the honey badger, be fearless in your development journey

**"Honey badger don't care, honey badger don't give a shit!"** - And neither should you when it comes to setting up the perfect Linux development environment. Let Honey Badger OS handle all the tedious configuration work so you can focus on what matters: being awesome at what you do.

**Happy coding, you fearless developer! 🦡**
