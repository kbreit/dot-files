#!/usr/bin/env bash

# Path to the wallpaper you're editing
CONF="$HOME/.config/hypr/hyprpaper.conf"

# Make sure required tools exist
command -v inotifywait >/dev/null 2>&1 || { echo "Install inotify-tools"; exit 1; }

# Watch the file for modifications
while inotifywait -e close_write "$CONF"; do
    # Tell hyprpaper to reload the wallpaper
    hyprctl hyprpaper reload ,\"$CONF\"
done

