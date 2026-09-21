#!/usr/bin/env bash
# foot: the default terminal, themed and with font-size keys.

step "foot"

if ! need_cmd foot; then
  skip "foot not installed — run the packages step"
  return 0 2>/dev/null || exit 0
fi

# The colour file must exist before foot.ini is linked: foot treats a dangling
# include as a hard error and refuses to start at all.
if [[ ! -s $HOME/.config/foot/dank-colors.ini ]]; then
  run mkdir -p "$HOME/.config/foot"
  if (( ! DRY_RUN )); then
    printf '# Written by anarchy-theme-apply on the next theme change.\n' \
      > "$HOME/.config/foot/dank-colors.ini"
  fi
  ok "placeholder colour file created"
fi

link config/foot/foot.ini "$HOME/.config/foot/foot.ini"

if (( ! DRY_RUN )) && ! foot --check-config >/dev/null 2>&1; then
  warn "foot rejected the config:"
  foot --check-config 2>&1 | head -3
fi

# Anything going through xdg-terminal-exec should land on foot too.
link config/xdg-terminals.list "$HOME/.config/xdg-terminals.list"

ok "Ctrl+Up / Ctrl+Down change the font size"
