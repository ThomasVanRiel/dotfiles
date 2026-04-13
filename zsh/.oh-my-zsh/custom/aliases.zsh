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
  else
    source .venv/bin/activate
  fi
}
