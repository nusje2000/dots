#!/usr/bin/env bash
source $(dirname "$0")/functions.sh

if is_osx; then
    info "OSX is not supported in ${BASH_SOURCE[0]}"
    return 0;
fi

if ! command_exists ngrok
then
    loading "installing ngrok"

    curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
    echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
    sudo apt update
    sudo apt install ngrok

    success "ngrok has been installed"
else
    success "ngrok is already installed"
fi
