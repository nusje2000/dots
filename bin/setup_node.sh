#!/usr/bin/env bash
source $(dirname "$0")/functions.sh

if is_osx; then
    info "OSX is not supported in ${BASH_SOURCE[0]}"
    return 0;
fi

if ! command_exists node
then
    loading "Installing node..."
    curl -sL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
    source ~/.bashrc
    success "node has been installed"
else
    success "node is already installed"
fi

if [ ! -d ~/.npm-global ]; then
    loading "setting up npm..."
    mkdir ~/.npm-global
    npm config set prefix '~/.npm-global'
    success "npm has been setup"
fi

if ! command_exists n
then
    loading "Installing n..."
    npm install -g n
    sudo mkdir -p /usr/local/n
    sudo chown -R $(whoami) /usr/local/n
    sudo mkdir -p /usr/local/bin /usr/local/lib /usr/local/include /usr/local/share
    sudo chown -R $(whoami) /usr/local/bin /usr/local/lib /usr/local/include /usr/local/share
    success "n has been installed"
else
    success "n is already installed"
fi
