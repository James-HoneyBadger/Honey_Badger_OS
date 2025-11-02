#!/bin/bash
# Honey Badger OS Script Verification Tool
# This script performs comprehensive verification of all installation scripts

set -uo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'
readonly BOLD='\033[1m'

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Helper functions
print_header() {
    echo -e "\n${BOLD}${BLUE}🦡 $1 🦡${NC}"
    echo "=================================="
}

print_test() {
    echo -e "${CYAN}Testing: $1${NC}"
}

print_pass() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    ((PASSED++))
}

print_fail() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    ((FAILED++))
}

print_warn() {
    echo -e "${YELLOW}⚠ WARN${NC}: $1"
    ((WARNINGS++))
}

print_info() {
    echo -e "${CYAN}ℹ INFO${NC}: $1"
}

# Test 1: Syntax Verification
test_syntax() {
    print_header "SYNTAX VERIFICATION"
    
    print_test "Main installation script"
    if bash -n install.sh; then
        print_pass "install.sh syntax is valid"
    else
        print_fail "install.sh has syntax errors"
    fi
    
    for script in distros/*/install-*.sh; do
        if [[ -f "$script" ]]; then
            print_test "$(basename "$script")"
            if bash -n "$script"; then
                print_pass "$script syntax is valid"
            else
                print_fail "$script has syntax errors"
            fi
        fi
    done
}

# Test 2: File Permissions
test_permissions() {
    print_header "FILE PERMISSIONS"
    
    print_test "Main script executable permission"
    if [[ -x "install.sh" ]]; then
        print_pass "install.sh is executable"
    else
        print_fail "install.sh is not executable"
    fi
    
    for script in distros/*/install-*.sh; do
        if [[ -f "$script" ]]; then
            print_test "$(basename "$script") executable permission"
            if [[ -x "$script" ]]; then
                print_pass "$script is executable"
            else
                print_fail "$script is not executable"
            fi
        fi
    done
}

# Test 3: Required Files and Structure
test_structure() {
    print_header "PROJECT STRUCTURE"
    
    local required_files=(
        "install.sh"
        "README.md"
        "LICENSE"
        "PROJECT_OVERVIEW.md"
        "config/honey-badger-os.conf"
        "config/nanorc"
        "theme/honey-badger-theme.css"
        "theme/gtkrc-2.0"
    )
    
    for file in "${required_files[@]}"; do
        print_test "Required file: $file"
        if [[ -f "$file" ]]; then
            print_pass "$file exists"
        else
            print_fail "$file is missing"
        fi
    done
    
    local required_dirs=(
        "distros"
        "distros/arch"
        "distros/debian"
        "distros/fedora"
        "distros/slackware"
        "distros/void"
        "config"
        "theme"
        "assets"
    )
    
    for dir in "${required_dirs[@]}"; do
        print_test "Required directory: $dir"
        if [[ -d "$dir" ]]; then
            print_pass "$dir directory exists"
        else
            print_fail "$dir directory is missing"
        fi
    done
}

# Test 4: Distribution Scripts Completeness
test_distro_scripts() {
    print_header "DISTRIBUTION SCRIPTS"
    
    local distros=("arch" "debian" "fedora" "slackware" "void")
    
    for distro in "${distros[@]}"; do
        local script="distros/$distro/install-$distro.sh"
        print_test "$distro distribution script"
        
        if [[ ! -f "$script" ]]; then
            print_fail "$script does not exist"
            continue
        fi
        
        # Check for required functions/sections
        local required_patterns=(
            "#!/bin/bash"
            "set -euo pipefail"
            "log_info"
            "log_error"
            "main"
        )
        
        local missing_patterns=()
        for pattern in "${required_patterns[@]}"; do
            if ! grep -q "$pattern" "$script"; then
                missing_patterns+=("$pattern")
            fi
        done
        
        if [[ ${#missing_patterns[@]} -eq 0 ]]; then
            print_pass "$script has required patterns"
        else
            print_fail "$script missing patterns: ${missing_patterns[*]}"
        fi
    done
}

# Test 5: Configuration Files Validation
test_config_files() {
    print_header "CONFIGURATION FILES"
    
    print_test "Honey Badger OS configuration"
    if [[ -f "config/honey-badger-os.conf" ]]; then
        if grep -q "HONEY_BADGER_VERSION" config/honey-badger-os.conf; then
            print_pass "Configuration file has version info"
        else
            print_warn "Configuration file missing version info"
        fi
        
        if grep -q "HONEY_BADGER_THEME" config/honey-badger-os.conf; then
            print_pass "Configuration file has theme settings"
        else
            print_warn "Configuration file missing theme settings"
        fi
    else
        print_fail "Configuration file missing"
    fi
    
    print_test "Nano configuration"
    if [[ -f "config/nanorc" ]]; then
        if grep -q "set linenumbers" config/nanorc; then
            print_pass "Nano config has line numbers enabled"
        else
            print_warn "Nano config missing line numbers setting"
        fi
        
        if grep -q "set autoindent" config/nanorc; then
            print_pass "Nano config has autoindent enabled"
        else
            print_warn "Nano config missing autoindent setting"
        fi
    else
        print_fail "Nano configuration file missing"
    fi
}

# Test 6: Theme Files
test_theme_files() {
    print_header "THEME FILES"
    
    print_test "GTK theme file"
    if [[ -f "theme/gtkrc-2.0" ]]; then
        print_pass "GTK 2.0 theme file exists"
    else
        print_fail "GTK 2.0 theme file missing"
    fi
    
    print_test "CSS theme file"
    if [[ -f "theme/honey-badger-theme.css" ]]; then
        if grep -q "color" theme/honey-badger-theme.css; then
            print_pass "CSS theme file has color definitions"
        else
            print_warn "CSS theme file may be incomplete"
        fi
    else
        print_fail "CSS theme file missing"
    fi
}

# Test 7: Package Lists Validation
test_package_lists() {
    print_header "PACKAGE LISTS VALIDATION"
    
    for script in distros/*/install-*.sh; do
        if [[ -f "$script" ]]; then
            local distro=$(basename "$(dirname "$script")")
            print_test "$distro package lists"
            
            # Check for common package manager commands
            local pm_found=false
            case "$distro" in
                arch)
                    if grep -q "pacman\|yay" "$script"; then
                        pm_found=true
                    fi
                    ;;
                debian)
                    if grep -q "apt-get\|apt " "$script"; then
                        pm_found=true
                    fi
                    ;;
                fedora)
                    if grep -q "dnf\|yum" "$script"; then
                        pm_found=true
                    fi
                    ;;
                slackware)
                    if grep -q "slackpkg\|installpkg" "$script"; then
                        pm_found=true
                    fi
                    ;;
                void)
                    if grep -q "xbps-install" "$script"; then
                        pm_found=true
                    fi
                    ;;
            esac
            
            if $pm_found; then
                print_pass "$distro uses correct package manager"
            else
                print_fail "$distro missing or incorrect package manager commands"
            fi
        fi
    done
}

# Test 8: Error Handling
test_error_handling() {
    print_header "ERROR HANDLING"
    
    print_test "Main script error handling"
    if grep -q "set -euo pipefail" install.sh; then
        print_pass "Main script has proper error handling"
    else
        print_fail "Main script missing error handling"
    fi
    
    if grep -q "trap.*exit" install.sh; then
        print_pass "Main script has interrupt handling"
    else
        print_warn "Main script missing interrupt handling"
    fi
    
    for script in distros/*/install-*.sh; do
        if [[ -f "$script" ]]; then
            print_test "$(basename "$script") error handling"
            if grep -q "set -euo pipefail" "$script"; then
                print_pass "$script has proper error handling"
            else
                print_fail "$script missing error handling"
            fi
        fi
    done
}

# Test 9: Documentation Quality
test_documentation() {
    print_header "DOCUMENTATION"
    
    local docs=("README.md" "PROJECT_OVERVIEW.md" "USER_GUIDE.md")
    
    for doc in "${docs[@]}"; do
        print_test "$doc content"
        if [[ -f "$doc" ]]; then
            local word_count=$(wc -w < "$doc")
            if [[ $word_count -gt 100 ]]; then
                print_pass "$doc has substantial content ($word_count words)"
            else
                print_warn "$doc seems too short ($word_count words)"
            fi
        else
            print_fail "$doc is missing"
        fi
    done
}

# Test 10: Security Checks
test_security() {
    print_header "SECURITY CHECKS"
    
    print_test "Root execution prevention"
    if grep -q "check_root\|EUID.*eq.*0" install.sh; then
        print_pass "Main script prevents root execution"
    else
        print_fail "Main script doesn't prevent root execution"
    fi
    
    print_test "Sudo privilege checking"
    if grep -q "sudo.*true\|check_sudo" install.sh; then
        print_pass "Main script checks sudo privileges"
    else
        print_warn "Main script doesn't verify sudo privileges"
    fi
    
    for script in distros/*/install-*.sh; do
        if [[ -f "$script" ]]; then
            print_test "$(basename "$script") uses sudo appropriately"
            if grep -q "sudo" "$script" && ! grep -q "sudo.*su\|sudo.*bash" "$script"; then
                print_pass "$script uses sudo safely"
            elif ! grep -q "sudo" "$script"; then
                print_warn "$script doesn't use sudo (may require root)"
            else
                print_fail "$script has potentially unsafe sudo usage"
            fi
        fi
    done
}

# Main execution
main() {
    echo -e "${BOLD}${YELLOW}🦡 Honey Badger OS Script Verification Tool 🦡${NC}\n"
    
    # Change to script directory
    cd "$(dirname "${BASH_SOURCE[0]}")"
    
    test_syntax
    test_permissions
    test_structure
    test_distro_scripts
    test_config_files
    test_theme_files
    test_package_lists
    test_error_handling
    test_documentation
    test_security
    
    # Summary
    print_header "VERIFICATION SUMMARY"
    echo -e "${GREEN}✓ Passed: $PASSED${NC}"
    echo -e "${YELLOW}⚠ Warnings: $WARNINGS${NC}"
    echo -e "${RED}✗ Failed: $FAILED${NC}"
    echo
    
    if [[ $FAILED -eq 0 ]]; then
        if [[ $WARNINGS -eq 0 ]]; then
            echo -e "${BOLD}${GREEN}🦡 ALL TESTS PASSED! Scripts are ready for deployment! 🦡${NC}"
        else
            echo -e "${BOLD}${YELLOW}🦡 Tests passed with warnings. Review warnings before deployment. 🦡${NC}"
        fi
        exit 0
    else
        echo -e "${BOLD}${RED}🦡 Some tests failed. Please fix issues before deployment. 🦡${NC}"
        exit 1
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi