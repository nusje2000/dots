#!/bin/sh
set -ex

HOST_UID="${HOST_UID:-1000}"
HOST_GID="${HOST_GID:-1000}"

# Remap ide user/group to match host UID/GID via /etc/passwd and /etc/group
# This avoids usermod/groupmod which scan the entire filesystem
if [ "$(id -g ide)" != "$HOST_GID" ]; then
    sed -i "s/^ide:x:[0-9]*:/ide:x:${HOST_GID}:/" /etc/group
    sed -i "s/^\(ide:[^:]*:[^:]*:\)[0-9]*:/\1${HOST_GID}:/" /etc/passwd
fi

if [ "$(id -u ide)" != "$HOST_UID" ]; then
    sed -i "s/^\(ide:[^:]*:\)[0-9]*:/\1${HOST_UID}:/" /etc/passwd
fi

# Install host CA certificates if mounted
if [ -d /usr/local/share/host-ca-certificates ] && [ "$(ls -A /usr/local/share/host-ca-certificates)" ]; then
    cp /usr/local/share/host-ca-certificates/* /usr/local/share/ca-certificates/
    update-ca-certificates
fi

# Configure git user from environment variables
gosu ide git config --global user.name "${GIT_USER_NAME:-Maarten Nusteling}"
gosu ide git config --global user.email "${GIT_USER_EMAIL:-maarten.nusteling@gmail.com}"

exec gosu ide /bin/zsh "$@"
