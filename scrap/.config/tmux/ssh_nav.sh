#!/usr/bin/env zsh

# Controls navigation when this machine is accessed over ssh
# For local navigation see "sway/scripts/tmux_nav.sh"

direction="$1"

case "$direction" in
  L)
    if [[ $(tmux display-message -p '#{pane_at_left}') -ne 1 ]]; then
      tmux select-pane -L
    else
      print L | socat - UNIX-CONNECT:/tmp/nav.sock
    fi
    ;;
  R)
    if [[ $(tmux display-message -p '#{pane_at_right}') -ne 1 ]]; then
      tmux select-pane -R
    else
      print R | socat - UNIX-CONNECT:/tmp/nav.sock
    fi
    ;;
  U)
    if [[ $(tmux display-message -p '#{pane_at_top}') -ne 1 ]]; then
      tmux select-pane -U
    else
      print U | socat - UNIX-CONNECT:/tmp/nav.sock
    fi
    ;;
  D)
    if [[ $(tmux display-message -p '#{pane_at_bottom}') -ne 1 ]]; then
      tmux select-pane -D
    else
      print D | socat - UNIX-CONNECT:/tmp/nav.sock
    fi
    ;;
esac
