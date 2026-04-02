# Honey Badger OS - Project Overview

## What It Is

Honey Badger OS is a **post-install automation framework** for Linux. It is not a Linux distribution — it runs on top of your existing installation to configure a complete development and desktop environment.

## Goals

1. **Multi-distro support** — A single entry point (`install.sh`) detects your distribution and runs the appropriate installer
2. **Consistent experience** — Same tools, theme, and workflow regardless of whether you run Arch, Debian, Fedora, Gentoo, openSUSE, Void, or Slackware
3. **Four installation profiles** — Full, Developer, Desktop, and Minimal to match different use cases
4. **Security-first** — No `eval`, no `curl|bash`, safe defaults, dry-run support
5. **Maintainability** — Shared library (`lib/common.sh`) eliminates code duplication across all distro scripts

## Architecture

```
install.sh  ──→  detect distro  ──→  distros/{distro}/install-{distro}.sh
                                          │
                                          ▼
                                     lib/common.sh  (shared functions)
                                          │
                                     config/honey-badger-os.conf
```

### Key Components

| Component | Purpose |
|-----------|---------|
| `install.sh` | Universal entry point — distro detection, install type selection, pre-flight checks |
| `lib/common.sh` | Shared library — logging, `hb_sudo`, theme setup, utilities, JSON output |
| `distros/*/install-*.sh` | Distro-specific installers — package lists, package manager commands, service management |
| `config/honey-badger-os.conf` | Project configuration — version, colors, feature flags |
| `config/nanorc` | Enhanced nano editor configuration with syntax highlighting |
| `theme/` | GTK2 and GTK3 theme files (goldenrod honey badger palette) |
| `assets/` | Standalone utility scripts (info, update, install) |

### Design Decisions

- **`hb_sudo()` wrapper**: All privileged commands go through `hb_sudo()` which respects `HONEY_BADGER_DRY_RUN`. This makes it safe to preview installations without root access.
- **No `eval`**: The wallpaper/asset installation previously used `eval` to execute dynamically-built strings. Now uses direct `convert` calls.
- **Distro-aware Docker repos**: The Debian installer detects the actual distribution ID (mapping derivatives like Linux Mint → Ubuntu) rather than hardcoding `ubuntu`.
- **Progress tracking**: `hb_set_total_steps(N)` + `hb_next_step("msg")` provides `[3/12] msg` progress indicators.
- **JSON summary**: Every installation writes a machine-readable summary to `/tmp/honeybadger-summary.json`.

## Testing Strategy

| Test Suite | What It Checks |
|-----------|----------------|
| `verify_scripts.sh` | Syntax (`bash -n`), file structure, required functions, package managers, parity |
| `verify_advanced.sh` | Security scanning (eval, curl\|bash, chmod 777), sudo patterns, service management |
| `test_final.sh` | Execution-level smoke tests — sourcing, dry-run, idempotency, JSON output, progress tracking |

## Supported Platforms

| Family | Package Manager | Init System | Derivatives |
|--------|----------------|-------------|-------------|
| Arch | pacman / yay | systemd | Manjaro, EndeavourOS, ArcoLinux, Artix |
| Debian | apt | systemd | Ubuntu, Mint, Pop!_OS, Elementary, Zorin, Kali |
| Fedora | dnf / yum | systemd | RHEL, CentOS, AlmaLinux, Rocky |
| Gentoo | emerge (Portage) | OpenRC / systemd | Funtoo |
| openSUSE | zypper | systemd | Leap, Tumbleweed, SLES, GeckoLinux |
| Void | xbps | runit | — |
| Slackware | slackpkg / sbopkg | SysV init | Salix |
