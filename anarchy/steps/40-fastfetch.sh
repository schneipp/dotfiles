#!/usr/bin/env bash
# fastfetch: system summary with the anarchy logo.
#
# The logo is alpha-keyed so it blends with the terminal background rather
# than sitting in a black box. kitty-direct hands the file path to the
# terminal instead of streaming pixel data through the pipe.

step "fastfetch"

if ! need_cmd fastfetch; then
  skip "fastfetch not installed"
  return 0 2>/dev/null || exit 0
fi

link config/fastfetch/config.jsonc "$HOME/.config/fastfetch/config.jsonc"
link config/fastfetch/anarchy.png  "$HOME/.config/fastfetch/anarchy.png"

# The logo is sixel, which foot and kitty both render. Everywhere else
# fastfetch still prints the text panels.
case "${TERM:-}" in
  foot|xterm-kitty|*kitty*) ok "$TERM renders sixel — the logo will show" ;;
  *) skip "logo needs a sixel-capable terminal; text output works anywhere" ;;
esac
