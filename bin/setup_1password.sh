#!/usr/bin/env bash
source $(dirname "$0")/functions.sh

if ! is_osx && ! grep  -r 1password /etc/apt &> /dev/null; then
    loading "Installing 1password repository..."

    sudo curl -sS https://downloads.1password.com/linux/keys/1password.asc | gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
    sudo echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | tee /etc/apt/sources.list.d/1password.list
    sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
    sudo curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
    sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
    sudo curl -sS https://downloads.1password.com/linux/keys/1password.asc | gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg

    sudo apt update

    success "Installed 1password repository"
else
    success "1password repository is already installed"
fi

if ! command_exists "op"; then
    if is_osx; then
        brew install 1password-cli
    else
        install_if_missing "1password-cli"
    fi
fi
