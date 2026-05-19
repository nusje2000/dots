#!/usr/bin/env bash
# fzf picker for Claude sessions. Lists every live session (running, waiting, idle).
# On select, switches the tmux client to that session/window/pane.

set -u

session_dir="$HOME/.claude/cc_state"
if [ ! -d "$session_dir" ]; then
    echo "No Claude sessions yet."
    sleep 1
    exit 0
fi

shopt -s nullglob
files=("$session_dir"/*.json)
if [ ${#files[@]} -eq 0 ]; then
    echo "No Claude sessions yet."
    sleep 1
    exit 0
fi

if ! command -v jq >/dev/null 2>&1; then
    echo "jq is required."
    sleep 2
    exit 1
fi

if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf is required."
    sleep 2
    exit 1
fi

live_panes=" $(tmux list-panes -a -F '#{pane_id}' 2>/dev/null | tr '\n' ' ')"
now_epoch=$(date -u +%s)

epoch_of() {
    local ts="$1"
    [ -z "$ts" ] && { echo 0; return; }
    if date -j -u -f "%Y-%m-%dT%H:%M:%SZ" "$ts" +%s 2>/dev/null; then return; fi
    date -u -d "$ts" +%s 2>/dev/null || echo 0
}

human_age() {
    local s="$1"
    if [ "$s" -lt 60 ]; then echo "${s}s ago"
    elif [ "$s" -lt 3600 ]; then printf "%dm ago" $((s/60))
    elif [ "$s" -lt 86400 ]; then printf "%dh ago" $((s/3600))
    else printf "%dd ago" $((s/86400))
    fi
}

# Build raw input lines: <sort_key>\t<display_line>\t<target_session>\t<target_window>\t<target_pane>
rows=()
for f in "${files[@]}"; do
    data=$(cat "$f" 2>/dev/null) || continue
    pane_id=$(jq -r '.tmux_pane_id // empty'    <<<"$data" 2>/dev/null)
    state=$(  jq -r '.state // empty'           <<<"$data" 2>/dev/null)
    cwd=$(    jq -r '.cwd // empty'             <<<"$data" 2>/dev/null)
    sess=$(   jq -r '.tmux_session // empty'    <<<"$data" 2>/dev/null)
    win=$(    jq -r '.tmux_window // empty'     <<<"$data" 2>/dev/null)
    pidx=$(   jq -r '.tmux_pane_index // empty' <<<"$data" 2>/dev/null)
    updated=$(jq -r '.updated_at // empty'      <<<"$data" 2>/dev/null)
    prompt=$( jq -r '.last_prompt // empty'     <<<"$data" 2>/dev/null)

    if [ -z "$pane_id" ] || [[ "$live_panes" != *" $pane_id "* ]]; then
        rm -f "$f"
        continue
    fi

    project=$(basename "${cwd:-?}")
    age=$(human_age $((now_epoch - $(epoch_of "$updated"))))

    case "$state" in
        waiting) icon=$'\e[33m⏸\e[0m'; sort_prio=0;;
        running) icon=$'\e[32m●\e[0m'; sort_prio=1;;
        idle)    icon=$'\e[37m✓\e[0m'; sort_prio=2;;
        *)       icon='?';             sort_prio=3;;
    esac

    upd_epoch=$(epoch_of "$updated")
    sort_key=$(printf '%d %020d' "$sort_prio" $((9999999999 - upd_epoch)))

    target="${sess}:${win}.${pidx}"
    prompt_short=${prompt:0:60}
    display=$(printf '%s  %-20s  %-22s  %-10s  %s' \
        "$icon" "$project" "$target" "$age" "$prompt_short")

    rows+=("$sort_key"$'\t'"$display"$'\t'"$sess"$'\t'"$win"$'\t'"$pidx")
done

if [ ${#rows[@]} -eq 0 ]; then
    echo "No live Claude sessions."
    sleep 1
    exit 0
fi

selection=$(
    printf '%s\n' "${rows[@]}" \
        | sort \
        | fzf --ansi \
              --delimiter=$'\t' \
              --with-nth=2 \
              --no-info \
              --reverse \
              --prompt='claude > ' \
              --header='enter: jump to pane    esc: cancel'
)

[ -z "$selection" ] && exit 0

IFS=$'\t' read -r _sort_key _display sess win pidx <<<"$selection"
[ -z "$sess" ] && exit 0

tmux switch-client -t "$sess" 2>/dev/null
tmux select-window -t "${sess}:${win}" 2>/dev/null
tmux select-pane   -t "${sess}:${win}.${pidx}" 2>/dev/null
