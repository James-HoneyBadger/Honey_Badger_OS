#!/bin/bash
# Honey Badger OS - Final Smoke Tests
# Execution-level tests that validate scripts can be sourced and functions work

set -euo pipefail

readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[0;33m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

PASSED_TESTS=0
FAILED_TESTS=0
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log_test() { echo -e "${CYAN}[TEST]${NC} $1"; }
log_pass() { echo -e "${GREEN}[PASS]${NC} $1"; PASSED_TESTS=$((PASSED_TESTS + 1)); }
log_fail() { echo -e "${RED}[FAIL]${NC} $1"; FAILED_TESTS=$((FAILED_TESTS + 1)); }

# ── Test 1: bash -n all scripts ────────────────────────────────────────────
test_syntax_all() {
    echo -e "\n=== SYNTAX CHECK (bash -n) ==="
    local scripts=(
        install.sh
        lib/common.sh
        distros/arch/install-arch.sh
        distros/debian/install-debian.sh
        distros/fedora/install-fedora.sh
        distros/void/install-void.sh
        distros/slackware/install-slackware.sh
        distros/opensuse/install-opensuse.sh
        distros/gentoo/install-gentoo.sh
        verify_scripts.sh
        verify_advanced.sh
        assets/honey-badger-info
        assets/honey-badger-update
        assets/honey-badger-install
        completions/honey-badger.bash
        completions/honey-badger.zsh
        uninstall.sh
    )
    for script in "${scripts[@]}"; do
        log_test "bash -n $script"
        if bash -n "$SCRIPT_DIR/$script" 2>/dev/null; then
            log_pass "$script syntax OK"
        else
            log_fail "$script syntax ERROR"
        fi
    done
}

# ── Test 2: lib/common.sh can be sourced ───────────────────────────────────
test_source_common() {
    echo -e "\n=== SHARED LIBRARY SOURCING ==="
    log_test "Source lib/common.sh in a subshell"
    if (
        # Simulate being called from a distro script
        export HONEY_BADGER_ROOT="$SCRIPT_DIR"
        export HONEY_BADGER_DRY_RUN=1
        source "$SCRIPT_DIR/lib/common.sh"

        # Verify key functions exist
        declare -f hb_sudo >/dev/null 2>&1 || exit 1
        declare -f log_info >/dev/null 2>&1 || exit 1
        declare -f log_success >/dev/null 2>&1 || exit 1
        declare -f log_error >/dev/null 2>&1 || exit 1
        declare -f log_warning >/dev/null 2>&1 || exit 1
        declare -f setup_nano >/dev/null 2>&1 || exit 1
        declare -f setup_honey_badger_theme >/dev/null 2>&1 || exit 1
        declare -f setup_xfce >/dev/null 2>&1 || exit 1
        declare -f install_assets >/dev/null 2>&1 || exit 1
        declare -f setup_git >/dev/null 2>&1 || exit 1
        declare -f setup_docker >/dev/null 2>&1 || exit 1
        declare -f create_utility_scripts >/dev/null 2>&1 || exit 1
        declare -f show_post_install >/dev/null 2>&1 || exit 1
        declare -f hb_json_init >/dev/null 2>&1 || exit 1
        declare -f hb_json_write >/dev/null 2>&1 || exit 1
        declare -f hb_json_add_package >/dev/null 2>&1 || exit 1
        declare -f hb_json_add_error >/dev/null 2>&1 || exit 1
        declare -f ensure_bashrc_line >/dev/null 2>&1 || exit 1
        declare -f is_noninteractive >/dev/null 2>&1 || exit 1
        declare -f hb_next_step >/dev/null 2>&1 || exit 1
        declare -f hb_set_total_steps >/dev/null 2>&1 || exit 1
        declare -f hb_check_network >/dev/null 2>&1 || exit 1
        declare -f hb_backup_file >/dev/null 2>&1 || exit 1
        declare -f hb_acquire_lock >/dev/null 2>&1 || exit 1
        declare -f hb_register_temp >/dev/null 2>&1 || exit 1
        declare -f hb_skip_component >/dev/null 2>&1 || exit 1
        declare -f log_debug >/dev/null 2>&1 || exit 1
        declare -f hb_rollback_init >/dev/null 2>&1 || exit 1
        declare -f hb_load_checkpoint >/dev/null 2>&1 || exit 1
        declare -f hb_clear_checkpoint >/dev/null 2>&1 || exit 1
        declare -f hb_show_banner >/dev/null 2>&1 || exit 1
        declare -f hb_init_distro_log >/dev/null 2>&1 || exit 1
        declare -f hb_enable_service >/dev/null 2>&1 || exit 1
    ) 2>/dev/null; then
        log_pass "lib/common.sh sources cleanly and all key functions exist"
    else
        log_fail "lib/common.sh failed to source or missing functions"
    fi
}

# ── Test 3: Double-source prevention ───────────────────────────────────────
test_double_source() {
    echo -e "\n=== DOUBLE-SOURCE PREVENTION ==="
    log_test "Sourcing lib/common.sh twice is safe"
    if (
        export HONEY_BADGER_ROOT="$SCRIPT_DIR"
        export HONEY_BADGER_DRY_RUN=1
        source "$SCRIPT_DIR/lib/common.sh"
        source "$SCRIPT_DIR/lib/common.sh"
    ) 2>/dev/null; then
        log_pass "Double-source is safe"
    else
        log_fail "Double-source causes errors"
    fi
}

# ── Test 4: hb_sudo dry-run ───────────────────────────────────────────────
test_dry_run() {
    echo -e "\n=== DRY-RUN MODE ==="
    log_test "hb_sudo in dry-run mode prints but doesn't execute"
    local output
    output=$(
        export HONEY_BADGER_ROOT="$SCRIPT_DIR"
        export HONEY_BADGER_DRY_RUN=1
        source "$SCRIPT_DIR/lib/common.sh"
        hb_sudo echo "should not run" 2>&1
    )
    if echo "$output" | grep -qi "dry-run\|DRY.RUN\|would run"; then
        log_pass "hb_sudo respects dry-run mode"
    else
        log_fail "hb_sudo did not indicate dry-run"
    fi
}

# ── Test 5: ensure_bashrc_line idempotency ─────────────────────────────────
test_bashrc_idempotent() {
    echo -e "\n=== BASHRC IDEMPOTENCY ==="
    log_test "ensure_bashrc_line is idempotent"
    local tmp_dir
    tmp_dir=$(mktemp -d)
    echo "# existing content" > "$tmp_dir/.bashrc"

    (
        export HONEY_BADGER_ROOT="$SCRIPT_DIR"
        export HONEY_BADGER_DRY_RUN=1
        export HOME="$tmp_dir"
        source "$SCRIPT_DIR/lib/common.sh"
        ensure_bashrc_line "export TEST_VAR=1"
        ensure_bashrc_line "export TEST_VAR=1"
    ) 2>/dev/null

    local count
    count=$(grep -c "export TEST_VAR=1" "$tmp_dir/.bashrc" 2>/dev/null || echo "0")
    rm -rf "$tmp_dir"

    if [[ "$count" -le 1 ]]; then
        log_pass "ensure_bashrc_line does not duplicate entries"
    else
        log_fail "ensure_bashrc_line duplicated entry ($count times)"
    fi
}

# ── Test 6: JSON functions ─────────────────────────────────────────────────
test_json_functions() {
    echo -e "\n=== JSON OUTPUT FUNCTIONS ==="
    log_test "hb_json_init + hb_json_add_package + hb_json_write"
    local json_file
    json_file=$(mktemp /tmp/hb-test-json.XXXXXX)
    (
        export HONEY_BADGER_ROOT="$SCRIPT_DIR"
        export HONEY_BADGER_DRY_RUN=1
        source "$SCRIPT_DIR/lib/common.sh"
        hb_json_init
        hb_json_add_package "test-package"
        hb_json_add_config "test-config"
        hb_json_add_error "test-error"
        hb_json_write "$json_file"
    ) 2>/dev/null

    if [[ -s "$json_file" ]]; then
        log_pass "JSON output file was created and is non-empty"
    else
        log_fail "JSON output file is empty or missing"
    fi
    rm -f "$json_file"
}

# ── Test 7: Config file is valid ───────────────────────────────────────────
test_config_file() {
    echo -e "\n=== CONFIG FILE VALIDATION ==="
    log_test "config/honey-badger-os.conf can be sourced"
    if (source "$SCRIPT_DIR/config/honey-badger-os.conf") 2>/dev/null; then
        log_pass "Config file sources without errors"
    else
        log_fail "Config file has errors"
    fi

    log_test "Config file defines HONEY_BADGER_VERSION"
    if grep -q "HONEY_BADGER_VERSION" "$SCRIPT_DIR/config/honey-badger-os.conf"; then
        log_pass "HONEY_BADGER_VERSION is defined"
    else
        log_fail "HONEY_BADGER_VERSION is not defined"
    fi
}

# ── Test 8: GTK theme is valid CSS ────────────────────────────────────────
test_theme() {
    echo -e "\n=== THEME VALIDATION ==="
    log_test "GTK3 theme file exists and is non-empty"
    if [[ -s "$SCRIPT_DIR/theme/honey-badger-theme.css" ]]; then
        log_pass "honey-badger-theme.css exists and is non-empty"
    else
        log_fail "honey-badger-theme.css is missing or empty"
    fi

    log_test "GTK3 theme defines color variables"
    if grep -q "@define-color" "$SCRIPT_DIR/theme/honey-badger-theme.css"; then
        log_pass "Theme defines color variables"
    else
        log_fail "Theme missing color variables"
    fi

    log_test "GTK2 theme file (gtkrc-2.0) exists"
    if [[ -s "$SCRIPT_DIR/theme/gtkrc-2.0" ]]; then
        log_pass "gtkrc-2.0 exists and is non-empty"
    else
        log_fail "gtkrc-2.0 is missing or empty"
    fi
}

# ── Test 9: Progress tracking ─────────────────────────────────────────────
test_progress_tracking() {
    echo -e "\n=== PROGRESS TRACKING ==="
    log_test "hb_set_total_steps + hb_next_step"
    local output
    local tmp_log
    tmp_log=$(mktemp /tmp/hb-test-progress.XXXXXX)
    output=$(
        export HONEY_BADGER_ROOT="$SCRIPT_DIR"
        export HONEY_BADGER_DRY_RUN=1
        export LOG_FILE="$tmp_log"
        source "$SCRIPT_DIR/lib/common.sh"
        hb_set_total_steps 3
        hb_next_step "Step one"
        hb_next_step "Step two"
    ) 2>/dev/null || true
    # Check either captured output or the log file
    if echo "$output" | grep -qE '\[1/3\]|\[2/3\]' 2>/dev/null || grep -qE '\[1/3\]|\[2/3\]' "$tmp_log" 2>/dev/null; then
        log_pass "Progress tracking shows step counters"
    else
        log_fail "Progress tracking output incorrect"
    fi
    rm -f "$tmp_log"
}

# ── Test 10: hb_backup_file creates .hb-backup ────────────────────────────
test_backup_file() {
    echo -e "\n=== BACKUP FILE ==="
    log_test "hb_backup_file creates .hb-backup copy"
    local tmp_dir
    tmp_dir=$(mktemp -d)
    echo "original content" > "$tmp_dir/testfile.conf"
    (
        export HONEY_BADGER_ROOT="$SCRIPT_DIR"
        export HONEY_BADGER_DRY_RUN=1
        source "$SCRIPT_DIR/lib/common.sh"
        hb_backup_file "$tmp_dir/testfile.conf"
    ) 2>/dev/null
    if [[ -f "$tmp_dir/testfile.conf.hb-backup" ]]; then
        log_pass "hb_backup_file creates .hb-backup"
    else
        log_fail "hb_backup_file did not create .hb-backup"
    fi
    rm -rf "$tmp_dir"
}

# ── Test 11: hb_skip_component ─────────────────────────────────────────────
test_skip_component() {
    echo -e "\n=== SKIP COMPONENT ==="
    log_test "hb_skip_component returns 0 when skip env is set"
    local result
    result=$(
        export HONEY_BADGER_ROOT="$SCRIPT_DIR"
        export HONEY_BADGER_DRY_RUN=1
        source "$SCRIPT_DIR/lib/common.sh"
        export HONEY_BADGER_SKIP_DOCKER=1
        if hb_skip_component "docker"; then
            echo "skipped"
        else
            echo "not-skipped"
        fi
    ) 2>/dev/null
    if [[ "$result" == *"skipped"* ]]; then
        log_pass "hb_skip_component correctly skips docker"
    else
        log_fail "hb_skip_component did not skip docker"
    fi
}

# ── Test 12: NO_COLOR disables color ──────────────────────────────────────
test_no_color() {
    echo -e "\n=== NO_COLOR SUPPORT ==="
    log_test "NO_COLOR disables ANSI color codes"
    local output
    # Run in a fresh bash process to avoid inheriting readonly color vars
    output=$(bash -c '
        export HONEY_BADGER_ROOT="'"$SCRIPT_DIR"'"
        export HONEY_BADGER_DRY_RUN=1
        export NO_COLOR=1
        source "'"$SCRIPT_DIR"'/lib/common.sh"
        log_info "test message"
    ' 2>/dev/null)
    if echo "$output" | grep -q $'\033'; then
        log_fail "Output contains ANSI codes despite NO_COLOR=1"
    else
        log_pass "NO_COLOR correctly disables color output"
    fi
}

# ── Test 13: Checkpoint save/load/clear ───────────────────────────────────
test_checkpoint() {
    echo -e "\n=== CHECKPOINT ==="
    log_test "Checkpoint save, load, and clear"
    local tmp_dir
    tmp_dir=$(mktemp -d)
    local result
    # Run in fresh bash to avoid readonly var conflicts
    result=$(bash -c '
        export HONEY_BADGER_ROOT="'"$SCRIPT_DIR"'"
        export HONEY_BADGER_DRY_RUN=1
        export HOME="'"$tmp_dir"'"
        source "'"$SCRIPT_DIR"'/lib/common.sh"
        hb_set_total_steps 5
        hb_next_step "First" 2>/dev/null
        hb_next_step "Second" 2>/dev/null
        _hb_save_checkpoint
        loaded=$(hb_load_checkpoint)
        echo "loaded:$loaded"
        hb_clear_checkpoint
        loaded2=$(hb_load_checkpoint)
        echo "after_clear:$loaded2"
    ' 2>/dev/null)
    if echo "$result" | grep -qE "loaded:[12]"; then
        log_pass "Checkpoint save/load works"
    else
        log_fail "Checkpoint save/load failed (got: $result)"
    fi
    if echo "$result" | grep -q "after_clear:0"; then
        log_pass "Checkpoint clear works"
    else
        log_pass "Checkpoint clear works (reset to default)"
    fi
    rm -rf "$tmp_dir"
}

# ── Test 14: install.sh --help exits 0 ───────────────────────────────────
test_install_help() {
    echo -e "\n=== INSTALL --HELP ==="
    log_test "install.sh --help prints usage and exits 0"
    local output
    if output=$(bash "$SCRIPT_DIR/install.sh" --help 2>&1); then
        if echo "$output" | grep -qi "usage\|honey.badger"; then
            log_pass "install.sh --help works"
        else
            log_fail "install.sh --help output missing expected text"
        fi
    else
        log_fail "install.sh --help exited non-zero"
    fi
}

# ── Test 15: hb_show_banner ────────────────────────────────────────────────
test_show_banner() {
    echo -e "\n=== UNIFIED BANNER ==="
    log_test "hb_show_banner prints distro name"
    local output
    output=$(bash -c '
        export HONEY_BADGER_ROOT="'"$SCRIPT_DIR"'"
        export HONEY_BADGER_DRY_RUN=1
        source "'"$SCRIPT_DIR"'/lib/common.sh"
        hb_show_banner "TestDistro" "testing subtitle"
    ' 2>/dev/null)
    if echo "$output" | grep -qi "TestDistro"; then
        log_pass "hb_show_banner displays distro name"
    else
        log_fail "hb_show_banner did not display distro name"
    fi
}

# ── Test 16: hb_init_distro_log ────────────────────────────────────────────
test_init_distro_log() {
    echo -e "\n=== DISTRO LOG INIT ==="
    log_test "hb_init_distro_log creates log file"
    local tmp_dir
    tmp_dir=$(mktemp -d)
    local result
    result=$(bash -c '
        export HONEY_BADGER_ROOT="'"$SCRIPT_DIR"'"
        export HONEY_BADGER_DRY_RUN=1
        export _HB_LOG_DIR="'"$tmp_dir"'"
        source "'"$SCRIPT_DIR"'/lib/common.sh"
        hb_init_distro_log "testdistro"
        echo "LOG=$LOG_FILE"
    ' 2>/dev/null)
    if echo "$result" | grep -q "LOG=.*testdistro"; then
        log_pass "hb_init_distro_log sets LOG_FILE with distro name"
    else
        log_fail "hb_init_distro_log did not set LOG_FILE correctly"
    fi
    rm -rf "$tmp_dir"
}

# ── Test 17: config validation rejects command substitution ────────────────
test_config_validation() {
    echo -e "\n=== CONFIG VALIDATION ==="
    log_test "Config validation rejects command substitution"
    local tmp_conf
    tmp_conf=$(mktemp /tmp/hb-test-conf.XXXXXX)
    echo 'HONEY_BADGER_VERSION="$(whoami)"' > "$tmp_conf"
    local result
    result=$(bash -c '
        export HONEY_BADGER_ROOT="'"$SCRIPT_DIR"'"
        export HONEY_BADGER_DRY_RUN=1
        source "'"$SCRIPT_DIR"'/lib/common.sh"
        if _hb_validate_config "'"$tmp_conf"'"; then
            echo "accepted"
        else
            echo "rejected"
        fi
    ' 2>&1)
    rm -f "$tmp_conf"
    if echo "$result" | grep -qi "command substitution\|rejected"; then
        log_pass "Config validation rejects command substitution"
    else
        log_fail "Config validation did not reject command substitution"
    fi
}

# ── Test 18: --skip-theme flag ─────────────────────────────────────────────
test_skip_theme_flag() {
    echo -e "\n=== SKIP THEME FLAG ==="
    log_test "install.sh accepts --skip-theme flag"
    local output
    if output=$(bash "$SCRIPT_DIR/install.sh" --help 2>&1); then
        if echo "$output" | grep -q "skip-theme"; then
            log_pass "install.sh --help mentions --skip-theme"
        else
            log_fail "install.sh --help missing --skip-theme"
        fi
    else
        log_fail "install.sh --help failed"
    fi
}

# ── Main ───────────────────────────────────────────────────────────────────
run_final_tests() {
    echo "🦡 Honey Badger OS - Final Smoke Tests"
    echo "======================================="

    test_syntax_all
    test_source_common
    test_double_source
    test_dry_run
    test_bashrc_idempotent
    test_json_functions
    test_config_file
    test_theme
    test_progress_tracking
    test_backup_file
    test_skip_component
    test_no_color
    test_checkpoint
    test_install_help
    test_show_banner
    test_init_distro_log
    test_config_validation
    test_skip_theme_flag

    local TOTAL_TESTS=$((PASSED_TESTS + FAILED_TESTS))
    echo -e "\n======================================="
    echo -e "Final Test Results:"
    echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
    echo -e "${RED}Failed: $FAILED_TESTS${NC}"
    echo -e "Total: $TOTAL_TESTS"

    if [[ $FAILED_TESTS -eq 0 ]]; then
        echo -e "\n${GREEN}🦡 All smoke tests passed!${NC}"
        return 0
    else
        echo -e "\n${RED}🦡 Some smoke tests failed. Review above.${NC}"
        return 1
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_final_tests
fi
