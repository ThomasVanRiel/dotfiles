#!/usr/bin/env bash
# tmux-mark.sh — toggle/cycle bookmarked windows across sessions

set -euo pipefail

current_target() {
    tmux display-message -p '#{session_name}:#{window_index}'
}

list_marked_targets() {
    tmux list-windows -a -F '#{session_name}:#{window_index}' -f '#{@marked}'
}

last_marked_target() {
    tmux show-option -sv @last_marked_target 2>/dev/null || true
}

target_exists() {
    local target="${1:?}"

    tmux list-windows -a -F '#{session_name}:#{window_index}' | grep -Fxq "$target"
}

marks_file() {
    local dir

    dir=$(tmux show-option -gv @resurrect-dir 2>/dev/null || true)
    dir=${dir:-$HOME/.tmux/resurrect}

    case "$dir" in
        "~")
            dir="$HOME"
            ;;
        "~/"*)
            dir="$HOME/${dir#~/}"
            ;;
        '$HOME')
            dir="$HOME"
            ;;
        '$HOME/'*)
            dir="$HOME/${dir#\$HOME/}"
            ;;
    esac

    printf '%s\n' "$dir/tmux-mark-state"
}

toggle() {
    local target
    target=$(current_target)

    if [ "$(tmux show-window-option -v @marked 2>/dev/null)" = "1" ]; then
        tmux set-window-option -u @marked

        if [ "$(last_marked_target)" = "$target" ]; then
            tmux set-option -s -u @last_marked_target
        fi
    else
        tmux set-window-option @marked 1
        tmux set-option -s @last_marked_target "$target"
    fi
}

cycle() {
    local direction="${1:?}" marked_windows current_target_value target count idx

    marked_windows=$(list_marked_targets)

    if [ -z "$marked_windows" ]; then
        tmux display-message "No marked windows"
        return
    fi

    count=$(echo "$marked_windows" | wc -l | tr -d ' ')
    current_target_value=$(current_target)

    if echo "$marked_windows" | grep -qx "$current_target_value"; then
        idx=0
        while IFS= read -r wid; do
            idx=$((idx + 1))
            if [ "$wid" = "$current_target_value" ]; then
                break
            fi
        done <<< "$marked_windows"

        if [ "$direction" = "next" ]; then
            idx=$(( idx % count + 1 ))
        else
            idx=$(( (idx - 2 + count) % count + 1 ))
        fi

        target=$(echo "$marked_windows" | sed -n "${idx}p")
    else
        target=$(last_marked_target)

        if [ -z "$target" ] || ! echo "$marked_windows" | grep -qx "$target"; then
            target=$(echo "$marked_windows" | head -n 1)
        fi
    fi

    tmux switch-client -t "$target"
    tmux set-option -s @last_marked_target "$target"
}

save_marks() {
    local file target last_target

    file=$(marks_file)
    mkdir -p "$(dirname "$file")"
    : > "$file"

    while IFS= read -r target; do
        [ -n "$target" ] || continue
        printf 'marked\t%s\n' "$target"
    done < <(list_marked_targets) >> "$file"

    last_target=$(last_marked_target)
    if [ -n "$last_target" ]; then
        printf 'last\t%s\n' "$last_target" >> "$file"
    fi
}

restore_marks() {
    local file line_type target restored_last_target

    file=$(marks_file)
    [ -f "$file" ] || return

    restored_last_target=""

    while IFS=$'\t' read -r line_type target; do
        case "$line_type" in
            marked)
                if target_exists "$target"; then
                    tmux set-window-option -t "$target" @marked 1
                fi
                ;;
            last)
                restored_last_target="$target"
                ;;
        esac
    done < "$file"

    if [ -n "$restored_last_target" ] && target_exists "$restored_last_target" &&
        [ "$(tmux show-window-option -v -t "$restored_last_target" @marked 2>/dev/null || true)" = "1" ]; then
        tmux set-option -s @last_marked_target "$restored_last_target"
    else
        tmux set-option -s -u @last_marked_target
    fi
}

case "${1:-}" in
    toggle)  toggle ;;
    next)    cycle next ;;
    prev)    cycle prev ;;
    save)    save_marks ;;
    restore) restore_marks ;;
    *)       echo "Usage: $0 {toggle|next|prev|save|restore}" >&2; exit 1 ;;
esac
