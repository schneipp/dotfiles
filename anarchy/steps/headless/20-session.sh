#!/usr/bin/env bash
# Session: log straight into Hyprland at boot and never suspend.
#
# RDP serves a running Hyprland, and with no screen or keyboard attached
# nobody is there to log in. greetd's initial_session starts Hyprland for the
# user once per boot; after a logout it falls back to a text login on tty1.
# A sleeping machine drops every connection, so the sleep targets are masked.

step "Headless session"

if (( NO_AUTOLOGIN )); then
  skip "autologin and sleep settings skipped (--no-autologin)"
  return 0
fi

HYPR_CMD=Hyprland
need_cmd start-hyprland && HYPR_CMD=start-hyprland
# Through the login shell, so the session gets the PATH and environment a
# normal login would (~/.local/bin, where the anarchy scripts live).
LOGIN_SHELL=$(getent passwd "$USER" | cut -d: -f7)
LOGIN_SHELL=${LOGIN_SHELL:-/bin/bash}

# ---------------------------------------------------------------- autologin

pkg_install greetd

# The package's own greeter account: "greeter" on Arch, "greetd" on Fedora.
GREETER=greeter
getent passwd greeter >/dev/null || { getent passwd greetd >/dev/null && GREETER=greetd; }

GREETD_CONF=/etc/greetd/config.toml
greetd_conf=$(cat <<EOF
# Written by anarchy (installer-headless-rdp.sh).
[terminal]
vt = 1

# Once per boot: straight into Hyprland, so RDP has a desktop to serve.
[initial_session]
command = "$LOGIN_SHELL -lc $HYPR_CMD"
user = "$USER"

# After a logout: a text login on tty1.
[default_session]
command = "agreety --cmd '$LOGIN_SHELL -lc $HYPR_CMD'"
user = "$GREETER"
EOF
)

if [[ -f $GREETD_CONF ]] && grep -q "^user = \"$USER\"" "$GREETD_CONF" 2>/dev/null; then
  skip "greetd already logs $USER in"
elif (( DRY_RUN )); then
  info "would write $GREETD_CONF (autologin $USER -> $HYPR_CMD)"
else
  [[ -f $GREETD_CONF ]] && sudo cp "$GREETD_CONF" "$GREETD_CONF.pre-anarchy.$STAMP"
  printf '%s\n' "$greetd_conf" | sudo tee "$GREETD_CONF" >/dev/null
  ok "$GREETD_CONF: autologin $USER -> $HYPR_CMD"
fi

# Swap the display manager. Only the boot target changes: stopping the running
# one now would end the session this installer may be running in.
current_dm=$(basename "$(readlink -f /etc/systemd/system/display-manager.service 2>/dev/null)" 2>/dev/null)
if [[ $current_dm == greetd.service ]]; then
  skip "greetd is already the display manager"
elif (( DRY_RUN )); then
  info "would replace ${current_dm:-no display manager} with greetd"
elif [[ -z $current_dm || $current_dm == . ]] ||
     confirm "Replace ${current_dm%.service} with greetd autologin at boot?"; then
  [[ -n $current_dm && $current_dm != . ]] && sudo systemctl disable "$current_dm" >/dev/null 2>&1
  if sudo systemctl enable greetd.service >/dev/null 2>&1; then
    ok "greetd enabled — autologin from the next boot"
  else
    warn "could not enable greetd.service"
  fi
else
  warn "kept ${current_dm%.service}: RDP only works once someone logs into Hyprland on the machine"
  [[ -t 0 ]] || warn "(no terminal to ask on — rerun with --yes to switch to greetd)"
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
