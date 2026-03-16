#!/bin/sh

# Configure git user from environment variables
git config --global user.name "${GIT_USER_NAME:-Maarten Nusteling}"
git config --global user.email "${GIT_USER_EMAIL:-maarten.nusteling@gmail.com}"

exec /bin/zsh "$@"
