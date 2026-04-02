# Bash completion for Honey Badger OS install.sh
# Source this file or place in /etc/bash_completion.d/

_honey_badger_install_sh() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local opts="--help --dry-run --non-interactive --no-color --verbose --quiet --skip-docker --skip-python --skip-node --skip-nano"
    COMPREPLY=($(compgen -W "$opts" -- "$cur"))
}
complete -F _honey_badger_install_sh install.sh
complete -F _honey_badger_install_sh ./install.sh

# Completion for honey-badger-install (package names from system)
_honey_badger_pkg_install() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    if [[ "$cur" == -* ]]; then
        COMPREPLY=($(compgen -W "--help" -- "$cur"))
        return
    fi
    # Complete from available packages if package manager supports it
    if command -v apt-cache >/dev/null 2>&1; then
        COMPREPLY=($(apt-cache --no-generate pkgnames "$cur" 2>/dev/null | head -50))
    elif command -v pacman >/dev/null 2>&1; then
        COMPREPLY=($(pacman -Ssq "^${cur}" 2>/dev/null | head -50))
    elif command -v dnf >/dev/null 2>&1; then
        COMPREPLY=($(dnf list --available -q 2>/dev/null | awk '{print $1}' | grep "^${cur}" | head -50))
    fi
}
complete -F _honey_badger_pkg_install honey-badger-install

# Completion for honey-badger-update / honey-badger-info
_honey_badger_simple() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=($(compgen -W "--help" -- "$cur"))
}
complete -F _honey_badger_simple honey-badger-update
complete -F _honey_badger_simple honey-badger-info
