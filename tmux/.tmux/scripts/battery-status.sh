#!/bin/bash
# Outputs battery icon + percentage for the tmux status bar, or nothing on
# machines with no battery (e.g. desktops). Colors/separator are applied in
# tmux.conf via #{?#{@battery_has_content},...} and #{?#{@battery_critical},...}
# following the same pattern as env-status.sh.

bat=$(find /sys/class/power_supply -maxdepth 1 -name 'BAT*' -print -quit 2>/dev/null)

if [ -z "$bat" ] || [ ! -r "$bat/capacity" ]; then
    tmux set-option -g @battery_has_content ""
    exit
fi

capacity=$(cat "$bat/capacity" 2>/dev/null)
status=$(cat "$bat/status" 2>/dev/null)

if [ "$status" = "Charging" ]; then
    icon="󰂄"
elif [ "$capacity" -ge 95 ]; then
    icon="󰁹"
elif [ "$capacity" -ge 90 ]; then
    icon="󰂂"
elif [ "$capacity" -ge 80 ]; then
    icon="󰂁"
elif [ "$capacity" -ge 70 ]; then
    icon="󰂀"
elif [ "$capacity" -ge 60 ]; then
    icon="󰁿"
elif [ "$capacity" -ge 50 ]; then
    icon="󰁾"
elif [ "$capacity" -ge 40 ]; then
    icon="󰁽"
elif [ "$capacity" -ge 30 ]; then
    icon="󰁼"
elif [ "$capacity" -ge 20 ]; then
    icon="󰁻"
else
    icon="󰂃"
fi

if [ "$status" != "Charging" ] && [ "$capacity" -le 20 ]; then
    tmux set-option -g @battery_critical "1"
else
    tmux set-option -g @battery_critical ""
fi

tmux set-option -g @battery_has_content "1"
echo "${icon} ${capacity}%"
