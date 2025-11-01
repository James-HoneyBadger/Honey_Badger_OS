#!/bin/bash
# Honey Badger OS Editor Configuration Hook
# Sets nano as the default system editor

# Configure alternatives system to use nano as default editor
update-alternatives --install /usr/bin/editor editor /usr/bin/nano 100
update-alternatives --set editor /usr/bin/nano

# Set up git to use nano by default
git config --system core.editor nano

# Create environment configuration for all users
cat >> /etc/bash.bashrc << 'EOF'

# Honey Badger OS default editor configuration
export EDITOR="nano"
export VISUAL="nano"
export GIT_EDITOR="nano"
EOF

# Configure for zsh if installed
if [ -f /etc/zsh/zshrc ]; then
    cat >> /etc/zsh/zshrc << 'EOF'

# Honey Badger OS default editor configuration
export EDITOR="nano"
export VISUAL="nano"
export GIT_EDITOR="nano"
EOF
fi

# Set nano as default for systemd
systemctl --global set-environment EDITOR=nano
systemctl --global set-environment VISUAL=nano

exit 0