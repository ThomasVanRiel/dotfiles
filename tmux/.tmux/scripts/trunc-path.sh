#!/usr/bin/env bash
# Truncate a path to MAX chars, cutting only at directory boundaries.
# Prefixes result with ~/ (under home) or ../ (elsewhere) when truncated.
# When command is ssh, formats as user@host:../path from pane_title.
# A single directory name longer than MAX is shown in full.
#
# Usage: trunc-path.sh <pane_current_command> <pane_current_path> <pane_title> [max]

cmd="$1"
raw="$2"
title="$3"
MAX=${4:-30}

trunc_path() {
    local path="$1"
    if [ ${#path} -le $MAX ]; then
        echo "$path"
        return
    fi

    local prefix stripped avail
    if [[ "$path" == "~" ]]; then
        echo "~"
        return
    elif [[ "$path" == "~/"* ]]; then
        prefix="~/"
        stripped="${path:2}"
    elif [[ "$path" == "/" ]]; then
        echo "/"
        return
    else
        prefix="../"
        stripped="${path#/}"
    fi

    avail=$((MAX - ${#prefix}))

    IFS='/' read -ra parts <<< "$stripped"
    local result=""
    for ((i=${#parts[@]}-1; i>=0; i--)); do
        local part="${parts[$i]}"
        [ -z "$part" ] && continue
        local candidate
        if [ -z "$result" ]; then
            candidate="$part"
        else
            candidate="$part/$result"
        fi
        if [ -n "$result" ] && [ ${#candidate} -gt $avail ]; then
            break
        fi
        result="$candidate"
    done

    echo "${prefix}${result}"
}

if [ "$cmd" = "ssh" ] && [[ "$title" == *@*:* ]]; then
    userhost="${title%%:*}"
    remotepath="${title#*:}"
    truncated=$(trunc_path "$remotepath")
    echo "${userhost}:${truncated}"
else
    home=$(eval echo ~)
    path=$(echo "$raw" | sed "s|^$home|~|")
    trunc_path "$path"
fi
