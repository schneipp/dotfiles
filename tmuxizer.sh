#!/bin/sh
# POSIX-compliant script - works with bash, ash, sh
# Install with: curl -sSL https://raw.githubusercontent.com/schneipp/dotfiles/master/tmuxizer.sh | sh

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

# ASCII Art
clear
cat << "EOF"
   ████████╗███╗   ███╗██╗   ██╗██╗  ██╗
   ╚══██╔══╝████╗ ████║██║   ██║╚██╗██╔╝
      ██║   ██╔████╔██║██║   ██║ ╚███╔╝
      ██║   ██║╚██╔╝██║██║   ██║ ██╔██╗
      ██║   ██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗
      ╚═╝   ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝

EOF
printf "${CYAN}${BOLD}    ✨ schneipp's Tmux Installation Script ✨${RESET}\n"
printf "${MAGENTA}    ═══════════════════════════════════════════${RESET}\n\n"

# Detect script directory (only works when run from file, not from curl | sh)
if [ -n "$0" ] && [ "$0" != "sh" ] && [ "$0" != "bash" ] && [ "$0" != "-sh" ] && [ "$0" != "-bash" ]; then
  SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"
else
  SCRIPT_DIR=""
fi

DOTFILES_DIR="$HOME/dotfiles"
TMUX_CONFIG_DIR="$HOME/.config/tmux"
TPM_DIR="$HOME/.tmux/plugins/tpm"

# Known tmux config locations to check/backup
TMUX_LEGACY_CONFIGS="
$HOME/.tmux.conf
$HOME/.tmux/tmux.conf
"

# ============================================================
# Step 1: Install tmux
# ============================================================
printf "${MAGENTA}═══════════════════════════════════════════${RESET}\n"
printf "${CYAN}📦 Installing Tmux${RESET}\n"
printf "${MAGENTA}═══════════════════════════════════════════${RESET}\n\n"

if command -v tmux >/dev/null 2>&1; then
  TMUX_VERSION=$(tmux -V 2>/dev/null)
  printf "${GREEN}✓ Tmux already installed: ${BOLD}$TMUX_VERSION${RESET}\n\n"
else
  printf "${YELLOW}⬇️  Installing tmux...${RESET}\n"

  OS_TYPE=$(uname -s)
  case "$OS_TYPE" in
    Darwin)
      printf "${GREEN}🍎 macOS detected${RESET}\n"
      if command -v brew >/dev/null 2>&1; then
        brew install tmux
      else
        printf "${RED}❌ Homebrew not found. Please install Homebrew first:${RESET}\n"
        printf "${BOLD}   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"${RESET}\n"
        exit 1
      fi
      ;;

    Linux)
      if [ -f /etc/alpine-release ]; then
        printf "${GREEN}🏔️  Alpine Linux detected${RESET}\n"
        apk add --no-cache tmux git
      elif [ -f /etc/fedora-release ]; then
        printf "${GREEN}🎩 Fedora detected${RESET}\n"
        sudo dnf install -y tmux git
      elif [ -f /etc/arch-release ]; then
        printf "${GREEN}🔷 Arch Linux detected${RESET}\n"
        sudo pacman -S --noconfirm tmux git
      elif [ -f /etc/apt/sources.list ]; then
        printf "${GREEN}🐧 Debian-based system detected${RESET}\n"
        sudo apt update
        sudo apt install -y tmux git
      else
        printf "${RED}❌ Unsupported Linux distribution${RESET}\n"
        printf "${BLUE}Please install tmux manually and run this script again${RESET}\n"
        exit 1
      fi
      ;;

    *)
      printf "${RED}❌ Unsupported OS: $OS_TYPE${RESET}\n"
      exit 1
      ;;
  esac

  if command -v tmux >/dev/null 2>&1; then
    TMUX_VERSION=$(tmux -V 2>/dev/null)
    printf "${GREEN}✓ Tmux installed: ${BOLD}$TMUX_VERSION${RESET}\n\n"
  else
    printf "${RED}❌ Failed to install tmux${RESET}\n"
    exit 1
  fi
fi

# ============================================================
# Step 2: Backup and remove existing tmux configs
# ============================================================
printf "${MAGENTA}═══════════════════════════════════════════${RESET}\n"
printf "${CYAN}🧹 Cleaning Up Existing Configs${RESET}\n"
printf "${MAGENTA}═══════════════════════════════════════════${RESET}\n\n"

BACKUP_TIMESTAMP=$(date +%s)

# Backup ~/.config/tmux if it exists
if [ -d "$TMUX_CONFIG_DIR" ] || [ -L "$TMUX_CONFIG_DIR" ]; then
  BACKUP="$TMUX_CONFIG_DIR.backup.$BACKUP_TIMESTAMP"
  printf "${YELLOW}📦 Backing up ${BOLD}$TMUX_CONFIG_DIR${RESET}${YELLOW} to ${BOLD}$BACKUP${RESET}\n"
  mv "$TMUX_CONFIG_DIR" "$BACKUP"
fi

# Backup legacy config locations
for config_file in $TMUX_LEGACY_CONFIGS; do
  if [ -f "$config_file" ] || [ -L "$config_file" ]; then
    BACKUP="$config_file.backup.$BACKUP_TIMESTAMP"
    printf "${YELLOW}📦 Backing up ${BOLD}$config_file${RESET}${YELLOW} to ${BOLD}$BACKUP${RESET}\n"
    mv "$config_file" "$BACKUP"
  fi
done

# Backup existing TPM installation
if [ -d "$TPM_DIR" ]; then
  BACKUP="$TPM_DIR.backup.$BACKUP_TIMESTAMP"
  printf "${YELLOW}📦 Backing up ${BOLD}$TPM_DIR${RESET}${YELLOW} to ${BOLD}$BACKUP${RESET}\n"
  mv "$TPM_DIR" "$BACKUP"
fi

printf "${GREEN}✓ Cleanup complete${RESET}\n\n"

# ============================================================
# Step 3: Install TPM (Tmux Plugin Manager)
# ============================================================
printf "${MAGENTA}═══════════════════════════════════════════${RESET}\n"
printf "${CYAN}🔌 Installing TPM (Tmux Plugin Manager)${RESET}\n"
printf "${MAGENTA}═══════════════════════════════════════════${RESET}\n\n"

printf "${YELLOW}📥 Cloning TPM...${RESET}\n"
mkdir -p "$(dirname "$TPM_DIR")"
if git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"; then
  printf "${GREEN}✓ TPM installed to ${BOLD}$TPM_DIR${RESET}\n\n"
else
  printf "${RED}❌ Failed to clone TPM${RESET}\n"
  exit 1
fi

# ============================================================
# Step 4: Install schneipp's tmux config
# ============================================================
printf "${MAGENTA}═══════════════════════════════════════════${RESET}\n"
printf "${CYAN}⚙️  Installing Configuration${RESET}\n"
printf "${MAGENTA}═══════════════════════════════════════════${RESET}\n\n"

# Check if running locally with tmux folder
if [ -n "$SCRIPT_DIR" ] && [ -d "$SCRIPT_DIR/tmux" ]; then
  # Running locally - symlink from script directory
  printf "${YELLOW}🔗 Creating symlink from ${BOLD}$SCRIPT_DIR/tmux${RESET}\n"
  mkdir -p "$(dirname "$TMUX_CONFIG_DIR")"
  ln -s "$SCRIPT_DIR/tmux" "$TMUX_CONFIG_DIR"
  printf "${GREEN}✓ Config symlinked to ${BOLD}$TMUX_CONFIG_DIR${RESET}\n\n"
else
  # Running remotely - clone dotfiles if needed
  if [ -d "$DOTFILES_DIR" ]; then
    printf "${YELLOW}📂 Dotfiles directory already exists at ${BOLD}$DOTFILES_DIR${RESET}\n"
    printf "${YELLOW}   Pulling latest changes...${RESET}\n"
    cd "$DOTFILES_DIR" && git pull
  else
    printf "${YELLOW}📥 Cloning dotfiles repository...${RESET}\n"
    if ! git clone https://github.com/schneipp/dotfiles.git "$DOTFILES_DIR"; then
      printf "${RED}❌ Failed to clone dotfiles repository${RESET}\n"
      printf "${BLUE}You can manually clone it later:${RESET}\n"
      printf "${BOLD}   git clone https://github.com/schneipp/dotfiles.git${RESET}\n\n"
      exit 1
    else
      printf "${GREEN}✓ Dotfiles cloned to ${BOLD}$DOTFILES_DIR${RESET}\n"
    fi
  fi

  # Create symlink if clone succeeded
  if [ -d "$DOTFILES_DIR/tmux" ]; then
    printf "${YELLOW}🔗 Creating symlink...${RESET}\n"
    mkdir -p "$(dirname "$TMUX_CONFIG_DIR")"
    ln -s "$DOTFILES_DIR/tmux" "$TMUX_CONFIG_DIR"
    printf "${GREEN}✓ Config symlinked to ${BOLD}$TMUX_CONFIG_DIR${RESET}\n\n"
  else
    printf "${RED}❌ Tmux config not found in dotfiles${RESET}\n\n"
    exit 1
  fi
fi

# ============================================================
# Step 5: Install tmux plugins
# ============================================================
printf "${MAGENTA}═══════════════════════════════════════════${RESET}\n"
printf "${CYAN}🔌 Installing Tmux Plugins${RESET}\n"
printf "${MAGENTA}═══════════════════════════════════════════${RESET}\n\n"

printf "${YELLOW}📦 Running TPM plugin installer...${RESET}\n"
# Run TPM install script (works without tmux running)
if [ -x "$TPM_DIR/bin/install_plugins" ]; then
  "$TPM_DIR/bin/install_plugins" || true
  printf "${GREEN}✓ Plugins installed${RESET}\n\n"
else
  printf "${YELLOW}⚠️  TPM install script not found. Plugins will install on first tmux start.${RESET}\n"
  printf "${CYAN}💡 Press ${BOLD}prefix + I${RESET}${CYAN} inside tmux to install plugins${RESET}\n\n"
fi

# ============================================================
# Verification
# ============================================================
printf "${MAGENTA}═══════════════════════════════════════════${RESET}\n"
printf "${CYAN}🔍 Verification${RESET}\n"
printf "${MAGENTA}═══════════════════════════════════════════${RESET}\n\n"

if [ -L "$TMUX_CONFIG_DIR" ] && [ -d "$TPM_DIR" ]; then
  printf "${GREEN}${BOLD}✓ Installation successful!${RESET}\n"
  printf "${CYAN}📍 Config: ${BOLD}$TMUX_CONFIG_DIR${RESET}\n"
  printf "${CYAN}📍 TPM: ${BOLD}$TPM_DIR${RESET}\n\n"

  printf "${MAGENTA}═══════════════════════════════════════════${RESET}\n"
  printf "${GREEN}${BOLD}   🎉 All done! Happy tmuxing! 🎉${RESET}\n"
  printf "${MAGENTA}═══════════════════════════════════════════${RESET}\n\n"

  printf "${CYAN}💡 Tips:${RESET}\n"
  printf "${BLUE}   • Start tmux: ${BOLD}tmux${RESET}\n"
  printf "${BLUE}   • Install plugins: ${BOLD}prefix + I${RESET}\n"
  printf "${BLUE}   • Update plugins: ${BOLD}prefix + U${RESET}\n\n"
else
  printf "${RED}${BOLD}❌ Installation may have failed${RESET}\n\n"
  exit 1
fi
