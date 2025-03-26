#!/usr/bin/env bash

PROJECTS_DIR=$HOME/projects
PROJECT="${1:-.}"

if [[ "$PROJECT" == git@* ]]; then
    read -p "$PROJECT appears to be a git project, would you like to clone this project? [Y/n] " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Nn]$ ]]; then
        exit 1
    fi

    cd $PROJECTS_DIR
    git clone $PROJECT
    PROJECT="$(echo "$PROJECT" | sed -e 's/.*\///' -e 's/\.git$//')"
fi

PROJECT_DIR=$(realpath "$PROJECTS_DIR/$PROJECT")

echo "[INFO] Loading project $PROJECT from path $PROJECT_DIR"

if [ ! -d $PROJECT_DIR ]; then
    echo "[ERROR] No project found named $PROJECT in path $PROJECT_DIR."
    exit 1
fi

SESSION=$(basename "$PROJECT_DIR")
SESSION=${SESSION//-/_}

echo "[INFO] Using session name \"$SESSION\""

if tmux has-session -t $SESSION 2>/dev/null; then
    echo "[INFO] Session already exists, attaching."
    tmux a -t "$SESSION"
    exit 0
fi

tmux new -d -s "$SESSION" -c "$PROJECT_DIR"
tmux send-keys -t "$SESSION" "v ." ENTER
tmux attach -t "$SESSION"

