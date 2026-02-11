#!/bin/bash
WALLPAPER_DIR="$HOME/Pictures/wallpapers"

# Pick a random wallpaper
WALLPAPER=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' \) | shuf -n 1)

[ -z "$WALLPAPER" ] && exit 1

# Apply via hyprpaper IPC
hyprctl hyprpaper preload "$WALLPAPER"
hyprctl hyprpaper wallpaper ",$WALLPAPER"
hyprctl hyprpaper unload all
hyprctl hyprpaper preload "$WALLPAPER"
