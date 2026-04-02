# 🦡 Honey Badger OS

## Fearless Multi-Distribution Post-Install Scripts

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Transform any supported Linux distribution into a **fearless development powerhouse** with the Honey Badger attitude — determined, uncompromising, and ready for anything!

## Overview

Honey Badger OS is a collection of post-install scripts that automate the setup of a complete development and desktop environment on fresh Linux installations. It is **not** a Linux distribution — it runs on top of your existing distro.

### Supported Distributions

| Family | Distributions |
|--------|--------------|
| **Arch** | Arch Linux, Manjaro, EndeavourOS, ArcoLinux, Artix |
| **Debian** | Debian, Ubuntu, Linux Mint, Pop!_OS, Elementary, Zorin, Kali |
| **Fedora** | Fedora, RHEL, CentOS, AlmaLinux, Rocky Linux |
| **Gentoo** | Gentoo, Funtoo |
| **openSUSE** | openSUSE Tumbleweed, openSUSE Leap, SLES, GeckoLinux |
| **Void** | Void Linux (glibc and musl) |
| **Slackware** | Slackware, Salix |

## Quick Start

```bash
git clone https://github.com/James-HoneyBadger/Honey_Badger_OS.git
cd Honey_Badger_OS
chmod +x install.sh
./install.sh
```

### Non-Interactive / CI Mode

```bash
export HONEY_BADGER_NONINTERACTIVE=1
export HONEY_BADGER_INSTALL_TYPE=full
./install.sh
```

### Dry-Run Mode

Preview what would happen without making changes:

```bash
./install.sh --dry-run
```

## Installation Types

| Type | Description | Size |
|------|-------------|------|
| **Full** | Complete XFCE desktop + full dev stack + productivity suite + theme | ~3-5 GB |
| **Developer** | Programming languages + containers + basic desktop + editors | ~2-3 GB |
| **Desktop** | XFCE desktop + productivity apps + basic dev tools + theme | ~2-3 GB |
| **Minimal** | Essential CLI tools + nano config + monitoring tools | ~500 MB-1 GB |

## What Gets Installed

### Base (all types)
- System utilities: `curl`, `wget`, `git`, `htop`, `neofetch`, `tmux`, `tree`
- Network tools: `openssh`, `rsync`, `nmap`
- Disk tools: `gparted`, `ntfs-3g`, `exfat-utils`
- Fonts: DejaVu, Liberation, Noto (including emoji)

### Developer Stack
- **Languages**: Python 3, Node.js, Go, Rust, Java (OpenJDK), Ruby
- **Build tools**: CMake, Ninja, Meson, Make, GCC, Clang
- **Containers**: Docker, Docker Compose
- **Databases**: PostgreSQL client, SQLite, Redis
- **Editors**: Neovim, enhanced Nano with syntax highlighting

### Desktop Environment
- XFCE4 with Whisker Menu, panel plugins, Thunar file manager
- LightDM display manager
- Custom Honey Badger GTK2/GTK3 theme (goldenrod palette)
- Application launchers: Rofi, dmenu

### Applications
- **Browsers**: Firefox, Chromium
- **Office**: LibreOffice
- **Media**: VLC, GIMP, Inkscape, Audacity, FFmpeg
- **Communication**: Thunderbird, Telegram Desktop

## Architecture

```
Honey_Badger_OS/
├── install.sh              # Universal installer (distro detection + dispatch)
├── lib/
│   └── common.sh           # Shared library (logging, hb_sudo, theme, utilities)
├── distros/
│   ├── arch/install-arch.sh
│   ├── debian/install-debian.sh
│   ├── fedora/install-fedora.sh
│   ├── gentoo/install-gentoo.sh
│   ├── opensuse/install-opensuse.sh
│   ├── slackware/install-slackware.sh
│   └── void/install-void.sh
├── config/
│   ├── honey-badger-os.conf  # Project configuration
│   └── nanorc                 # Enhanced nano config
├── theme/
│   ├── honey-badger-theme.css  # GTK3 theme
│   └── gtkrc-2.0              # GTK2 theme
├── assets/
│   ├── honey-badger-info      # System info script
│   ├── honey-badger-update    # System update script
│   └── honey-badger-install   # Package install helper
├── verify_scripts.sh          # Static verification tests
├── verify_advanced.sh         # Security & robustness tests
└── test_final.sh              # Execution-level smoke tests
```

### Shared Library (`lib/common.sh`)

All distro scripts source a shared library to eliminate code duplication:

- **`hb_sudo`** — Sudo wrapper that respects `--dry-run` mode
- **`hb_next_step` / `hb_set_total_steps`** — Progress tracking (`[3/12]`)
- **`log_info`, `log_success`, `log_error`, `log_warning`** — Consistent logging
- **`ensure_bashrc_line`** — Idempotent bashrc modifications
- **`setup_nano`, `setup_honey_badger_theme`, `setup_xfce`** — Shared configuration
- **`hb_json_init`, `hb_json_add_package`, `hb_json_write`** — Machine-readable output

## Utility Commands

After installation, these commands are available:

| Command | Description |
|---------|-------------|
| `honey-badger-info` | Display system information |
| `honey-badger-update` | Update system and all packages |
| `honey-badger-install <pkg>` | Install packages via native package manager |

## Testing & Verification

```bash
# Static checks (syntax, structure, parity)
bash verify_scripts.sh

# Security + robustness checks
bash verify_advanced.sh

# Execution-level smoke tests
bash test_final.sh
```

## Security

- No `eval` usage — eliminates injection vectors
- No `curl | bash` — downloads are saved to temp files before execution
- `hb_sudo` wrapper supports dry-run mode for safe previews
- GPG key imports use `--batch --yes` flags
- Docker repository detection uses actual distro ID (not hardcoded)
- All downloads use HTTPS

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Run all tests: `bash verify_scripts.sh && bash verify_advanced.sh && bash test_final.sh`
4. Commit and push
5. Open a Pull Request

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

*Honey Badger don't care. Honey Badger is fearless! 🦡*
