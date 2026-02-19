#!/usr/bin/env bash

set -e

SCRIPT_DIR=$(dirname "$(realpath "$0")")
source "$SCRIPT_DIR/../bin/functions.sh"

header "DNS Setup (dnsmasq)"

# --- Install dnsmasq ---
if ! brew list dnsmasq &> /dev/null; then
    if confirm "dnsmasq is not installed. Install it?"; then
        brew_install_if_missing dnsmasq
    else
        info "Skipping dnsmasq installation. Exiting."
        exit 0
    fi
else
    success "dnsmasq is already installed"
fi

# --- Configure dnsmasq ---
DNSMASQ_CONF="$(brew --prefix)/etc/dnsmasq.conf"
ENTRY="address=/localhost/127.0.0.1"

if grep -qF "$ENTRY" "$DNSMASQ_CONF" 2>/dev/null; then
    success "dnsmasq already configured for .localhost domains"
else
    info "Adding .localhost DNS entry to $DNSMASQ_CONF"
    echo "$ENTRY" >> "$DNSMASQ_CONF"
    success "dnsmasq configuration updated"
fi

# --- Start dnsmasq service ---
if sudo brew services list | grep -q "dnsmasq.*started"; then
    success "dnsmasq service is already running"
else
    info "Starting dnsmasq service..."
    sudo brew services start dnsmasq
    success "dnsmasq service started"
fi

# --- Configure macOS resolver ---
RESOLVER_DIR="/etc/resolver"
RESOLVER_FILE="$RESOLVER_DIR/localhost"

if [[ -f "$RESOLVER_FILE" ]] && grep -qF "nameserver 127.0.0.1" "$RESOLVER_FILE"; then
    success "macOS resolver already configured for .localhost"
else
    info "Configuring macOS to use dnsmasq for .localhost domains"
    sudo mkdir -p "$RESOLVER_DIR"
    echo "nameserver 127.0.0.1" | sudo tee "$RESOLVER_FILE" > /dev/null
    success "macOS resolver configured"
fi

info "You can verify with: dig test.localhost @127.0.0.1"
