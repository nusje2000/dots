#!/usr/bin/env bash
source $(dirname "$0")/functions.sh

SSH_DIR="$HOME/.ssh"
AUTH_KEY="id_ed25519_auth"
SIGN_KEY="id_ed25519_sign"

# Create .ssh directory if needed
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Install sshpk for PEM to OpenSSH conversion
if command_exists sshpk-conv; then
    info "Installing sshpk..."
    npm install -g sshpk
fi

# Fetch keys from 1Password
# Replace these with your actual 1Password item names
AUTH_ITEM="qhale6h7olfl45hnatvq767n5e"
SIGN_ITEM="oxjiqhytqdmgzkcd23rr2yb5wq"

if ! [ -f "$SSH_DIR/$AUTH_KEY" ]; then
    info "Fetching authentication key..."

    op item get "$AUTH_ITEM" --fields "private key" --account "my.1password.com" --reveal --format json | jq -r '.value' > "$SSH_DIR/$AUTH_KEY.pem"
    sshpk-conv $SSH_DIR/$AUTH_KEY.pem -t ssh -p > "$SSH_DIR/$AUTH_KEY"
    chmod 600 "$SSH_DIR/$AUTH_KEY"
    ssh-keygen -y -f "$SSH_DIR/$AUTH_KEY" > "$SSH_DIR/$AUTH_KEY.pub"

    ssh-add "$SSH_DIR/$AUTH_KEY"
    success "Authentication key fetched and saved to $SSH_DIR/$AUTH_KEY"
else
    success "Authentication key already exists at $SSH_DIR/$AUTH_KEY"
fi

if ! [ -f "$SSH_DIR/$SIGN_KEY" ]; then
    info "Fetching signing key..."

    op item get "$SIGN_ITEM" --fields "private key" --account "my.1password.com" --reveal --format json | jq -r '.value' > "$SSH_DIR/$SIGN_KEY.pem"
    sshpk-conv $SSH_DIR/$SIGN_KEY.pem -t ssh -p > "$SSH_DIR/$SIGN_KEY"
    chmod 600 "$SSH_DIR/$SIGN_KEY"
    ssh-keygen -y -f "$SSH_DIR/$SIGN_KEY" > "$SSH_DIR/$SIGN_KEY.pub"

    ssh-add "$SSH_DIR/$SIGN_KEY"
    success "Signing key fetched and saved to $SSH_DIR/$SIGN_KEY"
else
    success "Signing key already exists at $SSH_DIR/$SIGN_KEY"
fi

mkdir -p "$SSH_DIR/config.d"

cat > "$SSH_DIR/config" <<EOF
Include config.d/*.conf

Host *
    IdentityFile ~/.ssh/$AUTH_KEY
EOF
chmod 600 "$SSH_DIR/config"
