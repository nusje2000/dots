#!/usr/bin/env bash
source $(dirname "$0")/functions.sh

if is_osx; then
    info "Bash should only be used on linux systems, not OSX."
    return
fi

link_file "$PROJECT_DIR/shell/.aliasses" "$HOME/.bash_aliases"
link_file "$PROJECT_DIR/shell/ide.sh" "/usr/local/bin/ide"
link_file "$PROJECT_DIR/shell/.profile" "$HOME/.profile"
link_file "$PROJECT_DIR/shell/ide_completion.sh" "/usr/share/bash-completion/completions/ide"

if ! command_exists "htmlq"; then
    cargo install htmlq
fi

if ! command_exists "jless"; then
    cargo install jless
fi

if ! command_exists "bumpversion"; then
    pip install --upgrade bumpversion
fi

source "$HOME/.profile"

if ! command_exists "atuin"; then
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
fi

link_file "$PROJECT_DIR/atuin" "$HOME/.config/atuin"
