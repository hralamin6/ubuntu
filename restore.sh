#!/usr/bin/env bash
# restore.sh — Standalone restore utility
set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/core.sh"
source "${SCRIPT_DIR}/lib/backup.sh"
source "${SCRIPT_DIR}/lib/ui.sh"

main() {
  local session="${1:-}"
  log_section "Restore from Backup"

  if [[ -z "${session}" ]]; then
    backup_list
    echo ""
    printf "Enter session timestamp (or leave blank for latest): "
    read -r session
  fi

  restore_all "${session}"
}

main "$@"
