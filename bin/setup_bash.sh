#!/usr/bin/env bash
source $(dirname "$0")/functions.sh

link_file "$PROJECT_DIR/bash/.bash_aliases" "$HOME/.bash_aliases"
link_file "$PROJECT_DIR/bash/.profile" "$HOME/.profile"
link_file "$PROJECT_DIR/bash/ide.sh" "/usr/local/bin/ide"
link_file "$PROJECT_DIR/bash/ide_completion.sh" "/usr/share/bash-completion/completions/ide"

source "$HOME/.profile"

if ! command_exists "atuin"; then
    bash <(curl https://raw.githubusercontent.com/atuinsh/atuin/main/install.sh)
fi

if ! command_exists "htmlq"; then
    cargo install htmlq
fi

if ! command_exists "jless"; then
    cargo install jless
fi

link_file "$PROJECT_DIR/atuin" "$HOME/.config/atuin"
