#!/usr/bin/env bash

source $(dirname "$0")/functions.sh

header "Fonts"

FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

for font in "$PROJECT_DIR/fonts/"*.ttf; do
    FONT_NAME=$(basename "$font")
    if [ -f "$FONT_DIR/$FONT_NAME" ]; then
        success "$FONT_NAME is already installed"
    else
        cp "$font" "$FONT_DIR/$FONT_NAME"
        success "Installed $FONT_NAME"
    fi
done

loading "Rebuilding font cache..."
fc-cache -f
success "Font cache rebuilt"

info "Installed fonts:"
fc-list | grep -i "RobotoMono Nerd" || info "No RobotoMono Nerd Font found in fc-list — check your font files"
