# Honey Badger OS - Complete User Guide

Welcome to **Honey Badger OS** - a custom Linux distribution built from scratch with complete honey badger theming, multi-architecture support, and professional-grade features.

## 📋 Table of Contents

1. [Getting Started](#-getting-started)
2. [System Requirements](#-system-requirements)
3. [Available Editions](#-available-editions)
4. [Installation Guide](#-installation-guide)
5. [First Boot & Setup](#-first-boot--setup)
6. [Using Honey Badger OS](#-using-honey-badger-os)
7. [Advanced Features](#-advanced-features)
8. [Development & Building](#-development--building)
9. [Troubleshooting](#-troubleshooting)
10. [Contributing](#-contributing)

---

## 🚀 Getting Started

**Honey Badger OS** is a Debian-based Linux distribution featuring:

- **Complete visual theming** with honey badger branding
- **Multi-architecture support** (ARM64 + x86_64)
- **Nano editor integration** as the default system editor
- **Professional build system** for custom distributions
- **Production-ready ISOs** for real hardware deployment

### Quick Start

1. Download the appropriate ISO from the `/ISOs/` directory
2. Write to USB drive or boot in virtual machine
3. Experience the honey badger themed Linux environment
4. Explore nano editor with custom honey badger colors

---

## 💻 System Requirements

### Minimum Requirements

- **RAM**: 2GB minimum, 4GB recommended
- **Storage**: 8GB available space
- **Architecture**: ARM64 (AArch64) or x86_64
- **Boot**: UEFI or Legacy BIOS support

### Supported Hardware

- **ARM64**: Raspberry Pi 4, Apple Silicon Macs, ARM64 servers
- **x86_64**: Intel/AMD processors, most modern PCs
- **Virtual Machines**: QEMU, VirtualBox, VMware, etc.

### Recommended Specs

- **RAM**: 4GB+ for optimal performance
- **Storage**: 16GB+ for full installation
- **Network**: Ethernet or Wi-Fi for updates
- **Display**: 1024x768 minimum resolution

---

## 📦 Available Editions

### ARM64 (AArch64) - Production Ready

#### Basic Edition (`honey-badger-os-basic-20251101.iso`) - 347MB

- **Purpose**: Minimal, functional ARM64 system
- **Includes**: Essential tools, nano editor, SSH server
- **Branding**: Basic honey badger identity
- **Use Case**: Servers, embedded systems, minimal installs

#### Themed Edition (`honey-badger-os-themed-20251101.iso`) - 348MB ⭐ **RECOMMENDED**

- **Purpose**: Full honey badger experience
- **Includes**: Everything from Basic + complete theming
- **Features**:
  - 6 honey badger icon sizes (16px-256px)
  - 3 wallpaper resolutions (1920x1080, 1366x768, 1024x768)
  - Custom nano color scheme (brown/yellow)
  - Honey badger boot banner and MOTD
  - Complete visual identity integration
- **Use Case**: Desktop systems, development, showcase

### x86_64 - Demonstration

#### Demo Edition (`honey-badger-os-x86_64-demo-20251101.iso`) - 11MB

- **Purpose**: Cross-compilation proof-of-concept
- **Includes**: Minimal x86_64 system with honey badger theming
- **Features**: Complete branding assets, nano integration
- **Use Case**: Testing, development, architecture demonstration

---

## 🔧 Installation Guide

### Method 1: Virtual Machine (Recommended for Testing)

#### QEMU (ARM64)

```bash
# For ARM64 systems (Themed - Recommended)
qemu-system-aarch64 \
  -M virt \
  -m 4G \
  -cpu cortex-a57 \
  -device virtio-gpu-pci \
  -device qemu-xhid \
  -cdrom ISOs/aarch64/honey-badger-os-themed-20251101.iso

# For ARM64 systems (Basic)
qemu-system-aarch64 \
  -M virt \
  -m 2G \
  -cpu cortex-a57 \
  -cdrom ISOs/aarch64/honey-badger-os-basic-20251101.iso
```

#### QEMU (x86_64)

```bash
# For x86_64 systems (Demo)
qemu-system-x86_64 \
  -m 2G \
  -enable-kvm \
  -cdrom ISOs/x86_64/honey-badger-os-x86_64-demo-20251101.iso
```

#### VirtualBox

1. Create new VM with appropriate architecture
2. Allocate 2-4GB RAM
3. Mount ISO as optical drive
4. Start VM and boot from ISO

### Method 2: Physical Hardware (USB Boot)

#### Create Bootable USB

```bash
# Identify your USB device (replace /dev/sdX with actual device)
lsblk

# For ARM64 hardware (Themed - Recommended)
sudo dd if=ISOs/aarch64/honey-badger-os-themed-20251101.iso \
        of=/dev/sdX \
        bs=4M \
        status=progress \
        oflag=sync

# For x86_64 hardware (Demo)
sudo dd if=ISOs/x86_64/honey-badger-os-x86_64-demo-20251101.iso \
        of=/dev/sdX \
        bs=4M \
        status=progress \
        oflag=sync
```

#### Boot from USB

1. Insert USB drive into target system
2. Access BIOS/UEFI boot menu (usually F12, F2, or Delete)
3. Select USB drive as boot device
4. Boot into Honey Badger OS

### Method 3: Direct Hardware Installation

#### ARM64 Devices (Raspberry Pi, etc.)

```bash
# Write directly to SD card
sudo dd if=ISOs/aarch64/honey-badger-os-themed-20251101.iso \
        of=/dev/mmcblk0 \
        bs=4M \
        status=progress \
        oflag=sync
```

---

## 🎯 First Boot & Setup

### Boot Process

1. **GRUB Menu**: Select boot option
   - "🦡 Honey Badger OS - Live System" (standard)
   - "🦡 Honey Badger OS - Debug Mode" (verbose)
   - "🦡 Honey Badger OS - Safe Mode" (recovery)

2. **System Initialization**:
   - Honey badger boot banner displays
   - System services start
   - Live environment loads

3. **Login Screen**:
   - Default user: `honeybadger`
   - Default password: `live`

### Initial Configuration

```bash
# Change password (recommended)
passwd

# Update system
sudo apt update
sudo apt upgrade

# Set timezone
sudo timedatectl set-timezone America/New_York

# Configure network (if needed)
sudo systemctl enable --now NetworkManager
```

---

## 🦡 Using Honey Badger OS

### Default Applications

#### Nano Editor (Featured Application)

The system is built around **nano** as the primary text editor:

```bash
# Open file with nano (themed with honey badger colors)
nano filename.txt

# Nano features enabled:
# - Syntax highlighting
# - Line numbers
# - Mouse support
# - Auto-indentation
# - Custom honey badger color scheme (brown/yellow)
```

#### System Commands

```bash
# Display honey badger banner
honey-badger-banner.sh

# View system information
cat /etc/os-release

# Check honey badger assets
ls /usr/share/pixmaps/honey-badger*
ls /usr/share/backgrounds/honey-badger*
```

### File System Layout

```
/usr/share/pixmaps/          # Honey badger icons (6 sizes)
/usr/share/backgrounds/      # Honey badger wallpapers (3 resolutions)
/usr/local/bin/             # Honey badger scripts and tools
/etc/nanorc                 # Custom nano configuration
/etc/os-release             # Honey badger OS identification
```

### Customization

#### Wallpaper Usage

```bash
# Available wallpapers
ls /usr/share/backgrounds/honey-badger*

# Set as desktop background (if using GUI)
feh --bg-scale /usr/share/backgrounds/honey-badger-1920x1080.jpg
```

#### Icon Integration

```bash
# System icons available at:
/usr/share/pixmaps/honey-badger-16.png    # 16x16
/usr/share/pixmaps/honey-badger-32.png    # 32x32
/usr/share/pixmaps/honey-badger-48.png    # 48x48
/usr/share/pixmaps/honey-badger-64.png    # 64x64
/usr/share/pixmaps/honey-badger-128.png   # 128x128
/usr/share/pixmaps/honey-badger-256.png   # 256x256
```

---

## 🔬 Advanced Features

### Development Environment

```bash
# Install development tools
sudo apt install build-essential git vim code

# Python development
sudo apt install python3-dev python3-pip python3-venv

# Node.js development
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install nodejs
```

### System Administration

```bash
# Service management
sudo systemctl status honey-badger-services
sudo systemctl enable service-name

# Log analysis
journalctl -f                    # Follow logs
journalctl -u service-name       # Service-specific logs

# System monitoring
htop                            # Process monitor
df -h                          # Disk usage
free -h                        # Memory usage
```

### Network Configuration

```bash
# Static IP configuration
sudo nano /etc/netplan/50-cloud-init.yaml

# WiFi setup (if supported)
sudo nmcli device wifi list
sudo nmcli device wifi connect "SSID" password "password"
```

### Package Management

```bash
# Update package lists
sudo apt update

# Install packages
sudo apt install package-name

# Search packages
apt search keyword

# Remove packages
sudo apt remove package-name
sudo apt autoremove
```

---

## 🛠️ Development & Building

### Building from Source

#### Prerequisites

```bash
# Install build dependencies (on host system)
sudo apt install debootstrap squashfs-tools grub-pc-bin
sudo apt install grub-efi-amd64-bin isolinux syslinux-utils
sudo apt install xorriso mtools
```

#### Build Commands

```bash
# Clone or navigate to project
cd /home/james/Honey_Badger_OS

# Build ARM64 version
cd aarch64
sudo ./scripts/build-basic-iso.sh

# Build x86_64 version (cross-compile)
cd ../x86_64
sudo ./scripts/build-simple-x86_64.sh

# Verify builds
../verify-isos.sh
```

#### Customization

```bash
# Modify configurations
nano aarch64/config/honey-badger-os.conf

# Add packages
nano aarch64/packages/package-lists.txt

# Customize theming
# Edit files in assets/ directory

# Rebuild with changes
sudo ./scripts/build-basic-iso.sh
```

### Architecture Support

- **Native ARM64**: Full production builds on ARM64 hosts
- **Cross-compile x86_64**: Demonstration builds using QEMU emulation
- **Extensible**: Framework supports adding RISC-V, PowerPC, etc.

---

## 🔍 Troubleshooting

### Common Issues

#### Boot Problems

```bash
# If ISO won't boot:
1. Verify ISO integrity: sha256sum ISOs/arch/filename.iso
2. Check UEFI/Legacy BIOS settings
3. Try different USB creation tool
4. Use debug boot option in GRUB menu
```

#### Performance Issues

```bash
# If system is slow:
1. Check available RAM: free -h
2. Monitor processes: htop
3. Check disk space: df -h
4. Review system logs: journalctl -f
```

#### Network Issues

```bash
# If network doesn't work:
1. Check interface status: ip addr show
2. Test connectivity: ping 8.8.8.8
3. Restart network service: sudo systemctl restart NetworkManager
4. Check DNS: cat /etc/resolv.conf
```

### Recovery Options

```bash
# Boot into recovery mode
# Select "Safe Mode" from GRUB menu

# Emergency shell
# Press Ctrl+Alt+F2 for TTY2

# Reset user password
sudo passwd honeybadger

# Check system integrity
sudo fsck /dev/sda1
```

### Log Analysis

```bash
# System logs
journalctl -b                   # Current boot
journalctl -p err               # Errors only
journalctl -f                   # Follow live logs

# Specific services
journalctl -u NetworkManager
journalctl -u ssh
```

---

## 🤝 Contributing

### Development Setup

1. Fork the repository
2. Set up build environment
3. Make changes to configuration or scripts
4. Test builds thoroughly
5. Submit pull request with detailed description

### Areas for Contribution

- **New Architecture Support**: Add RISC-V, PowerPC, etc.
- **Additional Theming**: Enhance visual elements
- **Package Selection**: Improve default software selection
- **Documentation**: Expand user guides and tutorials
- **Testing**: Verify compatibility across hardware

### Reporting Issues

1. Use GitHub Issues for bug reports
2. Include system specifications
3. Provide detailed reproduction steps
4. Attach relevant log files

---

## 📚 Additional Resources

### Documentation

- [Project Overview](PROJECT_OVERVIEW.md)
- [Architecture Summary](ARCHITECTURE_SUMMARY.md)
- [Nano Configuration Guide](NANO_CONFIGURATION.md)
- [ISO Documentation](ISOs/README.md)

### Community

- **GitHub**: [Honey Badger OS Repository]
- **Issues**: [Bug Reports and Feature Requests]
- **Discussions**: [Community Forum]

### External Resources

- [Debian Documentation](https://www.debian.org/doc/)
- [ARM64 Linux Guide](https://www.kernel.org/doc/html/latest/arm64/)
- [Linux Distribution Building](https://linux-from-scratch.org/)

---

**Built with 🦡 by the Honey Badger OS Team**  
*Version 1.0 "Fearless" - November 2025*

> "Like the honey badger, this OS doesn't give up and gets the job done!"
