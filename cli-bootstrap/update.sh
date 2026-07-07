#!/usr/bin/env bash
# update.sh — Safe update for all cli-bootstrap components
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/core.sh"
source "${SCRIPT_DIR}/lib/detect.sh"
source "${SCRIPT_DIR}/lib/ui.sh"
source "${SCRIPT_DIR}/lib/pkg.sh"

readonly BOOTSTRAP_VERSION="$(cat "${SCRIPT_DIR}/VERSION" 2>/dev/null || echo '1.0.0')"

main() {
  detect_all

  printf "\n%b  CLI Bootstrap Update v%s%b\n\n" \
    "${CLR_BOLD_CYAN}" "${BOOTSTRAP_VERSION}" "${CLR_RESET}" >&2

  log_section "Updating System Packages"
  pkg_update
  DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq 2>/dev/null || true
  log_success "System packages updated."

  log_section "Updating Zsh Plugins"
  bash "${SCRIPT_DIR}/plugins/install.sh" update

  log_section "Updating Binary Tools"

  # Starship
  if command -v starship &>/dev/null; then
    log_info "Updating Starship..."
    curl -fsSL https://starship.rs/install.sh | sh -s -- --yes &>/dev/null && \
      log_success "Starship updated to $(starship --version 2>/dev/null | head -1)" || \
      log_warn "Starship update failed."
  fi

  # Zoxide
  if command -v zoxide &>/dev/null; then
    log_info "Updating zoxide..."
    curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh &>/dev/null && \
      log_success "zoxide updated." || log_warn "zoxide update failed."
  fi

  # Atuin
  if command -v atuin &>/dev/null; then
    log_info "Updating Atuin..."
    curl --proto '=https' --tlsv1.2 -sSf \
      https://setup.atuin.sh | sh &>/dev/null && \
      log_success "Atuin updated." || log_warn "Atuin update failed."
  fi

  # Re-deploy configs (non-destructively)
  log_section "Refreshing Configs"
  bash "${SCRIPT_DIR}/bootstrap.sh" --mode=update --non-interactive 2>/dev/null || true

  log_section "Running Doctor"
  bash "${SCRIPT_DIR}/doctor.sh" || true

  printf "\n%b  Update complete!%b\n\n" "${CLR_BOLD_GREEN}" "${CLR_RESET}" >&2
}

main "$@"
