#!/usr/bin/env bash
# =============================================================================
# bootstrap.sh — Master orchestrator for cli-bootstrap
# =============================================================================
set -Eeuo pipefail

BOOTSTRAP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly BOOTSTRAP_DIR
readonly BOOTSTRAP_VERSION="$(cat "${BOOTSTRAP_DIR}/VERSION" 2>/dev/null || echo '1.0.0')"

# Source libraries
source "${BOOTSTRAP_DIR}/lib/core.sh"
source "${BOOTSTRAP_DIR}/lib/detect.sh"
source "${BOOTSTRAP_DIR}/lib/pkg.sh"
source "${BOOTSTRAP_DIR}/lib/backup.sh"
source "${BOOTSTRAP_DIR}/lib/ui.sh"
source "${BOOTSTRAP_DIR}/lib/utils.sh"

# ---------------------------------------------------------------------------
# CONFIGURATION
# ---------------------------------------------------------------------------
: "${CLI_INSTALL_DIR:="${HOME}/.cli-bootstrap"}"
: "${CLI_CONFIG_DIR:="${HOME}/.config"}"
: "${CLI_MODE:="install"}"     # install | update | check
: "${CLI_NONINTERACTIVE:=0}"

export CLI_LOG_FILE="${CLI_INSTALL_DIR}/bootstrap.log"

# ---------------------------------------------------------------------------
# PARSE ARGUMENTS
# ---------------------------------------------------------------------------
parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --mode=*)        CLI_MODE="${1#--mode=}" ;;
      --non-interactive) CLI_NONINTERACTIVE=1 ;;
      --verbose)       CLI_LOG_LEVEL="${LOG_LEVEL_DEBUG}" ;;
      --silent)        CLI_LOG_LEVEL="${LOG_LEVEL_SILENT}" ;;
      --help|-h)       show_help; exit 0 ;;
      *) log_warn "Unknown argument: $1" ;;
    esac
    shift
  done
}

show_help() {
  cat <<EOF
cli-bootstrap v${BOOTSTRAP_VERSION} — Production-quality Linux CLI framework

Usage:
  bootstrap.sh [options]

Options:
  --mode=install     Full installation (default)
  --mode=update      Update all components
  --mode=check       Check only, no changes
  --non-interactive  Skip confirmation prompts
  --verbose          Enable debug logging
  --silent           Suppress all output
  --help             Show this help

EOF
}

# ---------------------------------------------------------------------------
# VALIDATION
# ---------------------------------------------------------------------------
validate_environment() {
  log_section "Environment Validation"

  detect_all
  detect_print_summary

  if ! is_supported_os; then
    log_warn "OS '${DETECT_OS_PRETTY}' is not officially supported."
    log_warn "Supported: Ubuntu 22.04/24.04, Debian 12/13"
    if ! ui_confirm "Continue anyway?" "n"; then
      die "Aborted by user."
    fi
  fi

  if ! is_apt_based; then
    die "This bootstrap requires apt (Debian/Ubuntu). Found: ${DETECT_PKG_MANAGER}"
  fi

  if ! can_escalate; then
    die "Root or sudo privileges are required."
  fi

  if ! has_internet; then
    die "No internet connection detected."
  fi

  log_success "Environment validation passed."
}

# ---------------------------------------------------------------------------
# STEP 1: SYSTEM PACKAGES
# ---------------------------------------------------------------------------
install_system_packages() {
  log_section "System Packages"

  require_root

  pkg_update

  # Core utilities
  pkg_install_batch "Core utilities" \
    curl wget git zsh tmux vim nano build-essential \
    ca-certificates gnupg lsb-release software-properties-common \
    apt-transport-https unzip zip gzip bzip2 xz-utils \
    coreutils util-linux locales tzdata

  # CLI tools (apt)
  pkg_install_batch "CLI tools" \
    fzf fd-find bat ripgrep jq tree rsync \
    htop btop ncdu duf eza \
    tldr thefuck direnv \
    openssh-client openssh-server \
    net-tools dnsutils iputils-ping nmap \
    inotify-tools lsof strace \
    python3 python3-pip python3-venv \
    bc bc jq

  # Try optional tools (graceful skip)
  pkg_install_batch "Optional tools" \
    ncal figlet toilet lolcat \
    speedtest-cli traceroute mtr \
    silversearcher-ag \
    pv progress \
    qrencode \
    cmatrix \
    fail2ban ufw \
    supervisor \
    nginx apache2

  # bat might be 'batcat' on Ubuntu/Debian
  if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
    ln -sf "$(which batcat)" "${HOME}/.local/bin/bat"
    log_debug "Created bat → batcat symlink"
  fi

  # fd might be 'fdfind' on Ubuntu/Debian
  if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
    ln -sf "$(which fdfind)" "${HOME}/.local/bin/fd"
    log_debug "Created fd → fdfind symlink"
  fi

  pkg_report_errors
}

# ---------------------------------------------------------------------------
# STEP 2: BINARY TOOLS (from web)
# ---------------------------------------------------------------------------
install_binary_tools() {
  log_section "Binary Tools"

  local arch="${DETECT_ARCH}"

  # --- Starship ---
  if ! command -v starship &>/dev/null; then
    log_info "Installing Starship prompt..."
    curl -fsSL https://starship.rs/install.sh | sh -s -- --yes &>/dev/null && \
      log_success "Starship installed." || log_warn "Starship install failed."
  else
    log_debug "Starship already installed: $(starship --version 2>/dev/null)"
  fi

  # --- Zoxide ---
  if ! command -v zoxide &>/dev/null; then
    log_info "Installing zoxide..."
    curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh &>/dev/null && \
      log_success "zoxide installed." || log_warn "zoxide install failed."
  else
    log_debug "zoxide already installed."
  fi

  # --- Atuin ---
  if ! command -v atuin &>/dev/null && [[ ! -x "${HOME}/.atuin/bin/atuin" ]] && [[ ! -x "${HOME}/.local/bin/atuin" ]]; then
    log_info "Installing Atuin..."
    local atuin_ver="18.3.0"
    local atuin_arch="x86_64"
    [[ "${arch}" == "arm64" ]] && atuin_arch="aarch64"
    local atuin_url="https://github.com/atuinsh/atuin/releases/download/v${atuin_ver}/atuin-${atuin_arch}-unknown-linux-gnu.tar.gz"
    local tmp
    tmp=$(mktemp -d)
    if curl -fsSL "${atuin_url}" -o "${tmp}/atuin.tar.gz" &>/dev/null && \
       tar -xzf "${tmp}/atuin.tar.gz" -C "${tmp}" &>/dev/null; then
      find "${tmp}" -name "atuin" -type f -exec install -m755 {} "${HOME}/.local/bin/atuin" \;
      log_success "Atuin installed."
    else
      log_warn "Atuin install failed."
    fi
    rm -rf "${tmp}"
  else
    log_debug "Atuin already installed."
  fi

  # --- git-delta ---
  if ! command -v delta &>/dev/null; then
    log_info "Installing git-delta..."
    local delta_ver="0.17.0"
    local delta_url
    if [[ "${arch}" == "arm64" ]]; then
      delta_url="https://github.com/dandavison/delta/releases/download/${delta_ver}/delta-${delta_ver}-aarch64-unknown-linux-gnu.tar.gz"
    else
      delta_url="https://github.com/dandavison/delta/releases/download/${delta_ver}/delta-${delta_ver}-x86_64-unknown-linux-gnu.tar.gz"
    fi
    local tmp
    tmp=$(mktemp -d)
    if curl -fsSL "${delta_url}" -o "${tmp}/delta.tar.gz" &>/dev/null && \
       tar -xzf "${tmp}/delta.tar.gz" -C "${tmp}" &>/dev/null; then
      find "${tmp}" -name "delta" -type f -exec install -m755 {} "${HOME}/.local/bin/delta" \;
      log_success "git-delta installed."
    else
      log_warn "git-delta install failed."
    fi
    rm -rf "${tmp}"
  fi

  # --- Yazi ---
  if ! command -v yazi &>/dev/null; then
    log_info "Installing Yazi..."
    local yazi_ver="v0.3.3"
    local yazi_url
    if [[ "${arch}" == "arm64" ]]; then
      yazi_url="https://github.com/sxyazi/yazi/releases/download/${yazi_ver}/yazi-aarch64-unknown-linux-gnu.zip"
    else
      yazi_url="https://github.com/sxyazi/yazi/releases/download/${yazi_ver}/yazi-x86_64-unknown-linux-gnu.zip"
    fi
    local tmp
    tmp=$(mktemp -d)
    if curl -fsSL "${yazi_url}" -o "${tmp}/yazi.zip" &>/dev/null && \
       unzip -q "${tmp}/yazi.zip" -d "${tmp}" &>/dev/null; then
      find "${tmp}" -name "yazi" -type f -exec install -m755 {} "${HOME}/.local/bin/yazi" \;
      log_success "Yazi installed."
    else
      log_warn "Yazi install failed."
    fi
    rm -rf "${tmp}"
  fi

  # --- GitHub CLI ---
  if ! command -v gh &>/dev/null; then
    log_info "Installing GitHub CLI..."
    if curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
         sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg &>/dev/null; then
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
        sudo tee /etc/apt/sources.list.d/github-cli.list &>/dev/null
      sudo apt-get update -qq &>/dev/null
      sudo apt-get install -y -qq gh &>/dev/null && \
        log_success "GitHub CLI installed." || log_warn "GitHub CLI install failed."
    else
      log_warn "GitHub CLI: failed to add GPG key."
    fi
  fi

  # --- lazygit ---
  if ! command -v lazygit &>/dev/null; then
    log_info "Installing lazygit..."
    local lg_ver
    lg_ver=$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest 2>/dev/null | \
             grep tag_name | sed 's/.*"v\([^"]*\)".*/\1/')
    lg_ver="${lg_ver:-0.44.1}"
    local lg_arch="Linux_x86_64"
    [[ "${arch}" == "arm64" ]] && lg_arch="Linux_arm64"
    local tmp
    tmp=$(mktemp -d)
    local lg_url="https://github.com/jesseduffield/lazygit/releases/download/v${lg_ver}/lazygit_${lg_ver}_${lg_arch}.tar.gz"
    if curl -fsSL "${lg_url}" -o "${tmp}/lazygit.tar.gz" &>/dev/null && \
       tar -xzf "${tmp}/lazygit.tar.gz" -C "${tmp}" &>/dev/null; then
      install -m755 "${tmp}/lazygit" "${HOME}/.local/bin/lazygit"
      log_success "lazygit installed."
    else
      log_warn "lazygit install failed."
    fi
    rm -rf "${tmp}"
  fi

  ensure_dir "${HOME}/.local/bin"
  add_to_path "${HOME}/.local/bin"
}

# ---------------------------------------------------------------------------
# STEP 3: ZSH PLUGINS
# ---------------------------------------------------------------------------
install_plugins() {
  log_section "Zsh Plugins"
  bash "${BOOTSTRAP_DIR}/plugins/install.sh" install
}

# ---------------------------------------------------------------------------
# STEP 4: DEPLOY CONFIGURATION FILES
# ---------------------------------------------------------------------------
deploy_configs() {
  log_section "Deploying Configuration"

  backup_init

  # Helper to deploy with backup
  deploy_config() {
    local src="${BOOTSTRAP_DIR}/configs/${1}"
    local dest="${2}"
    if [[ -f "${src}" ]]; then
      safe_install_file "${src}" "${dest}"
      log_success "  ✔  $(basename "${dest}")"
    else
      log_warn "  ⚠  Source missing: ${1}"
    fi
  }

  # Zsh
  deploy_config "zshenv"           "${HOME}/.zshenv"
  deploy_config "zshrc"            "${HOME}/.zshrc"

  # Starship
  ensure_dir "${CLI_CONFIG_DIR}"
  deploy_config "starship.toml"    "${CLI_CONFIG_DIR}/starship.toml"

  # Tmux
  deploy_config "tmux.conf"        "${HOME}/.tmux.conf"

  # Git
  deploy_config "gitconfig"        "${HOME}/.gitconfig"
  deploy_config "gitignore_global" "${HOME}/.config/git/ignore"
  ensure_dir "${HOME}/.config/git"
  deploy_config "gitignore_global" "${HOME}/.config/git/ignore"

  # Atuin
  ensure_dir "${CLI_CONFIG_DIR}/atuin"
  deploy_config "atuin.toml"       "${CLI_CONFIG_DIR}/atuin/config.toml"

  # Yazi
  ensure_dir "${CLI_CONFIG_DIR}/yazi"
  deploy_config "yazi/yazi.toml"   "${CLI_CONFIG_DIR}/yazi/yazi.toml"
  deploy_config "yazi/keymap.toml" "${CLI_CONFIG_DIR}/yazi/keymap.toml"
  deploy_config "yazi/theme.toml"  "${CLI_CONFIG_DIR}/yazi/theme.toml"

  # Ripgrep
  ensure_dir "${CLI_CONFIG_DIR}/ripgrep"
  cat > "${CLI_CONFIG_DIR}/ripgrep/config" <<'RGEOF'
--hidden
--follow
--smart-case
--glob=!.git/*
--glob=!node_modules/*
--glob=!vendor/*
RGEOF
  log_success "  ✔  ripgrep config"

  # Install aliases and functions into ~/.cli-bootstrap
  ensure_dir "${CLI_INSTALL_DIR}/aliases"
  ensure_dir "${CLI_INSTALL_DIR}/functions"
  ensure_dir "${CLI_INSTALL_DIR}/plugins"

  # Copy alias files
  for f in "${BOOTSTRAP_DIR}/aliases/"*.sh; do
    [[ -f "${f}" ]] && install -m644 "${f}" "${CLI_INSTALL_DIR}/aliases/"
  done
  log_success "  ✔  Aliases deployed"

  # Copy function files
  for f in "${BOOTSTRAP_DIR}/functions/"*.sh; do
    [[ -f "${f}" ]] && install -m644 "${f}" "${CLI_INSTALL_DIR}/functions/"
  done
  log_success "  ✔  Functions deployed"

  rollback_clear
}

# ---------------------------------------------------------------------------
# STEP 5: SET DEFAULT SHELL TO ZSH
# ---------------------------------------------------------------------------
set_default_shell() {
  log_section "Default Shell"

  local zsh_path
  zsh_path=$(command -v zsh 2>/dev/null || echo "")

  if [[ -z "${zsh_path}" ]]; then
    log_warn "zsh not found — cannot set default shell."
    return 0
  fi

  # Add to /etc/shells if missing
  if ! grep -qxF "${zsh_path}" /etc/shells 2>/dev/null; then
    echo "${zsh_path}" | sudo tee -a /etc/shells &>/dev/null
    log_debug "Added ${zsh_path} to /etc/shells"
  fi

  local current_shell
  current_shell=$(getent passwd "${USER}" | cut -d: -f7)

  if [[ "${current_shell}" == "${zsh_path}" ]]; then
    log_debug "Default shell already set to zsh."
    return 0
  fi

  if (( CLI_NONINTERACTIVE )); then
    chsh -s "${zsh_path}" "${USER}" && \
      log_success "Default shell set to zsh." || \
      log_warn "Failed to set default shell."
  else
    if ui_confirm "Set ${zsh_path} as default shell?" "y"; then
      chsh -s "${zsh_path}" "${USER}" && \
        log_success "Default shell set to zsh." || \
        log_warn "Failed to set default shell. Run manually: chsh -s ${zsh_path}"
    fi
  fi
}

# ---------------------------------------------------------------------------
# STEP 6: POST-INSTALL CHECKS
# ---------------------------------------------------------------------------
post_install_check() {
  log_section "Post-Install Check"

  local issues=0

  check_item() {
    local name="$1"
    local cmd="$2"
    if eval "${cmd}" &>/dev/null; then
      log_success "  ✔  ${name}"
    else
      log_warn "  ⚠  ${name}"
      (( issues += 1 ))
    fi
  }

  check_item "zsh"       "command -v zsh"
  check_item "starship"  "command -v starship"
  check_item "fzf"       "command -v fzf"
  check_item "bat"       "command -v bat || command -v batcat"
  check_item "eza"       "command -v eza"
  check_item "fd"        "command -v fd || command -v fdfind"
  check_item "rg"        "command -v rg"
  check_item "git"       "command -v git"
  check_item "zoxide"    "command -v zoxide"
  check_item "atuin"     "command -v atuin"
  check_item "tmux"      "command -v tmux"
  check_item "lazygit"   "command -v lazygit"
  check_item "delta"     "command -v delta"
  check_item "jq"        "command -v jq"
  check_item ".zshrc"    "[[ -f ${HOME}/.zshrc ]]"
  check_item ".zshenv"   "[[ -f ${HOME}/.zshenv ]]"
  check_item "starship.toml" "[[ -f ${HOME}/.config/starship.toml ]]"

  if (( issues > 0 )); then
    log_warn "${issues} component(s) with issues. Run ./doctor.sh for details."
  else
    log_success "All checks passed!"
  fi
}

# ---------------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------------
main() {
  parse_args "$@"

  ensure_dir "${CLI_INSTALL_DIR}"
  ensure_dir "${HOME}/.local/bin"

  local start_ms
  start_ms=$(date +%s%N)

  ui_banner "${BOOTSTRAP_VERSION}"

  log_section "Starting CLI Bootstrap v${BOOTSTRAP_VERSION}"
  log_info "Mode: ${CLI_MODE} | Log: ${CLI_LOG_FILE}"
  printf "\n"

  case "${CLI_MODE}" in
    install)
      validate_environment
      log_step 1 6 "System Packages"
      install_system_packages
      log_step 2 6 "Binary Tools"
      install_binary_tools
      log_step 3 6 "Zsh Plugins"
      install_plugins
      log_step 4 6 "Configuration Files"
      deploy_configs
      log_step 5 6 "Default Shell"
      set_default_shell
      log_step 6 6 "Verification"
      post_install_check
      ;;
    update)
      validate_environment
      install_system_packages
      install_binary_tools
      install_plugins
      deploy_configs
      post_install_check
      ;;
    check)
      validate_environment
      post_install_check
      ;;
    *)
      die "Unknown mode: ${CLI_MODE}"
      ;;
  esac

  local end_ms elapsed_ms
  end_ms=$(date +%s%N)
  elapsed_ms=$(( (end_ms - start_ms) / 1000000 ))

  ui_success_summary "${elapsed_ms}"
  rollback_clear
}

main "$@"
