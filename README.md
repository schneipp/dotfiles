# dotfiles

Personal dotfiles for Neovim, tmux, Hyprland, and more.

## One-Line Install

**Get a fully configured Neovim + tmux setup on any system:**

```bash
curl -sSL https://raw.githubusercontent.com/schneipp/dotfiles/master/neovimizer.sh | sh
```

That's it! The script handles everything automatically.

### What happens:
1. Installs `git` and `curl` (if missing)
2. Clones this dotfiles repo to `~/dotfiles`
3. Installs the **latest Neovim** (fetched from GitHub releases)
4. Symlinks LazyVim config to `~/.config/nvim`
5. Backs up any existing configs automatically
6. Configures UTF-8 locale and PATH
7. Optionally sets up **tmux** with Tokyo Night theme

### Tmux Only

If you just want tmux:

```bash
curl -sSL https://raw.githubusercontent.com/schneipp/dotfiles/master/tmuxizer.sh | sh
```

### Supported Platforms
- macOS (Homebrew)
- Debian/Ubuntu (apt)
- Fedora/RHEL (dnf)
- Arch Linux (pacman)
- Alpine Linux (apk)
- OpenBSD (pkg_add)
- FreeBSD (pkg)

Works in Docker containers, SSH sessions, and minimal environments.

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
