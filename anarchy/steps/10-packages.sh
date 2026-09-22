#!/usr/bin/env bash
# Packages: the compositor shell, launcher and everything the bar widgets need.

step "Packages"
require_arch

# Desktop shell (DankMaterialShell) — pulls in quickshell + qt6-wayland.
pac_install dms-shell-hyprland

# Terminals: foot is the default; kitty stays for its graphics protocol.
pac_install foot kitty

# The font foot and kitty are configured for. Without it both silently fall
# back to Noto Sans Mono, and the Nerd Font icons in fastfetch, the launcher
# and the bar come from whatever fallback happens to have them.
pac_install ttf-jetbrains-mono-nerd

# Bar widgets and DMS optional deps: media keys, brightness, visualiser,
# wallpaper theming, network and power-profile control, sound effects.
pac_install playerctl brightnessctl cava matugen networkmanager \
            power-profiles-daemon qt6-multimedia qt6ct

# The KDE Qt platform theme: lets Dolphin and other Qt/KDE apps follow the
# light/dark switch (QT_QPA_PLATFORMTHEME=kde in custom.lua).
pac_install plasma-integration

# Capture: region select, screenshot, clipboard, recording, annotation.
pac_install grim slurp wl-clipboard hyprpicker jq libnotify ffmpeg fastfetch
pac_install gpu-screen-recorder satty

# AUR helpers — the launcher's install flow offers an AUR source when present.
pac_install paru yay

# Optional but referenced by the shell aliases.
pac_install eza fzf zoxide starship bat

ok "packages done"
