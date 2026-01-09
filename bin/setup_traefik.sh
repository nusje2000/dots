#!/usr/bin/env bash

set -e
source $(dirname "$0")/functions.sh

mkdir -p "$HOME/.config/traefik"

link_file "$PROJECT_DIR/traefik" "$HOME/.config/traefik"
link_file "$PROJECT_DIR/traefik/start_traefik.sh" "/usr/local/bin/start_traefik"
link_file "$PROJECT_DIR/traefik/stop_traefik.sh" "/usr/local/bin/stop_traefik"
