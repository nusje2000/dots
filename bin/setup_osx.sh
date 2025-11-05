#!/usr/bin/env bash
source $(dirname "$0")/functions.sh

set -e

brew_install_if_missing wget
brew_install_if_missing ripgrep
brew_install_if_missing python
brew_install_if_missing ansible
brew_install_if_missing socat
brew_install_if_missing jq
brew_install_if_missing jless

brew_install_cask_if_missing raycast

