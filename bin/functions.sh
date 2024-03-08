function loading() {
    printf "\uea9a $1\n"
}

function success() {
    printf "\uf14a $1\n"
}

function install_if_missing() {
    if ! dpkg -s "$1" &> /dev/null;
    then
        loading "Installing $1..."
        sudo apt-get install "$1"
        success "$1 has been installed"
    else
        success "$1 is already installed"
    fi
}

function confirm() {
    read -p "$1 [y/N] " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    fi

   return 1 
}

function link_file() {
    SOURCE=$(realpath $1)
    TARGET=$(realpath $2)

    if [[ $(readlink -f "$TARGET") == "$SOURCE" ]]; then
        success "$TARGET already points to $SOURCE"

        return 0
    fi

    loading "Linking $TARGET to $SOURCE"

    if [[ -e $TARGET ]]; then
        if ! confirm "$TARGET already exists, remove it?"; then
            return 1
        fi

        rm -rf $TARGET
    fi

    ln -s $SOURCE $TARGET

    success "Created link from $TARGET to $SOURCE"
}
