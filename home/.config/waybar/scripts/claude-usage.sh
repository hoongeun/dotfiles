#!/bin/bash

# OAuth 토큰 가져오기
ACCESS_TOKEN=$(jq -r '.claudeAiOauth.accessToken' ~/.claude/.credentials.json 2>/dev/null)

if [ -z "$ACCESS_TOKEN" ] || [ "$ACCESS_TOKEN" == "null" ]; then
    echo ""
    exit 0
fi

# 캐시 파일
CACHE_FILE="/tmp/claude-usage-cache.json"
CACHE_MAX_AGE=120

# 캐시가 유효하면 재사용
if [ -f "$CACHE_FILE" ]; then
    CACHE_AGE=$(( $(date +%s) - $(stat -c %Y "$CACHE_FILE") ))
    if [ "$CACHE_AGE" -lt "$CACHE_MAX_AGE" ]; then
        USAGE=$(cat "$CACHE_FILE")
    fi
fi

# 캐시 미스 시 API 호출
if [ -z "$USAGE" ]; then
    USAGE=$(timeout 5 curl -s \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "anthropic-beta: oauth-2025-04-20" \
        "https://api.anthropic.com/api/oauth/usage" 2>/dev/null)

    # 에러 체크
    HAS_ERROR=$(echo "$USAGE" | jq -r '.error // empty' 2>/dev/null)
    if [ -z "$USAGE" ] || [ -n "$HAS_ERROR" ]; then
        # 에러 시 이전 캐시가 있으면 사용
        if [ -f "$CACHE_FILE" ]; then
            USAGE=$(cat "$CACHE_FILE")
        else
            echo "%{F#FF8C00}❋%{F-} %{F#888888}Claude%{F-} %{F#666666}--%%{F-}"
            exit 0
        fi
    else
        echo "$USAGE" > "$CACHE_FILE"
    fi
fi

# 주간 한도가 소진되면 주간 리셋을, 여유가 있으면 5시간 리셋을 표시
WINDOW=$(echo "$USAGE" | jq -c '
    if (.seven_day.utilization // 0) >= 100 or .five_hour == null then .seven_day
    else .five_hour
    end
')
PCT=$(echo "$WINDOW" | jq -r '.utilization // 0' | cut -d. -f1)
RESETS_AT=$(echo "$WINDOW" | jq -r '.resets_at')

# 남은 시간 계산
if [ "$RESETS_AT" != "null" ]; then
    RESET_TS=$(date -d "$RESETS_AT" +%s 2>/dev/null)
    NOW_TS=$(date +%s)
    REMAINING_SEC=$((RESET_TS - NOW_TS))

    if [ $REMAINING_SEC -gt 0 ]; then
        HOURS=$((REMAINING_SEC / 3600))
        if [ $HOURS -ge 24 ]; then
            DAYS=$((HOURS / 24))
            HOURS=$((HOURS % 24))
            TIME_LEFT=" ${DAYS}d${HOURS}h"
        else
            MINS=$(((REMAINING_SEC % 3600) / 60))
            TIME_LEFT=" ${HOURS}h${MINS}m"
        fi
    else
        TIME_LEFT=""
    fi
else
    TIME_LEFT=""
fi

# 퍼센트 색상 (값만)
if [ $PCT -lt 50 ]; then
    PCT_COLOR="#98c379"  # 초록
elif [ $PCT -lt 80 ]; then
    PCT_COLOR="#e5c07b"  # 노랑
else
    PCT_COLOR="#e06c75"  # 빨강
fi

# 출력: ❋ Claude 2h15m 30% (시간 먼저, 사용률 나중)
echo "%{F#FF8C00}❋%{F-} %{F#888888}Claude%{F-}${TIME_LEFT} %{F${PCT_COLOR}}${PCT}%%{F-}"
