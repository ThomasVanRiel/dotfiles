#!/usr/bin/env bash
# Pick files with fzf and type them at the cursor of another pane. Paths go in
# bare by default; a pane whose foreground process is known to want a different
# format gets a prefix instead (currently: Claude Code, which takes @path as a
# file reference).
#
# Meant to run inside a tmux popup started from the target pane's directory,
# so the paths stay relative to that pane's cwd.
#
# Usage: fzf-insert-files.sh <target-pane-id> [pane-command]
#        pane-command picks the prefix; queried from tmux if omitted.
#
# Bound in ~/.tmux.conf as prefix + f, with tmux expanding both formats:
#   tmux display-popup -d "#{pane_current_path}" -E \
#     "~/.tmux/scripts/fzf-insert-files.sh #{pane_id} #{pane_current_command}"
set -euo pipefail

PANE="${1:?target pane id required}"

# Claude Code usually runs itself in a bubblewrap sandbox, so such a pane reports
# "bwrap" and the claude process hangs below it; started straight from the
# ~/.local/bin/claude symlink the pane reports "claude" directly. Only "bwrap"
# needs the walk, since plenty of other things run sandboxed too.
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

# Keying off the *foreground* process is deliberate: a pane running a shell —
# including one where Claude is suspended with C-z — wants plain paths. Add a
# case here for any other program with its own path syntax.
case "$PANE_CMD" in
claude) PREFIX="@" ;;
bwrap) sandbox_runs_claude && PREFIX="@" || PREFIX="" ;;
*) PREFIX="" ;;
esac

# --strip-cwd-prefix keeps paths relative (no leading ./), which is what shell
# commands and editors both want.
#
# --no-ignore-vcs because fd applies .gitignore rules only inside a git repo:
# without it the same file is listed in a plain directory and silently missing
# once that directory is a repo. Build output, .env files and vendored deps are
# all things worth being able to insert. .fdignore/.ignore still apply.
selection="$(
  fd --type f --hidden --no-ignore-vcs --exclude .git --strip-cwd-prefix |
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
