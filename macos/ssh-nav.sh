#!/usr/bin/env bash
set -u

direction="${1:-}"

case "$direction" in
    L) key=M-h ;;
    D) key=M-j ;;
    U) key=M-k ;;
    R) key=M-l ;;
    *)
        printf 'usage: %s {L|D|U|R}\n' "$0" >&2
        exit 64
        ;;
esac

tmux send-keys "$key"
