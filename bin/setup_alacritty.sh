set -e

source $(dirname "$0")/functions.sh

if ! command_exists alacritty; then
    loading "Installing alacritty..."

    cd ..
    git clone https://github.com/alacritty/alacritty.git;
    cd alacritty;

    rustup override set stable
    rustup update stable

    cargo build --release

    sudo cp target/release/alacritty /usr/local/bin
    sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
    sudo desktop-file-install extra/linux/Alacritty.desktop
    sudo update-desktop-database

    success "alacritty has been installed"
else
    success "alacritty has already been installed"
fi

if [ ! -d "$PROJECT_DIR/alacritty/themes" ]; then
    loading "Cloning alacritty-themes..."
    git clone https://github.com/alacritty/alacritty-theme "$PROJECT_DIR/alacritty/themes"
    success "alacritty-themes has been cloned"
fi
