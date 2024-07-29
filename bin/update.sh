#!/usr/bin/env bash

source "$(dirname $0)/functions.sh"

logo

if is_wsl; then
    debug "Environment is using WSL"
else
    debug "Environment is not using WSL"
fi

header "Install apt packages"

install_if_missing "software-properties-common"
install_if_missing "autoconf"
install_if_missing "libfuse2"
install_if_missing "automake"
install_if_missing "build-essential"
install_if_missing "ca-certificates"
install_if_missing "caca-utils"
install_if_missing "cmake"
install_if_missing "coreutils"
install_if_missing "curl"
install_if_missing "doxygen"
install_if_missing "g++"
install_if_missing "g++-11"
install_if_missing "gcc-11"
install_if_missing "gettext"
install_if_missing "git"
install_if_missing "httpie"
install_if_missing "libfontconfig1-dev"
install_if_missing "libfreetype6-dev"
install_if_missing "libtool"
install_if_missing "libtool-bin"
install_if_missing "libxcb-xfixes0-dev"
install_if_missing "libxkbcommon-dev"
install_if_missing "lowdown"
install_if_missing "ninja-build"
install_if_missing "pkg-config"
install_if_missing "python3"
install_if_missing "ripgrep"
install_if_missing "sed"
install_if_missing "tmux"
install_if_missing "unzip"
install_if_missing "xclip"
install_if_missing "clangd"

header "Install frameworks & languages"

source $(dirname "$0")/setup_git.sh
source $(dirname "$0")/setup_rust.sh
source $(dirname "$0")/setup_bash.sh
source $(dirname "$0")/setup_ngrok.sh
source $(dirname "$0")/setup_php.sh
source $(dirname "$0")/setup_node.sh
source $(dirname "$0")/setup_arduino.sh

header "Install applications"

source $(dirname "$0")/setup_tmux.sh

if ! is_wsl; then
    install_if_missing "kcachegrind"
    $BIN_DIR/setup_docker.sh
    $BIN_DIR/setup_alacritty.sh
fi

$BIN_DIR/setup_btop.sh
$BIN_DIR/setup_nvim.sh

header "Setup environment"

loading "Running PackerSync..."
nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync' &> /dev/null
success "Packer sync was successfull"

debug "Reloading bash profile"
source ~/.profile
