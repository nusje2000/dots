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

# Bun-powered tmux tools (session switcher + PR/issue dashboard). The whole
# directory is linked so node_modules travels with it.
if command -v bun >/dev/null 2>&1; then
    loading "Installing tmux tool dependencies..."
    (cd "$PROJECT_DIR/tools" && bun install)
    success "tmux tool dependencies installed"
else
    info "bun is required for the tmux tools (session switcher, dashboard)"
fi
link_file "$PROJECT_DIR/tools" "$HOME/.tmux/tools"
