#!/usr/bin/env bash
source $(dirname "$0")/functions.sh

if is_osx; then
    info "OSX is not supported in ${BASH_SOURCE[0]}"
    return 0;
fi

if ! is_wsl; then
    debug "Skipping win32yank installation for non-wsl environment"
elif [ ! -f /usr/local/bin/win32yank.exe ]; then
    loading "Installing win32yank..."
    curl -sLo/tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/download/v0.1.1/win32yank-x64.zip
    unzip -p /tmp/win32yank.zip win32yank.exe > /tmp/win32yank.exe
    chmod +x /tmp/win32yank.exe
    sudo mv /tmp/win32yank.exe /usr/local/bin/
    success "win32yank has been installed"
else
    success "win32yank is already installed"
fi


if ! command_exists nvim; then
    loading "cloning nvim repository..."
    git clone https://github.com/neovim/neovim.git ../neovim
    loading "building nvim..."
    (cd ../neovim && git checkout stable && make CMAKE_BUILD_TYPE=RelWithDebInfo && sudo make install)
    success "nvim has been installed"
else
    success "nvim is already installed"
fi

if [ ! -d ~/.local/share/nvim/site/pack/packer/start/packer.nvim ]; then
    loading "Installing packer..."
    git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim || exit 1
    success "packer has been installed"
else
    success "packer is already installed"
fi

link_file "$PROJECT_DIR/nvim" "$HOME/.config/nvim"
link_file "$PROJECT_DIR/phpactor" "$HOME/.config/phpactor"
