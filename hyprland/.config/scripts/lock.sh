#!/bin/bash
# Pixelated lock screen script
# Takes screenshot, pixelates it, then locks with hyprlock

# Temp file for screenshot
TMPFILE="/tmp/lockscreen.png"

# Take screenshot
grim "$TMPFILE"

# Pixelate: scale down then back up (creates pixelation effect)
# Adjust the 10% value for more/less pixelation (lower = more pixelated)
magick "$TMPFILE" -scale 3% -scale 2000% "$TMPFILE"

# Lock with hyprlock (uses the image from hyprlock.conf)
hyprlock

# Cleanup
rm -f "$TMPFILE"
