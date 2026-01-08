# Define the zsh completion function
_ide() {
    local cur prev
    cur=${words[-1]}     # Current word being completed
    prev=${words[-2]}    # Previous word in the command line

    if [[ $prev == ide ]]; then
        local curdir
        curdir=$(pwd)                     # Save current directory
        cd "$HOME/projects/" 2>/dev/null || return # Change to projects directory
        compadd -d -- *(/)                # Complete directories
        cd "$curdir"                    # Restore original directory
    fi
}

# Register the _ide function for the ide command
compdef _ide ide

