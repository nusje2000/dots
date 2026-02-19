#!/usr/bin/env bash
source $(dirname "$0")/functions.sh

if ! command_exists node || ! command_exists nvm;
then
    loading "Installing node..."

    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    \. "$HOME/.nvm/nvm.sh"
    nvm install 24

    success "node has been installed"
else
    success "node is already installed"
fi

