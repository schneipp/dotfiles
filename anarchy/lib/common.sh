#!/usr/bin/env bash
# Shared helpers for the anarchy install steps.
# Sourced by install.sh; every step can rely on these.

ANARCHY_DIR=${ANARCHY_DIR:-"$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"}
DRY_RUN=${DRY_RUN:-0}
STAMP=$(date +%Y%m%d-%H%M%S)

# ------------------------------------------------------------------ output

if [[ -t 1 ]]; then
  C_RESET=$'\033[0m'; C_BOLD=$'\033[1m'; C_DIM=$'\033[2m'
  C_BLUE=$'\033[34m'; C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'; C_RED=$'\033[31m'
else
  C_RESET=; C_BOLD=; C_DIM=; C_BLUE=; C_GREEN=; C_YELLOW=; C_RED=
fi

step()  { printf '\n%s==>%s %s%s%s\n' "$C_BLUE$C_BOLD" "$C_RESET" "$C_BOLD" "$*" "$C_RESET"; }
info()  { printf '    %s\n' "$*"; }
ok()    { printf '    %s✓%s %s\n' "$C_GREEN" "$C_RESET" "$*"; }
warn()  { printf '    %s!%s %s\n' "$C_YELLOW" "$C_RESET" "$*" >&2; }
die()   { printf '\n%serror:%s %s\n' "$C_RED$C_BOLD" "$C_RESET" "$*" >&2; exit 1; }
skip()  { printf '    %s· %s%s\n' "$C_DIM" "$*" "$C_RESET"; }

run() {
  if (( DRY_RUN )); then
    printf '    %swould run:%s %s\n' "$C_DIM" "$C_RESET" "$*"
    return 0
  fi
  "$@"
}

# ------------------------------------------------------------------ checks

need_cmd() { command -v "$1" >/dev/null 2>&1; }

require_arch() {
  need_cmd pacman || die "This installer targets Arch/CachyOS (pacman not found)."
}

# ------------------------------------------------------------------ files

# back_up <path> — move an existing real file/dir aside, leave symlinks alone.
back_up() {
  local target=$1
  [[ -e $target || -L $target ]] || return 0
  if [[ -L $target ]]; then
    run rm -f "$target"
    return 0
  fi
  local backup="$target.pre-anarchy.$STAMP"
  info "backing up $(tilde "$target") -> $(basename "$backup")"
  run mv "$target" "$backup"
}

# link <source-in-repo> <destination>
link() {
  local src=$ANARCHY_DIR/$1 dest=$2
  [[ -e $src ]] || die "missing repo file: $src"

  if [[ -L $dest && "$(readlink -f "$dest")" == "$(readlink -f "$src")" ]]; then
    skip "$(tilde "$dest") already linked"
    return 0
  fi

  back_up "$dest"
  run mkdir -p "$(dirname "$dest")"
  run ln -s "$src" "$dest"
  ok "$(tilde "$dest") -> $(tilde "$src")"
}

# copy <source-in-repo> <destination> — for files the user is meant to edit.
copy() {
  local src=$ANARCHY_DIR/$1 dest=$2
  [[ -e $src ]] || die "missing repo file: $src"
  if [[ -e $dest ]]; then
    skip "$(tilde "$dest") exists, left alone"
    return 0
  fi
  run mkdir -p "$(dirname "$dest")"
  run cp "$src" "$dest"
  ok "$(tilde "$dest") created"
}

# ensure_line <file> <line> <match-regex> — append a line unless it's there.
ensure_line() {
  local file=$1 line=$2 pattern=$3
  if [[ -f $file ]] && grep -qE "$pattern" "$file"; then
    skip "$(tilde "$file") already references it"
    return 0
  fi
  info "appending to $(tilde "$file")"
  if (( DRY_RUN )); then
    printf '    %swould append:%s %s\n' "$C_DIM" "$C_RESET" "$line"
    return 0
  fi
  mkdir -p "$(dirname "$file")"
  printf '\n%s\n' "$line" >>"$file"
  ok "$(tilde "$file") updated"
}

tilde() { printf '%s' "${1/#$HOME/\~}"; }

# ------------------------------------------------------------------ pacman

# pac_install <pkg...> — install only what's missing.
pac_install() {
  local missing=()
  for p in "$@"; do
    pacman -Qq "$p" &>/dev/null || missing+=("$p")
  done
  if ((${#missing[@]} == 0)); then
    skip "already installed: $*"
    return 0
  fi
  info "installing: ${missing[*]}"
  run sudo pacman -S --needed --noconfirm "${missing[@]}"
}
