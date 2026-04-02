#compdef install.sh honey-badger-install honey-badger-update honey-badger-info
# Zsh completion for Honey Badger OS
# Place in $fpath or source directly

_install_sh() {
    _arguments \
        '--help[Show help message]' \
        '--dry-run[Simulate without making changes]' \
        '--non-interactive[Skip all prompts]' \
        '--no-color[Disable colored output]' \
        '--verbose[Show debug output]' \
        '--quiet[Suppress informational messages]' \
        '--skip-docker[Skip Docker setup]' \
        '--skip-python[Skip Python dev setup]' \
        '--skip-node[Skip Node.js dev setup]' \
        '--skip-nano[Skip nano configuration]' \
        '--skip-theme[Skip theme and wallpaper]' \
        '--no-theme[Skip theme and wallpaper]'
}

_honey_badger_install() {
    _arguments \
        '--help[Show help message]' \
        '*:package:_honey_badger_packages'
}

_honey_badger_packages() {
    if (( $+commands[apt-cache] )); then
        local -a pkgs
        pkgs=(${(f)"$(apt-cache --no-generate pkgnames "${words[CURRENT]}" 2>/dev/null | head -50)"})
        _describe 'package' pkgs
    elif (( $+commands[pacman] )); then
        local -a pkgs
        pkgs=(${(f)"$(pacman -Ssq "^${words[CURRENT]}" 2>/dev/null | head -50)"})
        _describe 'package' pkgs
    fi
}

_honey_badger_simple() {
    _arguments '--help[Show help message]'
}

compdef _install_sh install.sh
compdef _honey_badger_install honey-badger-install
compdef _honey_badger_simple honey-badger-update
compdef _honey_badger_simple honey-badger-info
