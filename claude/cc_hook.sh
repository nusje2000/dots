#!/usr/bin/env bash
# Claude Code hook script — records per-session state under ~/.claude/sessions/
# and fires macOS notifications. Invoked from settings.json with event name as $1
# and the hook JSON payload on stdin. Must exit 0 — never block Claude.

set -u

event="${1:-}"
[ -z "$event" ] && exit 0

input=$(cat)
[ -z "$input" ] && exit 0

if ! command -v jq >/dev/null 2>&1; then
    exit 0
fi

session_id=$(jq -r '.session_id // empty' <<<"$input" 2>/dev/null)
[ -z "$session_id" ] && exit 0

session_dir="$HOME/.claude/cc_state"
mkdir -p "$session_dir"
state_file="$session_dir/$session_id.json"

now=$(date -u +%Y-%m-%dT%H:%M:%SZ)
cwd=$(jq -r '.cwd // empty' <<<"$input" 2>/dev/null)

tmux_session=""; tmux_window=""; tmux_pane_index=""; tmux_pane_id=""
if [ -n "${TMUX:-}" ] && [ -n "${TMUX_PANE:-}" ]; then
    if pane_info=$(tmux display-message -p -t "$TMUX_PANE" \
        '#{session_name}	#{window_index}	#{pane_index}	#{pane_id}' 2>/dev/null); then
        IFS=$'\t' read -r tmux_session tmux_window tmux_pane_index tmux_pane_id <<<"$pane_info"
    fi
fi

existing="{}"
if [ -f "$state_file" ]; then
    existing=$(cat "$state_file" 2>/dev/null || echo "{}")
    [ -z "$existing" ] && existing="{}"
fi

epoch_of() {
    local ts="$1"
    [ -z "$ts" ] && { echo 0; return; }
    if date -j -u -f "%Y-%m-%dT%H:%M:%SZ" "$ts" +%s 2>/dev/null; then return; fi
    date -u -d "$ts" +%s 2>/dev/null || echo 0
}

human_duration() {
    local s="$1"
    if [ "$s" -lt 60 ]; then echo "${s}s"
    elif [ "$s" -lt 3600 ]; then printf "%dm%ds" $((s/60)) $((s%60))
    else printf "%dh%dm" $((s/3600)) $(((s%3600)/60))
    fi
}

notify() {
    local title="$1" subtitle="$2"
    command -v terminal-notifier >/dev/null 2>&1 || return 0
    terminal-notifier -sound default -title "$title" -subtitle "$subtitle" \
        >/dev/null 2>&1 &
}

# Store a short-lived "toast" the status segment renders inline.
# File format: line 1 = expiry epoch, line 2 = pre-formatted tmux message.
tmux_notify() {
    local kind="$1" title="$2" subtitle="$3"
    command -v tmux >/dev/null 2>&1 || return 0
    [ -z "${TMUX:-}" ] && return 0

    local icon color
    case "$kind" in
        waiting) icon="⏸"; color="#c8941f" ;;
        done)    icon="✓"; color="#22a05a" ;;
        *)       icon="●"; color="#80a0ff" ;;
    esac

    local expiry=$(( $(date +%s) + 10 ))
    # Two pills: [colored bg, white text] icon + title, then [gray bg, white text] subtitle.
    local msg="#[bg=${color},fg=#ffffff,bold] ${icon} ${title} #[bg=#3a3a3a,fg=#ffffff,nobold] ${subtitle} #[default]"
    local toast_dir="$HOME/.claude/cc_state/_toasts"
    mkdir -p "$toast_dir"
    # Filename prefix is the epoch so glob expansion sorts toasts chronologically.
    local uniq="$(date +%s)_${RANDOM}_$$"
    local toast_file="$toast_dir/${uniq}.toast"
    printf '%s\n%s\n' "$expiry" "$msg" > "$toast_file.tmp" && mv "$toast_file.tmp" "$toast_file"

    tmux refresh-client -S 2>/dev/null
}

state=""; new_started=""; new_prompt=""
notif_title=""; notif_subtitle=""; notif_kind=""

case "$event" in
    UserPromptSubmit)
        state="running"
        new_started="$now"
        new_prompt=$(jq -r '.prompt // empty' <<<"$input" 2>/dev/null | tr '\n' ' ' | cut -c1-120)
        ;;
    Stop)
        state="idle"
        prev_started=$(jq -r '.started_at // empty' <<<"$existing" 2>/dev/null)
        project=$(basename "${cwd:-$(jq -r '.cwd // empty' <<<"$existing")}")
        if [ -n "$prev_started" ]; then
            dur=$(( $(date -u +%s) - $(epoch_of "$prev_started") ))
            [ "$dur" -lt 0 ] && dur=0
            notif_title="$project"
            notif_subtitle="done in $(human_duration "$dur")"
        else
            notif_title="$project"
            notif_subtitle="done"
        fi
        notif_kind="done"
        ;;
    Notification)
        msg=$(jq -r '.message // empty' <<<"$input" 2>/dev/null)
        lower=$(printf '%s' "$msg" | tr '[:upper:]' '[:lower:]')
        project=$(basename "${cwd:-$(jq -r '.cwd // empty' <<<"$existing")}")
        case "$lower" in
            *"waiting for your input"*|*"waiting for input"*)
                exit 0
                ;;
            *permission*|*approval*|*"choose an option"*)
                state="waiting"
                notif_title="$project"
                notif_subtitle="Action required"
                notif_kind="waiting"
                ;;
            *)
                notif_title="$project"
                notif_subtitle="${msg:-Notification}"
                notif_kind="generic"
                ;;
        esac
        ;;
    *)
        exit 0
        ;;
esac

if [ -n "$notif_title" ]; then
    notify "$notif_title" "$notif_subtitle"
    tmux_notify "$notif_kind" "$notif_title" "$notif_subtitle"
fi

jq -c -n \
    --arg session_id   "$session_id" \
    --arg state        "${state:-}" \
    --arg cwd          "$cwd" \
    --arg tmux_session "$tmux_session" \
    --arg tmux_window  "$tmux_window" \
    --arg tmux_pane_index "$tmux_pane_index" \
    --arg tmux_pane_id "$tmux_pane_id" \
    --arg now          "$now" \
    --arg new_started  "$new_started" \
    --arg new_prompt   "$new_prompt" \
    --argjson existing "$existing" '
    ($existing // {}) as $e
    | {
        session_id:      $session_id,
        state:           (if $state == "" then ($e.state // "running") else $state end),
        cwd:             (if $cwd   == "" then ($e.cwd // "") else $cwd end),
        tmux_session:    (if $tmux_session    == "" then ($e.tmux_session    // "") else $tmux_session end),
        tmux_window:     (if $tmux_window     == "" then ($e.tmux_window     // "") else $tmux_window end),
        tmux_pane_index: (if $tmux_pane_index == "" then ($e.tmux_pane_index // "") else $tmux_pane_index end),
        tmux_pane_id:    (if $tmux_pane_id    == "" then ($e.tmux_pane_id    // "") else $tmux_pane_id end),
        started_at:      (if $new_started == "" then ($e.started_at // $now) else $new_started end),
        updated_at:      $now,
        last_prompt:     (if $new_prompt  == "" then ($e.last_prompt // "") else $new_prompt end)
    }' > "$state_file.tmp" 2>/dev/null && mv "$state_file.tmp" "$state_file"

exit 0
