#!/usr/bin/env zsh

direction="$1"

case "$direction" in 
	L) if [[ $(tmux display-message -p '#{pane_at_left}') -ne 1 ]]; then tmux select-pane -L; else swaymsg focus left || true; fi ;;
	R) if [[ $(tmux display-message -p '#{pane_at_right}') -ne 1 ]]; then tmux select-pane -R; else swaymsg focus right || true; fi ;;
	U) if [[ $(tmux display-message -p '#{pane_at_top}') -ne 1 ]]; then tmux select-pane -U; else swaymsg focus up || true; fi ;;
	D) if [[ $(tmux display-message -p '#{pane_at_bottom}') -ne 1 ]]; then tmux select-pane -D; else swaymsg focus down || true; fi ;;
esac
