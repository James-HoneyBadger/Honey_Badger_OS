# Building Honey Badger OS ARM64

This guide explains how to build a full-featured ARM64 ISO of Honey Badger OS that works reliably without kernel panics.

## Overview

The ARM64 build includes:

- **Hardware Support**: Comprehensive driver support for ARM64 devices
- **System Stability**: Kernel parameters and configurations to prevent panics
- **Full Desktop Environment**: XFCE4 with all productivity applications
- **Development Tools**: Complete development environment
- **Reliable Bootloader**: Properly configured GRUB-EFI for ARM64

## Build Requirements

### System Requirements

- **Disk Space**: At least 8GB free space
- **Memory**: 4GB RAM minimum (8GB recommended)
- **Internet**: Broadband connection for package downloads
- **Time**: 30-60 minutes depending on system performance

### Software Requirements

#### Option 1: Docker Build (Recommended for macOS/Windows)

- Docker Desktop installed and running
- No additional software required

#### Option 2: Native Linux Build

- Debian/Ubuntu-based Linux distribution
- Root access (sudo privileges)
- Required packages:

  ```bash
  sudo apt-get install debootstrap live-build squashfs-tools xorriso \
                       grub-efi-arm64 grub-efi-arm64-signed \
                       qemu-user-static binfmt-support calamares
  ```

## Quick Start

### Using Docker (Recommended)

1. **Install Docker Desktop** (if not already installed)
   - macOS: Download from [Docker.com](https://www.docker.com/products/docker-desktop)
   - Windows: Download from [Docker.com](https://www.docker.com/products/docker-desktop)
   - Linux: `sudo apt-get install docker.io docker-compose`

2. **Check Requirements**

   ```bash
   ./build-aarch64.sh check
   ```

3. **Build the ISO**

   ```bash
   ./build-aarch64.sh docker
   ```

### Using Native Linux Build

1. **Install Dependencies**

   ```bash
   sudo apt-get update
   sudo apt-get install debootstrap live-build squashfs-tools xorriso \
                        grub-efi-arm64 grub-efi-arm64-signed \
                        qemu-user-static binfmt-support calamares \
                        calamares-settings-debian
   ```

2. **Check Requirements**

   ```bash
   ./build-aarch64.sh check
   ```

3. **Build the ISO** (requires root)

   ```bash
   sudo ./build-aarch64.sh native
   ```

## Build Process Details

The build process includes several stages:

### 1. Environment Setup

- Creates isolated build environment
- Installs cross-compilation tools
- Configures ARM64 emulation (if needed)

### 2. Base System Creation

- Downloads Debian ARM64 packages
- Creates minimal bootable system
- Installs kernel and essential drivers

### 3. Package Installation

- **Base Packages**: Core system utilities and drivers
- **XFCE Desktop**: Complete desktop environment
- **Applications**: Office suite, browsers, multimedia tools
- **Development Tools**: Compilers, editors, version control

### 4. Hardware Configuration

- ARM64-specific kernel modules
- Hardware detection scripts
- Driver optimization for common ARM64 devices

### 5. System Hardening

- Stability configurations to prevent kernel panics
- Memory management optimization
- Boot parameter tuning

### 6. Bootloader Setup

- GRUB-EFI configuration for ARM64
- EFI boot manager setup
- Fallback boot options

### 7. ISO Creation

- Live system assembly
- Hybrid ISO generation (USB/DVD bootable)
- Integrity verification

## Build Output

After successful completion, you'll find:

```
ISOs/
└── honey-badger-os-1.0-arm64.iso    # Main ISO file (~3-4GB)
```

## Customization Options

### Package Selection

Edit the package lists in `aarch64/packages/`:

- `base-packages.list`: Core system packages
- `xfce-packages.list`: Desktop environment
- `applications.list`: User applications  
- `developer-packages.list`: Development tools

### System Configuration

Modify files in `aarch64/config/`:

- `honey-badger-os.conf`: Main build configuration
- `environment`: System environment variables
- `nanorc`: Default editor configuration

### Hardware Support

Add custom hardware support in `aarch64/scripts/hooks/`:

- `01-hardware-support.hook.chroot`: Hardware drivers
- `02-system-stability.hook.chroot`: Stability settings
- `04-bootloader-config.hook.chroot`: Boot configuration

## Troubleshooting

### Common Issues

**Build fails with "Permission denied"**

- Ensure you're running as root for native builds
- For Docker builds, ensure Docker has proper permissions

**"Insufficient disk space" error**

- Free up at least 8GB of disk space
- Clean previous builds: `./build-aarch64.sh clean`

**Package download failures**

- Check internet connection
- Verify Debian mirrors are accessible
- Try building again (temporary mirror issues)

**ARM64 emulation errors** (Docker builds)

- Ensure Docker has privileged access
- Restart Docker service
- Update Docker to latest version

### Build Logs

Build logs are available in:

- Docker builds: Container output
- Native builds: `/tmp/honey-badger-build/build.log`

### Clean Rebuild

To start fresh:

```bash
./build-aarch64.sh clean
./build-aarch64.sh [docker|native]
```

## Testing the ISO

### Virtual Testing

- **QEMU**: Test ARM64 ISO with QEMU emulation
- **UTM** (macOS): Native ARM64 virtualization

### Physical Testing

- **Raspberry Pi 4/5**: Boot from USB
- **ARM64 Laptops**: Boot from USB/SD card
- **ARM64 Servers**: IPMI virtual media

### Boot Test Command (QEMU)

```bash
qemu-system-aarch64 \
  -M virt \
  -cpu cortex-a57 \
  -m 2048 \
  -bios /usr/share/qemu-efi-aarch64/QEMU_EFI.fd \
  -cdrom ISOs/honey-badger-os-1.0-arm64.iso \
  -boot d
```

## Features Included

### Hardware Compatibility

- ✅ Raspberry Pi 4/5 support
- ✅ ARM64 laptops and desktops
- ✅ USB 3.0/3.1 devices
- ✅ Common WiFi chipsets
- ✅ Bluetooth support
- ✅ Audio (HDMI, USB, analog)

### Software Stack

- ✅ **Kernel**: Linux 6.11+ with ARM64 optimizations
- ✅ **Desktop**: XFCE4 with custom theming
- ✅ **Browser**: Firefox ESR + Chromium
- ✅ **Office**: LibreOffice suite
- ✅ **Development**: Python, Node.js, Java, C/C++, Rust, Go
- ✅ **Editors**: nano (default), vim, VS Code
- ✅ **Graphics**: GIMP, Inkscape, Blender

### System Features

- ✅ **Live Boot**: Run without installation
- ✅ **Installer**: Calamares graphical installer
- ✅ **Persistence**: Save changes to USB drive
- ✅ **Recovery**: Boot repair and recovery tools
- ✅ **Security**: Encrypted installation option

## Performance Optimizations

The ARM64 build includes several optimizations:

1. **Memory Management**: Tuned for ARM64 systems
2. **I/O Scheduling**: Optimized for ARM storage controllers
3. **CPU Scaling**: Dynamic frequency scaling
4. **Power Management**: Battery optimization for laptops

## Support and Updates

### Getting Help

- Check build logs for specific errors
- Verify system requirements are met
- Clean and retry build process

### Updates

- Package lists are updated for current Debian stable
- Kernel version configured for latest ARM64 support
- Hardware compatibility regularly improved

## Advanced Usage

### Custom Kernel

To use a different kernel version, edit `aarch64/config/honey-badger-os.conf`:

```bash
KERNEL_VERSION="6.12"  # Change version
```

### Additional Repositories

Add custom repositories in the build script's `configure_apt_sources()` function.

### Boot Parameters

Customize boot parameters in `aarch64/scripts/hooks/04-bootloader-config.hook.chroot`.

---

**Build Time**: Expect 30-60 minutes for complete build
**ISO Size**: Approximately 3-4GB
**Target**: ARM64/AArch64 systems (64-bit ARM)
**Base**: Debian Bookworm (stable)
