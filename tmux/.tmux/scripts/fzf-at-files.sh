#!/usr/bin/env bash
# Pick files with fzf and type them into another pane as Claude Code "@path"
# references. Meant to run inside a tmux popup started from the target pane's
# directory, so the paths are relative to whatever cwd Claude was launched in.
#
# Usage: fzf-at-files.sh <target-pane-id>
set -euo pipefail

PANE="${1:?target pane id required}"

# --strip-cwd-prefix keeps paths relative (no leading ./), which is what @ wants
selection="$(
  fd --type f --hidden --exclude .git --strip-cwd-prefix |
    fzf --multi \
        --prompt='@ ' \
        --height=100% \
        --border=none \
        --preview='bat --style=numbers --color=always --line-range=:200 {}' \
        --preview-window='right:60%'
)" || exit 0

[ -n "$selection" ] || exit 0

refs=""
while IFS= read -r file; do
  [ -n "$file" ] && refs+="@$file "
done <<< "$selection"

# -l sends the string literally instead of interpreting it as key names
tmux send-keys -t "$PANE" -l "$refs"
