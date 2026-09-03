#!/usr/bin/env bash
# Pick files with fzf and type them into another pane. If that pane is running
# Claude Code the paths are prefixed with @, so they land as file references;
# anywhere else they are inserted bare. Handles both
#   local   pane -> [bwrap ->] claude          files listed with local fd
#   remote  pane -> ssh -> [bwrap ->] claude   files listed over ssh
#
# Meant to run inside a tmux popup started from the target pane's directory,
# so the paths stay relative to that pane's cwd.
#
# Usage: fzf-insert-files.sh <target-pane-id> [pane-command] [border-colour]
#        pane-command decides the format; queried from tmux if omitted.
#
# Bound in ~/.tmux.conf as prefix + f. The popup is created with -B (no border)
# because fzf draws its own, labelled with the directory being browsed — which
# tmux cannot do, as -T is fixed before this script knows the remote path.
set -euo pipefail

# fzf re-invokes this script to list and to preview, so the remote context has
# to survive as FIF_* rather than as quoting inside fzf's own command strings.
#   --strip-cwd-prefix keeps paths relative (no leading ./), which is what
#   Claude Code's @ syntax and most shell commands both want.
#   fd hides .gitignored files; ctrl-g reloads with --no-ignore to show them.
case "${1:-}" in
--list)
  run=(fd --type f --hidden --exclude .git --strip-cwd-prefix ${2:+--no-ignore})
  ;;
--preview)
  [ -n "${2:-}" ] || exit 0
  run=(bat --style=numbers --color=always --line-range=:200 -- "$2")
  ;;
esac
if [ -n "${run:-}" ]; then
  [ -n "${FIF_SSH:-}" ] || exec "${run[@]}"
  eval "ssh=($FIF_SSH)"
  # Two things about the remote end. ssh joins its command arguments into one
  # string for the remote shell to re-parse, so the command has to arrive
  # already quoted — argv boundaries do not survive the trip. And it runs a
  # non-interactive, non-login shell, so ~/.local/bin and ~/.cargo/bin are
  # usually off PATH: fd and bat cannot be assumed.
  cmd="$(printf '%q ' "${run[@]}")"
  case ${run[0]} in
  fd) cmd="command -v fd >/dev/null 2>&1 && exec $cmd
find . -type f -not -path './.git/*' | sed 's|^\./||'" ;;
  bat) cmd="command -v bat >/dev/null 2>&1 && exec $cmd
exec head -n 200 -- $(printf '%q' "$2")" ;;
  esac
  exec "${ssh[@]}" "cd $(printf '%q' "$FIF_DIR") || exit 1
$cmd"
fi

PANE="${1:?target pane id required}"
PANE_CMD="${2:-$(tmux display-message -p -t "$PANE" '#{pane_current_command}')}"
COLOUR="${3:-blue}"
SELF="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"

die() { tmux display-message "files: $*"; exit 1; }

# Descendants of the pane's process, a few levels deep. Claude Code runs itself
# in a bubblewrap sandbox, so a Claude pane reports "bwrap" with claude beneath
# it; an ssh pane has the ssh client beneath the shell. Keying off the pane's
# foreground process is deliberate: with Claude suspended (C-z) the pane is a
# shell, and bare paths are what you want.
descendant() {
  local pids next
  pids="$(tmux display-message -p -t "$PANE" '#{pane_pid}')"
  for _ in 1 2 3; do
    pgrep -P "${pids// /,}" -x "$1" 2>/dev/null && return 0
    next="$(pgrep -P "${pids// /,}" 2>/dev/null | tr '\n' ' ')" || true
    [ -n "$next" ] || return 1
    pids="$next"
  done
  return 1
}

if [ "$PANE_CMD" = "ssh" ]; then
  # Reuse the running client's argv, so ports, identities and jump hosts carry
  # over as typed: everything up to the destination, minus any remote command.
  pid="$(descendant ssh | head -1)" || die "no ssh client under this pane"
  mapfile -d '' -t argv <"/proc/$pid/cmdline"
  SSH=("${argv[0]}" -o ControlMaster=auto -o ControlPersist=30 \
    -o ControlPath="${TMPDIR:-/tmp}/.tmux-fzf-%r@%h:%p")
  for ((i = 1; i < ${#argv[@]}; i++)); do
    SSH+=("${argv[i]}")
    case ${argv[i]} in
    -[bcDEeFIiJLlmOopQRSWw]) SSH+=("${argv[++i]}") ;; # option takes an argument
    -*) ;;
    *) break ;;                                      # destination
    esac
  done

  # The remote shell's prompt sets the pane title to user@host:path — the same
  # convention trunc-path.sh reads. One round trip turns that into a real
  # directory, decides the prefix, and formats it for the border label.
  title="$(tmux display-message -p -t "$PANE" '#{pane_title}')"
  case $title in *@*:*) title=${title#*:} ;; *) title="" ;; esac

  set +e
  out="$("${SSH[@]}" sh -s -- "$(printf '%q' "$title")" <<'REMOTE'
d=$1
case $d in "~") d=$HOME ;; "~/"*) d=$HOME/${d#"~/"} ;; esac
cwds=$(for p in $(pgrep -x claude 2>/dev/null); do readlink /proc/$p/cwd; done | sort -u)
# Claude owns the title while it runs; then the only clue left is claude itself.
[ -n "$d" ] || { set -- $cwds; [ $# = 1 ] || exit 4; d=$1; }
cd "$d" 2>/dev/null || exit 3
d=$(pwd -P)
# @refs only when a claude is sitting at, or above, that directory
p=0
for w in $cwds; do case $d in "$w" | "$w"/*) p=1 ;; esac; done
case $d in "$HOME"/*) disp="~${d#"$HOME"}" ;; *) disp=$d ;; esac
printf '%s\n%s\n%s\n' "$d" "$p" "$disp"
REMOTE
  )"
  rc=$?
  set -e
  case $rc in
  0) ;;
  3) die "remote directory not found: $title" ;;
  4) die "cannot tell which remote directory this pane is in" ;;
  *) die "ssh failed (exit $rc)" ;;
  esac

  export FIF_DIR="$(sed -n 1p <<<"$out")"
  export FIF_SSH="$(printf '%q ' "${SSH[0]}" -o BatchMode=yes "${SSH[@]:1}")"
  [ "$(sed -n 2p <<<"$out")" = 1 ] && PREFIX="@" || PREFIX=""
  LABEL="${SSH[-1]}:$(sed -n 3p <<<"$out")"
else
  case "$PANE_CMD" in
  claude) PREFIX="@" ;;
  bwrap) descendant claude >/dev/null && PREFIX="@" || PREFIX="" ;;
  *) PREFIX="" ;;
  esac
  LABEL="${PWD/#$HOME/\~}"
fi

self="$(printf '%q' "$SELF")"
# Stream into fzf rather than buffering the listing: on a large tree the popup
# has to come up at once and fill in, not sit blank while the remote indexes.
# stderr is held aside so a listing that fails is still reported, rather than
# looking like an empty directory.
err="$(mktemp)"
trap 'rm -f "$err"' EXIT

selection="$(
  "$SELF" --list 2>"$err" |
    fzf --multi \
      --prompt="${PREFIX:-> } " \
      --height=100% \
      --border=rounded \
      --border-label="  Files  $LABEL " \
      --border-label-pos=3 \
      --color="border:$COLOUR,label:$COLOUR" \
      --header='ctrl-g: include gitignored' \
      --bind="ctrl-g:reload($self --list --no-ignore)+change-header(gitignored included)" \
      --preview="$self --preview {}" \
      --preview-window='right:60%'
)" || true

if [ -z "$selection" ]; then
  if [ -s "$err" ]; then die "$(head -2 "$err" | tr '\n' ' ')"; fi
  exit 0
fi

text=""
while IFS= read -r file; do
  [ -n "$file" ] && text+="$PREFIX$file "
done <<<"$selection"

# -l sends the string literally instead of interpreting it as key names
tmux send-keys -t "$PANE" -l "$text"
