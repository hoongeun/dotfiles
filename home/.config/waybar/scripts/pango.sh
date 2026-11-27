#!/bin/bash
export PATH="$HOME/.local/bin:/home/linuxbrew/.linuxbrew/bin:$PATH"
# Run a polybar-style script, convert %{F#hex}..%{F-} to pango, emit waybar JSON.
out=$("$(dirname "$0")/$1" 2>/dev/null | head -1 | sed -e 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' \
  -e "s/%{F-}/<\/span>/g; s/%{F\(#[0-9a-fA-F]*\)}/<span foreground='\1'>/g; s/%%/%/g")
jq -nc --arg t "$out" '{text:$t}'
