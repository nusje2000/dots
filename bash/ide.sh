#!/usr/bin/env bash

PROJECT="${1:-.}"
PROJECT_DIR=$(realpath "$HOME/projects/$PROJECT")

echo "[INFO] Loading project $PROJECT from path $PROJECT_DIR"

if [ ! -d $PROJECT_DIR ]; then
    echo "[ERROR] No project found named $PROJECT in path $PROJECT_DIR."
    exit 1
fi

SESSION=$(basename "$PROJECT_DIR")

echo "[INFO] Using session name \"$SESSION\""

if tmux has-session -t $SESSION 2>/dev/null; then
    echo "[INFO] Session already exists, attaching."
    tmux a -t $SESSION
    exit 0
fi

tmux new -s $SESSION -c "$PROJECT_DIR"

