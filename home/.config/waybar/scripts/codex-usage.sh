#!/bin/bash

AUTH=~/.codex/auth.json
ACCESS_TOKEN=$(jq -r '.tokens.access_token' "$AUTH" 2>/dev/null)
ACCOUNT_ID=$(jq -r '.tokens.account_id' "$AUTH" 2>/dev/null)

if [ -z "$ACCESS_TOKEN" ] || [ "$ACCESS_TOKEN" == "null" ]; then
    echo ""
    exit 0
fi

CACHE_FILE="/tmp/codex-usage-cache.json"
CACHE_MAX_AGE=120

if [ -f "$CACHE_FILE" ]; then
    CACHE_AGE=$(( $(date +%s) - $(stat -c %Y "$CACHE_FILE") ))
    if [ "$CACHE_AGE" -lt "$CACHE_MAX_AGE" ]; then
        USAGE=$(cat "$CACHE_FILE")
    fi
fi

if [ -z "$USAGE" ]; then
    USAGE=$(timeout 5 curl -s \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "ChatGPT-Account-Id: $ACCOUNT_ID" \
        -H "User-Agent: codex-cli" \
        "https://chatgpt.com/backend-api/wham/usage" 2>/dev/null)

    # 토큰 만료 등으로 rate_limit이 없으면 이전 캐시 사용
    if ! echo "$USAGE" | jq -e '.rate_limit' >/dev/null 2>&1; then
        if [ -f "$CACHE_FILE" ]; then
            USAGE=$(cat "$CACHE_FILE")
        else
            echo "%{F#7A9DFF}󰆍%{F-} %{F#888888}Codex%{F-} %{F#666666}--%%{F-}"
            exit 0
        fi
    else
        echo "$USAGE" > "$CACHE_FILE"
    fi
fi

PCT=$(echo "$USAGE" | jq -r '.rate_limit.primary_window.used_percent // 0' | cut -d. -f1)
RESET_TS=$(echo "$USAGE" | jq -r '.rate_limit.primary_window.reset_at // empty')

# 주간 창이라 1일 이상이면 d/h로 표시
TIME_LEFT=""
if [ -n "$RESET_TS" ]; then
    REMAINING_SEC=$((RESET_TS - $(date +%s)))
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

if [ $PCT -lt 50 ]; then
    PCT_COLOR="#98c379"
elif [ $PCT -lt 80 ]; then
    PCT_COLOR="#e5c07b"
else
    PCT_COLOR="#e06c75"
fi

echo "%{F#7A9DFF}󰆍%{F-} %{F#888888}Codex%{F-}${TIME_LEFT} %{F${PCT_COLOR}}${PCT}%%{F-}"
