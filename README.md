# dotfiles
My Dotfiles..
nvim tweaked for rust
awesomewm, slightly tweaked
i3 & polybar setup
and things i dont remember, but notice if they are missing

## Quick Install

### Neovim + LazyVim

Get the latest Neovim + LazyVim config with one command:

```bash
# Using curl (recommended)
curl -sSL https://raw.githubusercontent.com/schneipp/dotfiles/master/neovimizer.sh | sh

# Or using wget
wget -qO- https://raw.githubusercontent.com/schneipp/dotfiles/master/neovimizer.sh | sh

# Or clone and run locally
git clone https://github.com/schneipp/dotfiles.git
cd dotfiles
sh neovimizer.sh
```

**What it does:**
- Installs Neovim v0.10.4 to `~/apps/nvim`
- Optionally adds to your shell PATH (bash/zsh/ash)
- Optionally clones this dotfiles repo and symlinks LazyVim config to `~/.config/nvim`
- Backs up existing Neovim config, data (`~/.local/share/nvim`), and state (`~/.local/state/nvim`)
- Offers to set up tmux configuration afterwards

### Tmux

Set up tmux with Tokyo Night theme and TPM:

```bash
# Using curl
curl -sSL https://raw.githubusercontent.com/schneipp/dotfiles/master/tmuxizer.sh | sh

# Or clone and run locally
git clone https://github.com/schneipp/dotfiles.git
cd dotfiles
sh tmuxizer.sh
```

**What it does:**
- Installs tmux via your system package manager
- Installs TPM (Tmux Plugin Manager) to `~/.tmux/plugins/tpm`
- Symlinks config to `~/.config/tmux`
- Backs up and removes conflicting configs (`~/.tmux.conf`, `~/.tmux/tmux.conf`, etc.)
- Pre-installs tmux plugins

### Supported platforms
- macOS (Homebrew)
- Alpine Linux (apk)
- Arch Linux (pacman)
- Debian/Ubuntu (apt)
- Fedora/RHEL (dnf)

## LazyVim Customizations

My LazyVim config extends the base distribution with the following modifications:

### Disabled Defaults
- **Bufferline** - No buffer tabs at top of screen

### Added Plugins
| Plugin | Description |
|--------|-------------|
| `toggleterm.nvim` | Floating terminal (`<C-t>` to toggle) |
| `multicursor.nvim` | Multi-cursor editing (VS Code-like) |
| `workspaces.nvim` | Project workspace management (`<leader>fw`) |
| `obsidian.nvim` | Obsidian vault integration (vault: `~/Documents/allthethings`) |
| `nvim-dbee` | Database explorer UI (`<leader>db`) |
| `sqls` | SQL language server with PostgreSQL support |
| `supermaven-nvim` | AI code completion (disabled by default) |
| OSC52 clipboard | SSH/tmux-friendly clipboard via OSC52 protocol |

### Theme Options
TokyoNight (default), plus Monokai Pro, Nightfox, OneDark, and Rose Pine installed.

### Custom Keybindings
| Key | Mode | Action |
|-----|------|--------|
| `<C-t>` | n | Toggle floating terminal |
| `<leader>fw` | n | List workspaces (Telescope) |
| `<leader>bi` | n | List buffers (Telescope) |
| `<leader>db` | n | Open database UI (dbee) |
| `<S-j>` / `<S-k>` | v | Move selection down/up |
| `<up>` / `<down>` | n | Add cursor above/below |
| `<C-n>` | n/v | Add cursor at next match |

### Language Support (via LazyVim extras)
Rust, Go, Python, TypeScript, Vue, Angular, PHP, Elixir, Docker, SQL, JSON, YAML, TOML, Markdown

### Code Style
- 2-space indentation
- 120 character line width (stylua)

## Environment Variables

Database configurations require the following environment variables:

```bash
export POSTGRES_PASSWORD="your-password"
export POSTGRES_HOST="172.17.0.1"  # optional, defaults to 172.17.0.1
```

Add these to your `~/.bashrc` or `~/.zshrc`.
