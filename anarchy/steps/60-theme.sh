#!/usr/bin/env bash
# Dark theme for Qt/KDE apps.
#
# DankMaterialShell exports a palette for GTK/Qt apps based on a light/dark
# flag in its session state. If that flag says light, apps like Dolphin open
# with a white palette while the shell itself stays dark. Force dark, then
# apply the KDE colour scheme DMS generates so KDE apps follow too.

step "Dark theme for Qt/KDE apps"

SESSION=$HOME/.local/state/DankMaterialShell/session.json

if [[ -f $SESSION ]]; then
  # DMS omits isLightMode entirely when it's dark, so "missing" also means dark.
  is_light=$(python3 - "$SESSION" <<'PY'
import json, sys
try:
    d = json.load(open(sys.argv[1]))
except Exception:
    d = {}
print("1" if d.get("isLightMode") else "0")
PY
)
  if [[ $is_light == "0" ]]; then
    skip "DMS already in dark mode"
  else
    info "setting DMS to dark mode"
    if (( ! DRY_RUN )); then
      cp "$SESSION" "$SESSION.pre-anarchy.$STAMP"
      # DMS rewrites this file on exit, so stop it before editing.
      need_cmd dms && dms kill >/dev/null 2>&1 || true
      sleep 1
      python3 - "$SESSION" <<'PY'
import json, sys
p = sys.argv[1]
d = json.load(open(p))
d["isLightMode"] = False
json.dump(d, open(p, "w"), indent=2)
PY
      ok "isLightMode -> false"
      if [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]] && need_cmd dms; then
        setsid nohup dms run >/dev/null 2>&1 </dev/null &
        sleep 5
        ok "DMS restarted"
      fi
    fi
  fi
else
  skip "DMS session state not found — run DMS once first"
fi

# KDE apps read ~/.config/kdeglobals, which DMS does not write directly.
if need_cmd plasma-apply-colorscheme; then
  if [[ -f $HOME/.local/share/color-schemes/DankMatugenDark.colors ]]; then
    if grep -q '^ColorScheme=DankMatugenDark' "$HOME/.config/kdeglobals" 2>/dev/null; then
      skip "kdeglobals already on DankMatugenDark"
    else
      [[ -f $HOME/.config/kdeglobals ]] && \
        run cp "$HOME/.config/kdeglobals" "$HOME/.config/kdeglobals.pre-anarchy.$STAMP"
      run plasma-apply-colorscheme DankMatugenDark
    fi
  else
    skip "DankMatugenDark.colors not generated yet"
  fi
else
  warn "plasma-apply-colorscheme not found (package: plasma-workspace) — KDE apps may stay light"
fi

# ------------------------------------------------------------- propagation
#
# DMS templates a fixed set of apps and stops there. anarchy-theme-apply picks
# up the rest — the KDE colour scheme, foot's palette, a GTK nudge — and
# reloads what is running. The path unit runs it on every theme change, which
# is what makes a theme switch reach everything the way Omarchy's did.

link bin/anarchy-theme-apply "$HOME/.local/bin/anarchy-theme-apply"
link bin/anarchy-logo-ansi   "$HOME/.local/bin/anarchy-logo-ansi"

link config/systemd/anarchy-theme.service "$HOME/.config/systemd/user/anarchy-theme.service"
link config/systemd/anarchy-theme.path    "$HOME/.config/systemd/user/anarchy-theme.path"

if (( ! DRY_RUN )); then
  systemctl --user daemon-reload
  if systemctl --user enable --now anarchy-theme.path >/dev/null 2>&1; then
    ok "theme changes now propagate automatically"
  else
    warn "could not enable anarchy-theme.path"
  fi
  "$HOME/.local/bin/anarchy-theme-apply" --quiet && ok "current theme pushed out"
fi

# Colour schemes shipped with anarchy. Point DMS at one with:
#   dms ipc call settings set customThemeFile ~/dotfiles/anarchy/themes/osaka-jade.json
#   dms ipc call settings set currentThemeName custom
info "themes available: $(cd "$ANARCHY_DIR/themes" && ls *.json | sed 's/\.json//' | paste -sd' ')"
