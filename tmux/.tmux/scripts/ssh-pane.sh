# Shared by the popup scripts that have to reach through an ssh pane to the
# remote side (fzf-insert-files.sh, yazi-popup.sh). Source it; it expects
# $PANE to hold the target pane id.

# Walk descendants of the pane's process a few levels deep. This locates either
# the ssh client beneath a remote pane or Claude beneath bubblewrap locally.
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

# Fill the SSH array with a command that reaches the pane's host. It reuses the
# running client's argv, so ports, identities and jump hosts carry over as
# typed: everything up to the destination, minus any remote command. The
# control socket makes the repeated round trips of a popup cheap.
pane_ssh() {
  local pid argv i
  pid="$(descendant ssh | head -1)" || return 1
  mapfile -d '' -t argv <"/proc/$pid/cmdline"
  SSH=("${argv[0]}" -o ControlMaster=auto -o ControlPersist=30 \
    -o ControlPath="${TMPDIR:-/tmp}/.tmux-ssh-%r@%h:%p")
  for ((i = 1; i < ${#argv[@]}; i++)); do
    SSH+=("${argv[i]}")
    case ${argv[i]} in
    -[bcDEeFIiJLlmOopQRSWw]) SSH+=("${argv[++i]}") ;; # option takes an argument
    -*) ;;
    *) break ;;                                      # destination
    esac
  done
}

# The remote shell's prompt sets the pane title to user@host:path — the same
# convention trunc-path.sh reads. Print the path part, or nothing when the
# title is something else (a remote program owns it, so no prompt is showing).
pane_remote_path() {
  local title
  title="$(tmux display-message -p -t "$PANE" '#{pane_title}')"
  case $title in *@*:*) printf '%s' "${title#*:}" ;; esac
}
