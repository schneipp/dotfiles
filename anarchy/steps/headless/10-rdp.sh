#!/usr/bin/env bash
# RDP server: hypr-rdp, one virtual monitor per remote screen.
#
# Hyprland's portal has no RemoteDesktop interface, so krdp and
# gnome-remote-desktop can't drive it, and xrdp only serves X11. hypr-rdp talks
# to Hyprland directly: wlr-screencopy for video, virtual pointer/keyboard for
# input. It serves a single output per process, so anarchy-rdp creates one
# headless output per monitor and runs one server for each.

step "RDP server (multi-monitor)"
require_arch

aur_install hypr-rdp

link bin/anarchy-rdp "$HOME/.local/bin/anarchy-rdp"

# ------------------------------------------------------------------ config

RDP_CONF=$HOME/.config/anarchy/rdp.conf
copy config/rdp/rdp.conf "$RDP_CONF"

if [[ -n ${RDP_MONITORS:-} ]]; then
  for m in $RDP_MONITORS; do
    [[ $m =~ ^[0-9]+x[0-9]+$ ]] || die "--monitors: '$m' is not WxH"
  done
  if (( DRY_RUN )); then
    info "would set MONITORS=($RDP_MONITORS) in $(tilde "$RDP_CONF")"
  else
    sed -i "s/^MONITORS=.*/MONITORS=($RDP_MONITORS)/" "$RDP_CONF"
    ok "monitors: $RDP_MONITORS"
  fi
fi

HYPR_RDP_CONF=$HOME/.config/hypr-rdp/config.toml
if [[ -e $HYPR_RDP_CONF ]]; then
  skip "$(tilde "$HYPR_RDP_CONF") exists, left alone"
elif (( DRY_RUN )); then
  info "would write $(tilde "$HYPR_RDP_CONF")"
else
  mkdir -p "$(dirname "$HYPR_RDP_CONF")"
  sed -e "s|@USER@|$USER|" -e "s|@HOME@|$HOME|" \
      "$ANARCHY_DIR/config/rdp/hypr-rdp.toml" >"$HYPR_RDP_CONF"
  chmod 600 "$HYPR_RDP_CONF"
  ok "$(tilde "$HYPR_RDP_CONF") created (user: $USER)"
fi

if [[ -f $HOME/.config/hypr-rdp/password ]]; then
  skip "RDP password already set (change it: anarchy-rdp password)"
elif (( DRY_RUN )); then
  info "would ask for an RDP password"
else
  info "the RDP login is $USER plus a password of its own, not your Linux one"
  "$HOME/.local/bin/anarchy-rdp" password || die "an RDP password is required"
fi

# Start with the session. custom.lua requires rdp.lua when it exists.
link config/hypr/rdp.lua "$HOME/.config/hypr/rdp.lua"

# ---------------------------------------------------------------- firewall

# shellcheck disable=SC1090
if [[ -f $RDP_CONF ]]; then source "$RDP_CONF"; else source "$ANARCHY_DIR/config/rdp/rdp.conf"; fi
first=${PORT:-3389}
last=$(( first + ${#MONITORS[@]} - 1 ))

if systemctl is-active -q ufw 2>/dev/null; then
  run sudo ufw allow "$first:$last/tcp" comment anarchy-rdp
  ok "ufw: opened $first-$last/tcp"
elif systemctl is-active -q firewalld 2>/dev/null; then
  run sudo firewall-cmd --permanent --add-port="$first-$last/tcp"
  run sudo firewall-cmd --reload
  ok "firewalld: opened $first-$last/tcp"
else
  skip "no active firewall (ports $first-$last/tcp)"
fi

# ------------------------------------------------------------------- start

if (( DRY_RUN )); then
  :
elif [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]]; then
  "$HOME/.local/bin/anarchy-rdp" restart >/dev/null && ok "RDP running on ports $first-$last"
else
  info "RDP starts with the next Hyprland session"
fi
