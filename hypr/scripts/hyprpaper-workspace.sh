#!/usr/bin/env bash

# Per-workspace wallpaper switcher for a single monitor.
# Listens to Hyprland's event socket and swaps wallpapers on workspace change.

WALLPAPER_DIR="$HOME/Documents/Wallpaper"

# Map workspace number to wallpaper filename
declare -A WALLPAPERS=(
    [1]="373.png"
    [2]="374.png"
)

DEFAULT_WALLPAPER="$WALLPAPER_DIR/373.png"

# Wait for hyprpaper IPC to be ready
until hyprctl hyprpaper listloaded >/dev/null 2>&1; do
    sleep 0.5
done

# Preload all wallpapers
for ws in "${!WALLPAPERS[@]}"; do
    hyprctl hyprpaper preload "$WALLPAPER_DIR/${WALLPAPERS[$ws]}"
done

# Set wallpaper for the current workspace at startup
CURRENT_WS=$(hyprctl activeworkspace -j | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])")
STARTUP_WALL="${WALLPAPERS[$CURRENT_WS]:-}"
if [[ -n "$STARTUP_WALL" ]]; then
    hyprctl hyprpaper wallpaper ",$WALLPAPER_DIR/$STARTUP_WALL"
else
    hyprctl hyprpaper wallpaper ",$DEFAULT_WALLPAPER"
fi

# Listen for workspace change events
SOCK="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

socat -U - "UNIX-CONNECT:$SOCK" | while read -r line; do
    if [[ "$line" == workspace\>\>* ]]; then
        WS="${line#workspace>>}"
        WALL="${WALLPAPERS[$WS]:-}"
        if [[ -n "$WALL" ]]; then
            hyprctl hyprpaper wallpaper ",$WALLPAPER_DIR/$WALL"
        else
            hyprctl hyprpaper wallpaper ",$DEFAULT_WALLPAPER"
        fi
    fi
done
