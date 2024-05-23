#!/usr/bin/env bash
set -e

RED="\e[31m"
GREEN="\e[32m"
PURPLE="\e[35m"
CYAN="\e[36m"
BLACK="\e[m"
BG_GREEN="\e[42m"
BG_PURPLE="\e[45m"
BG_CYAN="\e[46m"
BG_RED="\e[41m"
ENDCOLOR="\e[0m"
BAR_END="\ue0c0"

PROJECT_DIR=$(realpath $(dirname $(dirname "$0")))
BIN_DIR="$PROJECT_DIR/bin"

DISABLE_INTERACTION=false
if [[ $* == *-y* ]]; then
    DISABLE_INTERACTION=true
fi

VERBOSE=false
if [[ $* == *-v* ]]; then
    VERBOSE=true
fi


function logo() {
    LOGO=$(
        cat "$(dirname "$0")/header.txt" |
            sed "s/█\+/\\\\e[35m\0\\\\e[0m/g" |
            sed "s/╱\+/\\\\e[94m\0\\\\e[0m/g"
    )
    printf "$LOGO\n"
}

function loading() {
    printf "${BG_CYAN} \uea9a ${ENDCOLOR}${CYAN}${BAR_END}${ENDCOLOR}   $1\n"
}

function success() {
    printf "${BG_GREEN} \uf14a ${ENDCOLOR}${GREEN}${BAR_END}${ENDCOLOR}   $1\n"
}

function debug() {
    printf "${BG_PURPLE} \uf400 ${ENDCOLOR}${PURPLE}${BAR_END}${ENDCOLOR}   $1\n"
}

function header() {
    printf "\n${BG_RED}   ${ENDCOLOR}${RED}${BAR_END}${ENDCOLOR}\n"
    printf "${BG_RED}   ${ENDCOLOR}${RED}${BAR_END}${ENDCOLOR}   $1\n"
    printf "${BG_RED}   ${ENDCOLOR}${RED}${BAR_END}${ENDCOLOR}\n\n"
}

function is_wsl() {
    if [[ $(grep -i Microsoft /proc/version) ]]; then
        return 0
    fi

    return 1
}

function install_if_missing() {
    if ! dpkg -s "$1" &> /dev/null;
    then
        loading "Installing $1..."
        
        if [ $VERBOSE = true ]; then
            sudo apt-get install -y "$1"
        else
            sudo apt-get install -y "$1" &> /dev/null
        fi

        success "$1 has been installed"
    else
        success "$1 is already installed"
    fi
}

function confirm() {
    if [ $DISABLE_INTERACTION = true ]; then
        return 0
    fi

    read -p "$1 [y/N] " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    fi

   return 1 
}

function command_exists() {
    if command -v $1 &> /dev/null; then
        return 0
    fi

    return 1
}

function link_file() {
    SOURCE=$(realpath $1)
    TARGET=$(realpath $2)

    if [[ $(readlink -f "$TARGET") == "$SOURCE" ]]; then
        debug "$2 already points to $SOURCE"

        return 0
    fi

    loading "Linking $TARGET to $SOURCE"

    if [[ -e $TARGET ]]; then
        if ! confirm "$TARGET already exists, remove it?"; then
            return 1
        fi

        rm -rf $TARGET
    fi

    sudo ln -s $SOURCE $TARGET

    success "Created link from $TARGET to $SOURCE"
}
