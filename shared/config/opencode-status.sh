#!/usr/bin/env bash
# Aggregates opencode pane-level status options across all panes in a window.
# Usage: opencode-status.sh <window_id>
window_id=$1
statuses=$(tmux list-panes -t "$window_id" -F '#{@opencode_status}:#{@opencode_seen}' 2>/dev/null)

has_waiting=0
has_in_progress=0
has_complete=0
has_unseen=0

while IFS=: read -r status seen; do
  case "$status" in
    waiting)     has_waiting=1 ;;
    in_progress) has_in_progress=1 ;;
    complete)    has_complete=1; [ "$seen" != "1" ] && has_unseen=1 ;;
  esac
done <<< "$statuses"

if   [ $has_waiting -eq 1 ];     then echo "#[fg=#f7768e]🔔 "
elif [ $has_in_progress -eq 1 ]; then echo "#[fg=#e0af68]● "
elif [ $has_unseen -eq 1 ];      then echo "#[fg=#9ece6a]● "
elif [ $has_complete -eq 1 ];    then echo "#[fg=#9ece6a]○ "
fi
