#!/bin/sh
# Local Tmux installer - run from dotfiles directory
# This script is called by tmuxizer.sh after cloning the repo

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# Get script directory (dotfiles folder)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TMUX_CONFIG_DIR="$HOME/.config/tmux"
TPM_DIR="$HOME/.tmux/plugins/tpm"

# Known tmux config locations to backup
TMUX_LEGACY_CONFIGS="$HOME/.tmux.conf $HOME/.tmux/tmux.conf"

# Check if running as root
if [ "$(id -u)" -eq 0 ]; then
  SUDO=""
else
  SUDO="sudo"
fi

# ============================================================
# Step 1: Install tmux
# ============================================================
printf "${MAGENTA}===========================================${RESET}\n"
printf "${CYAN}Installing Tmux${RESET}\n"
printf "${MAGENTA}===========================================${RESET}\n\n"

if command -v tmux >/dev/null 2>&1; then
  TMUX_VERSION=$(tmux -V 2>/dev/null)
  printf "${GREEN}[OK] Tmux already installed: ${BOLD}$TMUX_VERSION${RESET}\n\n"
else
  printf "${YELLOW}Installing tmux...${RESET}\n"

  OS_TYPE=$(uname -s)
  case "$OS_TYPE" in
    Darwin)
      printf "${GREEN}macOS detected${RESET}\n"
      if command -v brew >/dev/null 2>&1; then
        brew install tmux
      else
        printf "${RED}Homebrew not found. Please install Homebrew first.${RESET}\n"
        exit 1
      fi
      ;;
    Linux)
      if [ -f /etc/alpine-release ]; then
        printf "${GREEN}Alpine Linux detected${RESET}\n"
        apk add --no-cache tmux
      elif [ -f /etc/fedora-release ]; then
        printf "${GREEN}Fedora detected${RESET}\n"
        $SUDO dnf install -y tmux
      elif [ -f /etc/arch-release ]; then
        printf "${GREEN}Arch Linux detected${RESET}\n"
        $SUDO pacman -S --noconfirm tmux
      elif [ -f /etc/apt/sources.list ]; then
        printf "${GREEN}Debian-based system detected${RESET}\n"
        $SUDO apt update
        $SUDO apt install -y tmux
      else
        printf "${RED}Unsupported Linux distribution${RESET}\n"
        printf "${BLUE}Please install tmux manually${RESET}\n"
        exit 1
      fi
      ;;
    OpenBSD)
      printf "${GREEN}OpenBSD detected${RESET}\n"
      $SUDO pkg_add tmux
      ;;
    FreeBSD)
      printf "${GREEN}FreeBSD detected${RESET}\n"
      $SUDO pkg install -y tmux
      ;;
    *)
      printf "${RED}Unsupported OS: $OS_TYPE${RESET}\n"
      exit 1
      ;;
  esac

  if command -v tmux >/dev/null 2>&1; then
    TMUX_VERSION=$(tmux -V 2>/dev/null)
    printf "${GREEN}[OK] Tmux installed: ${BOLD}$TMUX_VERSION${RESET}\n\n"
  else
    printf "${RED}Failed to install tmux${RESET}\n"
    exit 1
  fi
fi

# ============================================================
# Step 2: Backup and remove existing configs
# ============================================================
printf "${MAGENTA}===========================================${RESET}\n"
printf "${CYAN}Cleaning Up Existing Configs${RESET}\n"
printf "${MAGENTA}===========================================${RESET}\n\n"

BACKUP_TIMESTAMP=$(date +%s)

# Backup ~/.config/tmux
if [ -d "$TMUX_CONFIG_DIR" ] || [ -L "$TMUX_CONFIG_DIR" ]; then
  BACKUP="$TMUX_CONFIG_DIR.backup.$BACKUP_TIMESTAMP"
  printf "${YELLOW}Backing up $TMUX_CONFIG_DIR to $BACKUP${RESET}\n"
  mv "$TMUX_CONFIG_DIR" "$BACKUP"
fi

# Backup legacy configs
for config_file in $TMUX_LEGACY_CONFIGS; do
  if [ -f "$config_file" ] || [ -L "$config_file" ]; then
    BACKUP="$config_file.backup.$BACKUP_TIMESTAMP"
    printf "${YELLOW}Backing up $config_file to $BACKUP${RESET}\n"
    mv "$config_file" "$BACKUP"
  fi
done

# Backup existing TPM
if [ -d "$TPM_DIR" ]; then
  BACKUP="$TPM_DIR.backup.$BACKUP_TIMESTAMP"
  printf "${YELLOW}Backing up $TPM_DIR to $BACKUP${RESET}\n"
  mv "$TPM_DIR" "$BACKUP"
fi

printf "${GREEN}[OK] Cleanup complete${RESET}\n\n"

# ============================================================
# Step 3: Install TPM
# ============================================================
printf "${MAGENTA}===========================================${RESET}\n"
printf "${CYAN}Installing TPM (Tmux Plugin Manager)${RESET}\n"
printf "${MAGENTA}===========================================${RESET}\n\n"

printf "${YELLOW}Cloning TPM...${RESET}\n"
mkdir -p "$(dirname "$TPM_DIR")"
git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
printf "${GREEN}[OK] TPM installed to $TPM_DIR${RESET}\n\n"

# ============================================================
# Step 4: Symlink tmux config
# ============================================================
printf "${MAGENTA}===========================================${RESET}\n"
printf "${CYAN}Installing Configuration${RESET}\n"
printf "${MAGENTA}===========================================${RESET}\n\n"

mkdir -p "$(dirname "$TMUX_CONFIG_DIR")"
ln -s "$SCRIPT_DIR/tmux" "$TMUX_CONFIG_DIR"
printf "${GREEN}[OK] Config symlinked to $TMUX_CONFIG_DIR${RESET}\n\n"

# ============================================================
# Step 5: Install plugins (if bash available)
# ============================================================
printf "${MAGENTA}===========================================${RESET}\n"
printf "${CYAN}Installing Tmux Plugins${RESET}\n"
printf "${MAGENTA}===========================================${RESET}\n\n"

if command -v bash >/dev/null 2>&1; then
  printf "${YELLOW}Running TPM plugin installer...${RESET}\n"
  if [ -x "$TPM_DIR/bin/install_plugins" ]; then
    "$TPM_DIR/bin/install_plugins" || true
    printf "${GREEN}[OK] Plugins installed${RESET}\n\n"
  fi
else
  printf "${YELLOW}Bash not found - skipping automatic plugin install${RESET}\n"
  printf "${CYAN}Press prefix + I inside tmux to install plugins${RESET}\n\n"
fi

# ============================================================
# Verification
# ============================================================
printf "${MAGENTA}===========================================${RESET}\n"
printf "${CYAN}Verification${RESET}\n"
printf "${MAGENTA}===========================================${RESET}\n\n"

if [ -L "$TMUX_CONFIG_DIR" ] && [ -d "$TPM_DIR" ]; then
  printf "${GREEN}${BOLD}[OK] Installation successful!${RESET}\n"
  printf "${CYAN}Config: $TMUX_CONFIG_DIR${RESET}\n"
  printf "${CYAN}TPM: $TPM_DIR${RESET}\n\n"

  printf "${MAGENTA}===========================================${RESET}\n"
  printf "${GREEN}${BOLD}   All done! Happy tmuxing!${RESET}\n"
  printf "${MAGENTA}===========================================${RESET}\n\n"

  printf "${CYAN}Tips:${RESET}\n"
  printf "${BLUE}  - Start tmux: tmux${RESET}\n"
  printf "${BLUE}  - Install plugins: prefix + I${RESET}\n"
  printf "${BLUE}  - Update plugins: prefix + U${RESET}\n\n"
else
  printf "${RED}${BOLD}Installation may have failed${RESET}\n\n"
  exit 1
fi
