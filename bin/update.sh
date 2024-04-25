set -e

BIN_DIR=$(dirname "$0")
source $BIN_DIR/functions.sh

logo

if is_wsl; then
    debug "Environment is using WSL"
else
    debug "Environment is not using WSL"
fi

header "Install apt packages"

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

header "Install frameworks & languages"

if ! command_exists rustup; then
    loading "installing rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh 
    success "rustup has been installed"
else
    success "rustup is already installed"
fi

if ! command_exists php; then
    loading "Installing php..."

    sudo add-apt-repository ppa:ondrej/php -y
    sudo apt update

    install_if_missing "php8.3"
    install_if_missing "php8.3-cli"
    install_if_missing "php8.3-bz2"
    install_if_missing "php8.3-curl"
    install_if_missing "php8.3-mbstring"
    install_if_missing "php8.3-intl"

    success "php has been installed"
else
    success "php is already installed"
fi

if ! command_exists composer; then
    loading "Installing composer..."

    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php -r "if (hash_file('sha384', 'composer-setup.php') === 'dac665fdc30fdd8ec78b38b9800061b4150413ff2e3b6f88543c636f7cd84f6db9189d43a81e5503cda447da73c7e5b6') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
    php composer-setup.php
    php -r "unlink('composer-setup.php');"
    sudo mv composer.phar /usr/local/bin/composer

    success "composer has been installed"
else
    success "composer is already installed"
fi


if ! command_exists node
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

if ! command_exists n
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

if ! command_exists ngrok
then
    loading "installing ngrok"

    curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
    echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
    sudo apt update
    sudo apt install ngrok

    success "ngrok has been installed"
else
    success "ngrok is already installed"
fi

header "Install applications"

if [ ! -d ~/.tmux/plugins/tpm ]; then
    loading "Installing tpm..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    success "tpm has been installed"
else
    success "tpm is already installed"
fi

if ! is_wsl; then
    install_if_missing "kcachegrind"
    $BIN_DIR/setup_docker.sh
    $BIN_DIR/setup_alacritty.sh
fi

$BIN_DIR/setup_btop.sh
$BIN_DIR/setup_nvim.sh

header "Setup environment"

source $(dirname "$0")/setup_links.sh

loading "Running PackerSync..."
nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync' &> /dev/null
success "Packer sync was successfull"

debug "Reloading bash profile"
source ~/.profile
