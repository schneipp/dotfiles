#!/usr/bin/env bash
# Hyprland profile switcher
# Detects the current machine profile and updates symlinks

HYPR_DIR="$HOME/.config/hypr"
PROFILES_DIR="$HYPR_DIR/profiles"
PROFILE=""

# Detect profile by checking for marker files in home directory
for marker in "$HOME"/.*; do
    if [[ -f "$marker" ]]; then
        filename=$(basename "$marker")
        # Check if it's a profile marker (starts with dot and has no extension)
        if [[ "$filename" =~ ^\.[a-z]+ ]] && [[ -d "$PROFILES_DIR/${filename#.}" ]]; then
            PROFILE="${filename#.}"
            break
        fi
    fi
done

# Fallback if no profile detected
if [[ -z "$PROFILE" ]]; then
    echo "No profile marker found in $HOME"
    exit 1
fi

echo "Detected profile: $PROFILE"

# Update symlinks
cd "$HYPR_DIR" || exit 1

for config in monitors.conf workspaces.conf; do
    target="profiles/$PROFILE/$config"

    # Check if the profile config exists
    if [[ ! -f "$target" ]]; then
        echo "Warning: $target does not exist, skipping..."
        continue
    fi

    # Remove old symlink/file if exists
    [[ -L "$config" || -f "$config" ]] && rm "$config"

    # Create new symlink
    ln -s "$target" "$config"
    echo "Linked $config -> $target"
done

echo "Profile switched to: $PROFILE"
