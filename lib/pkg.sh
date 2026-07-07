#!/usr/bin/env bash
# =============================================================================
# lib/pkg.sh — Package management abstraction layer
# =============================================================================

[[ -n "${_CLI_BOOTSTRAP_PKG_LOADED:-}" ]] && return 0
readonly _CLI_BOOTSTRAP_PKG_LOADED=1

# ---------------------------------------------------------------------------
# STATE
# ---------------------------------------------------------------------------
_PKG_UPDATED=0          # Have we run apt-get update this session?
_PKG_INSTALL_ERRORS=()  # Track failed package installs

# ---------------------------------------------------------------------------
# APT UPDATE
# ---------------------------------------------------------------------------
pkg_update() {
  if (( _PKG_UPDATED )); then
    log_debug "apt-get update already run this session, skipping."
    return 0
  fi

  log_info "Updating package index..."
  if DEBIAN_FRONTEND=noninteractive apt-get update -qq 2>&1 | \
     grep -vE "^(Hit|Get|Ign|Reading|Building|Done)" | \
     while IFS= read -r line; do log_debug "${line}"; done; then
    _PKG_UPDATED=1
    log_success "Package index updated."
  else
    log_warn "apt-get update returned non-zero (may be harmless, continuing)."
    _PKG_UPDATED=1  # Treat as done to avoid retrying
  fi
}

# ---------------------------------------------------------------------------
# SINGLE PACKAGE INSTALL
# ---------------------------------------------------------------------------
# pkg_install <package> [<binary_check>]
# binary_check: if provided, skip install if this binary already exists
pkg_install() {
  local pkg="$1"
  local binary_check="${2:-}"

  # If a binary check is given and the binary exists, skip
  if [[ -n "${binary_check}" ]] && command -v "${binary_check}" &>/dev/null; then
    log_debug "  ↷ ${pkg} already available (${binary_check} found), skipping."
    return 0
  fi

  # Check via dpkg if already installed
  if dpkg-query -W -f='${Status}' "${pkg}" 2>/dev/null | grep -q "install ok installed"; then
    log_debug "  ↷ ${pkg} already installed (dpkg), skipping."
    return 0
  fi

  log_debug "  → Installing ${pkg}..."
  if DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
       --no-install-recommends "${pkg}" &>/dev/null; then
    log_success "  ✔ ${pkg}"
    return 0
  else
    log_warn "  ⚠ Failed to install ${pkg} (package may not exist in repos)"
    _PKG_INSTALL_ERRORS+=("${pkg}")
    return 0  # Never fail on a single package
  fi
}

# ---------------------------------------------------------------------------
# BATCH PACKAGE INSTALL
# ---------------------------------------------------------------------------
# pkg_install_batch <description> <pkg1> [pkg2] ...
pkg_install_batch() {
  local description="$1"
  shift
  local packages=("$@")

  log_info "Installing: ${description} (${#packages[@]} packages)"

  local ok=0 fail=0

  for pkg in "${packages[@]}"; do
    if dpkg-query -W -f='${Status}' "${pkg}" 2>/dev/null | \
       grep -q "install ok installed"; then
      log_debug "  ↷ ${pkg} (already installed)"
      (( ok++ ))
      continue
    fi

    if DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
         --no-install-recommends "${pkg}" &>/dev/null; then
      log_debug "  ✔ ${pkg}"
      (( ok++ ))
    else
      log_warn "  ⚠ ${pkg} — not available in repos, skipping."
      _PKG_INSTALL_ERRORS+=("${pkg}")
      (( fail++ ))
    fi
  done

  log_success "${description}: ${ok} installed, ${fail} skipped."
}

# ---------------------------------------------------------------------------
# PACKAGE REMOVAL
# ---------------------------------------------------------------------------
pkg_remove() {
  local pkg="$1"

  if ! dpkg-query -W -f='${Status}' "${pkg}" 2>/dev/null | \
       grep -q "install ok installed"; then
    log_debug "  ↷ ${pkg} not installed, skip removal."
    return 0
  fi

  log_info "Removing ${pkg}..."
  if DEBIAN_FRONTEND=noninteractive apt-get remove -y -qq "${pkg}" &>/dev/null; then
    log_success "Removed ${pkg}."
  else
    log_warn "Failed to remove ${pkg}."
  fi
}

# ---------------------------------------------------------------------------
# ADD EXTERNAL REPOSITORY
# ---------------------------------------------------------------------------
# pkg_add_repo_key <url> <keyring_path>
pkg_add_repo_key() {
  local url="$1"
  local keyring="$2"

  log_info "Adding GPG key → ${keyring}"
  curl -fsSL "${url}" | \
    gpg --dearmor | \
    install -Dm644 /dev/stdin "${keyring}"
  log_success "GPG key installed: ${keyring}"
}

# pkg_add_repo <source_line> <source_file>
pkg_add_repo() {
  local source_line="$1"
  local source_file="$2"

  local dest="/etc/apt/sources.list.d/${source_file}.list"
  if [[ -f "${dest}" ]]; then
    log_debug "Repo ${source_file} already configured, skipping."
    return 0
  fi

  echo "${source_line}" | install -Dm644 /dev/stdin "${dest}"
  log_success "Repo added: ${source_file}"
  _PKG_UPDATED=0  # Force re-update after new repo
}

# ---------------------------------------------------------------------------
# BINARY DOWNLOAD INSTALL
# ---------------------------------------------------------------------------
# pkg_install_binary <name> <url> <install_path>
# Downloads a single binary from a URL and installs it
pkg_install_binary() {
  local name="$1"
  local url="$2"
  local install_path="${3:-/usr/local/bin/${name}}"

  if command -v "${name}" &>/dev/null; then
    log_debug "${name} already in PATH, skipping download."
    return 0
  fi

  log_info "Downloading ${name}..."
  local tmp
  tmp=$(mktemp)

  if curl -fsSL --progress-bar "${url}" -o "${tmp}" 2>&1; then
    chmod +x "${tmp}"
    mv "${tmp}" "${install_path}"
    log_success "${name} installed → ${install_path}"
  else
    rm -f "${tmp}"
    log_warn "Failed to download ${name} from ${url}"
    return 1
  fi
}

# ---------------------------------------------------------------------------
# INSTALL FROM SCRIPT (curl | sh pattern)
# ---------------------------------------------------------------------------
pkg_install_via_script() {
  local name="$1"
  local url="$2"
  shift 2
  local extra_args=("$@")

  if command -v "${name}" &>/dev/null; then
    log_debug "${name} already installed, skipping."
    return 0
  fi

  log_info "Installing ${name} via install script..."
  if curl -fsSL "${url}" | sh -s -- "${extra_args[@]}" &>/dev/null; then
    log_success "${name} installed via script."
  else
    log_warn "Failed to install ${name} via script."
    return 1
  fi
}

# ---------------------------------------------------------------------------
# CARGO INSTALL (if cargo available)
# ---------------------------------------------------------------------------
pkg_cargo_install() {
  local crate="$1"
  local binary="${2:-${crate}}"

  if command -v "${binary}" &>/dev/null; then
    log_debug "${binary} already installed, skipping cargo install."
    return 0
  fi

  if ! command -v cargo &>/dev/null; then
    log_debug "cargo not available, skipping ${crate}."
    return 0
  fi

  log_info "Installing ${crate} via cargo..."
  if cargo install "${crate}" --quiet 2>/dev/null; then
    log_success "${crate} installed via cargo."
  else
    log_warn "Failed to install ${crate} via cargo."
    return 0
  fi
}

# ---------------------------------------------------------------------------
# REPORT
# ---------------------------------------------------------------------------
pkg_report_errors() {
  if (( ${#_PKG_INSTALL_ERRORS[@]} == 0 )); then
    return 0
  fi

  printf "\n%b  ⚠  Packages skipped (not available in repos):%b\n" \
    "${CLR_BOLD_YELLOW}" "${CLR_RESET}" >&2
  for p in "${_PKG_INSTALL_ERRORS[@]}"; do
    printf "     %b- %s%b\n" "${CLR_YELLOW}" "${p}" "${CLR_RESET}" >&2
  done
  printf "\n" >&2
}

# ---------------------------------------------------------------------------
# PURGE APT CACHE (optional cleanup)
# ---------------------------------------------------------------------------
pkg_cleanup() {
  log_info "Cleaning apt cache..."
  apt-get autoremove -y -qq &>/dev/null || true
  apt-get clean -qq &>/dev/null || true
  log_success "apt cache cleaned."
}
