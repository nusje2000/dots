set -e

source $(dirname "$0")/functions.sh

install_if_missing "caca-utils"
install_if_missing "ripgrep"

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
