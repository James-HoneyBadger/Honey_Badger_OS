# 🦡 Honey Badger OS - Complete User Guide# Honey Badger OS - Complete User Guide

**Transform any Linux distribution into a fearless development powerhouse!**Welcome to **Honey Badger OS** - a custom Linux distribution built from scratch with complete honey badger theming, multi-architecture support, and professional-grade features.

Welcome to **Honey Badger OS** - a comprehensive collection of post-install scripts that transforms your existing Linux distribution into a fully-featured, themed development environment. Like the honey badger itself, these scripts are determined, fearless, and uncompromising.## 📋 Table of Contents

## 📋 Table of Contents1. [Getting Started](#-getting-started)

2. [System Requirements](#-system-requirements)

1. [What is Honey Badger OS?](#-what-is-honey-badger-os)3. [Available Editions](#-available-editions)

2. [System Requirements](#-system-requirements)4. [Installation Guide](#-installation-guide)

3. [Supported Distributions](#-supported-distributions)5. [First Boot & Setup](#-first-boot--setup)

4. [Installation Types](#-installation-types)6. [Using Honey Badger OS](#-using-honey-badger-os)

5. [Quick Start Guide](#-quick-start-guide)7. [Advanced Features](#-advanced-features)

6. [Detailed Installation Guide](#-detailed-installation-guide)8. [Development & Building](#-development--building)

7. [After Installation](#-after-installation)9. [Troubleshooting](#-troubleshooting)

8. [Using Honey Badger OS](#-using-honey-badger-os)10. [Contributing](#-contributing)

9. [Customization](#-customization)

10. [Troubleshooting](#-troubleshooting)---

11. [Advanced Usage](#-advanced-usage)

12. [Contributing](#-contributing)## 🚀 Getting Started

---**Honey Badger OS** is a Debian-based Linux distribution featuring:

## 🌟 What is Honey Badger OS?- **Complete visual theming** with honey badger branding

- **Multi-architecture support** (ARM64 + x86_64)

**Honey Badger OS** is NOT a traditional Linux distribution. Instead, it's a sophisticated collection of post-installation scripts that **transforms your existing Linux installation** into a powerful, themed development environment.- **Nano editor integration** as the default system editor

- **Professional build system** for custom distributions

### Why Choose Honey Badger OS?- **Production-ready ISOs** for real hardware deployment

🦡 **Fearless Multi-Distribution Support** - Works with Arch, Debian, Ubuntu, Fedora, Slackware, Void Linux, and more### Quick Start

💪 **Determined Setup Process** - Comprehensive installation that handles dependencies, configurations, and optimizations automatically1. Download the appropriate ISO from the `/ISOs/` directory

2. Write to USB drive or boot in virtual machine

🎯 **Uncompromising Features** - Full development stack, custom theming, enhanced editor configuration, and productivity applications3. Experience the honey badger themed Linux environment

4. Explore nano editor with custom honey badger colors

🚀 **Ready for Anything** - Complete development environment configured in one script execution

---

### What You Get

## 💻 System Requirements

- **Enhanced nano Editor**: Fully configured with syntax highlighting, custom key bindings, and Honey Badger theme

- **Custom Visual Theme**: Brown and gold color scheme throughout the desktop environment### Minimum Requirements

- **Complete Development Stack**: Python, Node.js, Go, Rust, C/C++, Java, Ruby, PHP, and more

- **XFCE Desktop Environment**: Full desktop with productivity applications (optional)- **RAM**: 2GB minimum, 4GB recommended

- **Utility Scripts**: Custom management tools for your Honey Badger system- **Storage**: 8GB available space

- **Architecture**: ARM64 (AArch64) or x86_64

---- **Boot**: UEFI or Legacy BIOS support

## 💻 System Requirements### Supported Hardware

### Minimum Requirements- **ARM64**: Raspberry Pi 4, Apple Silicon Macs, ARM64 servers

- **x86_64**: Intel/AMD processors, most modern PCs

| Component | Minimum | Recommended |- **Virtual Machines**: QEMU, VirtualBox, VMware, etc.

|-----------|---------|-------------|

| **RAM** | 2GB | 4GB+ |### Recommended Specs

| **Storage** | 1GB free (minimal) | 5GB+ free (full) |

| **Architecture** | x86_64 or aarch64 | x86_64 or aarch64 |- **RAM**: 4GB+ for optimal performance

| **Internet** | Required | Broadband recommended |- **Storage**: 16GB+ for full installation

| **Privileges** | sudo access | sudo access |- **Network**: Ethernet or Wi-Fi for updates

- **Display**: 1024x768 minimum resolution

### Supported Architectures

---

- **x86_64** (Intel/AMD 64-bit) - Primary support

- **aarch64** (ARM 64-bit) - Full support including Raspberry Pi 4, Apple Silicon Macs## 📦 Available Editions

### Installation Time & Size### ARM64 (AArch64) - Production Ready

| Installation Type | Time | Size | Description |#### Basic Edition (`honey-badger-os-basic-20251101.iso`) - 347MB

|------------------|------|------|-------------|

| **Minimal** | 10-20 min | ~500MB-1GB | Command-line tools only |- **Purpose**: Minimal, functional ARM64 system

| **Developer** | 20-40 min | ~2-3GB | Development focused |- **Includes**: Essential tools, nano editor, SSH server

| **Desktop** | 20-40 min | ~2-3GB | Desktop productivity |- **Branding**: Basic honey badger identity

| **Full** | 30-60 min | ~3-5GB | Complete workstation |- **Use Case**: Servers, embedded systems, minimal installs

---#### Themed Edition (`honey-badger-os-themed-20251101.iso`) - 348MB ⭐ **RECOMMENDED**

## 🐧 Supported Distributions- **Purpose**: Full honey badger experience

- **Includes**: Everything from Basic + complete theming

Honey Badger OS supports **5 major Linux distribution families** covering the most popular distributions:- **Features**:

- 6 honey badger icon sizes (16px-256px)

### Arch Linux Family  - 3 wallpaper resolutions (1920x1080, 1366x768, 1024x768)

- **Arch Linux** - Rolling release, bleeding edge  - Custom nano color scheme (brown/yellow)

- **Manjaro** - User-friendly Arch derivative  - Honey badger boot banner and MOTD

- **EndeavourOS** - Minimal Arch installer  - Complete visual identity integration

- **ArcoLinux** - Educational Arch distribution- **Use Case**: Desktop systems, development, showcase

- **Artix** - Arch without systemd

### x86_64 - Demonstration

**Package Manager**: pacman + yay (AUR)  

**Init System**: systemd (Artix uses alternatives)#### Demo Edition (`honey-badger-os-x86_64-demo-20251101.iso`) - 11MB

### Debian Family- **Purpose**: Cross-compilation proof-of-concept

- **Debian** - Universal operating system- **Includes**: Minimal x86_64 system with honey badger theming

- **Ubuntu** - Popular desktop distribution  - **Features**: Complete branding assets, nano integration

- **Linux Mint** - User-friendly Ubuntu derivative- **Use Case**: Testing, development, architecture demonstration

- **Pop!_OS** - System76's Ubuntu derivative

- **Elementary OS** - macOS-like desktop experience---

- **Zorin OS** - Windows-like desktop experience

## 🔧 Installation Guide

**Package Manager**: apt + additional repositories  

**Init System**: systemd### Method 1: Virtual Machine (Recommended for Testing)

### Red Hat Family#### QEMU (ARM64)

- **Fedora** - Cutting-edge Red Hat technology

- **Red Hat Enterprise Linux (RHEL)** - Enterprise Linux```bash

- **CentOS** - Community enterprise distribution# For ARM64 systems (Themed - Recommended)

- **AlmaLinux** - RHEL rebuildqemu-system-aarch64 \

- **Rocky Linux** - RHEL rebuild  -M virt \

  -m 4G \

**Package Manager**: dnf/yum + RPM Fusion repositories    -cpu cortex-a57 \

**Init System**: systemd  -device virtio-gpu-pci \

  -device qemu-xhid \

### Slackware Family  -cdrom ISOs/aarch64/honey-badger-os-themed-20251101.iso

- **Slackware** - Oldest actively maintained distribution

- **Salix** - User-friendly Slackware derivative# For ARM64 systems (Basic)

qemu-system-aarch64 \

**Package Manager**: slackpkg + SlackBuilds.org    -M virt \

**Init System**: traditional init scripts  -m 2G \

  -cpu cortex-a57 \

### Void Linux  -cdrom ISOs/aarch64/honey-badger-os-basic-20251101.iso

- **Void Linux** - Independent rolling release distribution```

**Package Manager**: xbps  #### QEMU (x86_64)

**Init System**: runit

```bash

---# For x86_64 systems (Demo)

qemu-system-x86_64 \

## 📋 Installation Types  -m 2G \

  -enable-kvm \

Choose the installation type that best fits your use case:  -cdrom ISOs/x86_64/honey-badger-os-x86_64-demo-20251101.iso

```

### 1. 🚀 Full Installation (Recommended)

#### VirtualBox

**Perfect for**: Complete workstation setup, primary desktop systems

1. Create new VM with appropriate architecture

**What's Included**:2. Allocate 2-4GB RAM

- ✅ Complete XFCE desktop environment with all applications3. Mount ISO as optical drive

- ✅ Full development stack (all programming languages and tools)4. Start VM and boot from ISO

- ✅ Productivity suite (LibreOffice, GIMP, VLC, Firefox, Thunderbird)

- ✅ Enhanced nano editor with complete configuration### Method 2: Physical Hardware (USB Boot)

- ✅ Custom Honey Badger theme and branding

- ✅ All utilities and system tools#### Create Bootable USB

- ✅ Container tools (Docker/Podman)

- ✅ Database clients and tools```bash

# Identify your USB device (replace /dev/sdX with actual device)

**Size**: ~3-5GB  lsblk

**Time**: 30-60 minutes

# For ARM64 hardware (Themed - Recommended)

### 2. 💻 Developer Focussudo dd if=ISOs/aarch64/honey-badger-os-themed-20251101.iso \

        of=/dev/sdX \

**Perfect for**: Software developers, system administrators, programming workstations        bs=4M \

        status=progress \

**What's Included**:        oflag=sync

- ✅ Programming languages: Python, Node.js, Go, Rust, C/C++, Java, Ruby, PHP

- ✅ Development tools: Git, VS Code (where available), Neovim# For x86_64 hardware (Demo)

- ✅ Basic desktop environment (XFCE core components)sudo dd if=ISOs/x86_64/honey-badger-os-x86_64-demo-20251101.iso \

- ✅ Container tools (Docker/Podman)        of=/dev/sdX \

- ✅ Build tools: Make, CMake, Ninja, Meson        bs=4M \

- ✅ Database clients        status=progress \

- ✅ Enhanced nano configuration        oflag=sync

- ✅ Version control tools```

**Size**: ~2-3GB  #### Boot from USB

**Time**: 20-40 minutes

1. Insert USB drive into target system

### 3. 🖥️ Desktop Focus2. Access BIOS/UEFI boot menu (usually F12, F2, or Delete)

3. Select USB drive as boot device

**Perfect for**: General desktop users, office workers, media consumption4. Boot into Honey Badger OS

**What's Included**:### Method 3: Direct Hardware Installation

- ✅ Complete XFCE desktop environment

- ✅ Productivity applications (LibreOffice, Firefox, Thunderbird)#### ARM64 Devices (Raspberry Pi, etc.)

- ✅ Media applications (VLC, Audacity, GIMP, Inkscape)

- ✅ System utilities (file manager, archive tools, system monitor)```bash

- ✅ Basic development tools# Write directly to SD card

- ✅ Enhanced nano editorsudo dd if=ISOs/aarch64/honey-badger-os-themed-20251101.iso \

- ✅ Custom Honey Badger theming        of=/dev/mmcblk0 \

        bs=4M \

**Size**: ~2-3GB          status=progress \

**Time**: 20-40 minutes        oflag=sync

```

### 4. ⚡ Minimal Installation

---

**Perfect for**: Servers, embedded systems, minimal setups, learning environments

## 🎯 First Boot & Setup

**What's Included**:

- ✅ Essential command-line tools only### Boot Process

- ✅ Enhanced nano editor with full configuration

- ✅ Basic development utilities and build tools1. **GRUB Menu**: Select boot option

- ✅ System monitoring tools (htop, neofetch)   - "🦡 Honey Badger OS - Live System" (standard)

- ✅ Network utilities   - "🦡 Honey Badger OS - Debug Mode" (verbose)

- ❌ No desktop environment   - "🦡 Honey Badger OS - Safe Mode" (recovery)

- ❌ No GUI applications

2. **System Initialization**:

**Size**: ~500MB-1GB     - Honey badger boot banner displays

**Time**: 10-20 minutes   - System services start

   - Live environment loads

---

3. **Login Screen**:

## 🚀 Quick Start Guide   - Default user: `honeybadger`

   - Default password: `live`

### One-Command Installation

### Initial Configuration

The fastest way to get started:

```bash

```bash# Change password (recommended)

# Clone and install in one commandpasswd

git clone https://github.com/James-HoneyBadger/Honey_Badger_OS.git && cd Honey_Badger_OS && ./install.sh

```# Update system

sudo apt update

### Step-by-Step Quick Startsudo apt upgrade



1. **Open Terminal** on your Linux system# Set timezone

sudo timedatectl set-timezone America/New_York

2. **Clone the repository**:

   ```bash# Configure network (if needed)

   git clone https://github.com/James-HoneyBadger/Honey_Badger_OS.gitsudo systemctl enable --now NetworkManager

   cd Honey_Badger_OS```

   ```

---

3. **Run the installer**:

   ```bash## 🦡 Using Honey Badger OS

   ./install.sh

   ```### Default Applications



4. **Follow the prompts**:#### Nano Editor (Featured Application)

   - Distribution will be auto-detected

   - Choose your installation type (1-4)The system is built around **nano** as the primary text editor:

   - Confirm installation

```bash

5. **Reboot** (for desktop installations):# Open file with nano (themed with honey badger colors)

   ```bashnano filename.txt

   sudo reboot

   ```# Nano features enabled:

# - Syntax highlighting

6. **Enjoy your Honey Badger system!** 🦡# - Line numbers

# - Mouse support

---# - Auto-indentation

# - Custom honey badger color scheme (brown/yellow)

## 📖 Detailed Installation Guide```



### Prerequisites Checklist#### System Commands



Before starting, ensure you have:```bash

# Display honey badger banner

- [ ] **Supported Linux Distribution** (see supported list above)honey-badger-banner.sh

- [ ] **Internet Connection** (required for package downloads)  

- [ ] **Sudo Privileges** (administrative access)# View system information

- [ ] **Sufficient Disk Space** (see installation type requirements)cat /etc/os-release

- [ ] **Time Available** (installation can take 10-60 minutes)

# Check honey badger assets

### Step 1: Download Honey Badger OSls /usr/share/pixmaps/honey-badger*

ls /usr/share/backgrounds/honey-badger*

#### Method A: Git Clone (Recommended)```

```bash

# Clone the latest version### File System Layout

git clone https://github.com/James-HoneyBadger/Honey_Badger_OS.git

cd Honey_Badger_OS```

/usr/share/pixmaps/          # Honey badger icons (6 sizes)

# Verify download/usr/share/backgrounds/      # Honey badger wallpapers (3 resolutions)

ls -la/usr/local/bin/             # Honey badger scripts and tools

```/etc/nanorc                 # Custom nano configuration

/etc/os-release             # Honey badger OS identification

#### Method B: Direct Download```

```bash

# Download ZIP archive### Customization

wget https://github.com/James-HoneyBadger/Honey_Badger_OS/archive/refs/heads/main.zip

unzip main.zip#### Wallpaper Usage

cd Honey_Badger_OS-main

```bash

# Make installer executable# Available wallpapers

chmod +x install.shls /usr/share/backgrounds/honey-badger*

```

# Set as desktop background (if using GUI)

### Step 2: Pre-Installation Checkfeh --bg-scale /usr/share/backgrounds/honey-badger-1920x1080.jpg

```

Run a quick system check:

#### Icon Integration

```bash

# Check your distribution```bash

cat /etc/os-release# System icons available at:

/usr/share/pixmaps/honey-badger-16.png    # 16x16

# Check available disk space/usr/share/pixmaps/honey-badger-32.png    # 32x32

df -h //usr/share/pixmaps/honey-badger-48.png    # 48x48

/usr/share/pixmaps/honey-badger-64.png    # 64x64

# Check internet connectivity  /usr/share/pixmaps/honey-badger-128.png   # 128x128

ping -c 3 google.com/usr/share/pixmaps/honey-badger-256.png   # 256x256

```

# Verify sudo access

sudo whoami---

```

## 🔬 Advanced Features

### Step 3: Run the Universal Installer

### Development Environment

```bash

# Execute the main installer```bash

./install.sh# Install development tools

```sudo apt install build-essential git vim code



### Step 4: Installation Process Walkthrough# Python development

sudo apt install python3-dev python3-pip python3-venv

#### 4.1 Distribution Detection

The installer will automatically:# Node.js development

- Detect your Linux distributioncurl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -

- Identify the distribution familysudo apt install nodejs

- Verify compatibility```

- Display detection results

### System Administration

**Example Output**:

``````bash

🐧 DISTRIBUTION DETECTED# Service management

========================sudo systemctl status honey-badger-services

Distribution: ubuntusudo systemctl enable service-name

Family: debian

Version: 22.04# Log analysis

Script: distros/debian/install-debian.shjournalctl -f                    # Follow logs

```journalctl -u service-name       # Service-specific logs



#### 4.2 Installation Type Selection# System monitoring

You'll see a menu like this:htop                            # Process monitor

df -h                          # Disk usage

```free -h                        # Memory usage

🛠️  Select Installation Type:```



1) Full Installation (Recommended)### Network Configuration

   • Complete XFCE desktop environment with all applications

   • Full development stack (Python, Node.js, Go, Rust, C/C++, Java)```bash

   • Productivity suite (LibreOffice, GIMP, VLC, Firefox)# Static IP configuration

   • Size: ~3-5GB depending on distributionsudo nano /etc/netplan/50-cloud-init.yaml



2) Developer Focus# WiFi setup (if supported)

   • Programming languages and development toolssudo nmcli device wifi list

   • Basic desktop environmentsudo nmcli device wifi connect "SSID" password "password"

   • Container tools (Docker/Podman)```

   • Size: ~2-3GB

### Package Management

3) Minimal Installation

   • Essential command-line tools only```bash

   • Enhanced nano editor# Update package lists

   • No desktop environmentsudo apt update

   • Size: ~500MB-1GB

# Install packages

4) Desktop Focussudo apt install package-name

   • Complete XFCE desktop environment

   • Productivity applications# Search packages

   • Basic development toolsapt search keyword

   • Size: ~2-3GB

# Remove packages

Enter your choice (1-4):sudo apt remove package-name

```sudo apt autoremove

```

#### 4.3 Pre-Installation Summary

Review the installation plan:---

```## 🛠️ Development & Building

📋 INSTALLATION SUMMARY

======================### Building from Source

Target Distribution: ubuntu (debian family)

Installation Type: FULL#### Prerequisites

Script to Execute: distros/debian/install-debian.sh

```bash

This will install:# Install build dependencies (on host system)

✅ Complete XFCE desktop environmentsudo apt install debootstrap squashfs-tools grub-pc-bin

✅ Full development stacksudo apt install grub-efi-amd64-bin isolinux syslinux-utils

✅ Productivity applicationssudo apt install xorriso mtools

✅ Enhanced nano editor```

✅ Custom Honey Badger theme

#### Build Commands

⚠️  This will modify your system configuration!

Do you want to continue? [y/N]:```bash

```# Clone or navigate to project

cd /home/james/Honey_Badger_OS

#### 4.4 Installation Execution

The installer will:# Build ARM64 version

cd aarch64

1. **Update package databases** - Refresh available packagessudo ./scripts/build-basic-iso.sh

2. **Install essential packages** - Core system tools

3. **Install development tools** - Programming languages and tools (if selected)# Build x86_64 version (cross-compile)

4. **Install desktop environment** - XFCE desktop (if selected)cd ../x86_64

5. **Install productivity apps** - Office and media applications (if selected)sudo ./scripts/build-simple-x86_64.sh

6. **Configure nano editor** - Enhanced configuration with theming

7. **Apply Honey Badger theme** - Custom GTK theme and branding# Verify builds

8. **Configure desktop** - XFCE settings and customization../verify-isos.sh

9. **Enable services** - System services and daemons```

10. **Create utility scripts** - Honey Badger management tools

#### Customization

### Step 5: Post-Installation

```bash

#### 5.1 Installation Complete# Modify configurations

You'll see a summary like this:nano aarch64/config/honey-badger-os.conf



```# Add packages

🦡 HONEY BADGER OS INSTALLATION COMPLETE! 🦡nano aarch64/packages/package-lists.txt

=============================================

# Customize theming

Installation Type: FULL# Edit files in assets/ directory

Void Linux Architecture: x86_64

# Rebuild with changes

✅ Complete XFCE desktop environment installedsudo ./scripts/build-basic-iso.sh

✅ Full development stack (Python, Node.js, Go, Rust, C/C++, Java)```

✅ Productivity applications (LibreOffice, GIMP, VLC)

✅ Enhanced nano editor configured as default### Architecture Support

✅ Custom Honey Badger theme applied

- **Native ARM64**: Full production builds on ARM64 hosts

🔧 Utility Commands:- **Cross-compile x86_64**: Demonstration builds using QEMU emulation

  honey-badger-info     - Display system information- **Extensible**: Framework supports adding RISC-V, PowerPC, etc.

  honey-badger-update   - Update system and packages

  honey-badger-install  - Install packages---

```

## 🔍 Troubleshooting

#### 5.2 Reboot (Desktop Installations)

For desktop installations, reboot to complete setup:### Common Issues

```bash#### Boot Problems

sudo reboot

``````bash

# If ISO won't boot:

#### 5.3 First Login1. Verify ISO integrity: sha256sum ISOs/arch/filename.iso

After reboot:2. Check UEFI/Legacy BIOS settings

- **Display Manager**: LightDM with Honey Badger theme3. Try different USB creation tool

- **Desktop Environment**: XFCE4 with custom configuration4. Use debug boot option in GRUB menu

- **Default Editor**: nano with enhanced configuration```



---#### Performance Issues



## 🎉 After Installation```bash

# If system is slow:

### What Changed on Your System1. Check available RAM: free -h

2. Monitor processes: htop

#### System-Wide Changes3. Check disk space: df -h

- **Default Editor**: nano is now the system default editor4. Review system logs: journalctl -f

- **Visual Theme**: Custom Honey Badger GTK theme applied```

- **Desktop Environment**: XFCE4 configured and themed (if installed)

- **Package Additions**: Development tools, applications, and utilities installed#### Network Issues



#### Configuration Files Modified/Created```bash

- **`~/.nanorc`** - Enhanced nano configuration# If network doesn't work:

- **`~/.themes/HoneyBadger/`** - Custom GTK theme1. Check interface status: ip addr show

- **`~/.config/gtk-3.0/settings.ini`** - GTK theme settings2. Test connectivity: ping 8.8.8.8

- **`~/.config/xfce4/`** - XFCE desktop configuration (if installed)3. Restart network service: sudo systemctl restart NetworkManager

- **`~/.local/bin/honey-badger-*`** - Utility scripts4. Check DNS: cat /etc/resolv.conf

```

#### Services Enabled

- **NetworkManager** - Network management### Recovery Options

- **LightDM** - Display manager (desktop installations)

- **Audio Services** - PulseAudio or PipeWire```bash

- **Bluetooth** - Bluetooth support (where available)# Boot into recovery mode

# Select "Safe Mode" from GRUB menu

### Verify Installation

# Emergency shell

#### Check Honey Badger Status# Press Ctrl+Alt+F2 for TTY2

```bash

# Display system information# Reset user password

honey-badger-infosudo passwd honeybadger



# Check installed development tools# Check system integrity

which python3 node go rustc gccsudo fsck /dev/sda1

```

# Verify nano configuration

nano --version### Log Analysis

```

```bash

#### Test Desktop Environment (Desktop Installations)# System logs

- **Log out and log back in** to see the themed login screenjournalctl -b                   # Current boot

- **Check Applications Menu** for installed applicationsjournalctl -p err               # Errors only

- **Open Terminal** to see themed terminal with Honey Badger colorsjournalctl -f                   # Follow live logs

- **Open File Manager** to verify theming consistency

# Specific services

---journalctl -u NetworkManager

journalctl -u ssh

## 🦡 Using Honey Badger OS```



### Enhanced nano Editor---



Your nano editor is now supercharged with Honey Badger features:## 🤝 Contributing



#### Key Features### Development Setup

- **Syntax Highlighting** for 20+ programming languages

- **Custom Key Bindings** for improved productivity1. Fork the repository

- **Line Numbers** and mouse support2. Set up build environment

- **Auto-indentation** and smart tabbing3. Make changes to configuration or scripts

- **Honey Badger Color Scheme** with brown/gold themes4. Test builds thoroughly

5. Submit pull request with detailed description

#### Custom Key Bindings

| Key Combination | Action |### Areas for Contribution

|----------------|---------|

| **Ctrl+S** | Save file |- **New Architecture Support**: Add RISC-V, PowerPC, etc.

| **Ctrl+Q** | Quit nano |- **Additional Theming**: Enhance visual elements

| **Ctrl+R** | Find and replace |- **Package Selection**: Improve default software selection

| **Ctrl+X** | Cut line |- **Documentation**: Expand user guides and tutorials

| **Ctrl+C** | Copy line |- **Testing**: Verify compatibility across hardware

| **Ctrl+V** | Paste |

| **Ctrl+Z** | Undo |### Reporting Issues

| **Ctrl+Y** | Redo |

| **Ctrl+A** | Select all |1. Use GitHub Issues for bug reports

| **Ctrl+F** | Find text |2. Include system specifications

| **Ctrl+G** | Find next |3. Provide detailed reproduction steps

| **Ctrl+T** | Go to line |4. Attach relevant log files



#### Using nano---

```bash

# Create/edit a file## 📚 Additional Resources

nano myfile.py

### Documentation

# Edit with line numbers visible

nano -l myfile.sh- [Project Overview](PROJECT_OVERVIEW.md)

- [Architecture Summary](ARCHITECTURE_SUMMARY.md)

# Edit multiple files- [Nano Configuration Guide](NANO_CONFIGURATION.md)

nano file1.txt file2.txt file3.txt- [ISO Documentation](ISOs/README.md)

```

### Community

### Honey Badger Utility Scripts

- **GitHub**: [Honey Badger OS Repository]

Several utility scripts are installed to help manage your system:- **Issues**: [Bug Reports and Feature Requests]

- **Discussions**: [Community Forum]

#### Universal Commands (All Distributions)

### External Resources

##### `honey-badger-info`

Display comprehensive system information:- [Debian Documentation](https://www.debian.org/doc/)

```bash- [ARM64 Linux Guide](https://www.kernel.org/doc/html/latest/arm64/)

honey-badger-info- [Linux Distribution Building](https://linux-from-scratch.org/)

```

**Output Example**:---

```

🦡 HONEY BADGER OS SYSTEM INFORMATION**Built with 🦡 by the Honey Badger OS Team**  

====================================*Version 1.0 "Fearless" - November 2025*



🖥️  System:> "Like the honey badger, this OS doesn't give up and gets the job done!"

OS: Ubuntu 22.04.3 LTS x86_64
Kernel: 5.15.0-78-generic
Packages: 2547 (dpkg), 0 (snap)

📦 Development Tools Installed:
Python 3.10.12
Node v18.17.1
npm 9.6.7
go version go1.19.8 linux/amd64
rustc 1.70.0
gcc (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0
git version 2.34.1

📝 Default Editor: nano
🎨 Current Theme: HoneyBadger

🦡 Fearless • Determined • Uncompromising
```

##### `honey-badger-update`

Update system and packages:

```bash
honey-badger-update
```

**What it does**:

- Updates package databases
- Upgrades all installed packages
- Cleans package cache
- Provides summary of updates

##### `honey-badger-install`

Install packages using distribution's package manager:

```bash
# Install a package
honey-badger-install htop

# Install multiple packages
honey-badger-install git vim curl wget
```

#### Distribution-Specific Commands

##### Arch Linux Family: `honey-badger-aur`

```bash
# Install AUR packages
honey-badger-aur visual-studio-code-bin
honey-badger-aur google-chrome
```

##### Fedora/RHEL Family: `honey-badger-rpm`

```bash
# Install RPM packages
honey-badger-rpm code
honey-badger-rpm discord
```

##### Slackware Family: `honey-badger-slackbuild`

```bash
# Install SlackBuilds packages
honey-badger-slackbuild libreoffice
honey-badger-slackbuild firefox
```

##### Void Linux: `honey-badger-service`

```bash
# Manage runit services
honey-badger-service enable NetworkManager
honey-badger-service disable bluetooth
honey-badger-service status lightdm
```

### XFCE Desktop Environment (Desktop Installations)

#### Desktop Features

- **Custom Panel** with Honey Badger theme
- **Application Menu** with categorized applications
- **File Manager** (Thunar) with enhanced functionality
- **Terminal Emulator** with Honey Badger colors
- **System Settings** for customization

#### Key Applications Installed

| Category | Applications |
|----------|-------------|
| **Office** | LibreOffice Suite |
| **Web** | Firefox, Chromium |
| **Graphics** | GIMP, Inkscape |
| **Media** | VLC, Audacity |
| **Development** | Terminal, File Manager, Text Editors |
| **System** | System Monitor, Archive Manager, Calculator |

#### Desktop Shortcuts

- **Super (Windows) Key** - Application menu
- **Alt+F2** - Run command dialog
- **Alt+Tab** - Switch between windows
- **Ctrl+Alt+T** - Open terminal
- **Print Screen** - Take screenshot

---

## 🎨 Customization

### Theme Customization

#### Modify GTK Theme

```bash
# Edit main theme CSS
nano ~/.themes/HoneyBadger/gtk-3.0/gtk.css

# Edit GTK settings
nano ~/.config/gtk-3.0/settings.ini
```

#### Change Colors

The Honey Badger theme uses these color variables:

```css
@define-color honey_gold #ffb347;
@define-color honey_brown #8b4513;
@define-color dark_brown #654321;
@define-color light_brown #a0522d;
@define-color cream #fffdd0;
```

#### Apply Theme Changes

After modifying theme files:

```bash
# Log out and log back in, or restart XFCE
xfce4-session-logout --logout

# Or reload XFCE settings
xfconf-query -c xsettings -p /Net/ThemeName -s "Default" && \
xfconf-query -c xsettings -p /Net/ThemeName -s "HoneyBadger"
```

### nano Editor Customization

#### Edit nano Configuration

```bash
# Edit user nano config
nano ~/.nanorc

# View current configuration
cat ~/.nanorc
```

#### Common Customizations

```bash
# Add to ~/.nanorc

# Change tab size
set tabsize 2

# Enable soft wrapping
set softwrap

# Show whitespace characters  
set whitespace "»·"

# Enable spell checking
set spell

# Set backup directory
set backupdir "~/.nano/backups"

# Additional color schemes
# include "/usr/share/nano/python.nanorc"
# include "/usr/share/nano/javascript.nanorc"
```

### XFCE Desktop Customization

#### Panel Customization

```bash
# Open panel preferences
xfce4-panel --preferences

# Add panel plugins
xfce4-panel --add=clock
xfce4-panel --add=weather
```

#### Wallpaper and Appearance

```bash
# Change wallpaper
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorDP1/workspace0/last-image -s "/path/to/wallpaper.jpg"

# Open appearance settings
xfce4-appearance-settings

# Open window manager settings
xfce4-wm-settings
```

### Adding Custom Applications

#### Install Additional Software

**Arch Linux**:

```bash
# Official repositories
sudo pacman -S package-name

# AUR packages  
honey-badger-aur package-name
```

**Debian/Ubuntu**:

```bash
# Official repositories
sudo apt install package-name

# Snap packages
sudo snap install package-name

# Flatpak packages
flatpak install package-name
```

**Fedora/RHEL**:

```bash
# Official repositories
sudo dnf install package-name

# RPM packages
honey-badger-rpm package-name
```

**Slackware**:

```bash
# SlackBuilds
honey-badger-slackbuild package-name

# Official packages
sudo slackpkg install package-name
```

**Void Linux**:

```bash
# Official repositories
sudo xbps-install package-name
```

---

## 🔧 Troubleshooting

### Common Installation Issues

#### Issue: "Distribution not supported"

**Symptoms**: Installer says your distribution isn't supported

**Solutions**:

1. **Check if your distribution is a derivative**:

   ```bash
   cat /etc/os-release
   ```

2. **Try running family-specific script directly**:

   ```bash
   # For Ubuntu derivatives
   ./distros/debian/install-debian.sh
   
   # For Arch derivatives
   ./distros/arch/install-arch.sh
   ```

3. **Force distribution detection**:

   ```bash
   export FORCE_DISTRO=debian
   ./install.sh
   ```

#### Issue: "Permission denied" errors

**Symptoms**: Script fails with permission errors

**Solutions**:

1. **Make scripts executable**:

   ```bash
   chmod +x install.sh
   chmod +x distros/*/install-*.sh
   ```

2. **Check sudo privileges**:

   ```bash
   sudo whoami  # Should return 'root'
   ```

3. **Don't run as root**:

   ```bash
   # DON'T do this
   sudo ./install.sh  # ❌ Wrong
   
   # Do this instead
   ./install.sh       # ✅ Correct
   ```

#### Issue: Package installation failures

**Symptoms**: Some packages fail to install

**Solutions**:

1. **Update package databases**:

   ```bash
   # Arch
   sudo pacman -Sy
   
   # Debian/Ubuntu  
   sudo apt update
   
   # Fedora
   sudo dnf check-update
   
   # Void
   sudo xbps-install -S
   ```

2. **Check internet connectivity**:

   ```bash
   ping -c 3 google.com
   ```

3. **Check available disk space**:

   ```bash
   df -h /
   ```

4. **View installation logs**:

   ```bash
   cat /tmp/honeybadger-install.log
   ```

#### Issue: Theme not applying correctly

**Symptoms**: Desktop doesn't show Honey Badger theme

**Solutions**:

1. **Log out and log back in**
2. **Check theme installation**:

   ```bash
   ls -la ~/.themes/HoneyBadger/
   ```

3. **Manually apply theme**:

   ```bash
   xfconf-query -c xsettings -p /Net/ThemeName -s "HoneyBadger"
   ```

4. **Reset XFCE settings**:

   ```bash
   rm -rf ~/.config/xfce4/
   # Log out and log back in
   ```

### System-Specific Issues

#### Low Disk Space

**Check available space**:

```bash
df -h /
du -sh ~/.cache/
```

**Free up space**:

```bash
# Clean package cache (distribution-specific)
# Arch
sudo pacman -Sc

# Debian/Ubuntu
sudo apt autoremove && sudo apt autoclean

# Fedora  
sudo dnf clean all

# Void
sudo xbps-remove -O
```

#### Slow Internet Connection

**For slow connections**:

1. **Choose Minimal installation type**
2. **Install during off-peak hours**
3. **Use local package mirrors**

#### Virtual Machine Issues

**Common VM problems**:

1. **Insufficient RAM**: Allocate at least 2GB
2. **Graphics acceleration**: Enable 3D acceleration
3. **Guest additions**: Install VM guest tools after installation

### Getting Help

#### Check Log Files

```bash
# Main installation log
cat /tmp/honeybadger-install.log

# Distribution-specific log
cat /tmp/honeybadger-universal-install.log

# System logs
sudo journalctl -xe  # systemd systems
sudo tail /var/log/messages  # traditional systems
```

#### Gather System Information

Before requesting help, gather:

```bash
# System information
honey-badger-info > system-info.txt

# Distribution details
cat /etc/os-release >> system-info.txt

# Hardware information
lscpu >> system-info.txt
free -h >> system-info.txt
```

#### Report Issues

1. **Search existing issues**: [GitHub Issues](https://github.com/James-HoneyBadger/Honey_Badger_OS/issues)
2. **Create new issue** with:
   - Your distribution and version
   - Installation type attempted
   - Complete error messages
   - Log file contents
   - System information

---

## ⚙️ Advanced Usage

### Running Distribution-Specific Scripts

You can bypass the universal installer and run distribution-specific scripts directly:

```bash
# Arch Linux and derivatives
./distros/arch/install-arch.sh

# Debian, Ubuntu, and derivatives
./distros/debian/install-debian.sh

# Fedora, RHEL, and derivatives
./distros/fedora/install-fedora.sh

# Slackware and derivatives
./distros/slackware/install-slackware.sh

# Void Linux
./distros/void/install-void.sh
```

### Environment Variables

Control installation behavior with environment variables:

```bash
# Set installation type without prompts
export HONEY_BADGER_INSTALL_TYPE="developer"
./install.sh

# Force specific distribution family
export FORCE_DISTRO_FAMILY="debian"
./install.sh

# Skip certain installation steps
export SKIP_DESKTOP_INSTALL="true"
export SKIP_THEME_INSTALL="true"
./distros/debian/install-debian.sh
```

### Batch Installation

For multiple systems or automation:

```bash
# Create installation script
cat > batch-install.sh << 'EOF'
#!/bin/bash
export HONEY_BADGER_INSTALL_TYPE="developer"
git clone https://github.com/James-HoneyBadger/Honey_Badger_OS.git
cd Honey_Badger_OS
./install.sh
EOF

chmod +x batch-install.sh
./batch-install.sh
```

### Custom Package Lists

Modify package lists before installation:

```bash
# Edit package lists
nano distros/debian/packages/base-packages.list
nano distros/debian/packages/developer-packages.list

# Run installation
./distros/debian/install-debian.sh
```

### Development and Testing

#### Test in Virtual Machine

```bash
# Create VM with your target distribution
# Clone Honey Badger OS in VM
git clone https://github.com/James-HoneyBadger/Honey_Badger_OS.git

# Test installation
cd Honey_Badger_OS
./install.sh
```

#### Contribute New Distribution Support

1. **Create distribution directory**:

   ```bash
   mkdir -p distros/newdistro
   ```

2. **Create installer script**:

   ```bash
   cp distros/arch/install-arch.sh distros/newdistro/install-newdistro.sh
   # Modify for your distribution
   ```

3. **Update universal installer**:

   ```bash
   nano install.sh
   # Add detection logic for new distribution
   ```

4. **Test thoroughly**:

   ```bash
   ./distros/newdistro/install-newdistro.sh
   ```

5. **Submit pull request**

---

## 🤝 Contributing

We welcome contributions to make Honey Badger OS even better!

### Ways to Contribute

#### 1. Add New Distribution Support

- Create post-install scripts for additional Linux distributions
- Follow existing patterns and maintain feature parity
- Test thoroughly on target distribution

#### 2. Improve Existing Scripts

- Fix bugs or compatibility issues
- Add new packages or features
- Optimize installation performance
- Improve error handling

#### 3. Enhance Documentation

- Fix typos and improve clarity
- Add troubleshooting information
- Create guides for specific use cases
- Translate documentation

#### 4. Testing and Feedback

- Test on different hardware configurations
- Report bugs and compatibility issues
- Suggest new features or improvements
- Share success stories and use cases

### Development Workflow

1. **Fork the repository**
2. **Create feature branch**:

   ```bash
   git checkout -b feature/new-distribution-support
   ```

3. **Make changes and test**
4. **Commit with descriptive messages**:

   ```bash
   git commit -m "Add support for OpenSUSE Tumbleweed"
   ```

5. **Push to your fork**:

   ```bash
   git push origin feature/new-distribution-support
   ```

6. **Create pull request**

### Code Standards

#### Shell Scripting Guidelines

- Use `bash` with `set -euo pipefail` for error handling
- Follow existing color coding and output format
- Include comprehensive error handling
- Add detailed comments and documentation
- Use consistent function naming patterns

#### Testing Requirements

- Test on target distribution
- Verify all installation types work
- Check theme application
- Validate utility scripts functionality
- Ensure no conflicts with existing software

### Distribution Script Template

```bash
#!/bin/bash
# Honey Badger OS - [Distribution] Post-Install Script

set -euo pipefail

# Color definitions (use existing patterns)
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
# ... other colors

# Follow existing function structure
print_status() { ... }
print_success() { ... }
print_error() { ... }

# Include all installation types
install_essential_packages() { ... }
install_development_tools() { ... }
install_xfce_desktop() { ... }
configure_nano() { ... }
configure_honey_badger_theme() { ... }

# Main installation function
main() { ... }
```

---

## 📚 Additional Resources

### Documentation

- **[GitHub Repository](https://github.com/James-HoneyBadger/Honey_Badger_OS)** - Source code and latest updates
- **[Issues Tracker](https://github.com/James-HoneyBadger/Honey_Badger_OS/issues)** - Bug reports and feature requests
- **[Discussions](https://github.com/James-HoneyBadger/Honey_Badger_OS/discussions)** - Community discussions and help

### Related Projects

- **nano Editor** - [Official Documentation](https://www.nano-editor.org/)
- **XFCE Desktop** - [User Guide](https://docs.xfce.org/)
- **GTK Theming** - [Theme Development Guide](https://developer.gnome.org/gtk3/stable/theming.html)

### Community

- **GitHub Discussions** - Community support and discussions
- **Issue Tracker** - Bug reports and feature requests
- **Pull Requests** - Code contributions and improvements

---

## 🦡 Final Words

**Congratulations!** You've successfully transformed your Linux distribution into a Honey Badger OS powerhouse. Like the honey badger itself, your system is now:

- **Fearless** - Ready to tackle any development challenge
- **Determined** - Equipped with robust tools and configurations  
- **Uncompromising** - No shortcuts, just quality software and setup
- **Ready for Anything** - Complete development environment at your fingertips

### What's Next?

1. **Explore your enhanced nano editor** - Try editing different file types to see syntax highlighting
2. **Customize your desktop** - Make the Honey Badger theme your own
3. **Install additional software** - Use the honey-badger utility scripts
4. **Join the community** - Share your experience and help others
5. **Contribute back** - Help improve Honey Badger OS for everyone

### Remember the Honey Badger Way

**"Honey badger don't care, honey badger don't give a shit!"**

And neither should you when it comes to having the perfect Linux development environment. You've got all the tools, configurations, and attitude you need to be fearless in your computing journey.

**Happy coding, you fearless developer! 🦡**

---

*Honey Badger OS - Transform any Linux distribution into a fearless development powerhouse!*
