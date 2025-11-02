#!/bin/bash
# Honey Badger OS Script Verification Tool
# Tests the installation scripts for common issues and potential problems

set -euo pipefail

readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[0;33m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

log_test() {
    echo -e "${CYAN}[TEST]${NC} $1"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
}

log_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    PASSED_TESTS=$((PASSED_TESTS + 1))
}

log_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    FAILED_TESTS=$((FAILED_TESTS + 1))
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Test 1: Syntax validation
test_syntax() {
    echo -e "\n=== SYNTAX VALIDATION ==="
    
    log_test "Main installer script syntax"
    if bash -n install.sh 2>/dev/null; then
        log_pass "Main script syntax is valid"
    else
        log_fail "Main script has syntax errors"
        bash -n install.sh
    fi
    
    for script in distros/*/install-*.sh; do
        local script_name=$(basename "$script")
        log_test "Syntax check for $script_name"
        if bash -n "$script" 2>/dev/null; then
            log_pass "$script_name syntax is valid"
        else
            log_fail "$script_name has syntax errors"
            bash -n "$script"
        fi
    done
}

# Test 2: File structure validation
test_file_structure() {
    echo -e "\n=== FILE STRUCTURE VALIDATION ==="
    
    log_test "Required directories exist"
    local required_dirs=("distros" "config" "theme" "assets")
    for dir in "${required_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            log_pass "Directory '$dir' exists"
        else
            log_fail "Required directory '$dir' is missing"
        fi
    done
    
    log_test "Distribution scripts exist"
    local distros=("arch" "debian" "fedora" "slackware" "void")
    for distro in "${distros[@]}"; do
        local script="distros/$distro/install-$distro.sh"
        if [[ -f "$script" ]]; then
            log_pass "Script for $distro exists"
            if [[ -x "$script" ]]; then
                log_pass "Script for $distro is executable"
            else
                log_fail "Script for $distro is not executable"
            fi
        else
            log_fail "Script for $distro is missing"
        fi
    done
}

# Test 3: Hardcoded paths check
test_hardcoded_paths() {
    echo -e "\n=== HARDCODED PATHS CHECK ==="
    
    log_test "Checking for hardcoded paths"
    local found_hardcoded=false
    
    if grep -r "/Users/daddy" distros/ >/dev/null 2>&1; then
        log_fail "Found hardcoded paths in distribution scripts:"
        grep -rn "/Users/daddy" distros/ | while read -r line; do
            echo "  $line"
        done
        found_hardcoded=true
    fi
    
    if grep -r "/home/[^/]" distros/ >/dev/null 2>&1; then
        log_fail "Found potential hardcoded home paths:"
        grep -rn "/home/[^/]" distros/ | while read -r line; do
            echo "  $line"
        done
        found_hardcoded=true
    fi
    
    if ! $found_hardcoded; then
        log_pass "No obvious hardcoded paths found"
    fi
}

# Test 4: Required functions exist
test_required_functions() {
    echo -e "\n=== REQUIRED FUNCTIONS CHECK ==="
    
    local main_functions=("main" "detect_distribution" "check_sudo" "run_preflight_checks")
    
    for func in "${main_functions[@]}"; do
        log_test "Main script has '$func' function"
        if grep -q "^${func}()" install.sh || grep -q "^${func} ()" install.sh; then
            log_pass "Function '$func' found in main script"
        else
            log_fail "Function '$func' missing from main script"
        fi
    done
    
    # Check distribution scripts have main function
    for script in distros/*/install-*.sh; do
        local script_name=$(basename "$script")
        log_test "$script_name has main function"
        if grep -q "^main()" "$script" || grep -q "^main ()" "$script"; then
            log_pass "$script_name has main function"
        else
            log_fail "$script_name missing main function"
        fi
    done
}

# Test 5: Package manager commands validation
test_package_managers() {
    echo -e "\n=== PACKAGE MANAGER VALIDATION ==="
    
    # Check if scripts use appropriate package managers
    log_test "Arch script uses pacman"
    if grep -q "pacman\|yay" distros/arch/install-arch.sh; then
        log_pass "Arch script uses pacman/yay"
    else
        log_fail "Arch script doesn't use pacman/yay"
    fi
    
    log_test "Debian script uses apt"
    if grep -q "apt\|apt-get" distros/debian/install-debian.sh; then
        log_pass "Debian script uses apt"
    else
        log_fail "Debian script doesn't use apt"
    fi
    
    log_test "Fedora script uses dnf/yum"
    if grep -q "dnf\|yum" distros/fedora/install-fedora.sh; then
        log_pass "Fedora script uses dnf/yum"
    else
        log_fail "Fedora script doesn't use dnf/yum"
    fi
    
    log_test "Void script uses xbps"
    if grep -q "xbps" distros/void/install-void.sh; then
        log_pass "Void script uses xbps"
    else
        log_fail "Void script doesn't use xbps"
    fi
}

# Test 6: Environment variable usage
test_environment_variables() {
    echo -e "\n=== ENVIRONMENT VARIABLE USAGE ==="
    
    log_test "Scripts use HONEY_BADGER_INSTALL_TYPE"
    local scripts_using_var=0
    for script in distros/*/install-*.sh; do
        if grep -q "HONEY_BADGER_INSTALL_TYPE" "$script"; then
            scripts_using_var=$((scripts_using_var + 1))
        fi
    done
    
    if [[ $scripts_using_var -gt 0 ]]; then
        log_pass "$scripts_using_var distribution scripts use HONEY_BADGER_INSTALL_TYPE"
    else
        log_fail "No distribution scripts use HONEY_BADGER_INSTALL_TYPE"
    fi
    
    log_test "Main script sets environment variable"
    if grep -q "export HONEY_BADGER_INSTALL_TYPE" install.sh; then
        log_pass "Main script exports HONEY_BADGER_INSTALL_TYPE"
    else
        log_fail "Main script doesn't export HONEY_BADGER_INSTALL_TYPE"
    fi
}

# Test 7: Error handling
test_error_handling() {
    echo -e "\n=== ERROR HANDLING CHECK ==="
    
    log_test "Scripts use 'set -euo pipefail'"
    local scripts_with_safety=0
    for script in install.sh distros/*/install-*.sh; do
        if head -10 "$script" | grep -q "set -euo pipefail"; then
            scripts_with_safety=$((scripts_with_safety + 1))
        else
            log_fail "$(basename "$script") missing 'set -euo pipefail'"
        fi
    done
    
    if [[ $scripts_with_safety -eq 6 ]]; then
        log_pass "All scripts use proper error handling"
    else
        log_warn "$scripts_with_safety/6 scripts use 'set -euo pipefail'"
    fi
}

# Test 8: Configuration files exist
test_config_files() {
    echo -e "\n=== CONFIGURATION FILES CHECK ==="
    
    local config_files=("config/nanorc" "config/honey-badger-os.conf")
    for config in "${config_files[@]}"; do
        log_test "Configuration file '$config' exists"
        if [[ -f "$config" ]]; then
            log_pass "Configuration file '$config' found"
        else
            log_fail "Configuration file '$config' missing"
        fi
    done
}

# Main test runner
run_all_tests() {
    echo "🦡 Honey Badger OS Script Verification Tool"
    echo "============================================="
    
    test_syntax
    test_file_structure
    test_hardcoded_paths
    test_required_functions
    test_package_managers
    test_environment_variables
    test_error_handling
    test_config_files
    
    echo -e "\n============================================="
    echo -e "Test Results:"
    echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
    echo -e "${RED}Failed: $FAILED_TESTS${NC}"
    echo -e "Total: $TOTAL_TESTS"
    
    if [[ $FAILED_TESTS -eq 0 ]]; then
        echo -e "\n${GREEN}🦡 All tests passed! Scripts appear to be ready for deployment.${NC}"
        return 0
    else
        echo -e "\n${RED}🦡 Some tests failed. Please review the issues above.${NC}"
        return 1
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_all_tests
fi
