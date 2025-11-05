#!/usr/bin/env bash
source $(dirname "$0")/functions.sh

if is_osx; then
    brew_install_if_missing portaudio

    if ! command_exists spotifyd; then
        loading "Installing spotifyd..."

        TARGET=spotifyd-macos-aarch64-slim
        wget "https://github.com/Spotifyd/spotifyd/releases/download/v0.4.1/$TARGET.tar.gz"

        tar xzf "$TARGET.tar.gz"
        rm "$TARGET.tar.gz"

        chmod +x spotifyd
        sudo chown root:wheel spotifyd
        sudo mv spotifyd /usr/local/bin/spotifyd

        success "spotifyd has been installed"
    else
        success "spotifyd is already installed"
    fi

    if [ ! -f "/Library/LaunchDaemons/spotifyd.plist" ]; then
        loading "Installing spotifyd launch daemon..."

        sudo cp "$PROJECT_DIR/spotify/spotifyd.plist" /Library/LaunchDaemons/spotifyd.plist
        sudo launchctl load /Library/LaunchDaemons/spotifyd.plist

        success "spotifyd launch daemon has been installed"
    else
        success "spotifyd launch daemon is already installed"
    fi

    mkdir -p "$HOME/.config/spotifyd"
    mkdir -p "$HOME/.config/spotify-player"

    link_file "$PROJECT_DIR/spotify/spotifyd.conf" "$HOME/.config/spotifyd/spotifyd.conf"
    link_file "$PROJECT_DIR/spotify/player_app.toml" "$HOME/.config/spotify-player/app.toml"

    brew_install_if_missing spotify_player

    return 0
fi

if [[ ! -e /etc/apt/sources.list.d/spotify.list ]]; then
    loading "Installing up spotify repository..."

    curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
    echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
    sudo apt-get update 

    success "Installed spotify repository"
else
    success "spotify repository is already installed"
fi

install_if_missing spotify-client
