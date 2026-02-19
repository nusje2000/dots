#!/usr/bin/env bash

if [[ -z "$1" ]]; then
    echo "Usage: preview.sh <file>"
    exit 1
fi

TARGET="$1"

if [[ ! -e "$TARGET" ]]; then
    echo "Error: '$TARGET' does not exist"
    exit 1
fi

if [[ "$(uname)" != "Darwin" ]]; then
    echo "Error: preview.sh is only supported on macOS"
    exit 1
fi

if [[ -d "$TARGET" ]]; then
    open "$TARGET"
else
    open -a Preview "$TARGET"
fi
