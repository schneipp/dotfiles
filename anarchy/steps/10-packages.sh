#!/usr/bin/env bash
# Packages: the compositor shell, launcher and everything the bar widgets need.

step "Packages ($DISTRO)"
require_supported

if [[ $DISTRO == arch ]]; then

  # Desktop shell (DankMaterialShell) — pulls in quickshell + qt6-wayland.
  pkg_install dms-shell-hyprland

  # Terminals: foot is the default; kitty stays for its graphics protocol.
  pkg_install foot kitty

  # The font foot and kitty are configured for. Without it both silently fall
  # back to Noto Sans Mono, and the Nerd Font icons in fastfetch, the launcher
  # and the bar come from whatever fallback happens to have them.
  pkg_install ttf-jetbrains-mono-nerd

  # Bar widgets and DMS optional deps: media keys, brightness, visualiser,
  # wallpaper theming, network and power-profile control, sound effects.
  pkg_install playerctl brightnessctl cava matugen networkmanager \
              power-profiles-daemon qt6-multimedia qt6ct

  # The KDE Qt platform theme: lets Dolphin and other Qt/KDE apps follow the
  # light/dark switch (QT_QPA_PLATFORMTHEME=kde in custom.lua).
  pkg_install plasma-integration

  # Capture: region select, screenshot, clipboard, recording, annotation.
  pkg_install grim slurp wl-clipboard hyprpicker jq libnotify ffmpeg fastfetch
  pkg_install gpu-screen-recorder satty

  # AUR helpers — the launcher's install flow offers an AUR source when present.
  pkg_install paru yay

  # Optional but referenced by the shell aliases.
  pkg_install eza fzf zoxide starship bat

else  # fedora

  # Fedora ships none of Hyprland, and an older quickshell than DMS wants.
  # These COPRs carry current builds:
  #   sdegler/hyprland       Hyprland 0.56+, hyprpicker, satty, the portal
  #   avengemedia/dms        DankMaterialShell
  #   avengemedia/danklinux  quickshell and matugen, at the versions DMS needs
  #   brycensranch/gpu-screen-recorder-git   the recorder behind Capture
  copr_enable sdegler/hyprland
  copr_enable avengemedia/dms
  copr_enable avengemedia/danklinux
  copr_enable brycensranch/gpu-screen-recorder-git

  pkg_install hyprland xdg-desktop-portal-hyprland
  pkg_install dms quickshell

  pkg_install foot kitty

  pkg_install playerctl brightnessctl cava matugen NetworkManager \
              power-profiles-daemon qt6-qtmultimedia qt6ct

  pkg_install plasma-integration plasma-workspace

  # ffmpeg-free is Fedora's build; RPM Fusion's full ffmpeg replaces it fine.
  pkg_install grim slurp wl-clipboard hyprpicker jq libnotify fastfetch
  pkg_install_any ffmpeg-free ffmpeg
  pkg_install gpu-screen-recorder satty

  # Flathub is where Fedora users get most desktop apps; the launcher's
  # install flow searches it next to dnf.
  pkg_install flatpak
  if (( ! DRY_RUN )) && ! flatpak remotes --columns=name 2>/dev/null | grep -qx flathub; then
    flatpak remote-add --user --if-not-exists flathub \
      https://dl.flathub.org/repo/flathub.flatpakrepo && ok "Flathub added (user)"
  fi

  # starship is not in Fedora; the prompt falls back to plain bash without it.
  pkg_install eza fzf zoxide bat

  # No Fedora package has the Nerd Font variant. Fetch the upstream release.
  install_nerd_font
fi

ok "packages done"
