#!/usr/bin/env bash

set -e

SCRIPT_DIR=$(dirname "$(realpath "$0")")
source "$SCRIPT_DIR/../bin/functions.sh"

loading "Showing Traefik logs..."
(cd "$HOME/.config/traefik" && docker-compose logs -f)
