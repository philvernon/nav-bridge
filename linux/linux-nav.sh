#!/usr/bin/env bash
set -u

direction="${1:-}"

case "$direction" in
L)
    pane_direction=-L
    pane_edge='#{pane_at_left}'
    sway_direction=left
    ;;
R)
    pane_direction=-R
    pane_edge='#{pane_at_right}'
    sway_direction=right
    ;;
U)
    pane_direction=-U
    pane_edge='#{pane_at_top}'
    sway_direction=up
    ;;
D)
    pane_direction=-D
    pane_edge='#{pane_at_bottom}'
    sway_direction=down
    ;;
*)
    printf 'usage: %s {L|D|U|R}\n' "$0" >&2
    exit 64
    ;;
esac

focus_sway() {
    swaymsg focus "$sway_direction" >/dev/null 2>&1 || true
}

if ! at_edge="$(tmux display-message -p "$pane_edge" 2>/dev/null)"; then
    focus_sway
    exit
fi

if [[ "$at_edge" == 1 ]]; then
    focus_sway
else
    tmux select-pane "$pane_direction"
fi
