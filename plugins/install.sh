#!/usr/bin/env bash
# =============================================================================
# plugins/install.sh — Zsh plugin installer
# =============================================================================
# Clones and updates all Zsh plugins without a plugin manager overhead.
# =============================================================================

set -Eeuo pipefail

# Source core library if not already loaded
if [[ -z "${_CLI_BOOTSTRAP_CORE_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "${SCRIPT_DIR}/../lib/core.sh"
fi

# ---------------------------------------------------------------------------
# PLUGIN DIRECTORY
# ---------------------------------------------------------------------------
: "${CLI_BOOTSTRAP_PLUGINS:="${HOME}/.cli-bootstrap/plugins"}"
mkdir -p "${CLI_BOOTSTRAP_PLUGINS}"

# ---------------------------------------------------------------------------
# PLUGIN REGISTRY
# ---------------------------------------------------------------------------
# Format: "name|url|branch"
declare -a PLUGINS=(
  "zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions|master"
  "zsh-syntax-highlighting|https://github.com/zsh-users/zsh-syntax-highlighting|master"
  "zsh-completions|https://github.com/zsh-users/zsh-completions|master"
  "fzf-tab|https://github.com/Aloxaf/fzf-tab|master"
  "zsh-history-substring-search|https://github.com/zsh-users/zsh-history-substring-search|master"
  "zsh-you-should-use|https://github.com/MichaelAquilina/zsh-you-should-use|master"
  "alias-tips|https://github.com/djui/alias-tips|main"
)

# ---------------------------------------------------------------------------
# INSTALL OR UPDATE A SINGLE PLUGIN
# ---------------------------------------------------------------------------
install_plugin() {
  local name="$1"
  local url="$2"
  local branch="${3:-master}"
  local dest="${CLI_BOOTSTRAP_PLUGINS}/${name}"

  if [[ -d "${dest}/.git" ]]; then
    # Update existing
    log_debug "Updating plugin: ${name}"
    local current_hash new_hash
    current_hash=$(git -C "${dest}" rev-parse HEAD 2>/dev/null || echo "unknown")

    if git -C "${dest}" pull --ff-only --quiet 2>/dev/null; then
      new_hash=$(git -C "${dest}" rev-parse HEAD 2>/dev/null || echo "unknown")
      if [[ "${current_hash}" != "${new_hash}" ]]; then
        log_success "  ↑  ${name} updated"
      else
        log_debug "  ↷  ${name} already up to date"
      fi
    else
      log_warn "  ⚠  Failed to update ${name} (may have local changes)"
    fi
  else
    # Fresh clone
    log_info "Installing plugin: ${name}"
    rm -rf "${dest}"  # Clean up any partial install

    if git clone \
         --depth=1 \
         --branch "${branch}" \
         --quiet \
         "${url}" \
         "${dest}" 2>/dev/null; then
      log_success "  ✔  ${name} installed"
    else
      # Retry without branch (some repos use different default branch)
      if git clone \
           --depth=1 \
           --quiet \
           "${url}" \
           "${dest}" 2>/dev/null; then
        log_success "  ✔  ${name} installed (default branch)"
      else
        log_warn "  ✖  Failed to install ${name} from ${url}"
        rm -rf "${dest}"
        return 1
      fi
    fi
  fi
}

# ---------------------------------------------------------------------------
# INSTALL ALL PLUGINS
# ---------------------------------------------------------------------------
install_all_plugins() {
  log_section "Installing Zsh Plugins"

  if ! command -v git &>/dev/null; then
    log_error "git is required to install plugins."
    return 1
  fi

  local total="${#PLUGINS[@]}"
  local current=0
  local ok=0 fail=0

  for plugin_entry in "${PLUGINS[@]}"; do
    IFS='|' read -r name url branch <<< "${plugin_entry}"
    (( current++ ))
    log_step "${current}" "${total}" "${name}"

    install_plugin "${name}" "${url}" "${branch}" && (( ok++ )) || (( fail++ ))
  done

  printf "\n"
  log_success "Plugins: ${ok} installed/updated, ${fail} failed."
  printf "\n%bPlugin directory: %s%b\n\n" \
    "${CLR_DIM}" "${CLI_BOOTSTRAP_PLUGINS}" "${CLR_RESET}" >&2
}

# ---------------------------------------------------------------------------
# VERIFY PLUGINS
# ---------------------------------------------------------------------------
verify_plugins() {
  log_section "Verifying Plugins"

  local all_ok=1

  for plugin_entry in "${PLUGINS[@]}"; do
    IFS='|' read -r name url branch <<< "${plugin_entry}"
    local dest="${CLI_BOOTSTRAP_PLUGINS}/${name}"

    if [[ -d "${dest}" ]]; then
      log_success "  ✔  ${name}"
    else
      log_warn "  ✖  ${name} — NOT FOUND"
      all_ok=0
    fi
  done

  return $(( 1 - all_ok ))
}

# ---------------------------------------------------------------------------
# LIST PLUGINS
# ---------------------------------------------------------------------------
list_plugins() {
  printf "\n%b  Registered Plugins:%b\n\n" "${CLR_BOLD_WHITE}" "${CLR_RESET}" >&2

  for plugin_entry in "${PLUGINS[@]}"; do
    IFS='|' read -r name url branch <<< "${plugin_entry}"
    local dest="${CLI_BOOTSTRAP_PLUGINS}/${name}"
    local status="not installed"
    local color="${CLR_YELLOW}"

    if [[ -d "${dest}" ]]; then
      local commit
      commit=$(git -C "${dest}" rev-parse --short HEAD 2>/dev/null || echo "?")
      status="installed (${commit})"
      color="${CLR_GREEN}"
    fi

    printf "  %b%-40s%b  %b%s%b\n" \
      "${CLR_BOLD_WHITE}" "${name}" "${CLR_RESET}" \
      "${color}" "${status}" "${CLR_RESET}" >&2
  done

  printf "\n" >&2
}

# ---------------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------------
case "${1:-install}" in
  install)  install_all_plugins ;;
  update)   install_all_plugins ;;  # Same logic — idempotent
  verify)   verify_plugins ;;
  list)     list_plugins ;;
  *)
    echo "Usage: ${0} [install|update|verify|list]" >&2
    exit 1
    ;;
esac
