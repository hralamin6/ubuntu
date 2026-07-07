#!/usr/bin/env bash
# uninstall.sh — Clean removal and backup restore
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/core.sh"
source "${SCRIPT_DIR}/lib/backup.sh"
source "${SCRIPT_DIR}/lib/ui.sh"
source "${SCRIPT_DIR}/lib/utils.sh"

: "${CLI_INSTALL_DIR:="${HOME}/.cli-bootstrap"}"

main() {
  printf "\n%b  CLI Bootstrap — Uninstaller%b\n\n" \
    "${CLR_BOLD_RED}" "${CLR_RESET}" >&2

  log_warn "This will remove the CLI Bootstrap configuration."
  log_warn "Your original dotfiles will be restored from backup."

  if ! ui_confirm "Proceed with uninstall?" "n"; then
    log_info "Uninstall cancelled."
    exit 0
  fi

  log_section "Restoring Backups"

  # Restore original configs
  local files_to_restore=(
    "${HOME}/.zshrc"
    "${HOME}/.zshenv"
    "${HOME}/.zprofile"
    "${HOME}/.gitconfig"
    "${HOME}/.tmux.conf"
    "${HOME}/.config/starship.toml"
    "${HOME}/.config/atuin/config.toml"
  )

  for f in "${files_to_restore[@]}"; do
    restore_file "${f}" 2>/dev/null && \
      log_success "Restored: ${f}" || \
      log_debug "No backup for: ${f}"
  done

  log_section "Removing CLI Bootstrap Files"

  # Remove plugin directory
  if [[ -d "${CLI_INSTALL_DIR}/plugins" ]]; then
    rm -rf "${CLI_INSTALL_DIR}/plugins"
    log_success "Removed plugins."
  fi

  # Remove aliases/functions from install dir
  rm -rf "${CLI_INSTALL_DIR}/aliases" 2>/dev/null || true
  rm -rf "${CLI_INSTALL_DIR}/functions" 2>/dev/null || true
  log_success "Removed aliases and functions."

  # Ask about removing full install dir
  if ui_confirm "Remove ${CLI_INSTALL_DIR} entirely (including backups)?" "n"; then
    rm -rf "${CLI_INSTALL_DIR}"
    log_success "Removed: ${CLI_INSTALL_DIR}"
  else
    log_info "Kept: ${CLI_INSTALL_DIR} (backups preserved)"
  fi

  # Restore original shell
  local original_shell="/bin/bash"
  if ui_confirm "Reset default shell to ${original_shell}?" "n"; then
    chsh -s "${original_shell}" "${USER}" && \
      log_success "Default shell reset to ${original_shell}." || \
      log_warn "Could not reset shell. Run: chsh -s ${original_shell}"
  fi

  printf "\n%b  Uninstall complete. Restart your terminal.%b\n\n" \
    "${CLR_BOLD_GREEN}" "${CLR_RESET}" >&2
}

main "$@"
