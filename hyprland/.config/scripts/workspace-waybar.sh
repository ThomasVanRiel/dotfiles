#!/bin/bash
# Hide waybar on workspace 2 (terminal), show on all others.
# SIGUSR1 toggles waybar visibility; a state file tracks whether it is hidden.

SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
STATE="/tmp/waybar-hidden"

# Clean up stale state from any previous session
rm -f "$STATE"

hide_waybar() {
    if [ ! -f "$STATE" ]; then
        pkill -SIGUSR1 waybar
        touch "$STATE"
    fi
}

show_waybar() {
    if [ -f "$STATE" ]; then
        pkill -SIGUSR1 waybar
        rm -f "$STATE"
    fi
}

socat -U - UNIX-CONNECT:"$SOCKET" | while read -r line; do
    if echo "$line" | grep -qE "^workspace>>"; then
        ws=$(echo "$line" | grep -oP 'workspace>>\K\d+')
        if [ "$ws" = "2" ]; then
            hide_waybar
        else
            show_waybar
        fi
    fi
done
