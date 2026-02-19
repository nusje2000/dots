#!/usr/bin/env bash

set -e

SCRIPT_DIR=$(dirname "$(realpath "$0")")
source "$SCRIPT_DIR/../bin/functions.sh"

header "DNS Teardown (dnsmasq)"

# --- Remove macOS resolver ---
RESOLVER_FILE="/etc/resolver/localhost"

if [[ -f "$RESOLVER_FILE" ]]; then
    if confirm "Remove macOS resolver file ($RESOLVER_FILE)?"; then
        sudo rm "$RESOLVER_FILE"
        success "Removed $RESOLVER_FILE"
    fi
else
    success "macOS resolver file already absent"
fi

# --- Stop dnsmasq service ---
if sudo brew services list | grep -q "dnsmasq.*started"; then
    if confirm "Stop dnsmasq service?"; then
        sudo brew services stop dnsmasq
        success "dnsmasq service stopped"
    fi
else
    success "dnsmasq service is not running"
fi

# --- Remove dnsmasq config entry ---
DNSMASQ_CONF="$(brew --prefix)/etc/dnsmasq.conf"
ENTRY="address=/localhost/127.0.0.1"

if grep -qF "$ENTRY" "$DNSMASQ_CONF" 2>/dev/null; then
    if confirm "Remove .localhost DNS entry from $DNSMASQ_CONF?"; then
        sed -i '' "\|^${ENTRY}$|d" "$DNSMASQ_CONF"
        success "Removed .localhost entry from dnsmasq config"
    fi
else
    success "dnsmasq config entry already absent"
fi

success "DNS teardown complete"
