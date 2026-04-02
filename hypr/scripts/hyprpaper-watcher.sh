#!/usr/bin/env bash
# hyprpaper-daemon.sh - Listen to Hyprland workspace events and change wallpapers
set -euo pipefail

WALLPAPER_DIR="$HOME/Documents/Wallpaper"
CONF="$HOME/.config/hypr/hyprpaper.conf"
SOCKET="${XDG_RUNTIME_DIR}/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

# Ensure wallpaper directory exists
mkdir -p "$WALLPAPER_DIR"

# Function to change wallpaper for a workspace
change_wallpaper() {
    local workspace_id="$1"
    local wallpaper="${WALLPAPER_DIR}/${workspace_id}.png"
    
    # Check if wallpaper exists, fall back to default if not
    if [[ ! -f "$wallpaper" ]]; then
        wallpaper="${WALLPAPER_DIR}/default.png"
        if [[ ! -f "$wallpaper" ]]; then
            echo "Warning: No wallpaper found for workspace $workspace_id or default.png"
            return 1
        fi
    fi
    
    # Get monitor name (assumes single monitor; adjust if needed)
    local monitor=$(hyprctl monitors -j | jq -r '.[0].name')
    
    # Update config atomically to avoid corruption
    local temp_conf="${CONF}.tmp.$$"
    {
        grep -v "^wallpaper = " "$CONF" || true
        echo "wallpaper = ${monitor},${wallpaper}"
    } > "$temp_conf" && mv "$temp_conf" "$CONF"
    
    # Reload hyprpaper
    hyprctl hyprpaper reload "\"$CONF\"" 2>/dev/null || true
    echo "[$(date '+%H:%M:%S')] Changed workspace $workspace_id wallpaper to: $wallpaper"
}

# Check dependencies
command -v socat >/dev/null 2>&1 || { echo "Install socat (sudo apt install socat)"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "Install jq (sudo apt install jq)"; exit 1; }

# Verify socket exists
if [[ ! -S "$SOCKET" ]]; then
    echo "Error: Hyprland socket not found at $SOCKET"
    exit 1
fi

echo "Starting hyprpaper daemon..."
echo "Wallpapers directory: $WALLPAPER_DIR"
echo "Config file: $CONF"

# Listen to workspace change events
socat - "UNIX-CONNECT:$SOCKET" | while IFS= read -r event; do
    if [[ "$event" =~ ^workspace>> ]]; then
        # Extract workspace ID/name from event
        # Format: "workspace>>10" or "workspace>>work"
        workspace=$(echo "$event" | sed 's/^workspace>>//')
        
        # Extract numeric ID if it's a numbered workspace
        if [[ "$workspace" =~ ^[0-9]+ ]]; then
            workspace_id="$workspace"
        else
            # For named workspaces, you can map them or use the name
            workspace_id="$workspace"
        fi
        
        change_wallpaper "$workspace_id"
    fi
done
