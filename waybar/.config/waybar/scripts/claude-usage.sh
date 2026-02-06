#!/bin/bash
# Claude Code usage module for waybar

STATS_FILE="$HOME/.claude/stats-cache.json"
CURRENT_MONTH=$(date +%Y-%m)

# Check if Claude is running
if pgrep -x "claude" > /dev/null; then
    RUNNING=true
    ICON="󰚩"
else
    RUNNING=false
    ICON="󰚩"
fi

# Get billing period (current month) stats
if [[ -f "$STATS_FILE" ]]; then
    # Sum messages for current month
    MONTH_MESSAGES=$(jq -r --arg month "$CURRENT_MONTH" \
        '[.dailyActivity[] | select(.date | startswith($month)) | .messageCount] | add // 0' \
        "$STATS_FILE" 2>/dev/null)

    # Sum tokens for current month
    MONTH_TOKENS=$(jq -r --arg month "$CURRENT_MONTH" \
        '[.dailyModelTokens[] | select(.date | startswith($month)) | .tokensByModel | add] | add // 0' \
        "$STATS_FILE" 2>/dev/null)

    # Sum sessions for current month
    MONTH_SESSIONS=$(jq -r --arg month "$CURRENT_MONTH" \
        '[.dailyActivity[] | select(.date | startswith($month)) | .sessionCount] | add // 0' \
        "$STATS_FILE" 2>/dev/null)

    # Sum tool calls for current month
    MONTH_TOOLS=$(jq -r --arg month "$CURRENT_MONTH" \
        '[.dailyActivity[] | select(.date | startswith($month)) | .toolCallCount] | add // 0' \
        "$STATS_FILE" 2>/dev/null)

    # Default to 0 if empty
    MONTH_MESSAGES=${MONTH_MESSAGES:-0}
    MONTH_TOKENS=${MONTH_TOKENS:-0}
    MONTH_SESSIONS=${MONTH_SESSIONS:-0}
    MONTH_TOOLS=${MONTH_TOOLS:-0}
fi

# Format tokens for display (K for thousands)
if [[ "$MONTH_TOKENS" -ge 1000000 ]]; then
    TOKENS_DISPLAY=$(awk "BEGIN {printf \"%.1fM\", $MONTH_TOKENS/1000000}")
elif [[ "$MONTH_TOKENS" -ge 1000 ]]; then
    TOKENS_DISPLAY=$(awk "BEGIN {printf \"%.1fK\", $MONTH_TOKENS/1000}")
else
    TOKENS_DISPLAY="$MONTH_TOKENS"
fi

# Format output
if [[ "$RUNNING" == true ]]; then
    TEXT="$ICON  ${TOKENS_DISPLAY} tokens"
    CLASS="running"
else
    TEXT="$ICON"
    CLASS="idle"
fi

# Build tooltip
MONTH_NAME=$(date +%B)
TOOLTIP="Claude Code - $MONTH_NAME\n"
TOOLTIP+="─────────────────────\n"
if [[ "$RUNNING" == true ]]; then
    TOOLTIP+="Status: Active\n"
else
    TOOLTIP+="Status: Idle\n"
fi
TOOLTIP+="Messages: ${MONTH_MESSAGES}\n"
TOOLTIP+="Tokens: ${MONTH_TOKENS}\n"
TOOLTIP+="Sessions: ${MONTH_SESSIONS}\n"
TOOLTIP+="Tool calls: ${MONTH_TOOLS}"

# Output JSON for waybar
echo "{\"text\": \"$TEXT\", \"tooltip\": \"$TOOLTIP\", \"class\": \"$CLASS\"}"
