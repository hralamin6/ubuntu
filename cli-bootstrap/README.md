# CLI Bootstrap

> **Production-quality Linux CLI framework for developers, DevOps engineers, and cloud engineers.**

[![Version](https://img.shields.io/badge/version-1.0.0-blue?style=flat-square)](VERSION)
[![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Ubuntu%2022.04%20%7C%2024.04%20%7C%20Debian%2012%20%7C%2013-orange?style=flat-square)](#)
[![Arch](https://img.shields.io/badge/arch-amd64%20%7C%20arm64-purple?style=flat-square)](#)

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [What Gets Installed](#what-gets-installed)
- [Project Structure](#project-structure)
- [Usage](#usage)
- [Customization](#customization)
- [Updating](#updating)
- [Uninstalling](#uninstalling)
- [Doctor & Self-Healing](#doctor--self-healing)
- [Backup & Restore](#backup--restore)
- [Troubleshooting](#troubleshooting)
- [FAQ](#faq)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

CLI Bootstrap is a **modular, idempotent, production-quality** CLI environment framework. It transforms a bare Ubuntu/Debian server or workstation into a fully equipped developer workstation in minutes.

**Designed for:**
- Developers & Backend Engineers
- DevOps & Cloud Engineers
- Laravel/PHP Developers
- Security Researchers

**Key principles:**
- **Idempotent** — Run it twice, get the same result. Never breaks existing setups.
- **Safe** — Every modified file is backed up with a timestamp before overwriting.
- **Modular** — Each component is independent. Disable anything you don't need.
- **Fast** — Zsh startup under 80ms via lazy loading and completion caching.
- **Documented** — Every file has clear comments explaining what it does and why.

---

## Features

### Shell Environment
- **Zsh** with 30+ carefully chosen `setopt` options (no Oh My Zsh overhead)
- **Starship** prompt with Catppuccin Macchiato theme — shows git, docker, k8s, all cloud providers, 8 languages, battery, time
- **Atuin** for SQLite-backed fuzzy shell history with timeline search
- **Zoxide** for intelligent directory jumping
- Smart tab completion with `fzf-tab` (previews via `bat` and `eza`)

### Zsh Plugins (7, no plugin manager)
| Plugin | Purpose |
|---|---|
| zsh-autosuggestions | Fish-style inline suggestions |
| zsh-syntax-highlighting | Real-time command coloring |
| zsh-completions | Extended completion library |
| fzf-tab | FZF-powered completion with previews |
| history-substring-search | Arrow-key fuzzy history |
| you-should-use | Alias reminder system |
| alias-tips | Suggest aliases for typed commands |

### CLI Tools
| Tool | Purpose |
|---|---|
| `fzf` | Fuzzy finder — Ctrl+R, Ctrl+T, Alt+C |
| `bat` | `cat` with syntax highlighting |
| `eza` | Modern `ls` with icons and git status |
| `fd` | Fast `find` alternative |
| `ripgrep` | Fast `grep` alternative |
| `delta` | Beautiful git diffs |
| `lazygit` | Terminal UI for git |
| `atuin` | Shell history with search |
| `zoxide` | Smart `cd` |
| `yazi` | Terminal file manager |
| `btop` | Resource monitor |
| `jq` / `yq` | JSON/YAML processors |
| `xh` | Modern HTTP client |
| `doggo` | DNS lookup tool |
| `direnv` | Per-directory env vars |
| `thefuck` | Command correction |
| `gh` | GitHub CLI |
| `tldr` | Quick man pages |
| `hyperfine` | Benchmarking tool |

### Aliases — 160+
Categories: Navigation, Filesystem, Git, Docker, Laravel, PHP, Python, Node, Nginx, Apache, System, Monitoring, Networking, SSH, Compression, Package management, Clipboard, Search, Logs, Supervisor, Systemd, Security, Cloud (AWS/k8s/Terraform/GCP/Azure)

### Shell Functions — 110+
| Category | Examples |
|---|---|
| Filesystem | `extract`, `compress`, `mkcd`, `serve`, `find-large-files`, `fix-permissions` |
| Git | `git-clean`, `fuzzy-git-log`, `git-stats`, `git-switch-fzf`, `git-standup` |
| Docker | `docker-clean`, `denter`, `dlogs`, `dstats`, `dupbuild` |
| Laravel | `new-laravel`, `laravel-scaffold`, `fresh-db`, `laravel-clear-all`, `php-lint` |
| Network | `myip`, `killport`, `dns-lookup`, `ssl-expiry`, `ssh-tunnel`, `dns-propagation` |
| System | `sysinfo`, `benchmark`, `timer`, `cpu-temp`, `boot-analysis`, `genpasswd` |
| Dev | `json-pretty`, `yaml-pretty`, `jwt-decode`, `fuzzy-cd`, `port-check` |
| Misc | `weather`, `calc`, `colors`, `remind`, `qr`, `days-until` |

### Tmux Configuration
- True color support
- Mouse support with smart scroll
- Vi copy mode with clipboard integration (xclip/wl-copy)
- Catppuccin Macchiato status bar
- Smart pane switching (vim-aware)
- Floating popups for lazygit, yazi, fzf

### Git Configuration
- `delta` pager with syntax highlighting
- Histogram diff algorithm
- 80+ git aliases
- `zdiff3` conflict style
- URL shortcuts (`gh:`, `gl:`, `bb:`)
- Comprehensive global `.gitignore`

---

## Requirements

| Requirement | Version |
|---|---|
| OS | Ubuntu 22.04/24.04 or Debian 12/13 |
| Architecture | amd64 or arm64 |
| Shell | bash 4+ (for running bootstrap) |
| Internet | Required for package and tool downloads |
| Privileges | sudo or root |
| Disk space | ~500MB (packages + tools) |

---

## Installation

### Quick Install

```bash
git clone https://github.com/yourorg/cli-bootstrap.git
cd cli-bootstrap
chmod +x install.sh
sudo ./install.sh
```

### Manual Step-by-Step

```bash
# 1. Clone the repository
git clone https://github.com/yourorg/cli-bootstrap.git ~/cli-bootstrap
cd ~/cli-bootstrap

# 2. Review what will be installed
cat README.md

# 3. Run the bootstrapper
sudo bash bootstrap.sh

# 4. Reload your shell
exec zsh

# 5. Verify everything works
./doctor.sh
```

### Non-Interactive Install (CI/CD)

```bash
sudo bash bootstrap.sh --non-interactive
```

### Verbose/Debug Mode

```bash
sudo bash bootstrap.sh --verbose
```

---

## What Gets Installed

### System Packages (via apt)
```
curl wget git zsh tmux vim build-essential
fzf fd-find bat ripgrep jq tree rsync htop btop
ncdu tldr thefuck direnv openssh-client
net-tools dnsutils python3 python3-pip python3-venv
```

### Binary Tools (from upstream)
```
starship   — prompt (https://starship.rs)
zoxide     — smart cd (https://github.com/ajeetdsouza/zoxide)
atuin      — shell history (https://atuin.sh)
delta      — git diff (https://github.com/dandavison/delta)
yazi       — file manager (https://github.com/sxyazi/yazi)
lazygit    — git TUI (https://github.com/jesseduffield/lazygit)
gh         — GitHub CLI (https://cli.github.com)
```

### Configuration Files
```
~/.zshrc                      — main Zsh config
~/.zshenv                     — environment variables
~/.gitconfig                  — git config with delta
~/.config/git/ignore          — global gitignore
~/.config/starship.toml       — prompt theme
~/.tmux.conf                  — tmux config
~/.config/atuin/config.toml   — history config
~/.config/yazi/               — file manager config
```

### Installed Under `~/.cli-bootstrap/`
```
~/.cli-bootstrap/
├── plugins/          — zsh plugin repos
├── aliases/          — alias files
├── functions/        — function files
└── backups/          — timestamped backups
```

---

## Project Structure

```
cli-bootstrap/
├── bootstrap.sh        # Master installer (6-step pipeline)
├── install.sh          # Entry point wrapper
├── uninstall.sh        # Clean removal + restore
├── update.sh           # Update everything safely
├── doctor.sh           # Diagnostics + auto-fix
├── backup.sh           # Standalone backup utility
├── restore.sh          # Standalone restore utility
├── VERSION             # Semantic version
├── CHANGELOG.md        # Full changelog
├── LICENSE             # MIT
├── README.md           # This file
│
├── lib/
│   ├── core.sh         # Colors, logging, traps, rollback
│   ├── detect.sh       # System/env detection
│   ├── pkg.sh          # APT abstraction
│   ├── backup.sh       # Backup engine
│   ├── ui.sh           # Terminal UI components
│   └── utils.sh        # Misc helpers
│
├── configs/
│   ├── zshrc           # ~/.zshrc
│   ├── zshenv          # ~/.zshenv
│   ├── starship.toml   # Starship prompt
│   ├── tmux.conf       # Tmux config
│   ├── gitconfig       # Git config
│   ├── gitignore_global
│   ├── atuin.toml
│   ├── yazi/           # Yazi file manager
│   └── btop/           # btop monitor
│
├── plugins/
│   └── install.sh      # Plugin installer
│
├── aliases/            # 17 alias category files
├── functions/          # 8 function category files
└── themes/             # Starship themes
    ├── default.toml
    ├── minimal.toml
    └── powerline.toml
```

---

## Usage

### After Installation

```bash
# Reload shell
exec zsh

# Check everything works
./doctor.sh

# See all available aliases
alias | sort | less

# See all functions
typeset -f | grep "^[a-z]" | sort
```

### Yazi File Manager

```bash
y              # Open Yazi (with cwd tracking)
```

Press `h/j/k/l` to navigate, `Enter` to open, `q` to quit.

### FZF Key Bindings

| Key | Action |
|---|---|
| `Ctrl+R` | Fuzzy history search |
| `Ctrl+T` | Fuzzy file search |
| `Alt+C` | Fuzzy directory jump |
| `Tab` | FZF-powered completion |

### Atuin History

```bash
atuin search          # Search history
Ctrl+R                # Interactive TUI search
```

### Lazygit

```bash
lg                    # Open lazygit
```

---

## Customization

### Override Zsh Config

Create `~/.zshrc.local` — it's sourced at the end of `~/.zshrc`:

```zsh
# ~/.zshrc.local
export EDITOR="code"
export PROJECTS_DIR="${HOME}/Sites"
alias myalias="echo hello"
```

### Override Git Config

Create `~/.gitconfig.local`:

```ini
[user]
    name = Your Name
    email = you@example.com

[commit]
    gpgsign = true
```

### Change Starship Theme

```bash
# Switch to minimal theme
cp ~/.cli-bootstrap/../themes/minimal.toml ~/.config/starship.toml

# Switch to powerline theme
cp ~/.cli-bootstrap/../themes/powerline.toml ~/.config/starship.toml

# Edit the current theme
starshipconf  # alias for: nvim ~/.config/starship.toml
```

### Add Custom Aliases

```bash
# Edit the appropriate category file
nvim ~/.cli-bootstrap/aliases/navigation.sh

# Or create a new file
cat > ~/.cli-bootstrap/aliases/my.sh << 'EOF'
alias myproject='cd ~/projects/myapp && git status'
EOF
```

### Add Custom Functions

```bash
cat > ~/.cli-bootstrap/functions/my.sh << 'EOF'
my-function() {
  echo "Hello from my function"
}
EOF
```

### Disable a Plugin

Edit `~/.zshrc` and comment out the plugin load line:

```zsh
# Disable you-should-use
# __load_plugin "${CLI_BOOTSTRAP_PLUGINS}/zsh-you-should-use/..."
```

### Change Tmux Prefix

Edit `~/.tmux.conf` and uncomment:

```bash
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix
```

---

## Updating

```bash
cd ~/cli-bootstrap
git pull
./update.sh
```

Or update individual components:

```bash
# Update only zsh plugins
bash plugins/install.sh update

# Update only starship
curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
```

---

## Uninstalling

```bash
cd ~/cli-bootstrap
./uninstall.sh
```

This will:
1. Restore your original dotfiles from backup
2. Remove `~/.cli-bootstrap/plugins`, aliases, functions
3. Optionally remove `~/.cli-bootstrap` entirely
4. Optionally reset your default shell

---

## Doctor & Self-Healing

Run diagnostics:

```bash
./doctor.sh
```

Run with auto-fix (attempts to repair failed checks):

```bash
./doctor.sh --fix
```

The doctor checks:
- Required binaries (zsh, git, curl, fzf, etc.)
- Recommended tools (starship, bat, eza, delta, etc.)
- Zsh config syntax validity
- Plugin installation
- Starship binary and config
- Git user configuration
- FZF key binding integration
- Atuin database
- Broken symlinks in PATH

---

## Backup & Restore

Every time a config file is modified, a timestamped backup is created at:

```
~/.cli-bootstrap/backups/<timestamp>/
├── files/home/<user>/.zshrc
├── files/home/<user>/.gitconfig
└── manifest.json
```

### Manual Backup

```bash
./backup.sh backup
./backup.sh list
./backup.sh purge 5    # Keep last 5 sessions
```

### Manual Restore

```bash
./restore.sh            # Restore from latest backup
./restore.sh 20260707_141500   # Restore specific session
```

---

## Troubleshooting

### Zsh doesn't start / error on shell init

```bash
# Check syntax
zsh -n ~/.zshrc

# Start zsh with no rc
zsh --no-rcs

# Re-run doctor
bash ~/cli-bootstrap/doctor.sh
```

### Starship prompt not showing

```bash
# Check if binary is installed
which starship

# Check config
starship config

# Reinstall
curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
```

### Slow shell startup (>80ms)

```bash
# Measure startup time
time zsh -i -c exit

# Profile what's slow
zsh -i -c 'zprof' 2>&1 | head -20
```

Add `zmodload zsh/zprof` at the top of `~/.zshrc` to enable profiling.

### FZF not working

```bash
# Check if installed
which fzf

# Reinstall completion
$(brew --prefix)/opt/fzf/install  # macOS
/usr/share/doc/fzf/examples/key-bindings.zsh  # Linux
```

### atuin not syncing history

Sync is disabled by default. To enable, edit `~/.config/atuin/config.toml`:

```toml
[sync]
enabled = true
```

Then run `atuin register` or `atuin login`.

### Git delta not working

```bash
# Check if delta is installed
which delta

# Check git config
git config --global core.pager

# Reinstall delta
# See bootstrap.sh install_binary_tools()
```

---

## FAQ

**Q: Does this work on macOS?**

Not officially. The bootstrap uses `apt-get` for package management. macOS support via Homebrew is planned.

**Q: Can I run this on a production server?**

Yes. The bootstrap is designed to be safe on servers. It:
- Never deletes existing configs without backup
- Skips packages that aren't available
- Doesn't install desktop/GUI components by default
- Is fully reversible via `uninstall.sh`

**Q: Will this break my existing `.zshrc`?**

No. Your existing `.zshrc` is backed up before any modification. You can restore it at any time.

**Q: How do I keep just the aliases without the full install?**

```bash
# Source only what you want in ~/.zshrc.local
source ~/cli-bootstrap/aliases/git.sh
source ~/cli-bootstrap/functions/docker.sh
```

**Q: Does it work in Docker containers?**

Yes. Container detection is built-in. Some features (like WSL/VM detection) are skipped automatically.

**Q: How do I add my own Starship segment?**

Edit `~/.config/starship.toml` and add your segment. See [starship.rs/config](https://starship.rs/config) for all available modules.

**Q: Can I use Oh My Zsh alongside this?**

Not recommended — they conflict. This bootstrap intentionally replaces OMZ with a lighter, faster native setup.

**Q: Is this compatible with NVM?**

Yes. NVM is lazy-loaded in `~/.zshrc` to avoid adding startup overhead. It's activated on first use.

**Q: How do I update just git aliases?**

Edit `~/.cli-bootstrap/aliases/git.sh` — changes take effect on next shell reload (`exec zsh`).

**Q: What if a binary tool fails to install?**

The bootstrap gracefully skips any tool that fails to install and logs the error. Run `./doctor.sh` afterwards to see what's missing.

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/my-feature`
3. Make your changes following the existing style
4. Run `shellcheck` on any modified shell files
5. Update `CHANGELOG.md`
6. Open a pull request

### Code Style

- All shell files use `#!/usr/bin/env bash` and `set -Eeuo pipefail`
- Use `log_*` functions from `lib/core.sh` (never raw `echo`)
- Every new feature must be idempotent
- New packages must use `pkg_install`/`pkg_install_batch` (never bare `apt-get`)
- New config files must use `safe_install_file` (never bare `cp`)

---

## License

MIT License — see [LICENSE](LICENSE) for details.

---

*Built with ❤️ for developers who live in the terminal.*
