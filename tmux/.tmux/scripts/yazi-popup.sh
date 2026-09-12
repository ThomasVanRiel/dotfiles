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
# Usage: yazi-popup.sh <target-pane-id>
# Bound in ~/.tmux.conf as prefix + y.
set -euo pipefail

PANE="${1:?target pane id required}"

pane_var() { tmux display-message -p -t "$PANE" "$1"; }

cwd_file="$(mktemp -t yazi-cwd.XXXXXX)"
trap 'rm -f -- "$cwd_file"' EXIT

yazi --cwd-file="$cwd_file"

cwd="$(cat -- "$cwd_file")"
[ -n "$cwd" ] || exit 0
[ "$cwd" != "$(pane_var '#{pane_current_path}')" ] || exit 0

# Only a shell can be told to cd. Typing into nvim or claude would be worse
# than doing nothing, so say why instead.
shell="$(pane_var '#{pane_current_command}')"
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
