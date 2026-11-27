#!/usr/bin/env bash
set -o pipefail

if ! state=$(timeout 3 /usr/bin/tailscale status --json 2>/dev/null | jq -er '.BackendState'); then
    printf '%%{F#ff0000}TS ERR%%{F-}\n'
    if [ "${1:-}" = toggle ]; then
        notify-send 'Tailscale' '상태를 확인할 수 없습니다.'
    fi
    exit 0
fi

if [ "${1:-}" = toggle ]; then
    exec 9>"${XDG_RUNTIME_DIR:?}/waybar-tailscale.lock"
    if ! flock -n 9; then
        exit 0
    fi

    case "$state" in
        Running) action=(down) ;;
        Stopped) action=(up) ;;
        *)
            notify-send 'Tailscale' "연결 상태를 확인해 주세요: $state"
            exit 0
            ;;
    esac

    if ! error=$(/usr/bin/gnome-terminal --wait --title=Tailscale -- sudo /usr/bin/tailscale "${action[@]}" 2>&1); then
        notify-send 'Tailscale 변경 실패' "${error:-연결 상태를 변경하지 못했습니다.}"
        exit 1
    fi
    exit 0
fi

case "$state" in
    Running) printf '%%{F#888888}TS%%{F-} ON\n' ;;
    Stopped) printf '%%{F#444444}TS OFF%%{F-}\n' ;;
    NeedsLogin) printf '%%{F#ff0000}TS LOGIN%%{F-}\n' ;;
    *) printf '%%{F#888888}TS %s%%{F-}\n' "$state" ;;
esac
