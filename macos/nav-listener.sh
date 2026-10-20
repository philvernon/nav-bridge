#!/usr/bin/env bash
set -u

IFS= read -r direction || exit 1

case "$direction" in
   L) direction=west ;;
   D) direction=south ;;
   U) direction=north ;;
   R) direction=east ;;
   *) exit 64 ;;
esac

exec yabai -m window --focus "$direction"
