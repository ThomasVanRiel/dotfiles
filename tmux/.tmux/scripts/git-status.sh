#!/bin/bash
# Git status for tmux status bar — mirrors starship git_branch + git_status format.
# Args: $1 = current pane path, $2 = pane_current_command

# Skip when the pane is running ssh (path is local, git info would be wrong)
[ "$2" = "ssh" ] && exit

cd "$1" 2>/dev/null || exit

branch=$(git branch --show-current 2>/dev/null)
[ -z "$branch" ] && exit

status=""
porcelain=$(git status --porcelain 2>/dev/null)

# Conflicted (UU, AA, DD)
[ "$(echo "$porcelain" | grep -cE "^(UU|AA|DD)")" -gt 0 ] && status="${status}="
# Untracked
[ "$(echo "$porcelain" | grep -c "^??")" -gt 0 ] && status="${status}?"
# Stashed
[ "$(git stash list 2>/dev/null | wc -l)" -gt 0 ] && status="${status}\$"
# Modified (working tree: _M)
[ "$(echo "$porcelain" | grep -c "^.[M]")" -gt 0 ] && status="${status}!"
# Staged (index: added/modified/renamed/copied — NOT deleted)
[ "$(echo "$porcelain" | grep -cE "^[MARCU].")" -gt 0 ] && status="${status}+"
# Renamed (index)
[ "$(echo "$porcelain" | grep -c "^R.")" -gt 0 ] && status="${status}»"
# Deleted (staged D_ or unstaged _D)
[ "$(echo "$porcelain" | grep -cE "^D.|^.D")" -gt 0 ] && status="${status}✘"

# Ahead / behind
ahead_behind=""
upstream=$(git rev-parse --abbrev-ref --symbolic-full-name @{upstream} 2>/dev/null)
if [ -n "$upstream" ]; then
  ahead=$(git rev-list --count @{upstream}..HEAD 2>/dev/null || echo 0)
  behind=$(git rev-list --count HEAD..@{upstream} 2>/dev/null || echo 0)
  if [ "$ahead" -gt 0 ] && [ "$behind" -gt 0 ]; then
    ahead_behind=" ⇕⇡${ahead}⇣${behind}"
  elif [ "$ahead" -gt 0 ]; then
    ahead_behind=" ⇡${ahead}"
  elif [ "$behind" -gt 0 ]; then
    ahead_behind=" ⇣${behind}"
  fi
fi

suffix="${status}${ahead_behind}"
if [ -n "$suffix" ]; then
  echo " $branch ${suffix}"
else
  echo " $branch"
fi
