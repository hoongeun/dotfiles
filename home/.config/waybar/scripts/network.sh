#!/bin/bash

# Displays single active network with priority: Ethernet > WiFi > Modem

# Colors
COLOR_CONNECTED="#ffffff"
COLOR_DISCONNECTED="#444444"

# Icons (Nerd Font)
ICON_ETH_CONNECTED="󰈁"
ICON_ETH_DISCONNECTED="󰈂"
ICON_WIFI_FULL="󰤨"      # 100-80% (5칸)
ICON_WIFI_GOOD="󰤥"      # 79-60% (4칸)
ICON_WIFI_OK="󰤢"        # 59-40% (3칸)
ICON_WIFI_WEAK="󰤟"      # 39-20% (2칸)
ICON_WIFI_POOR="󰤜"      # 19-0% (1칸)
ICON_WIFI_DISCONNECTED="󰤮"
ICON_MODEM_CONNECTED="󰀂"
ICON_MODEM_DISCONNECTED="󰀂"

# Get WiFi icon based on signal strength (0-100)
get_wifi_icon() {
    local signal=$1
    if [ "$signal" -ge 80 ]; then
        echo "$ICON_WIFI_FULL"
    elif [ "$signal" -ge 60 ]; then
        echo "$ICON_WIFI_GOOD"
    elif [ "$signal" -ge 40 ]; then
        echo "$ICON_WIFI_OK"
    elif [ "$signal" -ge 20 ]; then
        echo "$ICON_WIFI_WEAK"
    else
        echo "$ICON_WIFI_POOR"
    fi
}

# Format output for Polybar
format_output() {
    local icon=$1
    local text=$2
    local color=$3
    echo "%{F${color}}${icon} ${text}%{F-}"
}

# Check for ethernet connection (priority 1)
check_ethernet() {
    local eth_connections=$(nmcli -t -f TYPE,STATE,CONNECTION device | grep "^ethernet:connected:")
    if [ -n "$eth_connections" ]; then
        local connection_name=$(echo "$eth_connections" | head -n1 | cut -d: -f3)
        if [ -z "$connection_name" ]; then
            connection_name="Wired"
        fi
        format_output "$ICON_ETH_CONNECTED" "$connection_name" "$COLOR_CONNECTED"
        return 0
    fi
    return 1
}

# Check for WiFi connection (priority 2)
check_wifi() {
    local wifi_device=$(nmcli -t -f DEVICE,TYPE,STATE device | grep ":wifi:connected$" | head -n1 | cut -d: -f1)

    if [ -n "$wifi_device" ]; then
        # Get SSID and signal strength
        local wifi_info=$(nmcli -t -f IN-USE,SIGNAL,SSID device wifi list | grep "^\*:")
        local signal=$(echo "$wifi_info" | cut -d: -f2)
        local ssid=$(echo "$wifi_info" | cut -d: -f3)

        if [ -z "$ssid" ]; then
            ssid="WiFi"
        fi

        if [ -z "$signal" ]; then
            signal=0
        fi

        local icon=$(get_wifi_icon "$signal")
        format_output "$icon" "$ssid" "$COLOR_CONNECTED"
        return 0
    fi
    return 1
}

# Check for modem/WWAN connection (priority 3)
check_modem() {
    local modem_connections=$(nmcli -t -f TYPE,STATE,CONNECTION device | grep -E "^(gsm|cdma):connected:")
    if [ -n "$modem_connections" ]; then
        local connection_name=$(echo "$modem_connections" | head -n1 | cut -d: -f3)
        if [ -z "$connection_name" ]; then
            connection_name="Modem"
        fi
        format_output "$ICON_MODEM_CONNECTED" "$connection_name" "$COLOR_CONNECTED"
        return 0
    fi
    return 1
}

# Show disconnected state
show_disconnected() {
    # Check what type of device is available but disconnected
    local wifi_device=$(nmcli -t -f DEVICE,TYPE device | grep ":wifi$" | head -n1)
    local eth_device=$(nmcli -t -f DEVICE,TYPE device | grep ":ethernet$" | head -n1)

    if [ -n "$wifi_device" ]; then
        format_output "$ICON_WIFI_DISCONNECTED" "disconnected" "$COLOR_DISCONNECTED"
    elif [ -n "$eth_device" ]; then
        format_output "$ICON_ETH_DISCONNECTED" "disconnected" "$COLOR_DISCONNECTED"
    else
        format_output "$ICON_MODEM_DISCONNECTED" "disconnected" "$COLOR_DISCONNECTED"
    fi
}

# Main logic - priority order
main() {
    # Check if NetworkManager is running
    if ! systemctl is-active --quiet NetworkManager; then
        echo "%{F#ff0000}󰱓 네트워크 오류%{F-}"
        exit 1
    fi

    # Priority: Ethernet > WiFi > Modem
    if check_ethernet; then
        exit 0
    elif check_wifi; then
        exit 0
    elif check_modem; then
        exit 0
    else
        show_disconnected
        exit 0
    fi
}

main
