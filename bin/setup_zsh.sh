#!/usr/bin/env bash

set -e

source $(dirname "$0")/functions.sh

if ! is_osx; then
    info "Zsh should only be used on OSX systems, not linux."
    return
fi

if [ ! -f "$PROJECT_DIR/shell/.secrets" ]; then
    cp "$PROJECT_DIR/shell/.secrets.dist" "$PROJECT_DIR/shell/.secrets"
fi

link_file "$PROJECT_DIR/shell/.aliases" "$HOME/.zsh_aliases"
link_file "$PROJECT_DIR/shell/.secrets" "$HOME/.secrets"
link_file "$PROJECT_DIR/shell/.zshrc" "$HOME/.zshrc"
link_file "$PROJECT_DIR/shell/ide.sh" "/usr/local/bin/ide"
link_file "$PROJECT_DIR/shell/preview.sh" "/usr/local/bin/preview"

mkdir -p "$HOME/.oh-my-zsh/custom/completions"
link_file "$PROJECT_DIR/shell/ide_completion.zsh" "$HOME/.oh-my-zsh/custom/completions/ide_completion.zsh"

# TODO: install HTMLQ, JLESS, BUMPVERSION

if ! command_exists "atuin"; then
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
fi

link_file "$PROJECT_DIR/atuin" "$HOME/.config/atuin"
