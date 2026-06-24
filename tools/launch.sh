#!/usr/bin/env bash
# Dispatcher for the Bun-powered tmux tools. Locates bun (whose bin dir is often
# absent from PATH inside a tmux popup) and execs the requested entrypoint that
# lives under src/. The invocation cwd (the pane's path) is preserved because the
# dir lookup runs in a subshell — the dashboard relies on it to scope by repo.
set -u

dir=$(cd "$(dirname "$0")" && pwd)

bun_bin=$(command -v bun 2>/dev/null || true)
[ -z "$bun_bin" ] && [ -x "$HOME/.bun/bin/bun" ] && bun_bin="$HOME/.bun/bin/bun"

if [ -z "$bun_bin" ]; then
    tmux display-message "bun is required for the tmux tools."
    exit 1
fi

cmd="${1:-}"
[ "$#" -gt 0 ] && shift

case "$cmd" in
    session-switcher) exec "$bun_bin" "$dir/src/session-switcher.ts" "$@" ;;
    dashboard)        exec "$bun_bin" "$dir/src/dashboard.ts" "$@" ;;
    *)
        echo "usage: launch.sh {session-switcher|dashboard} [args...]" >&2
        exit 1
        ;;
esac
