#!/usr/bin/env bash
#
#   █████╗ ███╗   ██╗ █████╗ ██████╗  ██████╗██╗  ██╗██╗   ██╗
#  ██╔══██╗████╗  ██║██╔══██╗██╔══██╗██╔════╝██║  ██║╚██╗ ██╔╝
#  ███████║██╔██╗ ██║███████║██████╔╝██║     ███████║ ╚████╔╝
#  ██╔══██║██║╚██╗██║██╔══██║██╔══██╗██║     ██╔══██║  ╚██╔╝
#  ██║  ██║██║ ╚████║██║  ██║██║  ██║╚██████╗██║  ██║   ██║
#  ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝
#
#  A Hyprland desktop on Arch/CachyOS: DankMaterialShell topbar, two launchers
#  (rofi + a Quickshell one that installs and uninstalls packages), vim-style
#  window management, and a consistently dark Qt/KDE theme.
#
#  Usage:
#    ./install.sh                 run every step
#    ./install.sh --dry-run       print what would happen, change nothing
#    ./install.sh hyprland rofi   run only the named steps
#    ./install.sh --list          show available steps
#
set -uo pipefail

ANARCHY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ANARCHY_DIR

# shellcheck source=lib/common.sh
source "$ANARCHY_DIR/lib/common.sh"

STEPS_DIR=$ANARCHY_DIR/steps

list_steps() {
  for f in "$STEPS_DIR"/*.sh; do
    local base name desc
    base=$(basename "$f" .sh)
    name=${base#*-}
    desc=$(sed -n '2s/^# //p' "$f")
    printf '  %-12s %s\n' "$name" "$desc"
  done
}

usage() {
  cat <<EOF
Usage: ./install.sh [options] [step...]

Options:
  --dry-run     Show what would change without touching anything
  --list        List available steps
  -h, --help    This message

Steps (run in this order when none are named):
$(list_steps)
EOF
}

# ---------------------------------------------------------------- arguments

WANTED=()
while (($#)); do
  case $1 in
    --dry-run) DRY_RUN=1; export DRY_RUN ;;
    --list)    list_steps; exit 0 ;;
    -h|--help) usage; exit 0 ;;
    -*)        die "unknown option: $1 (try --help)" ;;
    *)         WANTED+=("$1") ;;
  esac
  shift
done

# ------------------------------------------------------------------- checks

[[ $EUID -ne 0 ]] || die "Don't run this as root — it installs into \$HOME and calls sudo itself."
require_arch

if (( DRY_RUN )); then
  printf '%s*** DRY RUN — nothing will be changed ***%s\n' "$C_YELLOW$C_BOLD" "$C_RESET"
fi

# Only the packages step needs root, so only ask when it's actually going to run.
needs_sudo=0
if ((${#WANTED[@]} == 0)); then
  needs_sudo=1
else
  for w in "${WANTED[@]}"; do [[ $w == packages ]] && needs_sudo=1; done
fi

if (( ! DRY_RUN && needs_sudo )) && ! sudo -n true 2>/dev/null; then
  info "the packages step needs sudo; asking now so it doesn't stall later"
  sudo -v || die "sudo is required"
fi

# ------------------------------------------------------------------- driver

ran=0
for f in "$STEPS_DIR"/*.sh; do
  base=$(basename "$f" .sh)
  name=${base#*-}

  if ((${#WANTED[@]})); then
    match=0
    for w in "${WANTED[@]}"; do [[ $w == "$name" ]] && match=1; done
    (( match )) || continue
  fi

  # shellcheck disable=SC1090
  source "$f"
  ran=$((ran + 1))
done

if ((${#WANTED[@]} && ran == 0)); then
  die "no step matched: ${WANTED[*]} (try --list)"
fi

# ------------------------------------------------------------------ summary

cat <<EOF

$C_GREEN$C_BOLD==> anarchy installed$C_RESET

  Super+Space          the anarchy menu
  Super+Tab            window overview
  Super+Return         terminal
  Super+W              close window
  Super+h/j/k/l        focus       (+Shift moves, +Ctrl switches monitor)
  Print                select an area -> clipboard
  Super+Shift+R        record a region with audio (again to stop)
  Super+Shift+M        quit Hyprland

  Full keymap: anarchy/README.md

$(if [[ -z ${HYPRLAND_INSTANCE_SIGNATURE:-} ]]; then
    echo "  Log into Hyprland to start the shell and launcher."
  else
    echo "  Everything is live — no logout needed."
  fi)
EOF
