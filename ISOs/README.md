# Honey Badger OS - ISO Images

This directory contains all bootable ISO images for **Honey Badger OS** organized by CPU architecture.

## 📀 Available ISOs

### ARM64 (AArch64) Architecture

#### `honey-badger-os-basic-20251101.iso` (347MB)

- **Type**: Production-ready ARM64 distribution
- **Base**: Debian Bookworm with essential tools
- **Features**:
  - Nano editor as default (system-wide)
  - Basic honey badger branding
  - SSH server and networking tools
  - Minimal but functional system

#### `honey-badger-os-themed-20251101.iso` (348MB) ⭐ **RECOMMENDED**

- **Type**: Fully themed ARM64 distribution
- **Base**: Same as basic + complete visual theming
- **Features**:
  - Complete honey badger visual branding
  - Custom icons (6 sizes: 16px-256px)
  - Wallpapers (3 resolutions)
  - Themed nano editor (brown/yellow colors)
  - Honey badger banner and MOTD
  - Custom OS identification
  - All visual assets integrated

### x86_64 Architecture

#### `honey-badger-os-x86_64-demo-20251101.iso` (11MB)

- **Type**: Demonstration x86_64 system
- **Base**: Minimal cross-compiled system
- **Features**:
  - Proof-of-concept x86_64 build
  - Honey badger branding and assets
  - Shows multi-architecture capability
  - Lightweight demonstration system

## 🚀 Usage Instructions

### Boot ARM64 ISOs

```bash
# Recommended: Boot the fully themed version
qemu-system-aarch64 -M virt -m 2G -cpu cortex-a57 \
  -cdrom ISOs/aarch64/honey-badger-os-themed-20251101.iso

# Alternative: Boot the basic version
qemu-system-aarch64 -M virt -m 2G -cpu cortex-a57 \
  -cdrom ISOs/aarch64/honey-badger-os-basic-20251101.iso
```

### Boot x86_64 ISO

```bash
# Boot the demonstration x86_64 version
qemu-system-x86_64 -m 2G \
  -cdrom ISOs/x86_64/honey-badger-os-x86_64-demo-20251101.iso
```

### Write to USB Drive

```bash
# For ARM64 systems (like Raspberry Pi 4, Apple Silicon, etc.)
sudo dd if=ISOs/aarch64/honey-badger-os-themed-20251101.iso of=/dev/sdX bs=4M status=progress

# For x86_64 systems (Intel/AMD)
sudo dd if=ISOs/x86_64/honey-badger-os-x86_64-demo-20251101.iso of=/dev/sdX bs=4M status=progress
```

*Replace `/dev/sdX` with your actual USB device*

## 🦡 Honey Badger Features

All ISOs include the signature **Honey Badger OS** experience:

- **Nano Editor**: Custom configuration with honey badger color scheme
- **Visual Identity**: Consistent branding across all architectures  
- **System Integration**: Honey badger theming from boot to desktop
- **Professional Quality**: Production-ready distribution design

## 📊 ISO Comparison

| Feature | Basic ARM64 | Themed ARM64 | Demo x86_64 |
|---------|-------------|--------------|-------------|
| Size | 347MB | 348MB | 11MB |
| Architecture | ARM64 | ARM64 | x86_64 |
| Theming | Basic | Complete | Complete |
| Status | Production | Production | Demo |
| Bootable | ✅ | ✅ | ✅ |
| Installer | ✅ | ✅ | ⚠️ Demo |

---

**Built**: November 1, 2025  
**Project**: [Honey Badger OS](../README.md)  
**Architecture Support**: ARM64 (native) + x86_64 (cross-compiled)
