#!/bin/bash
# Claude Code usage module for waybar

STATS_FILE="$HOMa/.claude/stats-cache.json"
TODAY=$(date +%Y-%m-%d)

# Check if Claude is running
if pgrep -x "claude" > /dev/null; then
    RUNNING=true
    ICON="󰚩"
else
    RUNNING=false
    ICON="󰚩"
fi

# Get today's stats
if [[ -f "$STATS_FILE" ]]; then
    TODAY_MESSAGES=$(jq -r --arg date "$TODAY" '.dailyActivity[] | select(.date == $date) | .messageCount // 0' "$STATS_FILE" 2>/dev/null)
    TODAY_TOKENS=$(jq -r --arg date "$TODAY" '.dailyModelTokens[] | select(.date == $date) | .tokensByModel | add // 0' "$STATS_FILE" 2>/dev/null)
    TOTAL_MESSAGES=$(jq -r '.totalMessages // 0' "$STATS_FILE" 2>/dev/null)
    TOTAL_SESSIONS=$(jq -r '.totalSessions // 0' "$STATS_FILE" 2>/dev/null)

    # Default to 0 if empty
    TODAY_MESSAGES=${TODAY_MESSAGES:-0}
    TODAY_TOKENS=${TODAY_TOKENS:-0}
fi

# Format output
if [[ "$RUNNING" == true ]]; then
    TEXT="$ICON  ${TODAY_MESSAGES:-0} msgs"
    CLASS="running"
else
    TEXT="$ICON"
    CLASS="idle"
fi

# Build tooltip
TOOLTIP="Claude Code Stats\n"
TOOLTIP+="─────────────────\n"
if [[ "$RUNNING" == true ]]; then
    TOOLTIP+="Status: Active\n"
else
    TOOLTIP+="Status: Idle\n"
fi
TOOLTIP+="Today: ${TODAY_MESSAGES:-0} messages, ${TODAY_TOKENS:-0} tokens\n"
TOOLTIP+="Total: ${TOTAL_MESSAGES:-0} messages, ${TOTAL_SESSIONS:-0} sessions"

# Output JSON for waybar
echo "{\"text\": \"$TEXT\", \"tooltip\": \"$TOOLTIP\", \"class\": \"$CLASS\"}"
