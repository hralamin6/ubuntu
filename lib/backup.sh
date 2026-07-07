#!/usr/bin/env bash
# =============================================================================
# lib/backup.sh — Timestamped backup and restore engine
# =============================================================================

[[ -n "${_CLI_BOOTSTRAP_BACKUP_LOADED:-}" ]] && return 0
readonly _CLI_BOOTSTRAP_BACKUP_LOADED=1

# ---------------------------------------------------------------------------
# CONFIGURATION
# ---------------------------------------------------------------------------
: "${CLI_BACKUP_ROOT:="${HOME}/.cli-bootstrap/backups"}"
: "${CLI_BACKUP_TIMESTAMP:=$(date '+%Y%m%d_%H%M%S')}"

# Manifest file tracking what was backed up this session
_BACKUP_MANIFEST_FILE="${CLI_BACKUP_ROOT}/${CLI_BACKUP_TIMESTAMP}/manifest.json"
_BACKUP_SESSION_DIR="${CLI_BACKUP_ROOT}/${CLI_BACKUP_TIMESTAMP}"

# ---------------------------------------------------------------------------
# INITIALIZE BACKUP SESSION
# ---------------------------------------------------------------------------
backup_init() {
  mkdir -p "${_BACKUP_SESSION_DIR}"
  # Write initial manifest
  cat > "${_BACKUP_MANIFEST_FILE}" <<EOF
{
  "version": "1.0",
  "timestamp": "${CLI_BACKUP_TIMESTAMP}",
  "created_at": "$(date -Iseconds)",
  "host": "$(hostname -f 2>/dev/null || hostname)",
  "user": "${USER:-root}",
  "entries": []
}
EOF
  log_debug "Backup session initialized: ${_BACKUP_SESSION_DIR}"
}

# ---------------------------------------------------------------------------
# ADD ENTRY TO MANIFEST
# ---------------------------------------------------------------------------
_backup_manifest_add() {
  local type="$1"        # file | dir
  local source="$2"
  local destination="$3"

  # Read current manifest, append entry, write back
  if command -v python3 &>/dev/null; then
    python3 - "${_BACKUP_MANIFEST_FILE}" "${type}" "${source}" "${destination}" <<'PYEOF'
import sys, json
manifest_file, entry_type, source, destination = sys.argv[1:]
with open(manifest_file, 'r') as f:
    data = json.load(f)
data['entries'].append({
    'type': entry_type,
    'source': source,
    'destination': destination
})
with open(manifest_file, 'w') as f:
    json.dump(data, f, indent=2)
PYEOF
  else
    # Fallback: append a line to a simple text log
    echo "${type}|${source}|${destination}" >> "${_BACKUP_SESSION_DIR}/manifest.txt"
  fi
}

# ---------------------------------------------------------------------------
# BACKUP A FILE
# ---------------------------------------------------------------------------
# backup_file <source_path> [<description>]
# Returns the backup destination path in BACKUP_DEST
backup_file() {
  local source="$1"
  local description="${2:-}"

  # Nothing to backup if source doesn't exist
  if [[ ! -e "${source}" ]]; then
    log_debug "backup_file: ${source} does not exist, nothing to backup."
    BACKUP_DEST=""
    return 0
  fi

  # Ensure session is initialized
  [[ -d "${_BACKUP_SESSION_DIR}" ]] || backup_init

  # Construct destination path preserving directory structure
  local rel_path="${source#/}"  # Remove leading slash
  BACKUP_DEST="${_BACKUP_SESSION_DIR}/files/${rel_path}"

  local dest_dir
  dest_dir=$(dirname "${BACKUP_DEST}")
  mkdir -p "${dest_dir}"

  if cp -a "${source}" "${BACKUP_DEST}" 2>/dev/null; then
    _backup_manifest_add "file" "${source}" "${BACKUP_DEST}"
    log_debug "  ↷ Backed up: ${source} → ${BACKUP_DEST}"
    return 0
  else
    log_warn "Failed to backup ${source}"
    return 1
  fi
}

# ---------------------------------------------------------------------------
# BACKUP A DIRECTORY
# ---------------------------------------------------------------------------
# backup_dir <source_path> [<description>]
backup_dir() {
  local source="$1"
  local description="${2:-}"

  if [[ ! -d "${source}" ]]; then
    log_debug "backup_dir: ${source} does not exist, skipping."
    BACKUP_DEST=""
    return 0
  fi

  [[ -d "${_BACKUP_SESSION_DIR}" ]] || backup_init

  local rel_path="${source#/}"
  BACKUP_DEST="${_BACKUP_SESSION_DIR}/files/${rel_path}"

  if cp -ra "${source}" "${BACKUP_DEST}" 2>/dev/null; then
    _backup_manifest_add "dir" "${source}" "${BACKUP_DEST}"
    log_debug "  ↷ Backed up dir: ${source} → ${BACKUP_DEST}"
    return 0
  else
    log_warn "Failed to backup dir ${source}"
    return 1
  fi
}

# ---------------------------------------------------------------------------
# SAFE WRITE — backup before overwrite
# ---------------------------------------------------------------------------
# safe_write <destination_path> <content>
safe_write() {
  local dest="$1"
  local content="$2"

  backup_file "${dest}"
  printf '%s' "${content}" > "${dest}"
}

# ---------------------------------------------------------------------------
# SAFE COPY — backup destination before overwriting
# ---------------------------------------------------------------------------
safe_copy() {
  local src="$1"
  local dest="$2"

  backup_file "${dest}"
  install -D -m 644 "${src}" "${dest}"
}

# ---------------------------------------------------------------------------
# RESTORE A SINGLE FILE FROM LATEST BACKUP
# ---------------------------------------------------------------------------
# restore_file <original_path>
restore_file() {
  local original="$1"

  # Find latest backup session
  local latest_session
  latest_session=$(find "${CLI_BACKUP_ROOT}" -mindepth 1 -maxdepth 1 \
    -type d 2>/dev/null | sort -r | head -1)

  if [[ -z "${latest_session}" ]]; then
    log_warn "No backup sessions found in ${CLI_BACKUP_ROOT}"
    return 1
  fi

  local rel_path="${original#/}"
  local backup_copy="${latest_session}/files/${rel_path}"

  if [[ ! -e "${backup_copy}" ]]; then
    log_warn "No backup found for ${original} in ${latest_session}"
    return 1
  fi

  # Backup the current file before restoring (in case restore was wrong)
  backup_file "${original}" "pre-restore"

  cp -a "${backup_copy}" "${original}"
  log_success "Restored: ${original} ← ${backup_copy}"
}

# ---------------------------------------------------------------------------
# RESTORE ALL FROM A SPECIFIC SESSION
# ---------------------------------------------------------------------------
restore_all() {
  local session="${1:-}"

  if [[ -z "${session}" ]]; then
    session=$(find "${CLI_BACKUP_ROOT}" -mindepth 1 -maxdepth 1 \
      -type d 2>/dev/null | sort -r | head -1)
  fi

  if [[ -z "${session}" ]]; then
    log_error "No backup sessions found."
    return 1
  fi

  log_section "Restoring from backup: $(basename "${session}")"

  local files_dir="${session}/files"
  if [[ ! -d "${files_dir}" ]]; then
    log_warn "No files directory in backup session ${session}"
    return 1
  fi

  local count=0
  while IFS= read -r -d '' backup_file_path; do
    local rel_path="${backup_file_path#${files_dir}/}"
    local original_path="/${rel_path}"

    if [[ -f "${backup_file_path}" ]]; then
      local dest_dir
      dest_dir=$(dirname "${original_path}")
      mkdir -p "${dest_dir}"
      cp -a "${backup_file_path}" "${original_path}"
      log_debug "  ✔ Restored: ${original_path}"
      (( count++ ))
    fi
  done < <(find "${files_dir}" -type f -print0 2>/dev/null)

  log_success "Restored ${count} file(s) from backup."
}

# ---------------------------------------------------------------------------
# LIST BACKUP SESSIONS
# ---------------------------------------------------------------------------
backup_list() {
  log_section "Backup Sessions"

  if [[ ! -d "${CLI_BACKUP_ROOT}" ]]; then
    log_info "No backups found (${CLI_BACKUP_ROOT} does not exist)."
    return 0
  fi

  local count=0
  while IFS= read -r -d '' session_dir; do
    local ts
    ts=$(basename "${session_dir}")
    local file_count
    file_count=$(find "${session_dir}/files" -type f 2>/dev/null | wc -l)
    local manifest="${session_dir}/manifest.json"
    local created="unknown"
    if [[ -f "${manifest}" ]] && command -v python3 &>/dev/null; then
      created=$(python3 -c "import json; d=json.load(open('${manifest}')); print(d.get('created_at','unknown'))" 2>/dev/null || echo "unknown")
    fi
    printf "  %b%s%b  %b%s files%b  %bcreated: %s%b\n" \
      "${CLR_BOLD_CYAN}" "${ts}" "${CLR_RESET}" \
      "${CLR_GREEN}" "${file_count}" "${CLR_RESET}" \
      "${CLR_DIM}" "${created}" "${CLR_RESET}" >&2
    (( count++ ))
  done < <(find "${CLI_BACKUP_ROOT}" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null | sort -rz)

  if (( count == 0 )); then
    log_info "No backup sessions found."
  else
    printf "\n  %bTotal: %s session(s)%b\n\n" "${CLR_DIM}" "${count}" "${CLR_RESET}" >&2
  fi
}

# ---------------------------------------------------------------------------
# PURGE OLD BACKUPS (keep last N)
# ---------------------------------------------------------------------------
backup_purge_old() {
  local keep="${1:-5}"
  local sessions
  mapfile -t sessions < <(
    find "${CLI_BACKUP_ROOT}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort -r
  )

  local total=${#sessions[@]}
  if (( total <= keep )); then
    log_debug "Only ${total} sessions, nothing to purge."
    return 0
  fi

  log_info "Purging old backups (keeping last ${keep} of ${total})..."
  local i
  for (( i=keep; i<total; i++ )); do
    rm -rf "${sessions[$i]}"
    log_debug "Purged: ${sessions[$i]}"
  done
  log_success "Purged $(( total - keep )) old backup session(s)."
}

export CLI_BACKUP_ROOT CLI_BACKUP_TIMESTAMP
