#!/usr/bin/env bash

set -e

function loading() {
    printf "\e[46m\e[30m  \e[0m\e[36m\e[0m   %b\n" "$1"
}

function success() {
    printf "\e[42m\e[30m  \e[0m\e[32m\e[0m   %b\n" "$1"
}


loading "Stopping Traefik..."
(cd "$HOME/.config/traefik" && docker-compose stop)
success "Traefik stopped"
