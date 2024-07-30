#!/usr/bin/env bash
source $(dirname "$0")/functions.sh

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
