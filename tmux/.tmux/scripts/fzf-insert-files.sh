#!/usr/bin/env bash
# Pick files with fzf and type them into another pane, optionally prefixed.
# Meant to run inside a tmux popup started from the target pane's directory,
# so the paths stay relative to that pane's cwd.
#
# Usage: fzf-insert-files.sh <target-pane-id> [prefix]
#
#   fzf-insert-files.sh %3 @   ->  @src/main.py @README.md
#   fzf-insert-files.sh %3     ->  src/main.py README.md
set -euo pipefail

PANE="${1:?target pane id required}"
PREFIX="${2:-}"

# --strip-cwd-prefix keeps paths relative (no leading ./), which is what
# Claude Code's @ syntax and most shell commands both want
selection="$(
  fd --type f --hidden --exclude .git --strip-cwd-prefix |
    fzf --multi \
        --prompt="${PREFIX:-> } " \
        --height=100% \
        --border=none \
        --preview='bat --style=numbers --color=always --line-range=:200 {}' \
        --preview-window='right:60%'
)" || exit 0

[ -n "$selection" ] || exit 0

text=""
while IFS= read -r file; do
  [ -n "$file" ] && text+="$PREFIX$file "
done <<< "$selection"

# -l sends the string literally instead of interpreting it as key names
tmux send-keys -t "$PANE" -l "$text"
