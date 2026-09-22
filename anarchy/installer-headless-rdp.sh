#!/usr/bin/env bash
#
#  anarchy, headless: the full desktop from install.sh, served over RDP.
#
#  Runs everything install.sh does, then:
#    - hypr-rdp (AUR), with one virtual monitor per remote screen, each on its
#      own port, laid out side by side so windows and focus hop between them
#    - greetd autologin into Hyprland at boot, so there is a desktop to serve
#      with no keyboard or screen attached
#    - suspend and hibernate masked, the firewall opened if one is running
#
#  Usage:
#    ./installer-headless-rdp.sh                          everything, 2x 1920x1080
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
  --monitors "WxH ..."  remote monitor sizes, left to right (default: 1920x1080 1920x1080)
  --rdp-only            skip install.sh, set up only RDP and the headless session
  --no-autologin        leave the display manager and sleep settings alone
  -y, --yes             answer yes to the display-manager and sleep questions
  --dry-run             show what would change without touching anything
  -h, --help            this message
EOF
}

RDP_ONLY=0 NO_AUTOLOGIN=0 RDP_MONITORS=
while (($#)); do
  case $1 in
    --monitors)     [[ $# -ge 2 ]] || die "--monitors needs a value"; RDP_MONITORS=$2; shift ;;
    --monitors=*)   RDP_MONITORS=${1#*=} ;;
    --rdp-only)     RDP_ONLY=1 ;;
    --no-autologin) NO_AUTOLOGIN=1 ;;
    -y|--yes)       ASSUME_YES=1 ;;
    --dry-run)      DRY_RUN=1 ;;
    -h|--help)      usage; exit 0 ;;
    *)              die "unknown option: $1 (try --help)" ;;
  esac
  shift
done
export DRY_RUN ASSUME_YES RDP_MONITORS NO_AUTOLOGIN

[[ $EUID -ne 0 ]] || die "Don't run this as root — it installs into \$HOME and calls sudo itself."
require_arch

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
  info "the headless steps need sudo (AUR install, greetd, sleep targets)"
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
  ~/.config/anarchy/rdp.conf                   monitor sizes and ports

  Reboot to come up headless: greetd logs in and the servers start with Hyprland.
EOF
