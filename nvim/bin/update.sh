set -e

function install_if_missing() {
    if ! dpkg -s "$1" &> /dev/null;
    then
        printf "\uea9a Installing $1...\n"
        sudo apt-get install "$1"
        printf "\uf14a $1 has been installed\n"
    else
        printf "\uf14a $1 is already installed\n"
    fi
}

if [ ! -d ~/.local/share/nvim/site/pack/packer/start/packer.nvim ]; then
    printf "\uea9a Installing Packer...\n"
    git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim || exit 1
    printf "\uf14a packer has been installed\n"
else
    printf "\uf14a packer is already installed\n"
fi

if [ ! -f /usr/local/bin/win32yank.exe ]; then
    printf "\uea9a Installing win32yank...\n"
    curl -sLo/tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/download/v0.1.1/win32yank-x64.zip
    unzip -p /tmp/win32yank.zip win32yank.exe > /tmp/win32yank.exe
    chmod +x /tmp/win32yank.exe
    sudo mv /tmp/win32yank.exe /usr/local/bin/
    printf "\uf14a win32yank has been installed\n"
else
    printf "\uf14a win32yank is already installed\n"
fi

install_if_missing "caca-utils"
install_if_missing "ripgrep"

printf "\uea9a Running PackerSync...\n"
nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
printf "\uf14a Packer sync was successfull\n"

