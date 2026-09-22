#!/usr/bin/env bash
#
#  anarchy, headless: the full desktop from install.sh, served over RDP.
#
#  Runs everything install.sh does, then gives the user running it their own
#  desktop over RDP. Run it once per user: each gets a separate Hyprland, side
#  by side on the same machine, on ports of their own.
#    - hypr-rdp (AUR on Arch, the pinned upstream release on Fedora)
#    - one screen that follows the client window's size, or with --monitors,
#      several fixed monitors laid out side by side
#    - Hyprland as a systemd user service with no seat (libseat noop), started
#      at boot by lingering; no monitor or login needed
#    - suspend and hibernate masked, the firewall opened if one is running
#
#  Usage:
#    ./installer-headless-rdp.sh                          one resizable screen
#    ./installer-headless-rdp.sh --monitors "2560x1440 1920x1080"
#    ./installer-headless-rdp.sh --rdp-only               skip the desktop part
#    ./installer-headless-rdp.sh --dry-run                change nothing
#
set -uo pipefail

ANARCHY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ANARCHY_DIR

# shellcheck source=lib/common.sh
source "$ANARCHY_DIR/lib/common.sh"

usage() {
  cat <<EOF
Usage: ./installer-headless-rdp.sh [options]

Options:
  --dynamic             one screen that follows the client window (the default)
  --monitors "WxH ..."  fixed monitors instead, left to right, one port each
  --rdp-only            skip install.sh, set up only RDP and the headless session
  --no-session          don't set up the headless Hyprland service
  -y, --yes             answer yes to the sleep question
  --dry-run             show what would change without touching anything
  -h, --help            this message
EOF
}

RDP_ONLY=0 NO_SESSION=0 RDP_MONITORS= RDP_MODE= SESSION_STARTED=0
while (($#)); do
  case $1 in
    --dynamic)      RDP_MODE=dynamic ;;
    --monitors)     [[ $# -ge 2 ]] || die "--monitors needs a value"; RDP_MONITORS=$2; RDP_MODE=fixed; shift ;;
    --monitors=*)   RDP_MONITORS=${1#*=}; RDP_MODE=fixed ;;
    --rdp-only)     RDP_ONLY=1 ;;
    --no-session)   NO_SESSION=1 ;;
    -y|--yes)       ASSUME_YES=1 ;;
    --dry-run)      DRY_RUN=1 ;;
    -h|--help)      usage; exit 0 ;;
    *)              die "unknown option: $1 (try --help)" ;;
  esac
  shift
done
export DRY_RUN ASSUME_YES RDP_MONITORS RDP_MODE NO_SESSION

[[ $EUID -ne 0 ]] || die "Don't run this as root — it installs into \$HOME and calls sudo itself."
require_supported

# ------------------------------------------------------------------ desktop

if (( ! RDP_ONLY )); then
  args=()
  (( DRY_RUN )) && args+=(--dry-run)
  "$ANARCHY_DIR/install.sh" "${args[@]}" || die "install.sh failed — fix that first, or rerun with --rdp-only"
elif (( DRY_RUN )); then
  printf '%s*** DRY RUN — nothing will be changed ***%s\n' "$C_YELLOW$C_BOLD" "$C_RESET"
fi

# ------------------------------------------------------------------ headless

if (( ! DRY_RUN )) && ! sudo -n true 2>/dev/null; then
  info "the headless steps need sudo (hypr-rdp, ports, video group, lingering)"
  sudo -v || die "sudo is required"
fi

for f in "$ANARCHY_DIR"/steps/headless/*.sh; do
  # shellcheck disable=SC1090
  source "$f"
done

# ------------------------------------------------------------------ summary

printf '\n%s==> anarchy headless RDP installed%s\n\n' "$C_GREEN$C_BOLD" "$C_RESET"
if (( ! DRY_RUN )); then
  "$HOME/.local/bin/anarchy-rdp" status | sed 's/^/  /'
fi
cat <<EOF

  anarchy-rdp status | restart | password     manage it
  ~/.config/anarchy/rdp.conf                   mode, monitor sizes, port
  systemctl --user status anarchy-hyprland     the headless desktop itself

  Other users on this machine: run this installer as them for a desktop each.
EOF
if (( ! DRY_RUN && ! NO_SESSION && ! SESSION_STARTED )); then
  echo "  Reboot to start it (the video group and lingering apply from then)."
fi
