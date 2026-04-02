# Contributing to Honey Badger OS

Thank you for your interest in contributing! This guide covers the coding
conventions, testing workflow, and how to add support for a new distribution.

## Quick Start

```bash
git clone https://github.com/James-HoneyBadger/Honey_Badger_OS.git
cd Honey_Badger_OS
bash verify_scripts.sh      # Static checks (should be 115+ passed)
bash verify_advanced.sh     # Security checks (should be 28+ passed)
bash test_final.sh          # Smoke tests (should be 33+ passed)
```

## Project Structure

```
install.sh              # Entry point — detects distro, runs installer
lib/common.sh           # Shared library — DO NOT duplicate code; add here
config/
  honey-badger-os.conf  # User-facing configuration (sourced by common.sh)
  nanorc                # Enhanced nano configuration
distros/
  <distro>/
    install-<distro>.sh # Distribution-specific installer
assets/                 # Fallback utility scripts (overwritten at install time)
theme/                  # GTK2 and GTK3 theme files
completions/            # Shell completion scripts
.github/workflows/      # CI pipeline
```

## Coding Conventions

### Shell Style

- **Shebang**: `#!/bin/bash` (not `/bin/sh`)
- **Strict mode**: Every script starts with `set -euo pipefail`
- **Source shared lib**: `source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"`
- **Indentation**: 4 spaces (no tabs)
- **Line length**: 100 characters soft limit
- **Variables**: Use `local` inside functions. Always quote: `"$var"`, not `$var`
- **Parameter expansion**: Use `"${var:-default}"` for optional variables
- **Commands**: Check existence with `command -v`, not `which`
- **Temp files**: Use `mktemp` and register with `hb_register_temp "$file"`
- **Config changes**: Call `hb_backup_file "$path"` before overwriting user configs

### Naming

- Functions: `lowercase_with_underscores`
- Private/internal functions: `_hb_prefixed` (underscore prefix)
- Environment variables: `HONEY_BADGER_UPPER_CASE`
- Local variables: `lowercase`

### Logging

Use the shared logging functions — never raw `echo` for user output:
```bash
log_info "Informational message"       # Suppressed in --quiet mode
log_success "Completed something"      # Suppressed in --quiet mode
log_warning "Non-fatal issue"          # Always shown
log_error "Fatal problem"             # Always shown
log_debug "Verbose detail"            # Only shown with --verbose
log_step "Major phase label"          # Suppressed in --quiet mode
```

### Sudo

Always use `hb_sudo` instead of `sudo` directly. This enables `--dry-run` mode:
```bash
hb_sudo pacman -S --noconfirm vim     # Respects dry-run
hb_sudo systemctl enable lightdm     # Respects dry-run
```

## Adding a New Distribution

1. **Create the directory and script**:
   ```bash
   mkdir -p distros/newdistro
   touch distros/newdistro/install-newdistro.sh
   chmod +x distros/newdistro/install-newdistro.sh
   ```

2. **Use this template** as a starting point:
   ```bash
   #!/bin/bash
   # Honey Badger OS - NewDistro Post-Install Script
   # Supports: NewDistro Linux

   set -euo pipefail

   source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

   LOG_FILE="/tmp/honeybadger-newdistro-install.log"

   # Package lists
   declare -a BASE_PACKAGES=(...)
   declare -a DEVELOPER_PACKAGES=(...)
   declare -a DESKTOP_PACKAGES=(...)
   declare -a APPLICATIONS_PACKAGES=(...)

   check_newdistro_system() { ... }
   update_system() { ... }
   install_packages() { ... }

   install_full() { ... }
   install_developer() { ... }
   install_desktop() { ... }
   install_minimal() { ... }

   main() {
       local install_type="${HONEY_BADGER_INSTALL_TYPE:-full}"
       export HONEY_BADGER_DISTRO="newdistro"
       hb_json_init
       hb_set_total_steps 8

       check_newdistro_system
       update_system

       case "$install_type" in
           full)      install_full ;;
           developer) install_developer ;;
           desktop)   install_desktop ;;
           minimal)   install_minimal ;;
       esac

       create_utility_scripts "update-cmd" "install-cmd" "clean-cmd"
       show_post_install
   }

   main "$@"
   ```

3. **Register in `install.sh`**: Add your distro to `detect_distribution()`:
   ```bash
   newdistro)
       echo "newdistro"
       return 0
       ;;
   ```

4. **Add to CI**: Update `.github/workflows/ci.yml` matrix with a container image.

5. **Run the test suite**:
   ```bash
   bash verify_scripts.sh && bash verify_advanced.sh && bash test_final.sh
   ```

## Commit Messages

Use conventional commit format:
```
feat: add OpenSUSE distribution support
fix: slackware mirror auto-config in non-interactive mode
docs: update USER_GUIDE with new CLI flags
test: add edge case tests for symlinked bashrc
chore: bump version to 2.1.0
```

## Pull Request Checklist

- [ ] `bash -n` passes on all new/changed scripts
- [ ] All three test suites pass (`verify_scripts.sh`, `verify_advanced.sh`, `test_final.sh`)
- [ ] New functions use `local` for variables
- [ ] Temp files use `mktemp` + `hb_register_temp`
- [ ] Config overwrites use `hb_backup_file`
- [ ] `hb_sudo` used instead of bare `sudo`
- [ ] No `eval`, `curl | bash`, `chmod 777`, or hardcoded `/tmp` paths without `mktemp`
- [ ] CHANGELOG.md updated

## License

By contributing, you agree that your contributions will be licensed under the project's MIT License.
