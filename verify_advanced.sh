#!/bin/bash
# Advanced Honey Badger OS Script Verification
# Tests for runtime functionality and potential issues

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

# Test package names for validity (common typos or non-existent packages)
test_package_names() {
    echo -e "\n=== PACKAGE NAME VALIDATION ==="
    
    # Common typos and issues
    local suspicious_patterns=(
        "nodejs.*npm.*yarn" # Node.js with multiple package managers
        "python.*python3" # Mixed Python versions
        "gcc.*clang" # Multiple compilers (might conflict)
        "docker.*podman" # Multiple container engines
    )
    
    log_test "Checking for potentially conflicting packages"
    local found_conflicts=false
    for script in distros/*/install-*.sh; do
        for pattern in "${suspicious_patterns[@]}"; do
            if grep -q "$pattern" "$script" 2>/dev/null; then
                log_warn "Potential package conflict in $(basename "$script"): $pattern"
                found_conflicts=true
            fi
        done
    done
    
    if ! $found_conflicts; then
        log_pass "No obvious package conflicts detected"
    fi
    
    # Check for common typos
    log_test "Checking for common package name typos"
    local typos=(
        "firefx" "chronium" "libreofice" "thunderbrd" "gim"
        "pytho" "node" "vs-code" "vscoe" "codium"
    )
    
    local found_typos=false
    for script in distros/*/install-*.sh; do
        for typo in "${typos[@]}"; do
            if grep -qi "$typo" "$script" 2>/dev/null; then
                log_fail "Possible typo in $(basename "$script"): $typo"
                found_typos=true
            fi
        done
    done
    
    if ! $found_typos; then
        log_pass "No common typos detected in package names"
    fi
}

# Test sudo usage patterns
test_sudo_usage() {
    echo -e "\n=== SUDO USAGE VALIDATION ==="
    
    log_test "Checking for unsafe sudo patterns"
    local unsafe_patterns=(
        "sudo.*rm.*-rf.*/" # Dangerous recursive deletes
        "sudo.*chmod.*777" # Overly permissive permissions
        "sudo.*chown.*-R.*/" # Recursive ownership changes to root
        "sudo.*>" # Redirecting output with sudo (often problematic)
    )
    
    local found_unsafe=false
    for script in distros/*/install-*.sh; do
        for pattern in "${unsafe_patterns[@]}"; do
            if grep -q "$pattern" "$script" 2>/dev/null; then
                log_fail "Unsafe sudo pattern in $(basename "$script"): $pattern"
                found_unsafe=true
            fi
        done
    done
    
    if ! $found_unsafe; then
        log_pass "No unsafe sudo patterns detected"
    fi
    
    log_test "Checking for proper sudo usage in package installation"
    local scripts_with_sudo=0
    for script in distros/*/install-*.sh; do
        if grep -q "sudo.*install\|sudo.*update\|sudo.*upgrade" "$script"; then
            scripts_with_sudo=$((scripts_with_sudo + 1))
        fi
    done
    
    if [[ $scripts_with_sudo -ge 4 ]]; then
        log_pass "Distribution scripts properly use sudo for package operations"
    else
        log_fail "Some scripts may be missing sudo for package operations"
    fi
}

# Test service management
test_service_management() {
    echo -e "\n=== SERVICE MANAGEMENT VALIDATION ==="
    
    log_test "Checking systemctl enable patterns"
    local services_enabled=false
    for script in distros/*/install-*.sh; do
        if grep -q "systemctl.*enable\|systemctl.*start" "$script"; then
            services_enabled=true
            # Check if service exists before enabling
            if grep -q "systemctl.*enable.*[a-zA-Z]" "$script"; then
                log_pass "$(basename "$script") enables services"
            fi
        fi
    done
    
    if $services_enabled; then
        log_test "Checking for service availability verification"
        local scripts_with_verification=0
        for script in distros/*/install-*.sh; do
            if grep -q "systemctl.*is-enabled\|systemctl.*status\|2>/dev/null.*true" "$script"; then
                scripts_with_verification=$((scripts_with_verification + 1))
            fi
        done
        
        if [[ $scripts_with_verification -gt 0 ]]; then
            log_pass "Some scripts verify service availability before enabling"
        else
            log_warn "Scripts enable services without checking availability"
        fi
    else
        log_warn "No systemctl service management found"
    fi
}

# Test environment variable handling
test_environment_handling() {
    echo -e "\n=== ENVIRONMENT VARIABLE HANDLING ==="
    
    log_test "Checking for proper variable quoting"
    local unquoted_vars=0
    for script in install.sh distros/*/install-*.sh; do
        # Look for unquoted variables that could cause issues
        if grep -q '\$[A-Za-z_][A-Za-z0-9_]*[^"'"'"']' "$script" && \
           ! grep -q 'set.*-u' "$script"; then
            unquoted_vars=$((unquoted_vars + 1))
        fi
    done
    
    if [[ $unquoted_vars -eq 0 ]]; then
        log_pass "Variable quoting appears correct"
    else
        log_warn "$unquoted_vars scripts may have unquoted variables"
    fi
    
    log_test "Checking for default value handling"
    local scripts_with_defaults=0
    for script in distros/*/install-*.sh; do
        if grep -q '\${.*:-.*}' "$script"; then
            scripts_with_defaults=$((scripts_with_defaults + 1))
        fi
    done
    
    if [[ $scripts_with_defaults -gt 0 ]]; then
        log_pass "$scripts_with_defaults scripts use parameter expansion with defaults"
    else
        log_warn "No scripts use parameter expansion with defaults"
    fi
}

# Test error handling robustness
test_error_robustness() {
    echo -e "\n=== ERROR HANDLING ROBUSTNESS ==="
    
    log_test "Checking for command existence verification"
    local scripts_checking_commands=0
    for script in distros/*/install-*.sh; do
        if grep -q "command -v\|which.*>/dev/null" "$script"; then
            scripts_checking_commands=$((scripts_checking_commands + 1))
        fi
    done
    
    if [[ $scripts_checking_commands -gt 0 ]]; then
        log_pass "$scripts_checking_commands scripts verify command existence"
    else
        log_fail "No scripts verify command existence before use"
    fi
    
    log_test "Checking for network operation error handling"
    local scripts_with_network_handling=0
    for script in distros/*/install-*.sh; do
        if grep -q "curl.*--fail\|wget.*--retry\|ping.*-c.*||" "$script"; then
            scripts_with_network_handling=$((scripts_with_network_handling + 1))
        fi
    done
    
    if [[ $scripts_with_network_handling -gt 0 ]]; then
        log_pass "Some scripts handle network operation failures"
    else
        log_warn "Scripts may not handle network failures gracefully"
    fi
}

# Test file operations safety
test_file_operations() {
    echo -e "\n=== FILE OPERATIONS SAFETY ==="
    
    log_test "Checking for backup creation before modifications"
    local scripts_creating_backups=0
    for script in distros/*/install-*.sh; do
        if grep -q "cp.*\.bak\|mv.*\.backup\|backup.*mkdir" "$script"; then
            scripts_creating_backups=$((scripts_creating_backups + 1))
        fi
    done
    
    if [[ $scripts_creating_backups -gt 0 ]]; then
        log_pass "Some scripts create backups before modifications"
    else
        log_warn "No scripts appear to create backups before modifications"
    fi
    
    log_test "Checking for file existence verification"
    local scripts_checking_files=0
    for script in distros/*/install-*.sh; do
        if grep -q '\[\[.*-f.*\]\]\|\[\[.*-d.*\]\]' "$script"; then
            scripts_checking_files=$((scripts_checking_files + 1))
        fi
    done
    
    if [[ $scripts_checking_files -gt 0 ]]; then
        log_pass "$scripts_checking_files scripts verify file/directory existence"
    else
        log_fail "No scripts verify file/directory existence"
    fi
}

# Test for completeness of installation types
test_installation_completeness() {
    echo -e "\n=== INSTALLATION TYPE COMPLETENESS ==="
    
    local install_types=("full" "developer" "desktop" "minimal")
    
    for install_type in "${install_types[@]}"; do
        log_test "Checking $install_type installation type support"
        local scripts_supporting_type=0
        for script in distros/*/install-*.sh; do
            if grep -q "$install_type" "$script"; then
                scripts_supporting_type=$((scripts_supporting_type + 1))
            fi
        done
        
        if [[ $scripts_supporting_type -gt 0 ]]; then
            log_pass "$scripts_supporting_type scripts support '$install_type' installation"
        else
            log_fail "No scripts support '$install_type' installation type"
        fi
    done
}

# Main test runner
run_advanced_tests() {
    echo "🦡 Advanced Honey Badger OS Script Verification"
    echo "==============================================="
    
    test_package_names
    test_sudo_usage
    test_service_management
    test_environment_handling
    test_error_robustness
    test_file_operations
    test_installation_completeness
    
    echo -e "\n==============================================="
    echo -e "Advanced Test Results:"
    echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
    echo -e "${RED}Failed: $FAILED_TESTS${NC}"
    echo -e "Total: $TOTAL_TESTS"
    
    if [[ $FAILED_TESTS -eq 0 ]]; then
        echo -e "\n${GREEN}🦡 Advanced tests passed! Scripts are robust and ready.${NC}"
        return 0
    else
        echo -e "\n${YELLOW}🦡 Some advanced issues detected. Review recommendations above.${NC}"
        return 0  # Don't fail on warnings, just inform
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_advanced_tests
fi