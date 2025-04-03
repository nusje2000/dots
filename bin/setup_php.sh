#!/usr/bin/env bash
source $(dirname "$0")/functions.sh

if ! grep  -r ondrej/php /etc/apt &> /dev/null; then
    loading "Installing php repository..."

    sudo add-apt-repository ppa:ondrej/php -y
    sudo apt update

    success "Installed php repository"
else
    success "php repository is already installed"
fi

install_if_missing "php8.3"
install_if_missing "php8.3-cli"
install_if_missing "php8.3-bz2"
install_if_missing "php8.3-curl"
install_if_missing "php8.3-mbstring"
install_if_missing "php8.3-intl"
install_if_missing "php8.3-dom"
install_if_missing "php8.3-imap"
install_if_missing "php8.3-zip"
install_if_missing "php8.3-mysqli"

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

PHPCS="$PROJECT_DIR/phpactor/phpcs"
if [ ! -e "$PHPCS" ]; then
    loading "Installing phpcs..."
    wget https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar -O "$PHPCS"
    chmod a+x "$PHPCS"
    success "phpcs has been installed"
fi

PHPCBF="$PROJECT_DIR/phpactor/phpcbf"
if [ ! -e "$PHPCBF" ]; then
    loading "Installing phpcbf..."
    wget https://squizlabs.github.io/PHP_CodeSniffer/phpcbf.phar -O "$PHPCBF"
    chmod a+x "$PHPCBF"
    success "phpcbf has been installed"
fi

PHPSTAN="$PROJECT_DIR/phpactor/phpstan"
if [ ! -e "$PHPSTAN" ]; then
    loading "Installing phpstan..."
    wget https://github.com/phpstan/phpstan/releases/latest/download/phpstan.phar -O "$PHPSTAN"
    chmod a+x "$PHPSTAN"
    success "phpstan has been installed"
fi

STUB_FILES="$PROJECT_DIR/phpactor/phpstorm-stubs"
if [ ! -d $STUB_FILES ]; then
    loading "Cloning jetbrains/phpstorm-stubs"
    git clone https://github.com/JetBrains/phpstorm-stubs.git $STUB_FILES
    (cd $STUB_FILES && git checkout "v2024.2")
    success "Cloned jetbrains/phpstorm-stubs"
fi

PHP_DEBUGGER="$PROJECT_DIR/phpactor/php-debugger"
if [ ! -d $PHP_DEBUGGER ]; then
    loading "Cloning xdebug/vscode-php-debug"
    git clone https://github.com/xdebug/vscode-php-debug.git $PHP_DEBUGGER
    (cd $PHP_DEBUGGER && npm install && npm run build)
    success "Cloned xdebug/vscode-php-debug"
fi

link_file "$PROJECT_DIR/phpactor" "$HOME/.config/phpactor"
