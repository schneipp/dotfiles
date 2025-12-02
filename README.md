# dotfiles
My Dotfiles..
nvim tweaked for rust
awesomewm, slightly tweaked
i3 & polybar setup
and things i dont remember, but notice if they are missing

## Quick Neovim Install

Get the latest Neovim installed quickly with schneipp's installer script:

```bash
# Using curl
curl -sSL https://raw.githubusercontent.com/schneipp/dotfiles/master/getnv.sh | sh

# Or using wget
wget -qO- https://raw.githubusercontent.com/schneipp/dotfiles/master/getnv.sh | sh

# Or clone and run locally (to get LazyVim config option)
git clone https://github.com/schneipp/dotfiles.git
cd dotfiles
sh getnv.sh
```

Supports: macOS, Alpine Linux, Debian/Ubuntu, Fedora

## Environment Variables

Database configurations require the following environment variables:

```bash
export POSTGRES_PASSWORD="your-password"
export POSTGRES_HOST="172.17.0.1"  # optional, defaults to 172.17.0.1
```

Add these to your `~/.bashrc` or `~/.zshrc`.
