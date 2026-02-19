#!/usr/bin/env bash

set -e

PROJECTS_DIR=$HOME/projects
PROJECT="${1:-.}"

if [ "$PROJECT" == "new" ]; then
    echo "[INFO] Creating a new project."
    PROJECT_NAME="${2}"

    if [ -z "$PROJECT_NAME" ]; then
        read -p "Enter the new project name: " PROJECT_NAME
    fi

    cd $PROJECTS_DIR

    PROJECT_DIR="$PROJECTS_DIR/$PROJECT_NAME"

    # show select for templates
    echo "Select a template for your new project:"
    select TEMPLATE in "Tanstack start" "Empty"; do
        case $TEMPLATE in
            "Tanstack start")
                echo "[INFO] Creating a new Tanstack project in $PROJECT_DIR"
                npx @tanstack/cli create $PROJECT_NAME
                cd "$PROJECT_DIR"

                cat <<EOF > "$PROJECT_DIR/.env"
DOCKER_COMPOSE_PORT=3000
EOF

                cat <<EOF > "$PROJECT_DIR/docker-compose.yml"
services:
  app:
    image: riotbyte/node:24
    command: npm run dev -- --host 0.0.0.0
    volumes:
      - .:/home/node/application
    ports:
      - "\$DOCKER_COMPOSE_PORT:3000"
EOF
                ;;
            "Empty")
                echo "[INFO] Creating an empty project in $PROJECT_DIR"
                mkdir -p "$PROJECT_DIR"
                ;;
            *)
                echo "[ERROR] Invalid template selected."
                exit 1
                ;;
        esac
        break
    done

    echo "[INFO] New project created at $PROJECT_DIR"
    ide "$PROJECT_NAME"

    exit 0
fi

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
    if [ -n "$TMUX" ]; then
        tmux switch-client -t "$SESSION"
    else
        tmux a -t "$SESSION"
    fi
    exit 0
fi

tmux new -d -s "$SESSION" -c "$PROJECT_DIR"
tmux send-keys -t "$SESSION" "v ." ENTER
if [ -n "$TMUX" ]; then
    tmux switch-client -t "$SESSION"
else
    tmux attach -t "$SESSION"
fi

