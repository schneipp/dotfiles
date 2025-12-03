#!/bin/sh
# POSIX-compliant script - works with bash, ash, sh
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

# ASCII Art
clear
cat << "EOF"
   ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
   ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
   ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
   ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
   ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
   ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝

EOF
printf "${CYAN}${BOLD}    ✨ schneipp's Neovim Installation Script ✨${RESET}\n"
printf "${MAGENTA}    ═══════════════════════════════════════════${RESET}\n\n"

NVIM_DIR="$HOME/apps/nvim"
VERSION="v0.10.4"

printf "${BLUE}📦 Installing Neovim ${BOLD}$VERSION${RESET}${BLUE}...${RESET}\n\n"

# Create directory if needed
mkdir -p "$NVIM_DIR"

# Detect OS and install
OS_TYPE=$(uname -s)
case "$OS_TYPE" in
  Darwin)
    printf "${GREEN}🍎 macOS detected${RESET}\n\n"

    # Download macOS binary
    printf "${YELLOW}⬇️  Downloading...${RESET}\n"
    if ! curl -fL "https://github.com/neovim/neovim/releases/download/${VERSION}/nvim-macos-x86_64.tar.gz" -o /tmp/nvim.tar.gz; then
      printf "${RED}❌ Failed to download Neovim${RESET}\n"
      exit 1
    fi

    # Extract (strip the nvim-macos-x86_64 wrapper directory)
    printf "${YELLOW}📂 Extracting...${RESET}\n"
    tar -xzf /tmp/nvim.tar.gz -C "$NVIM_DIR" --strip-components=1
    rm /tmp/nvim.tar.gz

    printf "${GREEN}✓ Neovim installed to ${BOLD}$NVIM_DIR${RESET}\n"
    printf "${GREEN}✓ Binary location: ${BOLD}$NVIM_DIR/bin/nvim${RESET}\n\n"
    ;;

  Linux)
    # Detect Linux distribution
    if [ -f /etc/alpine-release ]; then
      printf "${GREEN}🏔️  Alpine Linux detected${RESET}\n\n"

      # Alpine uses apk
      apk add --no-cache neovim

    elif [ -f /etc/fedora-release ]; then
      printf "${GREEN}🎩 Fedora detected${RESET}\n\n"
      sudo dnf install -y neovim

    elif [ -f /etc/apt/sources.list ]; then
      printf "${GREEN}🐧 Debian-based system detected${RESET}\n\n"

      sudo apt update
      sudo apt install -y curl

      printf "${YELLOW}⬇️  Downloading...${RESET}\n"
      if ! curl -fL "https://github.com/neovim/neovim/releases/download/${VERSION}/nvim-linux64.tar.gz" -o /tmp/nvim.tar.gz; then
        printf "${RED}❌ Failed to download Neovim${RESET}\n"
        exit 1
      fi

      # Extract (strip the nvim-linux64 wrapper directory)
      printf "${YELLOW}📂 Extracting...${RESET}\n"
      tar -xzf /tmp/nvim.tar.gz -C "$NVIM_DIR" --strip-components=1
      rm /tmp/nvim.tar.gz

      printf "${GREEN}✓ Neovim installed to ${BOLD}$NVIM_DIR${RESET}\n"
      printf "${GREEN}✓ Binary location: ${BOLD}$NVIM_DIR/bin/nvim${RESET}\n\n"

    else
      printf "${RED}❌ Unsupported Linux distribution${RESET}\n"
      exit 1
    fi
    ;;

  *)
    printf "${RED}❌ Unsupported OS: $OS_TYPE${RESET}\n"
    exit 1
    ;;
esac

# Add to PATH
case ":$PATH:" in
  *":$NVIM_DIR/bin:"*)
    # Already in PATH, skip
    ;;
  *)
    if [ -d "$NVIM_DIR/bin" ]; then
      printf "${MAGENTA}═══════════════════════════════════════════${RESET}\n"
      printf "${CYAN}🛤️  PATH Configuration${RESET}\n"
      printf "${MAGENTA}═══════════════════════════════════════════${RESET}\n\n"

      printf "${YELLOW}Add Neovim to your shell PATH automatically? (y/n): ${RESET}"
      read -r REPLY

      case "$REPLY" in
        [Yy]*)
          # Detect shell
          SHELL_RC=""
          case "$SHELL" in
            *zsh)
              SHELL_RC="$HOME/.zshrc"
              ;;
            *bash)
              SHELL_RC="$HOME/.bashrc"
              ;;
            *ash)
              # Alpine/BusyBox uses ash, typically with profile
              SHELL_RC="$HOME/.profile"
              ;;
            *)
              printf "${RED}⚠️  Unknown shell: $SHELL${RESET}\n"
              printf "${BLUE}Manually add to your shell config:${RESET}\n"
              printf "${BOLD}  export PATH=\"%s/bin:\$PATH\"${RESET}\n\n" "$NVIM_DIR"
              ;;
          esac

          if [ -n "$SHELL_RC" ]; then
            # Check if already in config
            PATH_EXPORT="export PATH=\"$NVIM_DIR/bin:\$PATH\""
            if grep -q "$PATH_EXPORT" "$SHELL_RC" 2>/dev/null; then
              printf "${GREEN}✓ PATH already configured in ${BOLD}$SHELL_RC${RESET}\n\n"
            else
              printf "\n# Neovim\n%s\n" "$PATH_EXPORT" >> "$SHELL_RC"
              printf "${GREEN}✓ Added to ${BOLD}$SHELL_RC${RESET}\n"
              printf "${CYAN}💡 Run: ${BOLD}source $SHELL_RC${RESET}${CYAN} (or restart your terminal)${RESET}\n\n"
            fi
          fi
          ;;
        *)
          printf "${BLUE}Skipped. Manually add to your shell config:${RESET}\n"
          printf "${BOLD}  export PATH=\"%s/bin:\$PATH\"${RESET}\n\n" "$NVIM_DIR"
          ;;
      esac
    fi
    ;;
esac

# Offer to install schneipp's neovim config
printf "${MAGENTA}═══════════════════════════════════════════${RESET}\n"
printf "${CYAN}⚙️  Configuration Setup${RESET}\n"
printf "${MAGENTA}═══════════════════════════════════════════${RESET}\n\n"

# Detect script directory (only works when run from file, not from curl | sh)
if [ -n "$0" ] && [ "$0" != "sh" ] && [ "$0" != "bash" ] && [ "$0" != "-sh" ] && [ "$0" != "-bash" ]; then
  SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"
else
  SCRIPT_DIR=""
fi

DOTFILES_DIR="$HOME/dotfiles"
NVIM_CONFIG="$HOME/.config/nvim"

# Ask if user wants LazyVim config
printf "${YELLOW}Install schneipp's LazyVim config? (y/n): ${RESET}"
read -r REPLY

case "$REPLY" in
  [Yy]*)
    # Backup existing config if present
    if [ -d "$NVIM_CONFIG" ] || [ -L "$NVIM_CONFIG" ]; then
      BACKUP="$NVIM_CONFIG.backup.$(date +%s)"
      printf "${YELLOW}📦 Backing up existing config to ${BOLD}$BACKUP${RESET}\n"
      mv "$NVIM_CONFIG" "$BACKUP"
    fi

    # Backup nvim data directories (share and state)
    NVIM_SHARE="$HOME/.local/share/nvim"
    NVIM_STATE="$HOME/.local/state/nvim"

    if [ -d "$NVIM_SHARE" ]; then
      SHARE_BACKUP="$NVIM_SHARE.backup.$(date +%s)"
      printf "${YELLOW}📦 Backing up ${BOLD}$NVIM_SHARE${RESET}${YELLOW} to ${BOLD}$SHARE_BACKUP${RESET}\n"
      mv "$NVIM_SHARE" "$SHARE_BACKUP"
    fi

    if [ -d "$NVIM_STATE" ]; then
      STATE_BACKUP="$NVIM_STATE.backup.$(date +%s)"
      printf "${YELLOW}📦 Backing up ${BOLD}$NVIM_STATE${RESET}${YELLOW} to ${BOLD}$STATE_BACKUP${RESET}\n"
      mv "$NVIM_STATE" "$STATE_BACKUP"
    fi

    # Check if running locally with lazynvim folder
    if [ -n "$SCRIPT_DIR" ] && [ -d "$SCRIPT_DIR/lazynvim" ]; then
      # Running locally - symlink from script directory
      printf "${YELLOW}🔗 Creating symlink from ${BOLD}$SCRIPT_DIR/lazynvim${RESET}\n"
      ln -s "$SCRIPT_DIR/lazynvim" "$NVIM_CONFIG"
      printf "${GREEN}✓ LazyVim config symlinked to ${BOLD}$NVIM_CONFIG${RESET}\n\n"
    else
      # Running remotely or no local config - clone dotfiles
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
        else
          printf "${GREEN}✓ Dotfiles cloned to ${BOLD}$DOTFILES_DIR${RESET}\n"
        fi
      fi

      # Create symlink if clone succeeded
      if [ -d "$DOTFILES_DIR/lazynvim" ]; then
        printf "${YELLOW}🔗 Creating symlink...${RESET}\n"
        ln -s "$DOTFILES_DIR/lazynvim" "$NVIM_CONFIG"
        printf "${GREEN}✓ LazyVim config symlinked to ${BOLD}$NVIM_CONFIG${RESET}\n\n"
      else
        printf "${RED}❌ LazyVim config not found in dotfiles${RESET}\n\n"
      fi
    fi
    ;;
  *)
    printf "${BLUE}Skipped config installation${RESET}\n\n"
    ;;
esac

# Verify installation
printf "${MAGENTA}═══════════════════════════════════════════${RESET}\n"
printf "${CYAN}🔍 Verification${RESET}\n"
printf "${MAGENTA}═══════════════════════════════════════════${RESET}\n\n"

if [ -x "$NVIM_DIR/bin/nvim" ]; then
  NVIM_VERSION=$("$NVIM_DIR/bin/nvim" --version 2>/dev/null | head -n1)
  printf "${GREEN}${BOLD}✓ Installation successful!${RESET}\n"
  printf "${CYAN}📍 Version: ${BOLD}$NVIM_VERSION${RESET}\n\n"

  printf "${MAGENTA}═══════════════════════════════════════════${RESET}\n"
  printf "${GREEN}${BOLD}   🎉 All done! Happy coding! 🎉${RESET}\n"
  printf "${MAGENTA}═══════════════════════════════════════════${RESET}\n\n"

elif command -v nvim >/dev/null 2>&1; then
  NVIM_VERSION=$(nvim --version 2>/dev/null | head -n1)
  printf "${GREEN}${BOLD}✓ Installation successful!${RESET}\n"
  printf "${CYAN}📍 Version: ${BOLD}$NVIM_VERSION${RESET}\n\n"

  printf "${MAGENTA}═══════════════════════════════════════════${RESET}\n"
  printf "${GREEN}${BOLD}   🎉 All done! Happy coding! 🎉${RESET}\n"
  printf "${MAGENTA}═══════════════════════════════════════════${RESET}\n\n"

else
  printf "${RED}${BOLD}❌ Installation may have failed - nvim not found${RESET}\n\n"
  exit 1
fi

# Offer to configure tmux
printf "${MAGENTA}═══════════════════════════════════════════${RESET}\n"
printf "${CYAN}🖥️  Tmux Configuration${RESET}\n"
printf "${MAGENTA}═══════════════════════════════════════════${RESET}\n\n"

printf "${YELLOW}Would you also like to set up tmux with schneipp's config? (y/n): ${RESET}"
read -r REPLY

case "$REPLY" in
  [Yy]*)
    printf "${CYAN}Launching tmuxizer...${RESET}\n\n"
    # Check if running locally
    if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/tmuxizer.sh" ]; then
      sh "$SCRIPT_DIR/tmuxizer.sh"
    else
      # Running remotely - fetch and run tmuxizer
      curl -sSL https://raw.githubusercontent.com/schneipp/dotfiles/master/tmuxizer.sh | sh
    fi
    ;;
  *)
    printf "${BLUE}Skipped tmux configuration${RESET}\n"
    printf "${CYAN}💡 You can run it later with:${RESET}\n"
    printf "${BOLD}   curl -sSL https://raw.githubusercontent.com/schneipp/dotfiles/master/tmuxizer.sh | sh${RESET}\n\n"
    ;;
esac
