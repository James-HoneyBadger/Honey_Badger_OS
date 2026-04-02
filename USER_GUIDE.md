# Honey Badger OS - User Guide

## Prerequisites

- A fresh or existing Linux installation (see supported distros below)
- A regular user account with sudo privileges
- Internet connectivity
- At least 1 GB free disk space (5 GB recommended for full install)

## Supported Distributions

- **Arch Linux** family: Arch, Manjaro, EndeavourOS, ArcoLinux, Artix
- **Debian** family: Debian, Ubuntu, Linux Mint, Pop!_OS, Elementary, Zorin, Kali
- **Fedora** family: Fedora, RHEL, CentOS, AlmaLinux, Rocky Linux
- **Gentoo** family: Gentoo, Funtoo
- **openSUSE** family: openSUSE Tumbleweed, openSUSE Leap, SLES, GeckoLinux
- **Void Linux** (glibc and musl)
- **Slackware** family: Slackware, Salix

## Installation

### 1. Download

```bash
git clone https://github.com/James-HoneyBadger/Honey_Badger_OS.git
cd Honey_Badger_OS
```

### 2. Run the Installer

```bash
chmod +x install.sh
./install.sh
```

The installer will:
1. Detect your Linux distribution
2. Ask you to choose an installation type
3. Show a summary and ask for confirmation
4. Run the appropriate distro-specific installer

### 3. Choose an Installation Type

| Type | Best For |
|------|----------|
| **Full** | New installations where you want everything configured |
| **Developer** | Developers who need languages, containers, and build tools |
| **Desktop** | Users who want a themed XFCE desktop with productivity apps |
| **Minimal** | Servers or minimal setups — CLI tools only, no desktop |

## Advanced Usage

### Non-Interactive Mode

For scripted or CI environments:

```bash
export HONEY_BADGER_NONINTERACTIVE=1
export HONEY_BADGER_INSTALL_TYPE=developer
./install.sh
```

### Dry-Run Mode

Preview what would happen without making any system changes:

```bash
./install.sh --dry-run
```

Or combine with non-interactive:

```bash
HONEY_BADGER_NONINTERACTIVE=1 HONEY_BADGER_INSTALL_TYPE=full ./install.sh --dry-run
```

### Environment Variables

| Variable | Values | Description |
|----------|--------|-------------|
| `HONEY_BADGER_INSTALL_TYPE` | `full`, `developer`, `desktop`, `minimal` | Installation profile |
| `HONEY_BADGER_NONINTERACTIVE` | `1` | Skip confirmation prompts |
| `HONEY_BADGER_DRY_RUN` | `1` | Print commands instead of executing |
| `CI` | `true` | Also enables non-interactive mode |

## Post-Installation

### Utility Commands

After installation, these commands are available in `~/.local/bin/`:

```bash
honey-badger-info      # System information
honey-badger-update    # Update all system packages
honey-badger-install   # Install packages via native package manager
```

### What Changed on Your System

- **Packages**: Installed via your distro's package manager
- **Nano config**: Enhanced syntax highlighting in `~/.nanorc`
- **Bashrc**: Added PATH for `~/.local/bin` and utility aliases
- **Git**: Configured with safe defaults (if not already configured)
- **Theme**: Honey Badger GTK2/GTK3 theme installed (desktop/full types)
- **XFCE**: Configured with Whisker Menu, panel layout, dark theme (desktop/full types)
- **Docker**: Installed and user added to docker group (developer/full types)

### Rebooting

For desktop installations (full, desktop, developer), reboot to start the display manager:

```bash
sudo reboot
```

For minimal installations, restart your shell:

```bash
source ~/.bashrc
```

## Troubleshooting

### "No internet connectivity detected"

The installer pings `google.com` and `8.8.8.8`. If both fail, check your network configuration.

### "This script should not be run as root!"

Run as a regular user, not with `sudo ./install.sh`. The script uses `sudo` internally for privileged operations.

### "Insufficient disk space"

Free at least 1 GB on your root partition.

### Package installation failures

Some packages may not be available on all distros. Warnings are logged but don't stop the installation. Check the log file at `/tmp/honeybadger-<distro>-install.log`.

### JSON Summary

Every installation produces a machine-readable summary at `/tmp/honeybadger-summary.json` containing:
- Installed packages
- Configuration changes
- Any errors encountered

## Uninstalling

Honey Badger OS does not provide an automated uninstaller. Packages were installed via your distro's package manager and can be removed normally. Configuration files are placed in standard locations (`~/.nanorc`, `~/.config/`, `~/.local/bin/`).
