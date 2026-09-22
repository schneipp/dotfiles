#!/usr/bin/env bash
# RDP server: hypr-rdp, with a resizable screen or several fixed monitors.
#
# Hyprland's portal has no RemoteDesktop interface, so krdp and
# gnome-remote-desktop can't drive it, and xrdp only serves X11. hypr-rdp talks
# to Hyprland directly: wlr-screencopy for video, virtual pointer/keyboard for
# input. anarchy-rdp runs it: one server for a screen that follows the client
# window, or one per monitor for a fixed multi-monitor desk.

step "RDP server"
require_supported

HYPR_RDP_VERSION=0.1.6
HYPR_RDP_SHA256=f6f52a4683c6a6aae7543a13dbe445e7494e4e77a0e2e794a644740827ed304a

if [[ $DISTRO == arch ]]; then
  aur_install hypr-rdp
elif need_cmd hypr-rdp; then
  skip "hypr-rdp already installed ($(hypr-rdp --version 2>/dev/null))"
else
  # Not packaged for Fedora: the upstream release binary, pinned by checksum,
  # plus the libraries it links against and pactl for audio.
  pkg_install libva pipewire-libs libxkbcommon mesa-libgbm fuse3 pulseaudio-utils
  if (( DRY_RUN )); then
    info "would install hypr-rdp $HYPR_RDP_VERSION to /usr/local/bin"
  else
    tmp=$(mktemp -d)
    url=https://github.com/MuNeNICK/hypr-rdp/releases/download/v$HYPR_RDP_VERSION/hypr-rdp-v$HYPR_RDP_VERSION-x86_64-linux.tar.gz
    if curl -fsSL "$url" -o "$tmp/hypr-rdp.tgz" &&
       echo "$HYPR_RDP_SHA256  $tmp/hypr-rdp.tgz" | sha256sum -c --quiet; then
      tar --no-same-owner -xzf "$tmp/hypr-rdp.tgz" -C "$tmp"
      sudo install -Dm755 "$tmp/hypr-rdp" /usr/local/bin/hypr-rdp
      ok "hypr-rdp $HYPR_RDP_VERSION -> /usr/local/bin"
    else
      rm -rf "$tmp"
      die "could not fetch hypr-rdp $HYPR_RDP_VERSION (download or checksum failed)"
    fi
    rm -rf "$tmp"
  fi
fi

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

# set_conf <KEY> <value> — replace the line, or add it to a config written
# before the key existed.
set_conf() {
  (( DRY_RUN )) && { info "would set $1=$2 in $(tilde "$RDP_CONF")"; return 0; }
  if grep -q "^$1=" "$RDP_CONF"; then
    sed -i "s|^$1=.*|$1=$2|" "$RDP_CONF"
  else
    printf '\n%s=%s\n' "$1" "$2" >>"$RDP_CONF"
  fi
}

# Mode: --monitors means fixed; --dynamic, or a config from before modes
# existed, means dynamic.
if [[ -n ${RDP_MODE:-} ]]; then
  set_conf MODE "$RDP_MODE"
  ok "mode: $RDP_MODE"
elif [[ -f $RDP_CONF ]] && ! grep -q '^MODE=' "$RDP_CONF"; then
  set_conf MODE dynamic
  ok "mode: dynamic"
fi

# ------------------------------------------------------------------- ports
#
# Every user on the machine runs their own servers, so each needs ports of
# their own. /etc/anarchy/rdp-ports records who has which block of ten (a
# fixed-mode desk uses one per monitor): "user port" per line.

PORTS_DB=/etc/anarchy/rdp-ports
my_port=$(awk -v u="$USER" '$1 == u { print $2 }' "$PORTS_DB" 2>/dev/null)
if [[ -n $my_port ]]; then
  skip "port $my_port is registered for $USER"
else
  taken=" $(awk '{ print $2 }' "$PORTS_DB" 2>/dev/null | tr '\n' ' ') "
  # A user who set up RDP before the registry keeps the port they had,
  # unless someone else has claimed it since.
  had=$(sed -n 's/^PORT=\([0-9]*\).*/\1/p' "$RDP_CONF" 2>/dev/null)
  if [[ -n $had && $taken != *" $had "* ]]; then
    my_port=$had
  else
    my_port=3389
    while [[ $taken == *" $my_port "* ]]; do my_port=$((my_port + 10)); done
  fi
  if (( DRY_RUN )); then
    info "would register port $my_port for $USER in $PORTS_DB"
  else
    sudo install -d -m 755 "$(dirname "$PORTS_DB")"
    printf '%s %s\n' "$USER" "$my_port" | sudo tee -a "$PORTS_DB" >/dev/null
    sudo chmod 644 "$PORTS_DB"
    ok "port $my_port registered for $USER"
  fi
fi
[[ -f $RDP_CONF ]] && ! grep -q "^PORT=$my_port\$" "$RDP_CONF" && set_conf PORT "$my_port"

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
last=$first
[[ ${MODE:-dynamic} == fixed ]] && last=$(( first + ${#MONITORS[@]} - 1 ))
ports=$first; (( last > first )) && ports=$first-$last

if systemctl is-active -q ufw 2>/dev/null; then
  run sudo ufw allow "${ports/-/:}/tcp" comment anarchy-rdp
  ok "ufw: opened $ports/tcp"
elif systemctl is-active -q firewalld 2>/dev/null; then
  run sudo firewall-cmd --permanent --add-port="$ports/tcp"
  run sudo firewall-cmd --reload
  ok "firewalld: opened $ports/tcp"
else
  skip "no active firewall (port $ports/tcp)"
fi

# ------------------------------------------------------------------- start

if (( DRY_RUN )); then
  :
elif [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]]; then
  "$HOME/.local/bin/anarchy-rdp" restart >/dev/null && ok "RDP running on port $ports"
else
  info "RDP starts with the next Hyprland session"
fi
