#!/usr/bin/env bash
# Session: a Hyprland of your own at boot, with no seat, no login and no sleep.
#
# A normal Hyprland takes the machine's one seat, and a second user's is paused
# while the first is in front. Here Hyprland runs as a systemd user service
# instead (anarchy-hyprland-headless): libseat's noop backend opens the GPU
# directly, so every user who runs this installer gets their own desktop,
# running side by side. Lingering starts it at boot without anyone logging in.
# A sleeping machine drops every connection, so the sleep targets are masked.

step "Headless session"

if (( NO_SESSION )); then
  skip "session setup skipped (--no-session)"
  return 0
fi

link bin/anarchy-hyprland-headless "$HOME/.local/bin/anarchy-hyprland-headless"
# Session settings you may want to change: the modifier, the GPU.
copy config/rdp/headless.env "$HOME/.config/anarchy/headless.env"
link config/systemd/anarchy-hyprland.service "$HOME/.config/systemd/user/anarchy-hyprland.service"

# ---------------------------------------------------------------------- gpu
#
# The card node needs read/write. On a seat, logind grants that to whoever is
# in front; without one it comes from the video group.

if ! ls /dev/dri/card[0-9]* >/dev/null 2>&1; then
  # No GPU at all (a bare VM): vkms is a virtual one, and Mesa renders on the CPU.
  warn "no GPU device found — loading vkms, a virtual one (rendering on the CPU)"
  if (( ! DRY_RUN )); then
    echo vkms | sudo tee /etc/modules-load.d/anarchy-vkms.conf >/dev/null
    sudo modprobe vkms || warn "could not load vkms"
  fi
fi

if id -nG "$USER" | tr ' ' '\n' | grep -qx video; then
  skip "$USER is in the video group"
  gpu_ready=1
else
  run sudo usermod -aG video "$USER"
  ok "$USER added to the video group"
  gpu_ready=0
fi

# ---------------------------------------------------------------- lingering

if [[ $(loginctl show-user "$USER" -p Linger --value 2>/dev/null) == yes ]]; then
  skip "lingering already on for $USER"
else
  run sudo loginctl enable-linger "$USER"
  ok "lingering on: $USER's services start at boot"
fi

if (( ! DRY_RUN )); then
  systemctl --user daemon-reload
  systemctl --user enable anarchy-hyprland.service >/dev/null 2>&1 &&
    ok "anarchy-hyprland enabled"
fi

# --------------------------------------------------------------- autologin
#
# An earlier version of this installer logged one user into a seat Hyprland
# with greetd. That instance would compete with the service for the RDP port,
# so drop the autologin and leave greetd as a plain text login.

GREETD_CONF=/etc/greetd/config.toml
if [[ -f $GREETD_CONF ]] && grep -q 'Written by anarchy' "$GREETD_CONF" &&
   grep -q '^\[initial_session\]' "$GREETD_CONF"; then
  if (( DRY_RUN )); then
    info "would remove the greetd autologin from $GREETD_CONF"
  else
    sudo cp "$GREETD_CONF" "$GREETD_CONF.pre-anarchy.$STAMP"
    sudo sed -i '/^# Once per boot/,/^user = /d' "$GREETD_CONF"
    ok "greetd autologin removed (the service starts Hyprland now)"
  fi
fi

# -------------------------------------------------------------------- sleep

sleep_targets=(sleep.target suspend.target hibernate.target hybrid-sleep.target)
if [[ $(systemctl is-enabled suspend.target 2>/dev/null) == masked ]]; then
  skip "suspend already masked"
elif (( DRY_RUN )); then
  info "would mask ${sleep_targets[*]}"
elif confirm "Never suspend or hibernate (recommended for a server)?"; then
  sudo systemctl mask "${sleep_targets[@]}" >/dev/null 2>&1 && ok "suspend and hibernate disabled"
else
  warn "suspend left on: an idle timeout will cut RDP off"
fi

# -------------------------------------------------------------------- start
#
# A new group only reaches processes started after it, and the user manager
# that runs the service predates it. Start now only when nothing is in the way.

SESSION_STARTED=0
if (( DRY_RUN )); then
  :
elif pgrep -u "$USER" -x Hyprland >/dev/null && ! systemctl --user -q is-active anarchy-hyprland; then
  info "a Hyprland of yours is already running (a seat login): the service takes over at the next boot"
elif (( gpu_ready )); then
  systemctl --user restart anarchy-hyprland && SESSION_STARTED=1 && ok "headless Hyprland started"
else
  info "the video group applies from the next boot (or: sudo systemctl restart user@$(id -u))"
fi
