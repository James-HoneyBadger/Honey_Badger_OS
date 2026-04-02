# Changelog

All notable changes to Honey Badger OS will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-04-02

### Added
- **Shared library** (`lib/common.sh`) — eliminates code duplication across all 5 distro scripts
- **`--help` flag** — shows usage, flags, environment variables, and supported distros
- **`--no-color` flag** — disables colored output; also honors `NO_COLOR` env var (no-color.org)
- **`--verbose` / `--quiet` flags** — control log verbosity (debug, normal, errors-only)
- **`--skip-docker`, `--skip-python`, `--skip-node`, `--skip-nano`** — granular component control
- **Signal trapping & cleanup** — removes temp files and saves checkpoint on interrupt
- **Lock file** — prevents concurrent `install.sh` runs via `flock`
- **Config backup** — backs up `~/.bashrc`, `~/.nanorc`, `/etc/inittab` before overwriting (`.hb-backup`)
- **Checkpoint / resume** — interrupted installs can resume from the last successful step
- **Rollback manifest** — records installed packages and changed files for potential uninstall
- **Persistent logging** — logs rotate (keep 5) in `~/.local/share/honey-badger/logs/`
- **Network check hardening** — uses DNS resolution, `host`, `ping`, and `curl` fallback chain
- **`log_debug()` function** — for verbose/dev-mode output
- **`hb_check_network()`** — portable connectivity check that works behind firewalls
- **`hb_skip_component()`** — checks `HONEY_BADGER_SKIP_*` env vars
- **`hb_register_temp()`** — registers temp files for automatic cleanup on exit/signal
- **`hb_backup_file()`** — creates `.hb-backup` copy before overwriting configs
- **Input validation** — `honey-badger-install` validates package names against `[a-zA-Z0-9._+:-]`
- **`--help` on all utilities** — `honey-badger-info`, `honey-badger-update`, `honey-badger-install`
- **GitHub Actions CI** — syntax checking, ShellCheck, test suites, per-distro dry-run in containers
- **Shell completions** — Bash and Zsh completions for `install.sh` and utility scripts
- **CHANGELOG.md** — this file
- **CONTRIBUTING.md** — contributor guide with distro-addition walkthrough
- **Expanded config reference** — `honey-badger-os.conf` fully documented with all variables

### Changed
- **Version bumped** to 2.0.0
- **Config `HONEY_BADGER_DEV_MODE`** now wired up — enables verbose logging when `true`
- **Log files** moved from `/tmp/` to `~/.local/share/honey-badger/logs/` with rotation
- **Colors** respect `NO_COLOR`, non-TTY detection, and `--no-color`
- **Logging functions** respect `HONEY_BADGER_VERBOSITY` levels (quiet/normal/verbose)
- **File permissions** on utility scripts set explicitly to `755` instead of `chmod +x`
- **JSON array building** uses `[@]+"${[@]}"` pattern to avoid unbound variable errors on empty arrays

### Fixed
- **Slackware non-interactive breakage** — no longer prompts for mirror config when `--non-interactive`; auto-enables a mirror instead
- **Hardcoded sbopkg URL** — now resolves latest release from GitHub API with fallback
- **Temp file leak** — Debian Node.js setup and Slackware sbopkg temp files registered for cleanup on signal
- **Arch yay temp directory** — registered for cleanup if build is interrupted
- **`/etc/inittab` overwrite** — now backed up before modification on Slackware
- **`~/.xinitrc` overwrite** — now backed up before modification
- **Unknown CLI flags** — `install.sh` now errors on `--unknown` instead of silently ignoring

## [1.0.0] - 2024-01-01

### Added
- Initial release with Arch, Debian, Fedora, Void, and Slackware support
- Four installation types: full, developer, desktop, minimal
- XFCE desktop environment configuration
- Honey Badger GTK2/GTK3 theme
- Nano editor enhanced configuration
- Docker, Python, Node.js development environment setup
- Dry-run mode (`--dry-run`)
- Non-interactive mode (`--non-interactive`)
- Progress tracking with step counters
- JSON installation summary output
- Three-tier test suite (verify_scripts.sh, verify_advanced.sh, test_final.sh)
