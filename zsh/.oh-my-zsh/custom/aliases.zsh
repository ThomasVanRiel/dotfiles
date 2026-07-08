alias ta="tmux a"
alias claudecommit='claude --model haiku "/commit"'
alias dps='docker ps -a --format "table {{.Names}}\t{{.Status}}"'
alias e='eza --long --links --group --color=auto --git --git-repos' 
alias ea='e -a'
alias etree='e --tree --level=2'
alias gdt='git difftool'
venv() {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    deactivate
    return
  fi

  local dir="$PWD"
  local names=(.venv venv .env env)
  while true; do
    for name in "${names[@]}"; do
      if [[ -f "$dir/$name/bin/activate" ]]; then
        source "$dir/$name/bin/activate"
        echo "Activated venv at $dir/$name"
        return
      fi
    done
    [[ "$dir" == "/" ]] && break
    dir="$(dirname "$dir")"
  done

  echo "No virtualenv found in current or parent directories." >&2
  return 1
}

pacup() {
  local updates
  updates=$(checkupdates)
  if [[ -z "$updates" ]]; then
    echo "No updates available."
    return 0
  fi
  print -r -- "$updates" | awk '
    function strip(v,   r) { r=v; sub(/^[0-9]+:/,"",r); sub(/-[^-]*$/,"",r); return r }
    BEGIN { RED="\033[1;31m"; ORANGE="\033[38;5;208m"; GREEN="\033[32m"; RST="\033[0m" }
    {
      split(strip($2), o, /[.+_]/); split(strip($4), n, /[.+_]/)
      if      (o[1] != n[1]) { c=RED;    l="MAJOR" }
      else if (o[2] != n[2]) { c=ORANGE; l="minor" }
      else                   { c=GREEN;  l="patch" }
      printf "%s%-6s%s  %s\n", c, l, RST, $0
    }'
  echo
  read -q "?Proceed with pacman -Syu? [y/N] " && echo && sudo pacman -Syu
}
alias pipi="pip"
alias wgup="sudo WG_QUICK_USERSPACE_IMPLEMENTATION=wireguard-go wg-quick up surfshark"
alias wgdown="sudo WG_QUICK_USERSPACE_IMPLEMENTATION=wireguard-go wg-quick down surfshark"
alias wgstat="sudo wg show"

