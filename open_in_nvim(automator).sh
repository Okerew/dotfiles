#!/bin/zsh
while IFS= read -r f; do
  /opt/homebrew/bin/tmux send-keys -t "default:1.1" "nvim \"$f\"" Enter
done

# NOTE: Add this script in Automator app, through selecting in workflow receives
# current: "files or folders" in Finder, and adding this as a run shell script
