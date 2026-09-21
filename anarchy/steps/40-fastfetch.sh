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

# kitty-direct only draws in a terminal that speaks the kitty graphics
# protocol. Everywhere else fastfetch still prints the text panels.
case "${TERM:-}" in
  xterm-kitty|*kitty*) ok "kitty detected — the logo will render" ;;
  *) skip "logo needs a kitty-protocol terminal; text output works anywhere" ;;
esac
