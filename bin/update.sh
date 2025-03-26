#!/usr/bin/env bash

source "$(dirname $0)/functions.sh"

logo

if is_wsl; then
    debug "Environment is using WSL"
else
    debug "Environment is not using WSL"
fi

header "Install apt packages"

install_if_missing "dctrl-tools"
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
install_if_missing "fzf"

header "Install frameworks & languages"

source $BIN_DIR/setup_git.sh
source $BIN_DIR/setup_rust.sh
source $BIN_DIR/setup_bash.sh
source $BIN_DIR/setup_ngrok.sh
source $BIN_DIR/setup_php.sh
source $BIN_DIR/setup_node.sh
source $BIN_DIR/setup_arduino.sh

header "Install applications"

source $(dirname "$0")/setup_tmux.sh

if ! is_wsl; then
    install_if_missing "kcachegrind"
    source $BIN_DIR/setup_1password.sh
    source $BIN_DIR/setup_docker.sh
    source $BIN_DIR/setup_alacritty.sh
    source $BIN_DIR/setup_spotify.sh

    install_if_missing "remmina"
    install_if_missing "remmina-plugin-vnc"
fi

source $BIN_DIR/setup_btop.sh
source $BIN_DIR/setup_nvim.sh

header "Setup environment"

loading "Running PackerSync..."
nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync' &> /dev/null
success "Packer sync was successfull"

debug "Reloading bash profile"
source ~/.profile
