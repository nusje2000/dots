#!/usr/bin/env bash
source $(dirname "$0")/functions.sh

install_if_missing arduino-mk

if ! command_exists 'arduino-cli'; then
    loading "Installing arduino-cli..."
    curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | BINDIR=/usr/local/bin sh
    success "Installed arduino-cli"
else
    success "arduino-cli is already installed"
fi

if [ -f ]; then
    arduino-cli completion bash > arduino-cli.sh
    sudo mv arduino-cli.sh /etc/bash_completion.d
fi

