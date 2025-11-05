#!/usr/bin/env bash
source $(dirname "$0")/functions.sh

if is_osx; then
    debug "OXS detected, skipping alacritty install"
elif ! command_exists alacritty; then
    loading "Installing alacritty..."

    cd ..
    git clone https://github.com/alacritty/alacritty.git;
    cd alacritty;

    rustup override set stable
    rustup update stable

    cargo build --release

    sudo cp target/release/alacritty /usr/local/bin
    sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg

    if command_exists desktop-file-install; then
        sudo desktop-file-install extra/linux/Alacritty.desktop
        sudo update-desktop-database
    fi

    success "alacritty has been installed"
else
    success "alacritty has already been installed"
fi

if [ ! -d "$PROJECT_DIR/alacritty/themes" ]; then
    loading "Cloning alacritty-themes..."
    git clone https://github.com/alacritty/alacritty-theme "$PROJECT_DIR/alacritty/themes"
    success "alacritty-themes has been cloned"
fi

link_file "$PROJECT_DIR/alacritty" "$HOME/.config/alacritty"
