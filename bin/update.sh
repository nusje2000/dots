set -e

source $(dirname "$0")/functions.sh

install_if_missing "ninja-build"
install_if_missing "gettext"
install_if_missing "libtool"
install_if_missing "libtool-bin"
install_if_missing "autoconf"
install_if_missing "automake"
install_if_missing "cmake"
install_if_missing "g++"
install_if_missing "pkg-config"
install_if_missing "unzip"
install_if_missing "curl"
install_if_missing "doxygen"
install_if_missing "tmux"
install_if_missing "caca-utils"
install_if_missing "ripgrep"
install_if_missing "httpie"

if ! command -v nvim &> /dev/null; then
    loading "cloning nvim repository..."
    git clone https://github.com/neovim/neovim.git
    loading "building nvim..."
    (cd neovim && make CMAKE_BUILD_TYPE=RelWithDebInfo && sudo make install)
    success "nvim has been installed"
else
    success "nvim is already installed"
fi

if [ ! -d !/.tmux/plugins/tpm ]; then
    loading "Installing tpm..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    success "tpm has been installed"
else
    success "tpm is already installed"
fi

if [ ! -d ~/.local/share/nvim/site/pack/packer/start/packer.nvim ]; then
    loading "Installing Packer..."
    git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim || exit 1
    success "packer has been installed"
else
    success "packer is already installed"
fi

if [ ! -f /usr/local/bin/win32yank.exe ]; then
    loading "Installing win32yank..."
    curl -sLo/tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/download/v0.1.1/win32yank-x64.zip
    unzip -p /tmp/win32yank.zip win32yank.exe > /tmp/win32yank.exe
    chmod +x /tmp/win32yank.exe
    sudo mv /tmp/win32yank.exe /usr/local/bin/
    success "win32yank has been installed"
else
    success "win32yank is already installed"
fi

if ! command -v node &> /dev/null
then
    loading "Installing node..."
    curl -sL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
    source ~/.bashrc
    success "node has been installed"
else
    success "node is already installed"
fi

if [ ! -d ~/.npm-global ]; then
    loading "setting up npm..."
    mkdir ~/.npm-global
    npm config set prefix '~/.npm-global'
    success "npm has been setup"
fi

if ! command -v n &> /dev/null
then
    loading "Installing n..."
    npm install -g n
    sudo mkdir -p /usr/local/n
    sudo chown -R $(whoami) /usr/local/n
    sudo mkdir -p /usr/local/bin /usr/local/lib /usr/local/include /usr/local/share
    sudo chown -R $(whoami) /usr/local/bin /usr/local/lib /usr/local/include /usr/local/share
    success "n has been installed"
else
    success "n is already installed"
fi

source $(dirname "$0")/setup_links.sh

loading "Running PackerSync..."
nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync' &> /dev/null
success "Packer sync was successfull"
