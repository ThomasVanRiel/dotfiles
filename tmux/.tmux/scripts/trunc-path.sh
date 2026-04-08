#!/usr/bin/env bash
# Truncate a path to MAX chars, cutting only at directory boundaries.
# Prefixes result with ~/ (under home) or ../ (elsewhere) when truncated.
# A single directory name longer than MAX is shown in full.
MAX=${2:-30}
raw="$1"
home=$(eval echo ~)
path=$(echo "$raw" | sed "s|^$home|~|")

if [ ${#path} -le $MAX ]; then
    echo "$path"
    exit
fi

if [[ "$path" == "~" ]]; then
    echo "~"
    exit
elif [[ "$path" == "~/"* ]]; then
    prefix="~/"
    stripped="${path:2}"
elif [[ "$path" == "/" ]]; then
    echo "/"
    exit
else
    prefix="../"
    stripped="${path#/}"
fi

avail=$((MAX - ${#prefix}))

IFS='/' read -ra parts <<< "$stripped"
result=""
for ((i=${#parts[@]}-1; i>=0; i--)); do
    part="${parts[$i]}"
    [ -z "$part" ] && continue
    if [ -z "$result" ]; then
        candidate="$part"
    else
        candidate="$part/$result"
    fi
    # Always take at least one component (allows long single dir names)
    if [ -n "$result" ] && [ ${#candidate} -gt $avail ]; then
        break
    fi
    result="$candidate"
done

echo "${prefix}${result}"
