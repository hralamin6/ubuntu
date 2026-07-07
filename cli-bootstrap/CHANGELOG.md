# Changelog

All notable changes to cli-bootstrap are documented in this file.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] — 2026-07-07

### Added

#### Framework
- `bootstrap.sh` — Master orchestrator with 6-step install pipeline
- `install.sh` — Thin wrapper for bootstrap.sh
- `uninstall.sh` — Clean removal with backup restore
- `update.sh` — Safe update of all components
- `doctor.sh` — Self-healing diagnostics with `--fix` mode
- `backup.sh` — Standalone backup utility
- `restore.sh` — Standalone restore utility

#### Library (`lib/`)
- `core.sh` — Color system (8/256/truecolor), structured logging, rollback stack, ERR/INT/TERM traps
- `detect.sh` — Full environment fingerprinting: OS, arch, kernel, shell, terminal, PKG manager, VM, cloud, WSL, SSH, container, display, hardware, network
- `pkg.sh` — Idempotent apt abstraction: single/batch install, binary downloads, cargo support, error tracking
- `backup.sh` — Timestamped backup sessions with JSON manifest, LIFO restore, session purging
- `ui.sh` — Banner, spinner, progress bar, confirmation prompts, status tables, success summary
- `utils.sh` — Safe symlinks, temp files, version comparison, git clone-or-update, append-if-missing

#### Configuration (`configs/`)
- `zshenv` — XDG paths, PATH construction, editor/pager config, FZF/bat/ripgrep env vars
- `zshrc` — Full zsh setup: 30+ setopt flags, compinit caching, plugin loading, keybindings, lazy loaders
- `starship.toml` — Catppuccin Macchiato palette, 20+ segments: git, docker, k8s, AWS/GCP/Azure, all languages, battery, time
- `tmux.conf` — Mouse, vi mode, true color, Catppuccin status bar, smart pane switching, clipboard, popups
- `gitconfig` — Delta pager, histogram diff, 80+ aliases, URL shortcuts, `zdiff3` conflict style
- `gitignore_global` — Comprehensive global ignore: 10 languages, IDEs, secrets, build artifacts
- `atuin.toml` — Fuzzy history, global filter mode, sync disabled by default
- `yazi/yazi.toml` — File manager config with openers, image preview, archive support
- `yazi/keymap.toml` — Vim-like navigation, tabs, search, sort, shell integration
- `yazi/theme.toml` — Catppuccin Macchiato icons, filetype colors, status bar styling

#### Zsh Plugins
- `zsh-autosuggestions` — Fish-style suggestions with async mode
- `zsh-syntax-highlighting` — Command syntax coloring with custom style config
- `zsh-completions` — Extended completion library
- `fzf-tab` — FZF-powered tab completion with bat/eza previews
- `zsh-history-substring-search` — Fuzzy history search via arrow keys
- `zsh-you-should-use` — Alias reminder system
- `alias-tips` — Alias suggestion on full command use

#### Aliases (`aliases/`) — 160+ total
- `navigation.sh` — cd shortcuts, eza-based ls variants, zoxide, fzf navigation
- `filesystem.sh` — bat, fd, ripgrep, archives, permissions, clipboard, checksum
- `git.sh` — Full git workflow: branch, commit, log, push/pull, stash, rebase, lazygit, gh
- `docker.sh` — Docker containers, images, volumes, networks, compose workflows
- `laravel.sh` — Artisan, Sail, migrations, make commands, Composer, phpunit, pest, phpstan
- `python.sh` — py3, pip, virtualenv, poetry, conda, pytest, linting
- `node.sh` — npm, yarn, pnpm, bun, nvm, TypeScript, frontend tooling
- `system.sh` — systemd, apt, users, disk, kernel, power management
- `networking.sh` — IP info, ports, HTTP testing (xh/curl), SSH, DNS, firewall
- `cloud.sh` — AWS, kubectl, Helm, Terraform, GCP (gcloud), Azure (az)
- `monitoring.sh` — Logs, process/disk/network monitoring, fail2ban, supervisor, benchmarking
- `nginx.sh` — nginx + apache + systemd + security/SSL + compression + apt
- `security.sh` — Permission auditing, nmap, lynis
- `supervisor.sh` — Supervisor control extras
- `systemd.sh` — User-level systemd extras
- `compression.sh` — Archive format extras
- `package.sh` — APT extras

#### Functions (`functions/`) — 110+ total
- `filesystem.sh` — extract, compress, mkcd, serve, find-large-files, disk-report, fix-permissions
- `git.sh` — git-clean, fuzzy-log, conventional commits, git-stats, fzf branch switcher, standup
- `docker.sh` — docker-clean, denter, dlogs, dstats, docker-build-run, compose helpers
- `laravel.sh` — new-laravel, laravel-scaffold, artisan, fresh-db, tinker, php-lint, queue runner
- `network.sh` — myip, killport, dns-lookup, ssl-expiry, ssh-tunnel, speed-test, dns-propagation
- `system.sh` — sysinfo, benchmark, timer, mem/cpu-top, boot-analysis, system-clean, genpasswd
- `dev.sh` — fuzzy history/cd, JSON/YAML tools, jwt-decode, base64, port-check, mock-server
- `misc.sh` — weather, calc, colors, timer, remind, qr, unicode, days-until, motd

#### Themes (`themes/`)
- `default.toml` — Full Catppuccin Macchiato theme
- `minimal.toml` — Ultra-minimal: directory + git + character only
- `powerline.toml` — Powerline-style colored segment theme

#### Documentation
- `README.md` — Professional documentation with TOC, features, installation, customization, FAQ
- `CHANGELOG.md` — This file
- `LICENSE` — MIT
- `VERSION` — 1.0.0

### Technical Highlights
- Fully idempotent: safe to run multiple times
- Automatic timestamped backups before any config modification
- Complete rollback support via `uninstall.sh`
- Cloud provider detection: AWS, GCP, Azure, DigitalOcean, Hetzner
- Container detection: Docker, Podman, LXC, systemd-nspawn
- WSL v1/v2 detection
- Startup time target: <80ms via lazy loading and compinit caching
- `shellcheck`-compatible Bash strict mode throughout

---

## [Unreleased]

### Planned
- Fish shell support
- Nix/NixOS support
- Homebrew/macOS support
- Interactive TUI installer
- Plugin registry with versioning
- Automatic startup time measurement and reporting
