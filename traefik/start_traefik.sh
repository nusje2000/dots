#!/usr/bin/env bash

set -e

SCRIPT_DIR=$(dirname "$(realpath "$0")")
source "$SCRIPT_DIR/../bin/functions.sh"

# SCRIPT_DIR=$(dirname "$(realpath "$0")")
# $SCRIPT_DIR/setup_dns.sh

loading "Starting Traefik..."
(cd "$HOME/.config/traefik" && docker-compose up -d)
success "Traefik started"
