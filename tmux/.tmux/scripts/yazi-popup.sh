#!/usr/bin/env bash
# Open yazi in a popup and, when it exits with `Q`, cd the pane that opened it.
#
# A popup is its own process: leaving it cannot change the parent pane's
# directory the way the `y` shell wrapper can. So yazi's --cwd-file is read
# here and typed into the pane as a cd command -- the same trick
# fzf-insert-files.sh uses to insert paths. keymap.toml swaps yazi's quit
# keys, so `q` writes no cwd-file and leaves the pane alone, and `Q` is the
# deliberate "take me there" exit.
#
# A half-typed command survives the trip, the way fzf's alt-c widget leaves
# the line untouched: the cd cannot just be appended to whatever is already in
# the buffer, so the buffer is stashed first and restored at the new prompt.
# Only zsh has a buffer stack for this; see the second case below.
#
# An ssh pane is browsed on the far side: yazi runs remotely over the same
# connection (it has to be installed there), and the cd typed afterwards is
# meant for the remote shell. Whether that shell is at a prompt is read off
# the pane title, which it sets to user@host:path while it is.
#
# Usage: yazi-popup.sh <target-pane-id>
# Bound in ~/.tmux.conf as prefix + y.
set -euo pipefail

PANE="${1:?target pane id required}"
. "$(dirname "$0")/ssh-pane.sh"

pane_var() { tmux display-message -p -t "$PANE" "$1"; }
die() { tmux display-message "yazi: $*"; exit 1; }
# The remote login shell -- whichever it is -- parses every command ssh hands
# it, so what goes over is plain single-quoted text: the scripts carry no
# quotes or backslashes of their own, and the values travel as arguments.
sq() { printf "'%s'" "${1//\'/\'\\\'\'}"; }

if [ "$(pane_var '#{pane_current_command}')" = ssh ]; then
  pane_ssh || die "no ssh client under this pane"
  dir="$(pane_remote_path)"
  # Named here so the second round trip can find it again; remote mktemp
  # output would have to come back through the tty yazi is drawing on.
  name="yazi-cwd.$(date +%s).$$.$RANDOM"

  # The remote ssh command runs in a non-login, non-interactive shell, so
  # ~/.local/bin and ~/.cargo/bin -- where yazi usually lives -- are added by
  # hand, as tmux does for its own PATH.
  read -r -d '' browse <<'REMOTE' || true
d=$1 f=${TMPDIR:-/tmp}/$2
case $d in "~") d=$HOME ;; "~/"*) d=$HOME/${d#"~/"} ;; esac
cd "$d" 2>/dev/null || cd
PATH=$HOME/.local/bin:$HOME/.cargo/bin:$PATH
command -v yazi >/dev/null 2>&1 || exit 127
exec yazi --cwd-file="$f"
REMOTE
  set +e
  "${SSH[@]}" -t "sh -c $(sq "$browse") sh $(sq "$dir") $name"
  rc=$?
  set -e
  case $rc in
  0) ;;
  127) die "not installed on ${SSH[-1]}" ;;
  *) die "ssh failed (exit $rc)" ;;
  esac

  # Collect and remove the cwd-file, dropping it when yazi ended where it
  # started, and learn which shell the cd will be typed into.
  out="$("${SSH[@]}" "sh -s -- $(sq "$dir") $name" <<'REMOTE'
d=$1 f=${TMPDIR:-/tmp}/$2
c=$(cat "$f" 2>/dev/null)
rm -f "$f"
case $d in "~") d=$HOME ;; "~/"*) d=$HOME/${d#"~/"} ;; esac
[ -n "$c" ] && [ "$(cd "$c" 2>/dev/null && pwd -P)" = "$(cd "$d" 2>/dev/null && pwd -P)" ] && c=
printf '%s\n%s\n' "$c" "${SHELL##*/}"
REMOTE
  )" || die "ssh failed reading back the directory"
  cwd="$(sed -n 1p <<<"$out")"
  [ -n "$cwd" ] || exit 0
  [ -n "$dir" ] || die "remote pane is not at a shell prompt, staying put"
  shell="$(sed -n 2p <<<"$out")"
else
  cwd_file="$(mktemp -t yazi-cwd.XXXXXX)"
  trap 'rm -f -- "$cwd_file"' EXIT

  yazi --cwd-file="$cwd_file"

  cwd="$(cat -- "$cwd_file")"
  [ -n "$cwd" ] || exit 0
  [ "$cwd" != "$(pane_var '#{pane_current_path}')" ] || exit 0
  shell="$(pane_var '#{pane_current_command}')"
fi

# Only a shell can be told to cd. Typing into nvim or claude would be worse
# than doing nothing, so say why instead.
case "$shell" in
bash | zsh | fish | sh | dash) ;;
*)
  tmux display-message "yazi: pane is not at a shell prompt, staying put"
  exit 0
  ;;
esac

# Clear the prompt so the cd lands on a line of its own, and arrange for what
# was there to come back. yank=1 means the buffer is parked in the kill ring
# and has to be pulled back out by hand once the cd has run.
yank=""
case "$shell" in
zsh)
  # M-q is push-line: zsh keeps the buffer on its own stack and pops it at the
  # start of the next line editing session, with no second keystroke needed.
  # This is what `zle push-line` does inside fzf's alt-c widget.
  tmux send-keys -t "$PANE" M-q
  ;;
bash | fish)
  # No buffer stack in readline: go to the end of the line and kill backwards
  # over all of it, which parks the text in the kill ring for C-y below. The
  # space is a sentinel -- killing nothing leaves the ring untouched, so an
  # empty prompt would otherwise yank back whatever was killed earlier in the
  # session. It is backspaced away once the text is out again.
  tmux send-keys -t "$PANE" C-e Space C-u
  yank=1
  ;;
*)
  # sh and dash have no line editor at all; C-u is the tty's own line-kill,
  # and the text it erases is gone for good.
  tmux send-keys -t "$PANE" C-u
  ;;
esac

# -l sends the string literally instead of interpreting it as key names
tmux send-keys -t "$PANE" -l "cd -- $(printf '%q' "$cwd")"
tmux send-keys -t "$PANE" Enter

# Queued while cd runs; the shell reads it when the new prompt starts.
[ -z "$yank" ] || tmux send-keys -t "$PANE" C-y BSpace
