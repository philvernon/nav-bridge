#!/usr/bin/env bash
set -u

direction="${1:-}"
socket_path="${NAV_BRIDGE_SOCKET:-/tmp/nav.sock}"

case "$direction" in
L)
    pane_direction=-L
    pane_edge='#{pane_at_left}'
    ;;
R)
    pane_direction=-R
    pane_edge='#{pane_at_right}'
    ;;
U)
    pane_direction=-U
    pane_edge='#{pane_at_top}'
    ;;
D)
    pane_direction=-D
    pane_edge='#{pane_at_bottom}'
    ;;
*)
    printf 'usage: %s {L|D|U|R}\n' "$0" >&2
    exit 64
    ;;
esac

if [[ "$(tmux display-message -p "$pane_edge")" == 1 ]]; then
    printf '%s\n' "$direction" | socat - "UNIX-CONNECT:$socket_path"
else
    tmux select-pane "$pane_direction"
fi
