#!/usr/bin/env bash
source $(dirname "$0")/functions.sh

if is_osx; then
    info "OSX is not supported in ${BASH_SOURCE[0]}"
    return 0;
fi

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
