#!/bin/bash
# Honey Badger OS - Shared Library
# Common functions used across all distribution installers
#
# Source this file at the top of each distro script:
#   source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"
#
# shellcheck disable=SC2034  # Variables used by sourcing scripts

set -euo pipefail

# Prevent double-sourcing
[[ -n "${_HONEY_BADGER_COMMON_LOADED:-}" ]] && return 0
readonly _HONEY_BADGER_COMMON_LOADED=1

# ── NO_COLOR / --no-color support (https://no-color.org) ────────────────────
# Disable colors when NO_COLOR is set, when not a TTY, or when --no-color is passed
if [[ -n "${NO_COLOR:-}" ]] || [[ "${HONEY_BADGER_NO_COLOR:-0}" == "1" ]] || [[ ! -t 1 ]]; then
    _HB_USE_COLOR=0
else
    _HB_USE_COLOR=1
fi

# ── Color definitions (individually guarded to handle partial inheritance) ─────
if [[ "$_HB_USE_COLOR" == "1" ]]; then
    [[ -z "${RED:-}" ]]     && RED='\033[0;31m'
    [[ -z "${GREEN:-}" ]]   && GREEN='\033[0;32m'
    [[ -z "${YELLOW:-}" ]]  && YELLOW='\033[0;33m'
    [[ -z "${BLUE:-}" ]]    && BLUE='\033[0;34m'
    [[ -z "${MAGENTA:-}" ]] && MAGENTA='\033[0;35m'
    [[ -z "${CYAN:-}" ]]    && CYAN='\033[0;36m'
    [[ -z "${WHITE:-}" ]]   && WHITE='\033[0;37m'
    [[ -z "${BOLD:-}" ]]    && BOLD='\033[1m'
    [[ -z "${NC:-}" ]]      && NC='\033[0m'
else
    # Guard against readonly variables from parent shells
    readonly -p 2>/dev/null | grep -q ' RED=' || RED=''
    readonly -p 2>/dev/null | grep -q ' GREEN=' || GREEN=''
    readonly -p 2>/dev/null | grep -q ' YELLOW=' || YELLOW=''
    readonly -p 2>/dev/null | grep -q ' BLUE=' || BLUE=''
    readonly -p 2>/dev/null | grep -q ' MAGENTA=' || MAGENTA=''
    readonly -p 2>/dev/null | grep -q ' CYAN=' || CYAN=''
    readonly -p 2>/dev/null | grep -q ' WHITE=' || WHITE=''
    readonly -p 2>/dev/null | grep -q ' BOLD=' || BOLD=''
    readonly -p 2>/dev/null | grep -q ' NC=' || NC=''
fi

# ── Project root detection ───────────────────────────────────────────────────
if [[ -z "${HONEY_BADGER_ROOT:-}" ]]; then
    HONEY_BADGER_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

# ── Source config file (with key validation) ────────────────────────────────
_HB_VALID_CONFIG_KEYS=(
    HONEY_BADGER_VERSION HONEY_BADGER_CODENAME HONEY_BADGER_BUILD_DATE
    HONEY_BADGER_THEME_PRIMARY HONEY_BADGER_THEME_SECONDARY
    HONEY_BADGER_THEME_ACCENT HONEY_BADGER_THEME_BASE
    EDITOR VISUAL
    HONEY_BADGER_DEV_MODE
    HONEY_BADGER_SKIP_DOCKER HONEY_BADGER_SKIP_PYTHON
    HONEY_BADGER_SKIP_NODE HONEY_BADGER_SKIP_NANO HONEY_BADGER_SKIP_THEME
    HONEY_BADGER_GIT_USERNAME HONEY_BADGER_GIT_EMAIL
    HONEY_BADGER_LOG_COUNT HONEY_BADGER_NETWORK_TIMEOUT
    HONEY_BADGER_MIN_DISK_GB HONEY_BADGER_WALLPAPER_SIZE
    HONEY_BADGER_NPM_GLOBAL_PATH
)

_hb_validate_config() {
    local config_file="$1"
    while IFS= read -r line; do
        # Skip comments and blank lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// /}" ]] && continue
        # Extract variable name
        local var_name="${line%%=*}"
        var_name="${var_name// /}"
        # Reject lines with command substitution or subshells
        if [[ "$line" =~ \$\( ]] || [[ "$line" =~ \` ]]; then
            echo "SECURITY: Rejecting config line with command substitution: $line" >&2
            return 1
        fi
        # Check against whitelist
        local valid=false
        for key in "${_HB_VALID_CONFIG_KEYS[@]}"; do
            if [[ "$var_name" == "$key" ]]; then
                valid=true
                break
            fi
        done
        if ! $valid; then
            echo "WARNING: Unknown config key '$var_name' in $config_file (ignored)" >&2
        fi
    done < "$config_file"
    return 0
}

if [[ -f "$HONEY_BADGER_ROOT/config/honey-badger-os.conf" ]]; then
    if _hb_validate_config "$HONEY_BADGER_ROOT/config/honey-badger-os.conf"; then
        # shellcheck source=../config/honey-badger-os.conf
        source "$HONEY_BADGER_ROOT/config/honey-badger-os.conf"
    else
        echo "ERROR: Config file failed validation, using defaults" >&2
    fi
fi

# ── Verbosity control ───────────────────────────────────────────────────────
# Levels: 0=quiet (errors only), 1=normal (default), 2=verbose (debug output)
HONEY_BADGER_VERBOSITY="${HONEY_BADGER_VERBOSITY:-1}"

# ── Dry-run support ─────────────────────────────────────────────────────────
HONEY_BADGER_DRY_RUN="${HONEY_BADGER_DRY_RUN:-0}"

# ── Dev mode (from config) ──────────────────────────────────────────────────
# When HONEY_BADGER_DEV_MODE=true: skip confirmations, enable verbose logging
if [[ "${HONEY_BADGER_DEV_MODE:-false}" == "true" ]]; then
    HONEY_BADGER_VERBOSITY=2
fi

# ── Logging setup ────────────────────────────────────────────────────────────
# Persistent log directory with rotation
_HB_LOG_DIR="${HOME}/.local/share/honey-badger/logs"
mkdir -p "$_HB_LOG_DIR" 2>/dev/null || _HB_LOG_DIR="/tmp"

# Configurable log rotation count (default 5)
_HB_LOG_KEEP="${HONEY_BADGER_LOG_COUNT:-5}"

# Rotate logs: keep last N runs
_hb_rotate_logs() {
    local log_dir="$1"
    local keep="${_HB_LOG_KEEP}"
    local -a old_logs=()
    # Collect log files sorted oldest-first
    while IFS= read -r -d '' f; do
        old_logs+=("$f")
    done < <(find "$log_dir" -maxdepth 1 -name 'honeybadger-*.log' -type f -print0 2>/dev/null | sort -z)
    local count=${#old_logs[@]}
    local max_keep=$((keep - 1))
    if [[ $count -gt $max_keep ]]; then
        local to_remove=$((count - max_keep))
        for ((i = 0; i < to_remove; i++)); do
            rm -f "${old_logs[$i]}"
        done
    fi
}

_hb_rotate_logs "$_HB_LOG_DIR"

# Default log file with timestamp
: "${LOG_FILE:=${_HB_LOG_DIR}/honeybadger-$(date +%Y%m%d-%H%M%S).log}"
touch "$LOG_FILE" 2>/dev/null || LOG_FILE="/tmp/honeybadger-install.log"

# Wrap sudo: in dry-run mode, print the command instead of executing it
hb_sudo() {
    if [[ "$HONEY_BADGER_DRY_RUN" == "1" ]]; then
        log_info "[DRY-RUN] sudo $*"
        return 0
    fi
    sudo "$@"
}

# ── Progress tracking ───────────────────────────────────────────────────────
_HB_STEP_CURRENT=0
_HB_STEP_TOTAL=0

hb_set_total_steps() {
    _HB_STEP_TOTAL="$1"
    _HB_STEP_CURRENT=0
}

hb_next_step() {
    _HB_STEP_CURRENT=$((_HB_STEP_CURRENT + 1))
    local prefix=""
    if [[ $_HB_STEP_TOTAL -gt 0 ]]; then
        prefix="[${_HB_STEP_CURRENT}/${_HB_STEP_TOTAL}] "
    fi
    log_step "${prefix}$1"
}

# ── Logging functions ────────────────────────────────────────────────────────
log_info() {
    [[ "$HONEY_BADGER_VERBOSITY" -ge 1 ]] || return 0
    echo -e "${CYAN}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    [[ "$HONEY_BADGER_VERBOSITY" -ge 1 ]] || return 0
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

log_step() {
    [[ "$HONEY_BADGER_VERBOSITY" -ge 1 ]] || return 0
    echo -e "${BLUE}${BOLD}[STEP]${NC} $1" | tee -a "$LOG_FILE"
}

log_debug() {
    [[ "$HONEY_BADGER_VERBOSITY" -ge 2 ]] || return 0
    echo -e "${MAGENTA}[DEBUG]${NC} $1" | tee -a "$LOG_FILE"
}

# ── Non-interactive helpers ──────────────────────────────────────────────────
is_noninteractive() {
    [[ "${HONEY_BADGER_NONINTERACTIVE:-0}" == "1" || "${CI:-}" == "true" ]]
}

# ── Lock file (prevent concurrent runs) ─────────────────────────────────────
_HB_LOCK_FILE="/tmp/honeybadger-install.lock"
_HB_LOCK_FD=""

hb_acquire_lock() {
    exec 9>"$_HB_LOCK_FILE"
    if ! flock -n 9; then
        log_error "Another Honey Badger OS installation is already running."
        log_error "If this is wrong, remove $_HB_LOCK_FILE and try again."
        exit 1
    fi
    _HB_LOCK_FD=9
    echo $$ > "$_HB_LOCK_FILE"
    log_debug "Lock acquired (PID $$)"
}

hb_release_lock() {
    if [[ -n "$_HB_LOCK_FD" ]]; then
        flock -u 9 2>/dev/null || true
        rm -f "$_HB_LOCK_FILE"
        log_debug "Lock released"
    fi
}

# ── Signal trapping & cleanup ───────────────────────────────────────────────
declare -a _HB_TEMP_FILES=()

hb_register_temp() {
    _HB_TEMP_FILES+=("$1")
}

_hb_cleanup() {
    local exit_code=$?
    # Remove registered temp files
    for f in "${_HB_TEMP_FILES[@]:-}"; do
        [[ -n "$f" ]] && rm -f "$f" 2>/dev/null || true
    done
    # Release lock
    hb_release_lock
    # Save checkpoint on non-zero exit
    if [[ $exit_code -ne 0 && $_HB_STEP_CURRENT -gt 0 ]]; then
        _hb_save_checkpoint
        log_warning "Installation interrupted at step ${_HB_STEP_CURRENT}/${_HB_STEP_TOTAL}"
        log_info "Last completed step: ${_HB_STEP_CURRENT}"
        log_info "Re-run the installer to resume from the last checkpoint."
        log_info "Installation log: ${LOG_FILE}"
    fi
    exit "$exit_code"
}

trap '_hb_cleanup' EXIT
trap 'log_error "Installation interrupted by user (Ctrl+C)"; log_info "Log file: ${LOG_FILE}"; exit 130' INT TERM

# ── Config backup ────────────────────────────────────────────────────────────
# Back up a file before overwriting. Creates <file>.hb-backup if no backup exists yet.
hb_backup_file() {
    local file="$1"
    if [[ -f "$file" && ! -f "${file}.hb-backup" ]]; then
        cp "$file" "${file}.hb-backup"
        log_debug "Backed up $file -> ${file}.hb-backup"
        hb_json_add_config "backup:${file}.hb-backup"
    fi
}

# ── Checkpoint / resume ─────────────────────────────────────────────────────
_HB_CHECKPOINT_FILE="${HOME}/.local/share/honey-badger/checkpoint"

_hb_save_checkpoint() {
    mkdir -p "$(dirname "$_HB_CHECKPOINT_FILE")" 2>/dev/null || true
    cat > "$_HB_CHECKPOINT_FILE" << ENDCP
CHECKPOINT_STEP=${_HB_STEP_CURRENT}
CHECKPOINT_TOTAL=${_HB_STEP_TOTAL}
CHECKPOINT_DISTRO=${HONEY_BADGER_DISTRO:-unknown}
CHECKPOINT_TYPE=${HONEY_BADGER_INSTALL_TYPE:-unknown}
CHECKPOINT_TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ)
ENDCP
}

hb_load_checkpoint() {
    if [[ -f "$_HB_CHECKPOINT_FILE" ]]; then
        # shellcheck source=/dev/null
        source "$_HB_CHECKPOINT_FILE"
        echo "${CHECKPOINT_STEP:-0}"
    else
        echo "0"
    fi
}

hb_clear_checkpoint() {
    rm -f "$_HB_CHECKPOINT_FILE"
}

hb_should_skip_step() {
    local checkpoint_step="${1:-0}"
    [[ $_HB_STEP_CURRENT -le $checkpoint_step ]]
}

# ── Rollback manifest ───────────────────────────────────────────────────────
_HB_ROLLBACK_FILE="${HOME}/.local/share/honey-badger/rollback-manifest"

hb_rollback_init() {
    mkdir -p "$(dirname "$_HB_ROLLBACK_FILE")" 2>/dev/null || true
    echo "# Honey Badger OS Rollback Manifest - $(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$_HB_ROLLBACK_FILE"
}

hb_rollback_add_packages() {
    local pm_type="$1"
    shift
    for pkg in "$@"; do
        echo "PACKAGE:${pm_type}:${pkg}" >> "$_HB_ROLLBACK_FILE"
    done
}

hb_rollback_add_file() {
    echo "FILE:$1" >> "$_HB_ROLLBACK_FILE"
}

hb_rollback_add_group() {
    echo "GROUP:$1:$2" >> "$_HB_ROLLBACK_FILE"
}

# ── Network connectivity check ──────────────────────────────────────────────
hb_check_network() {
    local timeout="${HONEY_BADGER_NETWORK_TIMEOUT:-3}"
    log_debug "Checking network connectivity (timeout: ${timeout}s)..."
    # Try DNS resolution first (works behind firewalls that block ICMP)
    if command -v getent >/dev/null 2>&1; then
        if getent hosts dns.google >/dev/null 2>&1; then
            log_debug "Network OK (DNS resolution)"
            return 0
        fi
    fi
    # Fall back to host
    if command -v host >/dev/null 2>&1; then
        if host -W "$timeout" dns.google >/dev/null 2>&1; then
            log_debug "Network OK (host lookup)"
            return 0
        fi
    fi
    # Fall back to ping
    if ping -c 1 -W "$timeout" 8.8.8.8 >/dev/null 2>&1; then
        log_debug "Network OK (ping)"
        return 0
    fi
    # Last resort: try to reach a repo directly
    if curl -fsSL --connect-timeout "$timeout" --max-time 10 https://google.com -o /dev/null 2>/dev/null; then
        log_debug "Network OK (curl)"
        return 0
    fi
    log_error "No network connectivity detected"
    log_info "Please check your network connection and try again"
    return 1
}

# ── Unified banner display ──────────────────────────────────────────────────
hb_show_banner() {
    local distro_name="${1:-}"
    local subtitle="${2:-Fearless Linux Configuration}"
    echo -e "${BOLD}${YELLOW}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║           🦡  HONEY BADGER OS INSTALLER  🦡              ║"
    if [[ -n "$distro_name" ]]; then
        printf "║           %-42s ║\n" "$distro_name Edition"
    fi
    printf "║           %-42s ║\n" "$subtitle"
    echo "║           Version: ${HONEY_BADGER_VERSION:-2.0.0}                              ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# ── Unified distro log initialization ───────────────────────────────────────
hb_init_distro_log() {
    local distro_name="${1:-unknown}"
    LOG_FILE="${_HB_LOG_DIR}/honeybadger-${distro_name}-$(date +%Y%m%d-%H%M%S).log"
    touch "$LOG_FILE" 2>/dev/null || LOG_FILE="/tmp/honeybadger-${distro_name}-install.log"
    log_debug "Distro log initialized: $LOG_FILE"
}

# ── Unified service enablement (cross-init-system) ─────────────────────────
hb_enable_service() {
    local service_name="$1"
    if [[ "$HONEY_BADGER_DRY_RUN" == "1" ]]; then
        log_info "[DRY-RUN] Would enable service: $service_name"
        return 0
    fi
    # systemd
    if command -v systemctl >/dev/null 2>&1; then
        hb_sudo systemctl enable "$service_name" 2>/dev/null || true
        log_debug "Enabled $service_name via systemd"
        return 0
    fi
    # OpenRC
    if command -v rc-update >/dev/null 2>&1; then
        hb_sudo rc-update add "$service_name" default 2>/dev/null || true
        log_debug "Enabled $service_name via OpenRC"
        return 0
    fi
    # runit
    if [[ -d /etc/sv/"$service_name" ]]; then
        hb_sudo ln -sf "/etc/sv/$service_name" /var/service/ 2>/dev/null || true
        log_debug "Enabled $service_name via runit"
        return 0
    fi
    # SysV init
    if command -v update-rc.d >/dev/null 2>&1; then
        hb_sudo update-rc.d "$service_name" defaults 2>/dev/null || true
        log_debug "Enabled $service_name via SysV init"
        return 0
    fi
    log_warning "No supported init system found for enabling $service_name"
}

# ── Component skip flags ────────────────────────────────────────────────────
hb_skip_component() {
    local component="$1"
    local var_name="HONEY_BADGER_SKIP_${component^^}"
    [[ "${!var_name:-0}" == "1" ]]
}

# ── Idempotent bashrc helper ────────────────────────────────────────────────
ensure_bashrc_line() {
    local line="$1"
    local bashrc="$HOME/.bashrc"

    touch "$bashrc"
    hb_backup_file "$bashrc"
    if ! grep -Fxq "$line" "$bashrc"; then
        printf '%s\n' "$line" >> "$bashrc"
    fi
}

# ── JSON summary output ─────────────────────────────────────────────────────
# Collects installation events and writes a JSON summary at the end
declare -a _HB_JSON_PACKAGES_INSTALLED=()
declare -a _HB_JSON_CONFIGS_CHANGED=()
declare -a _HB_JSON_ERRORS=()
_HB_JSON_START_TIME=""

hb_json_init() {
    _HB_JSON_START_TIME="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}

hb_json_add_package() {
    _HB_JSON_PACKAGES_INSTALLED+=("$1")
}

hb_json_add_config() {
    _HB_JSON_CONFIGS_CHANGED+=("$1")
}

hb_json_add_error() {
    _HB_JSON_ERRORS+=("$1")
}

hb_json_write() {
    local output_file="${1:-/tmp/honeybadger-summary.json}"
    local end_time
    end_time="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    local distro="${HONEY_BADGER_DISTRO:-unknown}"
    local install_type="${HONEY_BADGER_INSTALL_TYPE:-unknown}"

    # Build JSON arrays safely
    local pkgs_json="" p
    for p in "${_HB_JSON_PACKAGES_INSTALLED[@]+"${_HB_JSON_PACKAGES_INSTALLED[@]}"}"; do
        pkgs_json="${pkgs_json}\"${p}\","
    done
    pkgs_json="[${pkgs_json%,}]"

    local configs_json="" c
    for c in "${_HB_JSON_CONFIGS_CHANGED[@]+"${_HB_JSON_CONFIGS_CHANGED[@]}"}"; do
        configs_json="${configs_json}\"${c}\","
    done
    configs_json="[${configs_json%,}]"

    local errors_json="" e
    for e in "${_HB_JSON_ERRORS[@]+"${_HB_JSON_ERRORS[@]}"}"; do
        errors_json="${errors_json}\"${e}\","
    done
    errors_json="[${errors_json%,}]"

    local status="success"
    if [[ ${#_HB_JSON_ERRORS[@]} -gt 0 ]]; then
        status="partial"
    fi

    cat > "$output_file" << ENDJSON
{
  "honey_badger_version": "${HONEY_BADGER_VERSION:-1.0.0}",
  "distro": "${distro}",
  "install_type": "${install_type}",
  "status": "${status}",
  "start_time": "${_HB_JSON_START_TIME}",
  "end_time": "${end_time}",
  "packages_installed": ${pkgs_json},
  "configs_changed": ${configs_json},
  "errors": ${errors_json}
}
ENDJSON
    log_info "Installation summary written to $output_file"
}

# ── Nano setup ───────────────────────────────────────────────────────────────
setup_nano() {
    hb_next_step "Setting up enhanced nano configuration..."

    if hb_skip_component "nano"; then
        log_info "Skipping nano setup (--skip-nano)"
        return 0
    fi

    mkdir -p ~/.nano/backups

    if [[ -f "$HONEY_BADGER_ROOT/config/nanorc" ]]; then
        hb_backup_file "$HOME/.nanorc"
        cp "$HONEY_BADGER_ROOT/config/nanorc" ~/.nanorc
    else
        log_warning "nanorc configuration file not found"
    fi

    ensure_bashrc_line 'export EDITOR=nano'
    ensure_bashrc_line 'export VISUAL=nano'

    hb_json_add_config "~/.nanorc"
    log_success "Enhanced nano configuration installed"
}

# ── Theme setup ──────────────────────────────────────────────────────────────
setup_honey_badger_theme() {
    hb_next_step "Installing Honey Badger theme..."

    local theme_dir="$HOME/.themes/HoneyBadger"
    local icon_dir="$HOME/.icons/HoneyBadger"

    mkdir -p "$theme_dir/gtk-2.0"
    mkdir -p "$theme_dir/gtk-3.0"
    mkdir -p "$icon_dir"

    # Copy theme files from project
    if [[ -f "$HONEY_BADGER_ROOT/theme/gtkrc-2.0" ]]; then
        cp "$HONEY_BADGER_ROOT/theme/gtkrc-2.0" "$theme_dir/gtk-2.0/gtkrc"
    else
        log_warning "GTK2 theme file not found, generating..."
        cat > "$theme_dir/gtk-2.0/gtkrc" << 'ENDGTK2'
# Honey Badger GTK2 Theme
gtk-color-scheme = "base_color:#2d2006\nbg_color:#8b6914\ntooltip_bg_color:#f5deb3\nselected_bg_color:#daa520\ntext_color:#f5deb3\nfg_color:#f5deb3\ntooltip_fg_color:#2d2006\nselected_fg_color:#2d2006"

style "default" {
    GtkButton::default_border = {0,0,0,0}
    GtkButton::default_outside_border = {0,0,0,0}
    GtkButton::child_displacement_x = 1
    GtkButton::child_displacement_y = 1

    base[NORMAL] = @base_color
    base[PRELIGHT] = shade(1.1, @base_color)
    base[SELECTED] = @selected_bg_color
    base[INSENSITIVE] = shade(0.9, @base_color)

    bg[NORMAL] = @bg_color
    bg[PRELIGHT] = shade(1.1, @bg_color)
    bg[SELECTED] = @selected_bg_color
    bg[INSENSITIVE] = shade(0.9, @bg_color)

    fg[NORMAL] = @fg_color
    fg[PRELIGHT] = @fg_color
    fg[SELECTED] = @selected_fg_color
    fg[INSENSITIVE] = shade(0.7, @fg_color)

    text[NORMAL] = @text_color
    text[PRELIGHT] = @text_color
    text[SELECTED] = @selected_fg_color
    text[INSENSITIVE] = shade(0.7, @text_color)
}

class "GtkWidget" style "default"
ENDGTK2
    fi

    if [[ -f "$HONEY_BADGER_ROOT/theme/honey-badger-theme.css" ]]; then
        cp "$HONEY_BADGER_ROOT/theme/honey-badger-theme.css" "$theme_dir/gtk-3.0/gtk.css"
    else
        log_warning "GTK3 theme file not found"
    fi

    # Create theme index
    cat > "$theme_dir/index.theme" << 'ENDINDEX'
[Desktop Entry]
Type=X-GNOME-Metatheme
Name=HoneyBadger
Comment=Honey Badger OS Theme
Encoding=UTF-8

[X-GNOME-Metatheme]
GtkTheme=HoneyBadger
MetacityTheme=HoneyBadger
IconTheme=HoneyBadger
ENDINDEX

    hb_json_add_config "~/.themes/HoneyBadger"
    log_success "Honey Badger theme installed"
}

# ── XFCE desktop configuration ──────────────────────────────────────────────
setup_xfce() {
    hb_next_step "Configuring XFCE desktop environment..."

    # Enable display manager (systemd)
    if command -v systemctl >/dev/null 2>&1; then
        if systemctl is-enabled lightdm >/dev/null 2>&1; then
            log_info "LightDM already enabled"
        else
            hb_sudo systemctl enable lightdm 2>/dev/null || true
            log_success "LightDM display manager enabled"
        fi
    fi

    # Configure LightDM greeter
    hb_sudo mkdir -p /etc/lightdm
    cat << 'ENDLIGHTDM' | hb_sudo tee /etc/lightdm/lightdm.conf >/dev/null
[Seat:*]
greeter-session=lightdm-gtk-greeter
user-session=xfce

[LightDM]
minimum-uid=1000
ENDLIGHTDM

    cat << 'ENDGREETER' | hb_sudo tee /etc/lightdm/lightdm-gtk-greeter.conf >/dev/null
[greeter]
theme-name=HoneyBadger
icon-theme-name=HoneyBadger
font-name=Sans 11
background=/usr/share/backgrounds/honeybadger.jpg
ENDGREETER

    hb_json_add_config "/etc/lightdm/lightdm.conf"
    log_success "XFCE desktop configured"
}

# ── Wallpaper / assets ───────────────────────────────────────────────────────
install_assets() {
    hb_next_step "Installing Honey Badger assets..."

    local wallpaper_dir="/usr/share/backgrounds"
    local wallpaper_size="${HONEY_BADGER_WALLPAPER_SIZE:-1920x1080}"
    hb_sudo mkdir -p "$wallpaper_dir"
    mkdir -p "$HOME/.local/share/icons"

    # Generate wallpaper safely (no eval)
    if command -v convert >/dev/null 2>&1; then
        local tmp_wallpaper
        tmp_wallpaper="$(mktemp /tmp/honeybadger-wallpaper.XXXXXX.jpg)"
        hb_register_temp "$tmp_wallpaper"
        if convert -size "$wallpaper_size" "gradient:#2d2006-#8b6914" \
            -font DejaVu-Sans-Bold -pointsize 72 -fill "#f5deb3" \
            -gravity center -annotate +0-100 "HONEY BADGER OS" \
            -pointsize 24 -annotate +0+50 "Fearless - Determined - Uncompromising" \
            "$tmp_wallpaper" 2>/dev/null && [[ -s "$tmp_wallpaper" ]]; then
            hb_sudo cp "$tmp_wallpaper" "$wallpaper_dir/honeybadger.jpg"
            log_success "Generated Honey Badger wallpaper (${wallpaper_size})"
        else
            log_warning "ImageMagick wallpaper generation failed or produced empty file"
            log_info "You can set a wallpaper manually at $wallpaper_dir/honeybadger.jpg"
        fi
    else
        log_info "ImageMagick not available, skipping wallpaper generation"
        log_info "Install ImageMagick and re-run, or set a wallpaper manually"
    fi

    log_success "Assets installed"
}

# ── Git configuration ────────────────────────────────────────────────────────
setup_git() {
    hb_next_step "Configuring Git..."

    if git config --global user.name >/dev/null 2>&1; then
        log_info "Git already configured"
        return 0
    fi

    if is_noninteractive; then
        local git_username="${HONEY_BADGER_GIT_USERNAME:-}"
        local git_email="${HONEY_BADGER_GIT_EMAIL:-}"

        if [[ -n "$git_username" && -n "$git_email" ]]; then
            git config --global user.name "$git_username"
            git config --global user.email "$git_email"
            git config --global init.defaultBranch main
            log_success "Git configured from environment variables"
        else
            log_warning "Skipping Git identity setup in non-interactive mode"
            log_info "Set HONEY_BADGER_GIT_USERNAME and HONEY_BADGER_GIT_EMAIL to configure automatically"
        fi
    else
        log_info "Git configuration needed. Please set up your Git identity:"
        echo -n "Enter your Git username: "
        read -r git_username
        echo -n "Enter your Git email: "
        read -r git_email

        git config --global user.name "$git_username"
        git config --global user.email "$git_email"
        git config --global init.defaultBranch main
        log_success "Git configured"
    fi

    hb_json_add_config "~/.gitconfig"
}

# ── Docker setup (with privilege warning) ────────────────────────────────────
setup_docker() {
    hb_next_step "Configuring Docker..."

    if hb_skip_component "docker"; then
        log_info "Skipping Docker setup (--skip-docker)"
        return 0
    fi

    if ! command -v docker >/dev/null 2>&1; then
        log_info "Docker not installed, skipping configuration"
        return 0
    fi

    # Enable service (systemd)
    if command -v systemctl >/dev/null 2>&1; then
        hb_sudo systemctl enable docker 2>/dev/null || true
        hb_sudo systemctl start docker 2>/dev/null || true
    fi

    # Add user to docker group WITH explicit warning
    if ! groups "$USER" | grep -q docker; then
        log_warning "Adding $USER to the 'docker' group grants root-equivalent privileges."
        log_warning "Only proceed if you trust all software running under this user account."
        hb_sudo usermod -aG docker "$USER"
        log_success "Docker configured (log out and back in for group changes to take effect)"
    else
        log_info "User already in docker group"
    fi

    hb_json_add_config "docker-group"
}

# ── Python development setup ────────────────────────────────────────────────
setup_python_dev() {
    if hb_skip_component "python"; then
        log_info "Skipping Python dev setup (--skip-python)"
        return 0
    fi

    local python_cmd=""
    if command -v python3 >/dev/null 2>&1; then
        python_cmd="python3"
    elif command -v python >/dev/null 2>&1; then
        python_cmd="python"
    else
        log_warning "Python not found, skipping Python dev setup"
        return 0
    fi

    $python_cmd -m pip install --user --upgrade pip setuptools wheel 2>/dev/null || true
    $python_cmd -m pip install --user pipx 2>/dev/null || true
    log_success "Python development environment configured"
}

# ── Node.js development setup ───────────────────────────────────────────────
setup_node_dev() {
    if hb_skip_component "node"; then
        log_info "Skipping Node.js dev setup (--skip-node)"
        return 0
    fi

    if ! command -v npm >/dev/null 2>&1; then
        log_warning "npm not found, skipping Node.js dev setup"
        return 0
    fi

    local npm_global="${HONEY_BADGER_NPM_GLOBAL_PATH:-$HOME/.npm-global}"
    mkdir -p "$npm_global"
    npm config set prefix "$npm_global"
    ensure_bashrc_line "export PATH=${npm_global}/bin:\$PATH"

    npm install -g typescript ts-node nodemon eslint prettier 2>/dev/null || true
    log_success "Node.js development environment configured"
}

# ── Development environment orchestrator ─────────────────────────────────────
setup_development_environment() {
    hb_next_step "Setting up development environment..."
    setup_git
    setup_docker
    setup_python_dev
    setup_node_dev
    log_success "Development environment setup completed"
}

# ── Utility script creation ──────────────────────────────────────────────────
# Creates distro-aware utility scripts. Caller must pass the package manager
# commands as arguments.
#   create_utility_scripts <pm_update_cmd> <pm_install_cmd> <pm_clean_cmd>
# E.g.: create_utility_scripts "sudo pacman -Syu --noconfirm" "sudo pacman -S --noconfirm" "sudo pacman -Sc --noconfirm"
create_utility_scripts() {
    local pm_update_cmd="${1:-echo 'No package manager update command configured'}"
    local pm_install_cmd="${2:-echo 'No package manager install command configured'}"
    local pm_clean_cmd="${3:-echo 'No package manager clean command configured'}"

    hb_next_step "Creating Honey Badger utility scripts..."

    local bin_dir="$HOME/.local/bin"
    mkdir -p "$bin_dir"
    ensure_bashrc_line "export PATH=\"\$HOME/.local/bin:\$PATH\""

    # ── honey-badger-info ──
    cat > "$bin_dir/honey-badger-info" << 'EOF'
#!/bin/bash
# Honey Badger OS System Information
echo -e "\033[1;33m🦡 Honey Badger OS System Information 🦡\033[0m"
echo "=================================================="
echo "Hostname:    $(hostname)"
echo "User:        $(whoami)"
if [[ -f /etc/os-release ]]; then
    # shellcheck source=/dev/null
    source /etc/os-release
    echo "OS:          ${PRETTY_NAME:-Unknown}"
else
    echo "OS:          $(uname -o)"
fi
echo "Kernel:      $(uname -r)"
echo "Architecture:$(uname -m)"
echo "Uptime:      $(uptime -p 2>/dev/null || uptime)"
echo "Memory:      $(free -h 2>/dev/null | awk '/^Mem:/ {print $3"/"$2}' || echo 'N/A')"
echo "Disk Usage:  $(df -h / | awk 'NR==2 {print $3"/"$2" ("$5" used)"}')"
echo "Desktop:     ${XDG_CURRENT_DESKTOP:-None}"
echo "Shell:       ${SHELL##*/}"
echo "Editor:      ${EDITOR:-Not set}"
echo "HB Version:  ${HONEY_BADGER_VERSION:-1.0.0}"
echo "=================================================="
echo -e "\033[1;32mHoney badger don't care, honey badger don't give a shit!\033[0m"
EOF

    # ── honey-badger-update ──
    cat > "$bin_dir/honey-badger-update" << ENDUPDATE
#!/bin/bash
# Honey Badger OS System Update Script
set -euo pipefail

echo -e "\033[1;33m🦡 Honey Badger OS System Update 🦡\033[0m"

echo "Updating system packages..."
${pm_update_cmd}

# Update Snap packages if available
if command -v snap >/dev/null 2>&1; then
    echo "Updating Snap packages..."
    sudo snap refresh || true
fi

# Update Flatpak packages if available
if command -v flatpak >/dev/null 2>&1; then
    echo "Updating Flatpak packages..."
    sudo flatpak update -y || true
fi

echo "Cleaning package cache..."
${pm_clean_cmd}

echo -e "\033[1;32m🦡 System update completed! 🦡\033[0m"
ENDUPDATE

    # ── honey-badger-install ──
    cat > "$bin_dir/honey-badger-install" << ENDINSTALL
#!/bin/bash
# Honey Badger OS Package Install Script
set -euo pipefail

if [[ \$# -eq 0 ]]; then
    echo "Usage: honey-badger-install <package1> [package2] ..."
    exit 1
fi

# Validate package names (alphanumeric, hyphens, dots, underscores, plus signs)
for arg in "\$@"; do
    if [[ ! "\$arg" =~ ^[a-zA-Z0-9][a-zA-Z0-9._+:-]*\$ ]]; then
        echo -e "\033[0;31mInvalid package name: \$arg\033[0m"
        echo "Package names may only contain: letters, digits, dots, hyphens, underscores, plus signs"
        exit 1
    fi
done

echo -e "\033[1;33m🦡 Installing packages: \$* 🦡\033[0m"

if ${pm_install_cmd} "\$@"; then
    echo -e "\033[1;32m🦡 Packages installed successfully! 🦡\033[0m"
else
    echo -e "\033[1;31mFailed to install packages\033[0m"
    exit 1
fi
ENDINSTALL

    chmod 755 "$bin_dir/honey-badger-info" "$bin_dir/honey-badger-update" "$bin_dir/honey-badger-install"

    hb_json_add_config "~/.local/bin/honey-badger-*"
    log_success "Utility scripts created in $bin_dir"
}

# ── Post-install summary ────────────────────────────────────────────────────
show_post_install() {
    local install_type="${HONEY_BADGER_INSTALL_TYPE:-full}"

    echo "" | tee -a "$LOG_FILE"
    log_success "Honey Badger OS installation completed!"
    echo -e "${BOLD}${YELLOW}🦡 Like the honey badger, you're now fearless and ready for anything! 🦡${NC}" | tee -a "$LOG_FILE"

    if [[ "$install_type" != "minimal" ]]; then
        echo -e "${CYAN}Reboot your system to start using the new desktop environment:${NC}" | tee -a "$LOG_FILE"
        echo -e "${YELLOW}sudo reboot${NC}" | tee -a "$LOG_FILE"
    else
        echo -e "${CYAN}Restart your terminal or run: source ~/.bashrc${NC}" | tee -a "$LOG_FILE"
    fi

    echo "" | tee -a "$LOG_FILE"
    echo -e "${CYAN}Available commands:${NC}" | tee -a "$LOG_FILE"
    echo "  • honey-badger-info    - Display system information" | tee -a "$LOG_FILE"
    echo "  • honey-badger-update  - Update system and packages" | tee -a "$LOG_FILE"
    echo "  • honey-badger-install - Install additional packages" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
    echo -e "${CYAN}Installation log:${NC} $LOG_FILE" | tee -a "$LOG_FILE"

    # Write JSON summary if available
    hb_json_write
}
