# dotfiles
My Dotfiles..
nvim tweaked for rust
awesomewm, slightly tweaked
i3 & polybar setup
and things i dont remember, but notice if they are missing

## Quick Neovim Install

Get the latest Neovim + LazyVim config with one command:

```bash
# Using curl (recommended)
curl -sSL https://raw.githubusercontent.com/schneipp/dotfiles/master/getnv.sh | sh

# Or using wget
wget -qO- https://raw.githubusercontent.com/schneipp/dotfiles/master/getnv.sh | sh

# Or clone and run locally
git clone https://github.com/schneipp/dotfiles.git
cd dotfiles
sh getnv.sh
```

### What it does:
- ✅ Installs Neovim v0.10.4 to `~/apps/nvim`
- ✅ Optionally adds to your shell PATH (bash/zsh/ash)
- ✅ Optionally clones this dotfiles repo and symlinks LazyVim config to `~/.config/nvim`
- ✅ Backs up existing Neovim config automatically
- ✅ Beautiful colored terminal output with ASCII art

### Supported platforms:
- macOS (Intel & Apple Silicon)
- Alpine Linux (ash/BusyBox)
- Debian/Ubuntu
- Fedora/RHEL

## Environment Variables

Database configurations require the following environment variables:

```bash
export POSTGRES_PASSWORD="your-password"
export POSTGRES_HOST="172.17.0.1"  # optional, defaults to 172.17.0.1
```

Add these to your `~/.bashrc` or `~/.zshrc`.
