# Honey Badger OS - Archboot Edition

A comprehensive development-focused Linux distribution based on Arch Linux with Archboot, featuring the complete Honey Badger environment setup.

## Overview

This archboot edition provides a streamlined way to install Honey Badger OS with all the essential development tools, XFCE desktop environment, and custom theming. Built on the solid foundation of Arch Linux, it offers both the flexibility of Arch and the convenience of a pre-configured development environment.

## Features

### 🦡 **Core Honey Badger Features**

- **Custom Theme**: Earth-toned theme with Honey Badger branding
- **hb.jpg as Distro Icon**: Multiple sizes and locations for system integration
- **nano as Default Editor**: Enhanced configuration with syntax highlighting
- **Developer-Focused**: Complete development tool stack included

### 🖥️ **Desktop Environment**

- **XFCE4 Desktop**: Full desktop environment with goodies package
- **Complete Applications**:
  - Thunar file manager with plugins
  - XFCE Terminal with custom configuration
  - Panel with custom plugins and layout
  - Settings manager and system tools

### 🛠️ **Development Tools**

#### Programming Languages

- **Python** with pip, pipenv, and poetry
- **Node.js** with npm and yarn  
- **Go** with full toolchain
- **Rust** with rustup and cargo
- **C/C++** with GCC and Clang
- **Java** (OpenJDK) with development tools
- Additional languages: Ruby, PHP, Perl, Lua, Haskell

#### Code Editors & IDEs

- **nano** (enhanced configuration as default)
- **Neovim** with modern configuration
- **Visual Studio Code** with essential extensions
- **Vim** for traditional users
- Additional editors available via AUR

#### Version Control

- **Git** with sensible defaults and GitHub CLI
- **Git LFS** for large file support
- **Mercurial** and **Subversion** for legacy projects

#### Container & Cloud Tools

- **Docker** with Docker Compose
- **Kubernetes** tools (kubectl, helm, minikube)
- **Terraform** for infrastructure as code
- **Vagrant** for development environments
- **VirtualBox** and **QEMU** for virtualization

#### Database Tools

- **PostgreSQL** and **MySQL** clients
- **Redis** tools and desktop manager
- **DBeaver** universal database tool
- **MongoDB Compass** for MongoDB

#### Networking & Security

- **Wireshark** for network analysis
- **Nmap** for network scanning  
- **OpenSSL** and **GnuPG** for encryption
- **KeePassXC** password manager

### 📱 **Applications**

#### Productivity

- **LibreOffice** complete office suite
- **Firefox** as default browser (with Developer Edition)
- **Thunderbird** email client
- **GIMP** for image editing
- **VLC** media player

#### Development Utilities

- **Postman** / **Insomnia** for API testing
- **Slack** / **Discord** for team communication
- **VS Code** with development extensions

### 🎨 **Theming & Customization**

#### Honey Badger Theme

- **Dark theme** with earth tones (browns, golds, blacks)
- **Custom XFCE configuration** with Honey Badger colors
- **GTK theme** for consistent application styling
- **Icon theme** integration with hb.jpg as primary icon

#### Desktop Configuration

- **Panel configuration** with useful plugins
- **Wallpaper support** for Honey Badger images
- **Terminal theming** with custom color scheme
- **Font configuration** with programming fonts

## Installation Guide

### Prerequisites

1. **Download** the Honey Badger Archboot ISO
2. **Boot** from the ISO on your target system
3. **Network connection** for package downloads

### Quick Installation

#### Option 1: Automated Setup

```bash
# After booting from ISO
/honey-badger/scripts/quick-setup.sh
```

#### Option 2: Manual Installation

1. **Install base Arch Linux**:

   ```bash
   # Partition disk (example for UEFI)
   cfdisk /dev/sda
   
   # Format partitions
   mkfs.fat -F32 /dev/sda1      # EFI partition
   mkfs.ext4 /dev/sda2          # Root partition
   
   # Mount partitions
   mount /dev/sda2 /mnt
   mkdir -p /mnt/boot
   mount /dev/sda1 /mnt/boot
   
   # Install base system
   pacstrap /mnt base linux linux-firmware nano
   
   # Generate fstab
   genfstab -U /mnt >> /mnt/etc/fstab
   
   # Chroot into system
   arch-chroot /mnt
   
   # Basic configuration
   ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
   hwclock --systohc
   echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
   locale-gen
   echo "LANG=en_US.UTF-8" > /etc/locale.conf
   echo "honeybadger" > /etc/hostname
   
   # Set root password
   passwd
   
   # Create user
   useradd -m -G wheel -s /bin/bash username
   passwd username
   
   # Install bootloader (systemd-boot for UEFI)
   bootctl install
   
   # Configure bootloader
   echo "title Honey Badger OS
   linux /vmlinuz-linux
   initrd /initramfs-linux.img
   options root=/dev/sda2 rw" > /boot/loader/entries/honeybadger.conf
   
   # Enable sudo for wheel group
   echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
   
   # Exit chroot
   exit
   ```

2. **Run Honey Badger setup**:

   ```bash
   /honey-badger/install-honey-badger.sh
   ```

3. **Reboot** into your new system:

   ```bash
   umount -R /mnt
   reboot
   ```

### Installation Types

#### Full Installation

- Complete XFCE desktop environment
- All development tools and languages
- Productivity applications
- Multimedia support
- **Recommended for most users**

#### Minimal Installation  

- Essential system tools only
- nano editor configuration
- Basic development utilities
- **For servers or resource-constrained systems**

#### Developer Focus

- Programming languages and tools
- Code editors and IDEs
- Version control systems
- Container and cloud tools
- **Perfect for software developers**

#### Desktop Focus

- XFCE desktop environment
- Office and productivity applications
- Media applications
- System utilities
- **Great for general desktop use**

## Post-Installation

### First Steps

After rebooting into your new Honey Badger OS:

1. **Check system info**:

   ```bash
   honey-badger-info
   ```

2. **Update system**:

   ```bash
   honey-badger-update
   ```

3. **Backup configuration**:

   ```bash
   honey-badger-backup
   ```

### Customization

#### Theme Customization

- Theme files located in `/honey-badger/theme/`
- XFCE settings in `~/.config/xfce4/`
- GTK theme in `~/.config/gtk-3.0/`

#### Adding More Software

```bash
# Official repositories
sudo pacman -S package-name

# AUR packages (yay is pre-installed)
yay -S aur-package-name
```

#### Development Environment

- Default editor: `nano` (configured in `/etc/environment`)
- Development directory: `~/Development/`
- Git configured with sensible defaults

### Utility Scripts

#### honey-badger-info

Shows system information and installed tools:

```bash
honey-badger-info
```

#### honey-badger-update

Updates system and development tools:

```bash
honey-badger-update
```

#### honey-badger-backup

Backs up user configurations:

```bash
honey-badger-backup
```

## File Structure

```
/honey-badger/
├── assets/
│   ├── hb.jpg                    # Main distro icon
│   └── wallpapers/               # Honey Badger wallpapers
├── config/
│   ├── nanorc-enhanced          # Enhanced nano configuration
│   └── developer-packages.conf  # Package lists
├── scripts/
│   ├── post-install-setup.sh    # Main installation script
│   └── quick-setup.sh           # Quick setup wizard
├── theme/
│   ├── honeybadger.colors       # Theme color definitions
│   └── honey-badger-gtk.css     # GTK theme CSS
├── install-honey-badger.sh      # Main installer
└── README.md                    # This file
```

## Troubleshooting

### Common Issues

#### Package Installation Fails

```bash
# Update package databases
sudo pacman -Sy

# Clear package cache if needed
sudo pacman -Sc
```

#### Display Manager Issues

```bash
# Enable lightdm
sudo systemctl enable lightdm
sudo systemctl start lightdm
```

#### Network Issues

```bash
# Enable NetworkManager
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager
```

#### Theme Not Applied

```bash
# Reapply theme
xfconf-query -c xsettings -p /Net/ThemeName -s "HoneyBadger"
```

### Getting Help

1. **Check system logs**:

   ```bash
   journalctl -xe
   ```

2. **Verify installation**:

   ```bash
   honey-badger-info
   ```

3. **Community support**: GitHub issues and discussions

## Development

### Building the ISO

To build your own Honey Badger Archboot ISO:

```bash
cd /path/to/honey-badger-os/archboot
./build-honey-badger-archboot.sh
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with the build system
5. Submit a pull request

## License

Honey Badger OS is released under the MIT License. Individual packages maintain their respective licenses.

## Acknowledgments

- **Arch Linux** team for the excellent base system
- **Archboot** project for the installation framework  
- **XFCE** team for the desktop environment
- **nano** developers for the excellent editor
- All the open-source projects that make this possible

---

**Honey Badger OS** - Because development should be fearless! 🦡
