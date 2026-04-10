#!/bin/bash
class=$(hyprctl activewindow -j 2>/dev/null | jq -r '.class // empty')
if [ -n "$class" ]; then
    echo "󰣆 $class"
fi
