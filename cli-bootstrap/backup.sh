#!/usr/bin/env bash
# backup.sh — Standalone backup utility
set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/core.sh"
source "${SCRIPT_DIR}/lib/backup.sh"
source "${SCRIPT_DIR}/lib/ui.sh"

main() {
  local action="${1:-backup}"
  shift || true

  case "${action}" in
    backup)
      backup_init
      log_section "Creating Backup"
      local files=(
        "${HOME}/.zshrc" "${HOME}/.zshenv" "${HOME}/.zprofile"
        "${HOME}/.gitconfig" "${HOME}/.tmux.conf"
        "${HOME}/.config/starship.toml"
        "${HOME}/.config/atuin/config.toml"
      )
      for f in "${files[@]}"; do
        [[ -e "${f}" ]] && backup_file "${f}" && log_success "Backed up: ${f}" || true
      done
      log_success "Backup complete: ${_BACKUP_SESSION_DIR}"
      ;;
    list)    backup_list ;;
    purge)   backup_purge_old "${1:-5}" ;;
    *)
      echo "Usage: backup.sh [backup|list|purge [keep_count]]"
      exit 1 ;;
  esac
}

main "$@"
