#!/usr/bin/env bash
# Packages: the compositor shell, launcher and everything the bar widgets need.

step "Packages"
require_arch

# Desktop shell (DankMaterialShell) — pulls in quickshell + qt6-wayland.
pac_install dms-shell-hyprland

# The terminal the package and editor flows open in.
pac_install kitty

# Bar widgets and DMS optional deps: media keys, brightness, visualiser,
# wallpaper theming, network and power-profile control, sound effects.
pac_install playerctl brightnessctl cava matugen networkmanager \
            power-profiles-daemon qt6-multimedia qt6ct

# Capture: region select, screenshot, clipboard, recording, annotation.
pac_install grim slurp wl-clipboard hyprpicker jq libnotify ffmpeg fastfetch
pac_install gpu-screen-recorder satty

# AUR helpers — the launcher's install flow offers an AUR source when present.
pac_install paru yay

# Optional but referenced by the shell aliases.
pac_install eza fzf zoxide starship bat

ok "packages done"
