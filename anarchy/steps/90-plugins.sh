#!/usr/bin/env bash
# DankMaterialShell plugins bundled with anarchy.

step "Shell plugins"

PLUGINS=$HOME/.config/DankMaterialShell/plugins

if [[ ! -d $(dirname "$PLUGINS") ]]; then
  skip "DankMaterialShell has not run yet — start it once, then re-run"
  return 0 2>/dev/null || exit 0
fi

# spotmarchy: Spotify + time-synced lyrics, ported from Omarchy's plugin API.
link plugins/spotmarchy "$PLUGINS/spotLyrics"

if need_cmd dms && [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]] && (( ! DRY_RUN )); then
  dms ipc call plugins rescan >/dev/null 2>&1 || true
  if dms ipc call plugins enable spotLyrics 2>&1 | grep -q SUCCESS; then
    ok "spotLyrics enabled"
    info "add it to a bar section in Settings → Bar → Widgets"
  else
    warn "could not enable spotLyrics; check 'dms ipc call plugins status spotLyrics'"
  fi
else
  skip "not in a running session — enable with: dms ipc call plugins enable spotLyrics"
fi

command -v magick >/dev/null 2>&1 || \
  warn "imagemagick missing — the panel's album-cover backdrop stays plain"
