#!/usr/bin/env bash

source $(dirname "$0")/functions.sh

if ! command_exists claude; then
    loading "Installing claude..."
    curl -fsSL https://claude.ai/install.sh | bash
    success "claude has been installed"
else
    success "claude has already been installed"
fi


if is_osx; then
    brew_install_if_missing terminal-notifier

    # check if claude directory exists
    if [ ! -d "$HOME/.claude/ccnotify" ]; then
        loading "Setting up claude notifications..."

        mkdir -p "$PROJECT_DIR/claude/ccnotify"
        mkdir -p "$HOME/.claude/ccnotify"

        git clone https://github.com/dazuiba/CCNotify.git "$PROJECT_DIR/claude/ccnotify"
        (cd "$PROJECT_DIR/claude/ccnotify" && git reset --hard add20f8f669de30a48a08fe4b1b19e42e77de5f2)
        yes | cp "$PROJECT_DIR/claude/ccnotify/ccnotify.py" "$HOME/.claude/ccnotify/ccnotify.py"

        success "claude notifications have been setup"
    else
        success "claude notifications have already been setup"
    fi
fi

link_file "$PROJECT_DIR/claude/settings.json" "$HOME/.claude/settings.json"
