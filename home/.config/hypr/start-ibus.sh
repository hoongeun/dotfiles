#!/bin/sh
set -e

gsettings set org.freedesktop.ibus.general preload-engines "['hangul']"
gsettings set org.freedesktop.ibus.general engines-order "['xkb:us::eng', 'hangul']"
gsettings set org.freedesktop.ibus.general use-global-engine true
gsettings set org.freedesktop.ibus.general.hotkey triggers '[]'
gsettings set org.freedesktop.ibus.engine.hangul switch-keys 'Shift+space'
gsettings set org.freedesktop.ibus.engine.hangul initial-input-mode 'hangul'
ibus-daemon -dr

for attempt in 1 2 3 4 5; do
    ibus engine hangul && exit 0
    sleep 1
done
exit 1
