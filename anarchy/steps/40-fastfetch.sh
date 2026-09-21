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
link config/fastfetch/anarchy.txt  "$HOME/.config/fastfetch/anarchy.txt"

# The logo is braille text art in 24-bit colour (see bin/anarchy-logo-braille),
# so it renders in any terminal with truecolour and a braille-capable font —
# foot, kitty, a TTY emulator, over SSH. No image protocol needed.
ok "logo: braille text art, works in any truecolour terminal"
