#!/bin/bash
# screenrecord.sh - Screen region recorder for Hyprland/Wayland
# Toggle: first invocation starts recording, second invocation stops it.
# Output: MP4 saved to ~/Videos with a timestamp filename.
# Dependencies: wf-recorder, slurp, notify-send

OUTPUT_DIR="$HOME/Videos"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="${OUTPUT_DIR}/recording_${TIMESTAMP}.mp4"
CODEC="libx264"      # software encoder; swap for h264_nvenc on NVIDIA
FRAMERATE="30"

# Toggle: stop if already recording
if pgrep -x wf-recorder > /dev/null; then
    pkill -SIGINT wf-recorder
    notify-send "Screen Recorder" "Recording stopped." --urgency=low
    exit 0
fi

# Region selection (Escape → empty string → exit cleanly)
REGION=$(slurp 2>/dev/null)
if [[ -z "$REGION" ]]; then
    notify-send "Screen Recorder" "Recording cancelled." --urgency=low
    exit 0
fi

mkdir -p "$OUTPUT_DIR"

notify-send "Screen Recorder" "Recording started. Run the script again to stop." --urgency=normal

wf-recorder \
    -g "$REGION" \
    -c "$CODEC" \
    -r "$FRAMERATE" \
    -f "$OUTPUT_FILE"

if [[ -f "$OUTPUT_FILE" ]]; then
    notify-send "Screen Recorder" "Saved: $OUTPUT_FILE" --urgency=normal
else
    notify-send "Screen Recorder" "Recording failed - no file written." --urgency=critical
fi
