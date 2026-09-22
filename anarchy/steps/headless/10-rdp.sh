#!/usr/bin/env bash
# RDP server: hypr-rdp, one virtual monitor per remote screen.
#
# Hyprland's portal has no RemoteDesktop interface, so krdp and
# gnome-remote-desktop can't drive it, and xrdp only serves X11. hypr-rdp talks
# to Hyprland directly: wlr-screencopy for video, virtual pointer/keyboard for
# input. It serves a single output per process, so anarchy-rdp creates one
# headless output per monitor and runs one server for each.

step "RDP server (multi-monitor)"
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
