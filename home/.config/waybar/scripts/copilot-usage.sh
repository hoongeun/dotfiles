#!/bin/bash

CACHE_FILE="/tmp/copilot-usage-cache.json"
CACHE_MAX_AGE=120
ICON="%{F#C9A0FF}$(printf '\U000F02A4')%{F-}"

if [ -f "$CACHE_FILE" ]; then
    CACHE_AGE=$(( $(date +%s) - $(stat -c %Y "$CACHE_FILE") ))
    if [ "$CACHE_AGE" -lt "$CACHE_MAX_AGE" ]; then
        USAGE=$(cat "$CACHE_FILE")
    fi
fi

if [ -z "$USAGE" ]; then
    USAGE=$(timeout 5 gh api /copilot_internal/user 2>/dev/null)

    if ! echo "$USAGE" | jq -e '.quota_snapshots.premium_interactions' >/dev/null 2>&1; then
        if [ -f "$CACHE_FILE" ]; then
            USAGE=$(cat "$CACHE_FILE")
        else
            echo "$ICON %{F#888888}Copilot%{F-} %{F#666666}--%%{F-}"
            exit 0
        fi
    else
        echo "$USAGE" > "$CACHE_FILE"
    fi
fi

PCT=$(echo "$USAGE" | jq -r '100 - .quota_snapshots.premium_interactions.percent_remaining | floor')
RESET_DATE=$(echo "$USAGE" | jq -r '.quota_reset_date // empty')

TIME_LEFT=""
if [ -n "$RESET_DATE" ]; then
    REMAINING_SEC=$(( $(date -d "$RESET_DATE" +%s) - $(date +%s) ))
    if [ $REMAINING_SEC -gt 0 ]; then
        DAYS=$((REMAINING_SEC / 86400))
        HOURS=$(((REMAINING_SEC % 86400) / 3600))
        MINS=$(((REMAINING_SEC % 3600) / 60))
        if [ $DAYS -gt 0 ]; then
            TIME_LEFT=" ${DAYS}d${HOURS}h"
        else
            TIME_LEFT=" ${HOURS}h${MINS}m"
        fi
    fi
fi

if [ "$PCT" -lt 50 ]; then
    PCT_COLOR="#98c379"
elif [ "$PCT" -lt 80 ]; then
    PCT_COLOR="#e5c07b"
else
    PCT_COLOR="#e06c75"
fi

echo "$ICON %{F#888888}Copilot%{F-}${TIME_LEFT} %{F${PCT_COLOR}}${PCT}%%{F-}"
