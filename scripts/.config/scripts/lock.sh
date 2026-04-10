#!/bin/bash
# Pixelated lock screen wallpaper script
# Takes screenshot, pixelates it, sets it as the noctalia wallpaper, then locks

PIXELATED="/tmp/lockscreen.png"

# Take screenshot and pixelate in one step
grim - | magick - -scale 3% -scale 2000% "$PIXELATED"

# Set as wallpaper before locking
qs -c noctalia-shell ipc call wallpaper set "$PIXELATED" ""

# Lock
qs -c noctalia-shell ipc call lockScreen lock
