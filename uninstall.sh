#!/bin/bash
# Honey Badger OS - Uninstall Script
# Removes Honey Badger OS configurations and utility scripts using the rollback manifest.
# Does NOT remove system packages (use your distro's package manager for that).

set -euo pipefail

# ── Color support ────────────────────────────────────────────────────────────
if [[ -n "${NO_COLOR:-}" ]] || [[ ! -t 1 ]]; then
    RED='' GREEN='' YELLOW='' CYAN='' BOLD='' NC=''
else
    RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[0;33m'
    CYAN='\033[0;36m' BOLD='\033[1m' NC='\033[0m'
fi

log_info()    { echo -e "${CYAN}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# ── Help ─────────────────────────────────────────────────────────────────────
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    cat << 'EOF'
Usage: uninstall.sh [--dry-run]

Removes Honey Badger OS customizations:
  • Utility scripts (~/.local/bin/honey-badger-*)
  • Theme files (~/.themes/HoneyBadger, ~/.icons/HoneyBadger)
  • Nano configuration (~/.nanorc, ~/.nano/)
  • Restores backed-up config files (.hb-backup -> original)
  • Clears Honey Badger data (~/.local/share/honey-badger/)

Options:
  --dry-run   Show what would be removed without actually doing it
  --help      Show this help message

NOTE: System packages installed by Honey Badger OS are NOT removed.
      Use your distribution's package manager to remove them.
EOF
    exit 0
fi

DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

# ── Confirmation ─────────────────────────────────────────────────────────────
echo -e "${BOLD}${YELLOW}🦡 Honey Badger OS Uninstaller 🦡${NC}"
echo ""

if [[ $DRY_RUN -eq 1 ]]; then
    log_info "DRY-RUN MODE: showing what would be removed"
    echo ""
fi

if [[ $DRY_RUN -eq 0 ]]; then
    echo -e "${YELLOW}This will remove Honey Badger OS customizations from your system.${NC}"
    echo -e "${YELLOW}System packages will NOT be removed.${NC}"
    echo ""
    echo -n "Continue? [y/N]: "
    read -r response
    case "$response" in
        [yY]|[yY][eE][sS]) ;;
        *) log_info "Uninstall cancelled."; exit 0 ;;
    esac
    echo ""
fi

removed=0

# ── Helper ───────────────────────────────────────────────────────────────────
do_remove() {
    local target="$1"
    if [[ -e "$target" || -L "$target" ]]; then
        if [[ $DRY_RUN -eq 1 ]]; then
            log_info "Would remove: $target"
        else
            rm -rf "$target"
            log_success "Removed: $target"
        fi
        ((removed++))
    fi
}

do_restore_backup() {
    local backup="$1"
    local original="${backup%.hb-backup}"
    if [[ -f "$backup" ]]; then
        if [[ $DRY_RUN -eq 1 ]]; then
            log_info "Would restore: $backup -> $original"
        else
            mv "$backup" "$original"
            log_success "Restored: $original"
        fi
        ((removed++))
    fi
}

# ── Remove utility scripts ──────────────────────────────────────────────────
log_info "Checking Honey Badger utility scripts..."
for script in honey-badger-info honey-badger-update honey-badger-install; do
    do_remove "$HOME/.local/bin/$script"
done

# ── Remove theme ────────────────────────────────────────────────────────────
log_info "Checking theme files..."
do_remove "$HOME/.themes/HoneyBadger"
do_remove "$HOME/.icons/HoneyBadger"

# ── Remove nano config ──────────────────────────────────────────────────────
log_info "Checking nano configuration..."
do_restore_backup "$HOME/.nanorc.hb-backup"

# ── Restore backed-up files ─────────────────────────────────────────────────
log_info "Checking for backed-up config files..."
do_restore_backup "$HOME/.bashrc.hb-backup"
do_restore_backup "$HOME/.xinitrc.hb-backup"

# ── Process rollback manifest ───────────────────────────────────────────────
MANIFEST="$HOME/.local/share/honey-badger/rollback-manifest"
if [[ -f "$MANIFEST" ]]; then
    log_info "Processing rollback manifest..."
    while IFS= read -r line; do
        [[ "$line" =~ ^# ]] && continue
        [[ -z "$line" ]] && continue
        case "$line" in
            FILE:*)
                do_remove "${line#FILE:}"
                ;;
            GROUP:*:*)
                local group user
                group="${line#GROUP:}"
                user="${group#*:}"
                group="${group%%:*}"
                if [[ $DRY_RUN -eq 1 ]]; then
                    log_info "Would remove user $user from group $group"
                else
                    sudo gpasswd -d "$user" "$group" 2>/dev/null || true
                    log_success "Removed $user from group $group"
                fi
                ((removed++))
                ;;
            PACKAGE:*)
                # Log but don't auto-remove packages (safety)
                log_info "Skipping package removal (manual): ${line#PACKAGE:}"
                ;;
        esac
    done < "$MANIFEST"
fi

# ── Remove Honey Badger data directory ──────────────────────────────────────
log_info "Checking Honey Badger data..."
do_remove "$HOME/.local/share/honey-badger"

# ── Clean bashrc additions ──────────────────────────────────────────────────
if [[ -f "$HOME/.bashrc" ]]; then
    log_info "Checking bashrc for Honey Badger additions..."
    local_patterns=(
        'export EDITOR=nano'
        'export VISUAL=nano'
        'export PATH="$HOME/.local/bin:$PATH"'
        'export PATH=~/.npm-global/bin:$PATH'
    )
    for pattern in "${local_patterns[@]}"; do
        if grep -Fxq "$pattern" "$HOME/.bashrc" 2>/dev/null; then
            if [[ $DRY_RUN -eq 1 ]]; then
                log_info "Would remove from .bashrc: $pattern"
            else
                grep -Fxv "$pattern" "$HOME/.bashrc" > "$HOME/.bashrc.tmp" && \
                    mv "$HOME/.bashrc.tmp" "$HOME/.bashrc"
                log_success "Removed from .bashrc: $pattern"
            fi
            ((removed++))
        fi
    done
fi

# ── Summary ─────────────────────────────────────────────────────────────────
echo ""
if [[ $DRY_RUN -eq 1 ]]; then
    log_info "Dry run complete. $removed items would be affected."
else
    if [[ $removed -gt 0 ]]; then
        log_success "Uninstall complete. $removed items removed."
        log_info "Restart your terminal or run: source ~/.bashrc"
    else
        log_info "Nothing to remove — Honey Badger OS is not installed or already cleaned up."
    fi
fi
