#!/usr/bin/env bash
# Pick files with fzf and type them into another pane. If that pane is running
# Claude Code the paths are prefixed with @, so they land as file references;
# anywhere else they are inserted bare.
#
# Meant to run inside a tmux popup started from the target pane's directory,
# so the paths stay relative to that pane's cwd.
#
# Usage: fzf-insert-files.sh <target-pane-id> [pane-command]
#        pane-command decides the format; queried from tmux if omitted.
#
# Bound in ~/.tmux.conf as prefix + f, with tmux expanding both formats:
#   tmux display-popup -d "#{pane_current_path}" -E \
#     "~/.tmux/scripts/fzf-insert-files.sh #{pane_id} #{pane_current_command}"
set -euo pipefail

PANE="${1:?target pane id required}"

# The pane's foreground process decides the format. Claude Code runs itself in a
# bubblewrap sandbox, so a Claude pane reports "bwrap" and the claude process is
# a child of it; a pane started straight from the ~/.local/bin/claude symlink
# reports "claude". Keying off the foreground process is deliberate: with Claude
# suspended (C-z) the pane is a shell, and bare paths are what you want.
sandbox_runs_claude() {
  local pids next
  pids="$(tmux display-message -p -t "$PANE" '#{pane_pid}')" || return 1
  # a few levels deep, in case the sandbox nests claude under a helper process
  for _ in 1 2 3; do
    pgrep -P "${pids// /,}" -x claude >/dev/null 2>&1 && return 0
    next="$(pgrep -P "${pids// /,}" 2>/dev/null | tr '\n' ' ')" || true
    [ -n "$next" ] || return 1
    pids="$next"
  done
  return 1
}

PANE_CMD="${2:-$(tmux display-message -p -t "$PANE" '#{pane_current_command}')}"

case "$PANE_CMD" in
claude) PREFIX="@" ;;
bwrap) sandbox_runs_claude && PREFIX="@" || PREFIX="" ;;
*) PREFIX="" ;;
esac

# --strip-cwd-prefix keeps paths relative (no leading ./), which is what
# Claude Code's @ syntax and most shell commands both want.
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
done <<<"$selection"

# -l sends the string literally instead of interpreting it as key names
tmux send-keys -t "$PANE" -l "$text"
