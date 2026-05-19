#!/usr/bin/env bash
# Tmux status segment: compact counts of live Claude sessions.
# Reads ~/.claude/sessions/*.json, prunes entries whose tmux pane is gone,
# emits `●N ⏸N ✓N` (only non-zero states). Empty output if no live sessions.

set -u

session_dir="$HOME/.claude/cc_state"
[ -d "$session_dir" ] || exit 0

shopt -s nullglob
files=("$session_dir"/*.json)
[ ${#files[@]} -eq 0 ] && exit 0

live_panes=" $(tmux list-panes -a -F '#{pane_id}' 2>/dev/null | tr '\n' ' ')"

running=0; waiting=0; idle=0
for f in "${files[@]}"; do
    pane_id=$(grep -oE '"tmux_pane_id"[[:space:]]*:[[:space:]]*"[^"]*"' "$f" 2>/dev/null | head -1 | sed -E 's/.*"([^"]*)"$/\1/')
    if [ -n "$pane_id" ] && [[ "$live_panes" != *" $pane_id "* ]]; then
        rm -f "$f"
        continue
    fi
    state=$(grep -oE '"state"[[:space:]]*:[[:space:]]*"[^"]*"' "$f" 2>/dev/null | head -1 | sed -E 's/.*"([^"]*)"$/\1/')
    case "$state" in
        running) running=$((running+1));;
        waiting) waiting=$((waiting+1));;
        idle)    idle=$((idle+1));;
    esac
done

out=""
[ "$waiting" -gt 0 ] && out+="#[fg=#ffcb6b]⏸${waiting} "
[ "$running" -gt 0 ] && out+="#[fg=#80ff80]●${running} "
[ "$idle"    -gt 0 ] && out+="#[fg=#808080]✓${idle} "

toast_dir="$session_dir/_toasts"
toasts=""
if [ -d "$toast_dir" ]; then
    now_epoch=$(date +%s)
    for tf in "$toast_dir"/*.toast; do
        [ -f "$tf" ] || continue
        expiry=$(head -1 "$tf" 2>/dev/null)
        if [ -n "$expiry" ] && [ "$expiry" -gt "$now_epoch" ] 2>/dev/null; then
            toast_msg=$(tail -n +2 "$tf")
            toasts+="${toast_msg}  "
        else
            rm -f "$tf"
        fi
    done
fi

if [ -n "$toasts" ]; then
    out="${toasts}  #[default]${out% }"
fi

# Clean up old single-toast file from the previous design.
rm -f "$session_dir/_toast" 2>/dev/null

printf '%s' "${out% }"
