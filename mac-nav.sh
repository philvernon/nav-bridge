#!/usr/bin/env bash
set -u

direction="${1:-}"
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

case "$direction" in
    L|D|U|R) ;;
    *)
        printf 'usage: %s {L|D|U|R}\n' "$0" >&2
        exit 64
        ;;
esac

focus_yabai() {
    case "$direction" in
        L) yabai -m window --focus west || true ;;
        R) yabai -m window --focus east || true ;;
        U) yabai -m window --focus north || true ;;
        D) yabai -m window --focus south || true ;;
    esac
}

# If tmux cannot identify a current pane, navigate at the macOS window layer.
if ! pane_cmd="$(tmux display-message -p '#{pane_current_command}' 2>/dev/null)"; then
    focus_yabai
    exit
fi

# Preserve Meta+hjkl across an SSH pane so the remote side can handle it.
if [[ "$pane_cmd" == "ssh" ]]; then
    exec "$script_dir/ssh-nav.sh" "$direction"
fi

case "$direction" in
    L)
        if [[ "$(tmux display-message -p '#{pane_at_left}')" != 1 ]]; then
            tmux select-pane -L
        else
            focus_yabai
        fi
        ;;
    R)
        if [[ "$(tmux display-message -p '#{pane_at_right}')" != 1 ]]; then
            tmux select-pane -R
        else
            focus_yabai
        fi
        ;;
    U)
        if [[ "$(tmux display-message -p '#{pane_at_top}')" != 1 ]]; then
            tmux select-pane -U
        else
            focus_yabai
        fi
        ;;
    D)
        if [[ "$(tmux display-message -p '#{pane_at_bottom}')" != 1 ]]; then
            tmux select-pane -D
        else
            focus_yabai
        fi
        ;;
esac
