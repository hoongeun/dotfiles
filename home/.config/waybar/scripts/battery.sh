#!/bin/bash

BATTERY="BAT0"
BAT_PATH="/sys/class/power_supply/$BATTERY"

# 배터리가 없으면 종료
if [ ! -d "$BAT_PATH" ]; then
    echo ""
    exit 0
fi

# 배터리 퍼센트
CAPACITY=$(cat "$BAT_PATH/capacity" 2>/dev/null || echo "0")

# 충전 상태
STATUS=$(cat "$BAT_PATH/status" 2>/dev/null || echo "Unknown")

# 퍼센트에 따른 색상
if [ "$STATUS" = "Charging" ]; then
    PCT_COLOR="#61afef"  # 파란색 (충전 중)
elif [ $CAPACITY -ge 80 ]; then
    PCT_COLOR="#98c379"  # 초록 (80% 이상)
elif [ $CAPACITY -ge 50 ]; then
    PCT_COLOR="#ffffff"  # 흰색 (50-80%)
elif [ $CAPACITY -ge 20 ]; then
    PCT_COLOR="#e5c07b"  # 노랑 (20-50%)
else
    PCT_COLOR="#e06c75"  # 빨강 (20% 미만)
fi

# 출력: BAT 85%
echo "%{F#888888}BAT%{F-} %{F${PCT_COLOR}}${CAPACITY}%%{F-}"
