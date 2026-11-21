#!/bin/sh
set -e

if [ "${1:-}" != "--install" ]; then
    if hyprpm reload && hyprctl plugin list | grep -q '^Plugin hy3 '; then
        hyprctl reload
        exit 0
    fi
    exec ghostty --title="hy3 setup" -e sh "$0" --install
fi

if ! hyprpm list | grep -q 'Plugin hy3'; then
    if ! printf 'y\n' | hyprpm add https://github.com/outfoxxed/hy3; then
        notify-send -u critical "hy3 설치 실패" "hyprpm 로그를 확인하세요."
        printf 'hy3 installation failed. Press Enter to close. '
        read -r _
        exit 1
    fi
fi
if ! hyprpm enable hy3 || ! hyprpm reload -n; then
    notify-send -u critical "hy3 활성화 실패" "hyprpm 로그를 확인하세요."
    printf 'hy3 activation failed. Press Enter to close. '
    read -r _
    exit 1
fi
hyprctl reload
