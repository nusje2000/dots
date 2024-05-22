#!/usr/bin/env bash
source $(dirname "$0")/functions.sh

if ! command_exists btop; then
    loading "Installing btop..."

    cd ..
    git clone https://github.com/aristocratos/btop.git
    cd btop
    make
    sudo make install

    success "btop has been installed"
else
    success "btop has already been installed"
fi
