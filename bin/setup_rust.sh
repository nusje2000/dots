#!/usr/bin/env bash
source $(dirname "$0")/functions.sh

if ! command_exists rustup; then
    loading "installing rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    success "rustup has been installed"
else
    success "rustup is already installed"
fi
