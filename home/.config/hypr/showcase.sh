#!/bin/sh
# Toggle a screenshot-friendly layout: float and cascade the windows on the
# active workspace, or tile them again on the second run.
set -eu

STATE="${XDG_RUNTIME_DIR:-/tmp}/hypr-showcase"

if [ -s "$STATE" ]; then
    cmds=""
    while read -r addr; do
        cmds="$cmds dispatch settiled address:$addr;"
    done < "$STATE"
    rm -f "$STATE"
    [ -n "$cmds" ] && hyprctl --batch "$cmds" >/dev/null
    exit 0
fi

monitor=$(hyprctl monitors -j | jq -c '.[] | select(.focused)')
workspace=$(printf '%s' "$monitor" | jq '.activeWorkspace.id')
addrs=$(hyprctl clients -j | jq -r --argjson ws "$workspace" \
    '[.[] | select(.workspace.id == $ws and .floating == false)] | sort_by(.at[0], .at[1]) | .[].address')
[ -n "$addrs" ] || exit 0

count=$(printf '%s\n' "$addrs" | wc -l)
geom=$(printf '%s' "$monitor" | jq -r '
    (.width / .scale | floor) as $w | (.height / .scale | floor) as $h
    | "\(.x + .reserved[0]) \(.y + .reserved[1]) \($w - .reserved[0] - .reserved[2]) \($h - .reserved[1] - .reserved[3])"')
set -- $geom
mx=$1 my=$2 mw=$3 mh=$4

# Each window takes ~55% x 60% of the screen; the stack is centered.
ww=$((mw * 55 / 100))
wh=$((mh * 60 / 100))
step_x=$((mw * 12 / 100))
step_y=$((mh * 10 / 100))
if [ "$count" -gt 1 ]; then
    max_x=$(((mw - ww) / (count - 1)))
    max_y=$(((mh - wh) / (count - 1)))
    [ "$step_x" -le "$max_x" ] || step_x=$max_x
    [ "$step_y" -le "$max_y" ] || step_y=$max_y
fi
start_x=$((mx + (mw - ww - step_x * (count - 1)) / 2))
start_y=$((my + (mh - wh - step_y * (count - 1)) / 2))

cmds=""
i=0
for addr in $addrs; do
    x=$((start_x + step_x * i))
    y=$((start_y + step_y * i))
    cmds="$cmds dispatch setfloating address:$addr;"
    cmds="$cmds dispatch resizewindowpixel exact $ww $wh,address:$addr;"
    cmds="$cmds dispatch movewindowpixel exact $x $y,address:$addr;"
    cmds="$cmds dispatch alterzorder top,address:$addr;"
    i=$((i + 1))
done
printf '%s\n' "$addrs" > "$STATE"
hyprctl --batch "$cmds" >/dev/null
