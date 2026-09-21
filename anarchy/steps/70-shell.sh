#!/usr/bin/env bash
# Bash config: aliases, functions and shell setup.
#
# Originally Omarchy's default bash rc, lifted out and de-omarchy'd so it
# stands on its own. Keeps the eza/fzf/zoxide aliases, git shortcuts, the
# fns/ helpers, and mise + starship init.

step "Bash config"

link config/bash "$HOME/.config/bash"

ensure_line "$HOME/.bashrc" \
  '# Aliases, functions and shell setup (anarchy)
# Do not edit ~/.config/bash directly — override below this line instead.
source ~/.config/bash/rc' \
  '^\s*source\s+~/\.config/bash/rc'

# Sanity check: a login-ish bash must survive sourcing it.
if (( ! DRY_RUN )); then
  if bash -ic 'true' </dev/null >/dev/null 2>&1; then
    ok "interactive bash starts cleanly"
  else
    warn "interactive bash reported errors — check 'bash -i' output"
  fi
fi
