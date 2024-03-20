set -e
source $(dirname "$0")/functions.sh
PROJECT_ROOT=$(dirname $(dirname "$0"))

link_file "$PROJECT_ROOT/bash/.bash_aliases" "$HOME/.bash_aliases"
link_file "$PROJECT_ROOT/bash/.profile" "$HOME/.profile"
link_file "$PROJECT_ROOT/nvim" "$HOME/.config/nvim"
link_file "$PROJECT_ROOT/git/.gitconfig" "$HOME/.gitconfig"
