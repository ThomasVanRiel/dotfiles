#!/bin/bash
# Mirrors starship's rust/nodejs/python modules for the tmux status bar.
# Outputs only raw icons + versions — no colors, no separators.
# Colors and separators are applied in tmux.conf via #{?#{@env_has_content},...}.
# Args: $1 = pane_id, $2 = pane_current_path, $3 = pane_current_command
#       $4 = active_venv (#{@venv}, set per-pane by the shell's precmd hook)

pane_id="$1"
dir="$2"
cmd="$3"
active_venv="$4"

skip() { tmux set-option -p -t "$pane_id" @env_has_content ""; exit; }

[ "$cmd" = "ssh" ] && skip
[ -d "$dir" ]      || skip

git_root=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null)

has_file() {
    local f
    for f in "$@"; do
        [ -f "$dir/$f" ] && return 0
        [ -n "$git_root" ] && [ -f "$git_root/$f" ] && return 0
    done
    return 1
}

has_glob() {
    local g="$1"
    ls "$dir"/$g 2>/dev/null | grep -q . && return 0
    [ -n "$git_root" ] && ls "$git_root"/$g 2>/dev/null | grep -q . && return 0
    return 1
}

out=""
if has_file "Cargo.toml"; then
    ver=$(rustc --version 2>/dev/null | awk '{print $2}')
    out="${out}  ${ver}"
fi
if has_file "package.json"; then
    ver=$(node --version 2>/dev/null | sed 's/^v//')
    out="${out}  ${ver}"
fi
if has_file "pyproject.toml" "requirements.txt" "setup.py" || has_glob "*.py" || [ -n "$active_venv" ]; then
    ver=$(python3 --version 2>/dev/null | awk '{print $2}')
    out="${out}  ${ver}${active_venv:+ ${active_venv}}"
fi
# if has_file "go.mod"; then
#     ver=$(go version 2>/dev/null | awk '{print $3}' | sed 's/^go//')
#     out="${out}  ${ver}"
# fi
# if has_file "composer.json"; then
#     ver=$(php --version 2>/dev/null | awk 'NR==1{print $2}')
#     out="${out}  ${ver}"
# fi

if [ -n "$out" ]; then
    tmux set-option -p -t "$pane_id" @env_has_content "1"
    echo "${out# }"
else
    tmux set-option -p -t "$pane_id" @env_has_content ""
fi
