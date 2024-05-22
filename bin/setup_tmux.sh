#!/usr/bin/env bash
source $(dirname "$0")/functions.sh

if [ ! -d ~/.tmux/plugins/tpm ]; then
    loading "Installing tpm..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    success "tpm has been installed"
else
    success "tpm is already installed"
fi

link_file "$PROJECT_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
