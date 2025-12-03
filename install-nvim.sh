#!/bin/sh
# Local Neovim installer - run from dotfiles directory
# This script is called by neovimizer.sh after cloning the repo

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
NVIM_DIR="$HOME/apps/nvim"
NVIM_CONFIG="$HOME/.config/nvim"

# Check if running as root
if [ "$(id -u)" -eq 0 ]; then
  SUDO=""
else
  SUDO="sudo"
fi

# ============================================================
# Step 1: Install Neovim
# ============================================================
printf "${MAGENTA}===========================================${RESET}\n"
printf "${CYAN}Installing Neovim${RESET}\n"
printf "${MAGENTA}===========================================${RESET}\n\n"

# Fetch latest version from GitHub API
printf "${YELLOW}Fetching latest Neovim version...${RESET}\n"
VERSION=$(curl -sSL https://api.github.com/repos/neovim/neovim/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$VERSION" ]; then
  printf "${RED}Failed to fetch latest version, using fallback v0.10.4${RESET}\n"
  VERSION="v0.10.4"
fi

printf "${BLUE}Installing Neovim ${BOLD}$VERSION${RESET}${BLUE}...${RESET}\n\n"

# Create directory if needed
mkdir -p "$NVIM_DIR"

# Detect OS and architecture
OS_TYPE=$(uname -s)
ARCH=$(uname -m)

install_neovim() {
  case "$OS_TYPE" in
    Darwin)
      printf "${GREEN}macOS detected${RESET}\n"
      if [ "$ARCH" = "arm64" ]; then
        ASSET="nvim-macos-arm64.tar.gz"
      else
        ASSET="nvim-macos-x86_64.tar.gz"
      fi
      printf "${YELLOW}Downloading $ASSET...${RESET}\n"
      curl -fL "https://github.com/neovim/neovim/releases/download/${VERSION}/${ASSET}" -o /tmp/nvim.tar.gz
      printf "${YELLOW}Extracting...${RESET}\n"
      tar -xzf /tmp/nvim.tar.gz -C "$NVIM_DIR" --strip-components=1
      rm /tmp/nvim.tar.gz
      printf "${GREEN}[OK] Neovim installed to ${BOLD}$NVIM_DIR${RESET}\n\n"
      ;;

    Linux)
      if [ -f /etc/alpine-release ]; then
        printf "${GREEN}Alpine Linux detected${RESET}\n"
        apk add --no-cache neovim
        printf "${GREEN}[OK] Neovim installed via apk${RESET}\n\n"
        return
      elif [ -f /etc/fedora-release ]; then
        printf "${GREEN}Fedora detected${RESET}\n"
        $SUDO dnf install -y neovim
        printf "${GREEN}[OK] Neovim installed via dnf${RESET}\n\n"
        return
      elif [ -f /etc/arch-release ]; then
        printf "${GREEN}Arch Linux detected${RESET}\n"
        $SUDO pacman -S --noconfirm neovim
        printf "${GREEN}[OK] Neovim installed via pacman${RESET}\n\n"
        return
      fi

      # For other Linux distros, download binary
      printf "${GREEN}Linux detected, downloading binary${RESET}\n"
      if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
        ASSET="nvim-linux-arm64.tar.gz"
      else
        ASSET="nvim-linux-x86_64.tar.gz"
      fi

      printf "${YELLOW}Downloading $ASSET...${RESET}\n"
      if ! curl -fL "https://github.com/neovim/neovim/releases/download/${VERSION}/${ASSET}" -o /tmp/nvim.tar.gz; then
        # Try old naming convention
        ASSET_OLD="nvim-linux64.tar.gz"
        printf "${YELLOW}Trying old asset name $ASSET_OLD...${RESET}\n"
        curl -fL "https://github.com/neovim/neovim/releases/download/${VERSION}/${ASSET_OLD}" -o /tmp/nvim.tar.gz
      fi

      printf "${YELLOW}Extracting...${RESET}\n"
      tar -xzf /tmp/nvim.tar.gz -C "$NVIM_DIR" --strip-components=1
      rm /tmp/nvim.tar.gz
      printf "${GREEN}[OK] Neovim installed to ${BOLD}$NVIM_DIR${RESET}\n\n"
      ;;

    OpenBSD)
      printf "${GREEN}OpenBSD detected${RESET}\n"
      $SUDO pkg_add neovim
      printf "${GREEN}[OK] Neovim installed via pkg_add${RESET}\n\n"
      return
      ;;

    FreeBSD)
      printf "${GREEN}FreeBSD detected${RESET}\n"
      $SUDO pkg install -y neovim
      printf "${GREEN}[OK] Neovim installed via pkg${RESET}\n\n"
      return
      ;;

    *)
      printf "${RED}Unsupported OS: $OS_TYPE${RESET}\n"
      exit 1
      ;;
  esac
}

install_neovim

# ============================================================
# Step 2: Add to PATH (if installed to ~/apps/nvim)
# ============================================================
if [ -d "$NVIM_DIR/bin" ]; then
  case ":$PATH:" in
    *":$NVIM_DIR/bin:"*)
      # Already in PATH
      ;;
    *)
      printf "${MAGENTA}===========================================${RESET}\n"
      printf "${CYAN}PATH Configuration${RESET}\n"
      printf "${MAGENTA}===========================================${RESET}\n\n"

      printf "${YELLOW}Add Neovim to your shell PATH automatically? (y/n): ${RESET}"
      read -r REPLY

      case "$REPLY" in
        [Yy]*)
          SHELL_RC=""
          case "$SHELL" in
            *zsh)  SHELL_RC="$HOME/.zshrc" ;;
            *bash) SHELL_RC="$HOME/.bashrc" ;;
            *ash)  SHELL_RC="$HOME/.profile" ;;
            *ksh)  SHELL_RC="$HOME/.kshrc" ;;
            *)
              printf "${YELLOW}Unknown shell: $SHELL${RESET}\n"
              printf "${BLUE}Manually add: export PATH=\"$NVIM_DIR/bin:\$PATH\"${RESET}\n\n"
              ;;
          esac

          if [ -n "$SHELL_RC" ]; then
            PATH_EXPORT="export PATH=\"$NVIM_DIR/bin:\$PATH\""
            if grep -q "$NVIM_DIR/bin" "$SHELL_RC" 2>/dev/null; then
              printf "${GREEN}[OK] PATH already configured in $SHELL_RC${RESET}\n\n"
            else
              printf "\n# Neovim\n%s\n" "$PATH_EXPORT" >> "$SHELL_RC"
              printf "${GREEN}[OK] Added to $SHELL_RC${RESET}\n"
              printf "${CYAN}Run: source $SHELL_RC${RESET}\n\n"
            fi
          fi
          ;;
        *)
          printf "${BLUE}Skipped. Add manually: export PATH=\"$NVIM_DIR/bin:\$PATH\"${RESET}\n\n"
          ;;
      esac
      ;;
  esac
fi

# ============================================================
# Step 3: Install LazyVim config
# ============================================================
printf "${MAGENTA}===========================================${RESET}\n"
printf "${CYAN}LazyVim Configuration${RESET}\n"
printf "${MAGENTA}===========================================${RESET}\n\n"

printf "${YELLOW}Install schneipp LazyVim config? (y/n): ${RESET}"
read -r REPLY

case "$REPLY" in
  [Yy]*)
    # Backup existing config
    if [ -d "$NVIM_CONFIG" ] || [ -L "$NVIM_CONFIG" ]; then
      BACKUP="$NVIM_CONFIG.backup.$(date +%s)"
      printf "${YELLOW}Backing up existing config to $BACKUP${RESET}\n"
      mv "$NVIM_CONFIG" "$BACKUP"
    fi

    # Backup nvim data directories
    for dir in "$HOME/.local/share/nvim" "$HOME/.local/state/nvim"; do
      if [ -d "$dir" ]; then
        BACKUP="$dir.backup.$(date +%s)"
        printf "${YELLOW}Backing up $dir to $BACKUP${RESET}\n"
        mv "$dir" "$BACKUP"
      fi
    done

    # Ensure .config exists and create symlink
    mkdir -p "$(dirname "$NVIM_CONFIG")"
    ln -s "$SCRIPT_DIR/lazynvim" "$NVIM_CONFIG"
    printf "${GREEN}[OK] LazyVim config symlinked to $NVIM_CONFIG${RESET}\n\n"
    ;;
  *)
    printf "${BLUE}Skipped config installation${RESET}\n\n"
    ;;
esac

# ============================================================
# Step 4: Verify installation
# ============================================================
printf "${MAGENTA}===========================================${RESET}\n"
printf "${CYAN}Verification${RESET}\n"
printf "${MAGENTA}===========================================${RESET}\n\n"

NVIM_BIN=""
if [ -x "$NVIM_DIR/bin/nvim" ]; then
  NVIM_BIN="$NVIM_DIR/bin/nvim"
elif command -v nvim >/dev/null 2>&1; then
  NVIM_BIN="nvim"
fi

if [ -n "$NVIM_BIN" ]; then
  NVIM_VERSION=$("$NVIM_BIN" --version 2>/dev/null | head -n1)
  printf "${GREEN}${BOLD}[OK] Installation successful!${RESET}\n"
  printf "${CYAN}Version: ${BOLD}$NVIM_VERSION${RESET}\n\n"
else
  printf "${RED}${BOLD}Installation may have failed - nvim not found${RESET}\n\n"
  exit 1
fi

# ============================================================
# Step 5: Offer tmux setup
# ============================================================
printf "${MAGENTA}===========================================${RESET}\n"
printf "${CYAN}Tmux Configuration${RESET}\n"
printf "${MAGENTA}===========================================${RESET}\n\n"

printf "${YELLOW}Would you also like to set up tmux? (y/n): ${RESET}"
read -r REPLY

case "$REPLY" in
  [Yy]*)
    if [ -f "$SCRIPT_DIR/install-tmux.sh" ]; then
      exec sh "$SCRIPT_DIR/install-tmux.sh"
    else
      printf "${RED}Tmux installer not found${RESET}\n"
    fi
    ;;
  *)
    printf "${BLUE}Skipped. Run later: sh $SCRIPT_DIR/install-tmux.sh${RESET}\n\n"
    ;;
esac

printf "${MAGENTA}===========================================${RESET}\n"
printf "${GREEN}${BOLD}   All done! Happy coding!${RESET}\n"
printf "${MAGENTA}===========================================${RESET}\n\n"
