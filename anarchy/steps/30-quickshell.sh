#!/usr/bin/env bash
# qsl — the Quickshell launcher, plus its package backend.
#
# Runs as a daemon and toggles over Quickshell IPC, so opening it is instant.
# Delete on an entry uninstalls the owning package; Ctrl+I opens the installer.

step "Quickshell launcher (qsl)"

link config/quickshell/launcher "$HOME/.config/quickshell/launcher"

for b in qsl-pkg qsl-capture qsl-wall launch-webapp webapp-handler-zoom webapp-handler-hey transcode; do
  link "bin/$b" "$HOME/.local/bin/$b"
done

if ! printf '%s' ":$PATH:" | grep -q ":$HOME/.local/bin:"; then
  warn "~/.local/bin is not on PATH — the launcher shells out to qsl-pkg by name."
fi

if need_cmd qs; then
  # Restart any running instance so it picks up the linked config.
  if qs -c launcher ipc call launcher close >/dev/null 2>&1; then
    skip "launcher already running"
  else
    if [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]] && (( ! DRY_RUN )); then
      setsid nohup qs -c launcher >/dev/null 2>&1 </dev/null &
      ok "launcher started"
    else
      skip "not in a Hyprland session — starts at next login"
    fi
  fi
else
  warn "quickshell (qs) not installed; run the packages step first"
fi
