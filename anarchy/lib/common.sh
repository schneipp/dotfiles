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

# DISTRO: arch (pacman: Arch, CachyOS, EndeavourOS, …) or fedora (dnf).
detect_distro() {
  local id="" like=""
  if [[ -r /etc/os-release ]]; then
    id=$(. /etc/os-release; echo "${ID:-}")
    like=$(. /etc/os-release; echo "${ID_LIKE:-}")
  fi
  if need_cmd pacman && [[ " $id $like " == *" arch "* || $id == arch ]]; then
    echo arch
  elif need_cmd dnf && [[ " $id $like " == *" fedora "* || $id == fedora ]]; then
    echo fedora
  elif need_cmd pacman; then
    echo arch
  elif need_cmd dnf; then
    echo fedora
  else
    echo unknown
  fi
}
DISTRO=${DISTRO:-$(detect_distro)}

require_supported() {
  case $DISTRO in
    arch|fedora) ;;
    *) die "This installer targets Arch/CachyOS (pacman) or Fedora (dnf); found neither." ;;
  esac
}
# Older name, kept for steps written before Fedora support.
require_arch() { require_supported; }

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

# ---------------------------------------------------------------- packages

# pkg_installed <pkg> — true when the package is installed.
pkg_installed() {
  case $DISTRO in
    arch)   pacman -Qq "$1" &>/dev/null ;;
    fedora) rpm -q --whatprovides "$1" &>/dev/null ;;
  esac
}

# pkg_install <pkg...> — install only what's missing, with the native
# package manager. Names are the distro's own; the steps pick per distro.
# On Fedora a package no enabled repo has is reported and skipped rather than
# failing the whole batch, since several extras live in optional COPRs.
pkg_install() {
  local missing=()
  for p in "$@"; do
    pkg_installed "$p" || missing+=("$p")
  done
  if ((${#missing[@]} == 0)); then
    skip "already installed: $*"
    return 0
  fi
  info "installing: ${missing[*]}"
  case $DISTRO in
    arch)   run sudo pacman -S --needed --noconfirm "${missing[@]}" ;;
    fedora) run sudo dnf install -y --skip-unavailable "${missing[@]}"
            (( DRY_RUN )) && return 0
            local p left=()
            for p in "${missing[@]}"; do pkg_installed "$p" || left+=("$p"); done
            ((${#left[@]} == 0)) || warn "not available in the enabled repos: ${left[*]}" ;;
  esac
}
# Older name, kept for steps written before Fedora support.
pac_install() { pkg_install "$@"; }

# copr_enable <owner/project> — Fedora only: add a COPR repository.
copr_enable() {
  [[ $DISTRO == fedora ]] || return 0
  local repo=$1
  if dnf copr list 2>/dev/null | grep -q "/$repo\b"; then
    skip "COPR $repo already enabled"
    return 0
  fi
  pkg_installed dnf5-plugins || pkg_installed dnf-plugins-core || \
    run sudo dnf install -y dnf5-plugins
  run sudo dnf copr enable -y "$repo" && ok "COPR $repo enabled"
}

# aur_install <pkg...> — install from the AUR with paru, showing the anarchy
# trust report first so a low-vote package is a visible choice, not a surprise.
aur_install() {
  [[ $DISTRO == arch ]] || die "aur_install: the AUR is Arch-only"
  local missing=()
  for p in "$@"; do
    pkg_installed "$p" || missing+=("$p")
  done
  if ((${#missing[@]} == 0)); then
    skip "already installed: $*"
    return 0
  fi
  need_cmd paru || die "paru is needed for the AUR (run the packages step first)"
  local audit=$ANARCHY_DIR/bin/qsl-aur-audit
  for p in "${missing[@]}"; do
    [[ -x $audit ]] && "$audit" --text "$p" 2>/dev/null | sed 's/^/    │ /'
  done
  info "installing from the AUR: ${missing[*]}"
  run paru -S --needed --noconfirm --skipreview "${missing[@]}"
}

# confirm <question> — yes/no prompt. ASSUME_YES=1 answers yes; with no
# terminal to ask on, the answer is no.
confirm() {
  (( ASSUME_YES )) && return 0
  [[ -t 0 ]] || return 1
  local reply
  read -rp "    $1 [y/N] " reply
  [[ $reply == [yY]* ]]
}
ASSUME_YES=${ASSUME_YES:-0}

# pkg_install_any <pkg...> — the first of several alternatives, unless one is
# already installed (ffmpeg vs ffmpeg-free).
pkg_install_any() {
  local p
  for p in "$@"; do
    pkg_installed "$p" && { skip "already installed: $p"; return 0; }
  done
  pkg_install "$1"
}

# install_nerd_font — JetBrainsMono Nerd Font from the upstream release, for
# distros that don't package it. Pinned by version and checksum.
NERD_FONT_URL=https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.1/JetBrainsMono.tar.xz
NERD_FONT_SHA256=04d5e8f903693f9dd13e16f867e994834e681eb3c72c0d337a770dcda09010cf
install_nerd_font() {
  local dir=$HOME/.local/share/fonts/JetBrainsMonoNerd
  if fc-list 2>/dev/null | grep -q "JetBrainsMono Nerd Font"; then
    skip "JetBrainsMono Nerd Font already installed"
    return 0
  fi
  if (( DRY_RUN )); then
    info "would download JetBrainsMono Nerd Font into $(tilde "$dir")"
    return 0
  fi
  local tmp
  tmp=$(mktemp -d)
  if curl -fsSL "$NERD_FONT_URL" -o "$tmp/font.tar.xz" &&
     echo "$NERD_FONT_SHA256  $tmp/font.tar.xz" | sha256sum -c --quiet; then
    mkdir -p "$dir"
    tar --no-same-owner -xJf "$tmp/font.tar.xz" -C "$dir" --wildcards '*.ttf'
    fc-cache -f "$dir" >/dev/null 2>&1
    ok "JetBrainsMono Nerd Font -> $(tilde "$dir")"
  else
    warn "could not fetch JetBrainsMono Nerd Font (download or checksum failed)"
  fi
  rm -rf "$tmp"
}
