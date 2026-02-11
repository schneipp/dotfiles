#!/bin/bash
# Toggle game mode - enables only DP-2, disables other monitors

STATE_FILE="/tmp/hypr-gamemode-active"
MONITORS_CONF="$HOME/.config/hypr/monitors.conf"

if [ -f "$STATE_FILE" ]; then
    # Game mode is active, restore normal configuration from monitors.conf
    while IFS= read -r line; do
        if [[ "$line" =~ ^monitor=(.+)$ ]]; then
            hyprctl keyword monitor "${BASH_REMATCH[1]}"
        fi
    done < "$MONITORS_CONF"
    rm "$STATE_FILE"
    notify-send "Game Mode" "Disabled - All monitors restored"
else
    # Enable game mode - only DP-2 active
    # Disable all monitors except DP-2
    while IFS= read -r line; do
        if [[ "$line" =~ ^monitor=([^,]+), ]]; then
            monitor_name="${BASH_REMATCH[1]}"
            if [ "$monitor_name" != "DP-2" ]; then
                hyprctl keyword monitor "$monitor_name,disable"
            else
                # Extract resolution and scale from DP-2 line, reposition to 0x0
                if [[ "$line" =~ ^monitor=DP-2,([^,]+),([^,]+),(.+)$ ]]; then
                    resolution="${BASH_REMATCH[1]}"
                    scale="${BASH_REMATCH[3]}"
                    hyprctl keyword monitor "DP-2,$resolution,0x0,$scale"
                fi
            fi
        fi
    done < "$MONITORS_CONF"
    touch "$STATE_FILE"
    notify-send "Game Mode" "Enabled - DP-2 only"
fi
