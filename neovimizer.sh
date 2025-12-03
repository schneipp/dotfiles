#!/bin/sh
# POSIX-compliant bootstrap script - works with bash, ash, sh
# Install with: curl -sSL https://raw.githubusercontent.com/schneipp/dotfiles/master/neovimizer.sh | sh

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

DOTFILES_DIR="$HOME/dotfiles"
REPO_URL="https://github.com/schneipp/dotfiles.git"

# Check if running as root (skip sudo if so)
if [ "$(id -u)" -eq 0 ]; then
  SUDO=""
else
  SUDO="sudo"
fi

# ASCII Art
clear
cat << "EOF"
   _   _                 _
  | \ | | ___  _____   _(_)_ __ ___
  |  \| |/ _ \/ _ \ \ / / | '_ ` _ \
  | |\  |  __/ (_) \ V /| | | | | | |
  |_| \_|\___|\___/ \_/ |_|_| |_| |_|

EOF
printf "${CYAN}${BOLD}    schneipp Neovim Installation Script${RESET}\n"
printf "${MAGENTA}    ==========================================${RESET}\n\n"

# ============================================================
# Step 1: Install git and curl
# ============================================================
printf "${MAGENTA}===========================================${RESET}\n"
printf "${CYAN}Installing Dependencies${RESET}\n"
printf "${MAGENTA}===========================================${RESET}\n\n"

install_deps() {
  if command -v git >/dev/null 2>&1 && command -v curl >/dev/null 2>&1; then
    printf "${GREEN}[OK] git and curl already installed${RESET}\n\n"
    return 0
  fi

  printf "${YELLOW}Installing git and curl...${RESET}\n"

  OS_TYPE=$(uname -s)
  case "$OS_TYPE" in
    Darwin)
      printf "${GREEN}macOS detected${RESET}\n"
      if command -v brew >/dev/null 2>&1; then
        brew install git curl
      else
        # macOS has curl, just need git via xcode tools
        xcode-select --install 2>/dev/null || true
      fi
      ;;
    Linux)
      if [ -f /etc/alpine-release ]; then
        printf "${GREEN}Alpine Linux detected${RESET}\n"
        apk add --no-cache git curl
      elif [ -f /etc/fedora-release ]; then
        printf "${GREEN}Fedora detected${RESET}\n"
        $SUDO dnf install -y git curl
      elif [ -f /etc/arch-release ]; then
        printf "${GREEN}Arch Linux detected${RESET}\n"
        $SUDO pacman -S --noconfirm git curl
      elif [ -f /etc/apt/sources.list ]; then
        printf "${GREEN}Debian-based system detected${RESET}\n"
        $SUDO apt update
        $SUDO apt install -y git curl
      else
        printf "${RED}Unsupported Linux distribution${RESET}\n"
        printf "${BLUE}Please install git and curl manually and run this script again${RESET}\n"
        exit 1
      fi
      ;;
    OpenBSD)
      printf "${GREEN}OpenBSD detected${RESET}\n"
      $SUDO pkg_add git curl
      ;;
    FreeBSD)
      printf "${GREEN}FreeBSD detected${RESET}\n"
      $SUDO pkg install -y git curl
      ;;
    *)
      printf "${RED}Unsupported OS: $OS_TYPE${RESET}\n"
      printf "${BLUE}Please install git and curl manually and run this script again${RESET}\n"
      exit 1
      ;;
  esac

  printf "${GREEN}[OK] Dependencies installed${RESET}\n\n"
}

install_deps

# ============================================================
# Step 2: Clone or update dotfiles
# ============================================================
printf "${MAGENTA}===========================================${RESET}\n"
printf "${CYAN}Setting Up Dotfiles${RESET}\n"
printf "${MAGENTA}===========================================${RESET}\n\n"

if [ -d "$DOTFILES_DIR" ]; then
  printf "${YELLOW}Dotfiles directory exists, pulling latest...${RESET}\n"
  cd "$DOTFILES_DIR"
  git pull || printf "${YELLOW}Warning: git pull failed, continuing with existing files${RESET}\n"
else
  printf "${YELLOW}Cloning dotfiles repository...${RESET}\n"
  git clone "$REPO_URL" "$DOTFILES_DIR"
  cd "$DOTFILES_DIR"
fi

printf "${GREEN}[OK] Dotfiles ready at ${BOLD}$DOTFILES_DIR${RESET}\n\n"

# ============================================================
# Step 3: Run the local installer
# ============================================================
printf "${MAGENTA}===========================================${RESET}\n"
printf "${CYAN}Running Local Installer${RESET}\n"
printf "${MAGENTA}===========================================${RESET}\n\n"

if [ -f "$DOTFILES_DIR/install-nvim.sh" ]; then
  exec sh "$DOTFILES_DIR/install-nvim.sh"
else
  printf "${RED}Local installer not found at $DOTFILES_DIR/install-nvim.sh${RESET}\n"
  exit 1
fi
