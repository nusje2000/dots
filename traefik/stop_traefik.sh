#!/usr/bin/env bash

set -e

SCRIPT_DIR=$(dirname "$(realpath "$0")")
source "$SCRIPT_DIR/../bin/functions.sh"


loading "Stopping Traefik..."
(cd "$HOME/.config/traefik" && docker-compose stop)
success "Traefik stopped"
