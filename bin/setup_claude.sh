#!/usr/bin/env bash

source $(dirname "$0")/functions.sh

if ! command_exists claude; then
    loading "Installing claude..."
    curl -fsSL https://claude.ai/install.sh | bash
    success "claude has been installed"
else
    success "claude has already been installed"
fi


if is_osx; then
    brew_install_if_missing terminal-notifier

    # check if claude directory exists
    if [ ! -d "$HOME/.claude/ccnotify" ]; then
        loading "Setting up claude notifications..."

        mkdir -p "$PROJECT_DIR/claude/ccnotify"
        mkdir -p "$HOME/.claude/ccnotify"

        git clone https://github.com/dazuiba/CCNotify.git "$PROJECT_DIR/claude/ccnotify"
        (cd "$PROJECT_DIR/claude/ccnotify" && git reset --hard add20f8f669de30a48a08fe4b1b19e42e77de5f2)
        yes | cp "$PROJECT_DIR/claude/ccnotify/ccnotify.py" "$HOME/.claude/ccnotify/ccnotify.py"

        success "claude notifications have been setup"
    else
        success "claude notifications have already been setup"
    fi
fi

link_file "$PROJECT_DIR/claude/settings.json" "$HOME/.claude/settings.json"
link_file "$PROJECT_DIR/claude/global-claude.md" "$HOME/.claude/CLAUDE.md"

function claude_mcp_exists() {
    NAME=$1

    if jq -e --arg NAME "$NAME" '.mcpServers[$NAME]' ~/.claude.json > /dev/null; then
        return 0
    else
        return 1
    fi
}

if ! claude_mcp_exists "context7"; then
    info "Adding context7 MCP to claude..."
    TOKEN=$(op read "op://Private/Context7/Saved on context7.com/API Key - Claude Code")
    claude mcp add --transport http --scope user context7 https://mcp.context7.com/mcp --header "CONTEXT7_API_KEY: $TOKEN"
    success "Added context7 MCP to claude"
else
    success "context7 MCP already exists in claude"
fi

if ! claude_mcp_exists "home-assistant"; then
    info "Adding home-assistant MCP to claude..."
    TOKEN=$(op read "op://Private/Home Assistant/API Key - Claude Code")
    claude mcp add --transport http --scope user home-assistant http://localhost:8123/api/claude --header "Authorization: Bearer $TOKEN"
    success "Added home-assistant MCP to claude"
else
    success "home-assistant MCP already exists in claude"
fi

