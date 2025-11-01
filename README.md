# Honey Badger OS

> **🦡 Fearless Multi-Architecture Linux Distribution**

Honey Badger OS is a custom Linux distribution with complete honey badger theming, multi-architecture support, and a focus on the nano text editor. Like its namesake, this OS is fearless, resilient, and gets the job done without giving up.

## 📚 Complete Documentation

**For full details, see our comprehensive documentation:**

- **[📖 USER GUIDE](USER_GUIDE.md)** - Complete user documentation, installation, and usage
- **[🚀 RELEASES](RELEASES.md)** - Version information, downloads, and release notes
- **[🏗️ PROJECT OVERVIEW](PROJECT_OVERVIEW.md)** - Project goals, architecture, and roadmap  
- **[⚙️ ARCHITECTURE SUMMARY](ARCHITECTURE_SUMMARY.md)** - Technical implementation details
- **[💿 ISO Documentation](ISOs/README.md)** - Available ISO images and usage

## 🚀 Quick Start

### Available ISOs (705MB Total)

**ARM64 (AArch64) - Production Ready:**

- `honey-badger-os-basic-20251101.iso` (347MB) - Minimal functional system
- `honey-badger-os-themed-20251101.iso` (348MB) ⭐ **RECOMMENDED** - Full theming

**x86_64 - Cross-Compilation Demo:**

- `honey-badger-os-x86_64-demo-20251101.iso` (11MB) - Architecture demonstration

### Boot with QEMU

```bash
# ARM64 Themed (Recommended)
qemu-system-aarch64 -M virt -m 4G -cpu cortex-a57 \
  -device virtio-gpu-pci -device qemu-xhid \
  -cdrom ISOs/aarch64/honey-badger-os-themed-20251101.iso

# x86_64 Demo
qemu-system-x86_64 -m 2G \
  -cdrom ISOs/x86_64/honey-badger-os-x86_64-demo-20251101.iso
```

## ✨ Key Features

### 🦡 **Complete Honey Badger Theming**

- 6 icon sizes (16px-256px) with honey badger branding
- 3 wallpaper resolutions optimized for different displays  
- Custom nano editor colors (brown/yellow theme)
- Boot banners, MOTD, and complete visual identity

### 🏗️ **Multi-Architecture Support**

- **ARM64**: Native compilation with full production features
- **x86_64**: Cross-compilation with QEMU emulation
- **Extensible**: Framework ready for RISC-V, PowerPC, etc.

### 📝 **Nano Editor Focus**

- Enhanced nano editor as the system default
- Custom color scheme matching honey badger theme
- Optimized configuration for development work
- Syntax highlighting and modern features

### 🔧 **Professional Build System**

- **Build Tools**: Make, CMake, Autotools, Ninja, Meson
- **Debugging**: GDB, Valgrind, Strace

### 📦 **Installation**

- **Calamares installer** with custom branding
- Graphical installation with partitioning support
- Live system for testing before installation
- Custom user setup and system configuration

### 🎨 **Applications**

- **Web Browsers**: Firefox ESR, Chromium
- **Office Suite**: LibreOffice with GTK3 integration
- **Multimedia**: VLC, Audacity, GIMP, Inkscape, Blender
- **System Tools**: GParted, Synaptic, System Monitor
- **Communication**: Thunderbird, Pidgin, HexChat

## System Requirements

### Minimum Requirements

- **Processor**: ARM64/AArch64 compatible CPU
- **Memory**: 2 GB RAM (4 GB recommended)
- **Storage**: 8 GB available space (16 GB recommended)
- **Graphics**: Any ARM64 compatible GPU with basic 2D acceleration

### Recommended Specifications

- **Processor**: Modern ARM64 CPU (Cortex-A75 or newer)
- **Memory**: 8 GB RAM or more
- **Storage**: 32 GB SSD or faster storage
- **Graphics**: GPU with OpenGL 2.0+ support
- **Network**: Ethernet or Wi-Fi capability

## Quick Start

### 1. Download and Verify

```bash
# Download the latest ISO (replace with actual URL when available)
wget https://releases.honeybadger-os.org/honey-badger-os-1.0-arm64.iso

# Verify checksum
sha256sum honey-badger-os-1.0-arm64.iso
```

### 2. Create Installation Media

```bash
# For ARM64 devices with SD card support
dd if=honey-badger-os-1.0-arm64.iso of=/dev/sdX bs=4M status=progress
sync
```

### 3. Boot and Install

1. Insert installation media and boot from it
2. Select "Install Honey Badger OS" from the boot menu
3. Follow the Calamares installer steps
4. Reboot and enjoy your new system!

## Building from Source

### Prerequisites

- Debian/Ubuntu-based build system
- At least 10 GB free disk space
- 4 GB RAM minimum (8 GB recommended)
- Root access for the build process

### Build Process

#### 1. Clone and Setup

```bash
git clone https://github.com/honeybadger-os/honeybadger-os.git
cd honeybadger-os
./scripts/setup.sh
```

#### 2. Customize (Optional)

```bash
# Edit main configuration
nano config/honey-badger-os.conf

# Customize package selection
nano packages/developer-packages.list
nano packages/applications.list

# Modify theme
nano theme/honey-badger-theme.css
```

#### 3. Build ISO

```bash
# Build the distribution (requires root)
sudo ./scripts/build-iso.sh
```

The build process will:

1. Install build dependencies
2. Create the live-build environment
3. Configure APT sources for ARM64
4. Install all specified packages
5. Apply custom configurations and themes
6. Generate the bootable ISO image

#### 4. Output

The completed ISO will be located at:

```
build/iso/honey-badger-os-1.0-arm64.iso
```

## Configuration

### Package Management

Honey Badger OS uses APT as the primary package manager with these sources configured:

```bash
# Main Debian repositories
deb http://deb.debian.org/debian bookworm main contrib non-free
deb http://security.debian.org/debian-security bookworm-security main contrib non-free
deb http://deb.debian.org/debian bookworm-updates main contrib non-free
```

### Default User

- **Username**: Created during installation via Calamares
- **Groups**: users, sudo, audio, video, netdev, plugdev
- **Shell**: Bash with completion
- **Desktop**: XFCE4 with Honey Badger theme
- **Default Editor**: Nano (configured system-wide)

### Network Configuration

- **Network Manager**: For Wi-Fi and Ethernet
- **SSH**: OpenSSH server (disabled by default)
- **Firewall**: UFW (uncomplicated firewall)

## Customization

### Adding Packages

Edit the package lists in the `packages/` directory:

- `base-packages.list` - Essential system packages
- `xfce-packages.list` - Desktop environment
- `developer-packages.list` - Development tools
- `applications.list` - User applications

### Theming

The custom Honey Badger theme can be modified:

- **GTK Theme**: `theme/honey-badger-theme.css`
- **Color Scheme**: Dark background (#2B2B2B) with honey gold accents (#FFB000)
- **Icons**: Compatible with most icon themes

### Default Editor

Nano is configured as the system-wide default editor:

- **Environment Variables**: `EDITOR`, `VISUAL`, `GIT_EDITOR` all set to nano
- **System Alternatives**: Nano is set as the default through update-alternatives
- **Configuration**: User-friendly nano settings with syntax highlighting, line numbers, and mouse support
- **Location**: Global config in `/etc/nanorc`, user config in `~/.nanorc`

### Calamares Installer

Installer configuration is in the `calamares/` directory:

- `settings.conf` - Main installer configuration
- `branding.desc` - Custom branding and appearance
- `users.conf` - User creation settings

## Troubleshooting

### Build Issues

#### Cross-compilation Problems

If building on x86_64 for ARM64:

```bash
# Install cross-compilation tools
sudo apt install gcc-aarch64-linux-gnu qemu-user-static
sudo update-binfmts --enable qemu-aarch64
```

#### Insufficient Space

```bash
# Check available space
df -h
# Clean build directory if needed
sudo ./scripts/clean-build.sh
```

#### Package Installation Failures

```bash
# Update package lists
sudo apt update
# Check for broken packages
sudo apt --fix-broken install
```

### Runtime Issues

#### Graphics Problems

- Ensure ARM64 graphics drivers are installed
- Check X.org log: `sudo journalctl -u display-manager`

#### Wi-Fi Not Working

- Install additional firmware: `sudo apt install firmware-misc-nonfree`
- Check network interfaces: `ip link show`

#### Application Crashes

- Check system logs: `sudo journalctl -f`
- Verify architecture compatibility: `file /path/to/application`

## Development

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the build process
5. Submit a pull request

### Project Structure

```
honey-badger-os/
├── build/              # Build output directory
├── calamares/          # Installer configuration
├── config/             # System configuration
├── packages/           # Package lists
├── scripts/            # Build scripts
├── theme/              # Custom theme files
├── live-build/         # Live-build working directory
└── README.md          # This file
```

### Adding New Features

1. Update package lists if new software is needed
2. Add configuration files to `config/`
3. Update build scripts if necessary
4. Test thoroughly on target hardware
5. Update documentation

## Support

### Documentation

- **User Guide**: Available in `/usr/share/doc/honeybadger-os/`
- **Man Pages**: Standard Linux documentation via `man`
- **Online Wiki**: <https://wiki.honeybadger-os.org>

### Community

- **Forum**: <https://forum.honeybadger-os.org>
- **IRC**: #honeybadger-os on Libera.Chat
- **Matrix**: #honeybadger-os:matrix.org

### Bug Reports

Report issues at: <https://github.com/honeybadger-os/honeybadger-os/issues>

Please include:

- Hardware information (`lscpu`, `lsusb`, `lspci`)
- System logs (`journalctl -b`)
- Steps to reproduce the issue
- Expected vs actual behavior

## License

Honey Badger OS is distributed under the GNU General Public License v3.0.
See the `LICENSE` file for details.

Individual packages included in the distribution retain their original licenses.

## Credits

### Built On

- **Debian GNU/Linux** - Base system and packages
- **XFCE Desktop Environment** - Desktop interface
- **Calamares** - System installer
- **Live-Build** - ISO creation toolkit

### Inspired By

The fearless honey badger (Mellivora capensis), known for its tenacious and fearless nature.

---

**Honey Badger OS** - *Because your development environment should be as fearless as you are.*
