#!/usr/bin/env bash
# Web apps: standalone browser windows for sites you use like apps.
#
# launch-webapp is linked by the quickshell step; this step only checks that
# it has a browser to work with and repoints any legacy .desktop files.

step "Web apps"

APPS=$HOME/.local/share/applications

if ! [[ -d $APPS ]]; then
  skip "no $(tilde "$APPS")"
  return 0 2>/dev/null || exit 0
fi

# Migrate entries still pointing at omarchy's launcher.
migrated=0
while IFS= read -r -d '' f; do
  if grep -q 'Exec=omarchy-launch-webapp ' "$f"; then
    run sed -i 's|Exec=omarchy-launch-webapp |Exec=launch-webapp |' "$f"
    migrated=$((migrated + 1))
  fi
  if grep -q 'Exec=omarchy-webapp-handler-' "$f"; then
    run sed -i 's|Exec=omarchy-webapp-handler-|Exec=webapp-handler-|' "$f"
    migrated=$((migrated + 1))
  fi
done < <(find "$APPS" -maxdepth 1 -name '*.desktop' -print0)

if (( migrated )); then
  ok "repointed $migrated legacy launcher entries"
else
  skip "no legacy entries to migrate"
fi

# --app= is a Chromium flag; Firefox has no equivalent.
found=""
for c in brave brave-browser chromium google-chrome-stable google-chrome \
         microsoft-edge-stable vivaldi-stable opera helium; do
  if need_cmd "$c"; then found=$c; break; fi
done

if [[ -n $found ]]; then
  ok "web apps will open with $found"
else
  warn "no Chromium-family browser installed — web apps need one of:"
  warn "  brave, chromium, google-chrome, microsoft-edge, vivaldi, opera"
  warn "  (Firefox cannot do --app windows)"
fi
