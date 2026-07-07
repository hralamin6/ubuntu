#!/usr/bin/env bash
# =============================================================================
# lib/utils.sh — Miscellaneous utilities: symlinks, dirs, downloads, paths
# =============================================================================

[[ -n "${_CLI_BOOTSTRAP_UTILS_LOADED:-}" ]] && return 0
readonly _CLI_BOOTSTRAP_UTILS_LOADED=1

# ---------------------------------------------------------------------------
# REQUIRE A BINARY
# ---------------------------------------------------------------------------
# require_binary <name> [<install_hint>]
require_binary() {
  local name="$1"
  local hint="${2:-Install with: apt-get install ${name}}"

  if ! command -v "${name}" &>/dev/null; then
    die "Required binary '${name}' not found. ${hint}"
  fi
}

# require_binary_soft — warn only, don't die
require_binary_soft() {
  local name="$1"
  local hint="${2:-}"

  if ! command -v "${name}" &>/dev/null; then
    log_warn "Binary '${name}' not found. ${hint}"
    return 1
  fi
  return 0
}

# ---------------------------------------------------------------------------
# SAFE SYMLINK
# ---------------------------------------------------------------------------
# safe_symlink <target> <link_path>
# Backs up existing link_path before creating symlink
safe_symlink() {
  local target="$1"
  local link="$2"

  # If already correct symlink, skip
  if [[ -L "${link}" && "$(readlink "${link}")" == "${target}" ]]; then
    log_debug "  ↷ Symlink already correct: ${link} → ${target}"
    return 0
  fi

  # Backup existing file/dir/symlink
  if [[ -e "${link}" || -L "${link}" ]]; then
    backup_file "${link}" 2>/dev/null || true
    rm -rf "${link}"
  fi

  # Ensure parent directory exists
  local parent
  parent=$(dirname "${link}")
  mkdir -p "${parent}"

  ln -sf "${target}" "${link}"
  log_debug "  ✔ Symlink: ${link} → ${target}"
}

# ---------------------------------------------------------------------------
# ENSURE DIRECTORY EXISTS
# ---------------------------------------------------------------------------
ensure_dir() {
  local dir="$1"
  local mode="${2:-755}"

  if [[ ! -d "${dir}" ]]; then
    mkdir -p "${dir}"
    chmod "${mode}" "${dir}"
    log_debug "  ✔ Created directory: ${dir}"
  fi
}

# ---------------------------------------------------------------------------
# SAFE INSTALL FILE
# ---------------------------------------------------------------------------
# safe_install_file <src> <dest> [<mode>]
# Backs up dest before installing src
safe_install_file() {
  local src="$1"
  local dest="$2"
  local mode="${3:-644}"

  if [[ ! -f "${src}" ]]; then
    log_warn "Source file not found: ${src}"
    return 1
  fi

  # Backup existing
  if [[ -e "${dest}" ]]; then
    backup_file "${dest}" 2>/dev/null || true
  fi

  local dest_dir
  dest_dir=$(dirname "${dest}")
  mkdir -p "${dest_dir}"

  install -m "${mode}" "${src}" "${dest}"
  log_debug "  ✔ Installed: ${dest}"
}

# ---------------------------------------------------------------------------
# ADD TO PATH (idempotent)
# ---------------------------------------------------------------------------
# add_to_path <dir> — adds to current session PATH if not already present
add_to_path() {
  local dir="$1"
  case ":${PATH}:" in
    *":${dir}:"*) return 0 ;;
    *)            export PATH="${dir}:${PATH}" ;;
  esac
}

# ---------------------------------------------------------------------------
# VERSION COMPARISON
# ---------------------------------------------------------------------------
# version_compare <v1> <v2>
# Returns: 0 if v1==v2, 1 if v1>v2, 2 if v1<v2
version_compare() {
  local v1="$1"
  local v2="$2"

  if [[ "${v1}" == "${v2}" ]]; then
    return 0
  fi

  local IFS=.
  local i
  local a=("${v1}"); local b=("${v2}")

  # Zero-pad shorter version
  for (( i=${#a[@]}; i<${#b[@]}; i++ )); do a[i]=0; done
  for (( i=${#b[@]}; i<${#a[@]}; i++ )); do b[i]=0; done

  for (( i=0; i<${#a[@]}; i++ )); do
    local na="${a[$i]##0}"
    local nb="${b[$i]##0}"
    na="${na:-0}"; nb="${nb:-0}"
    if (( na > nb )); then return 1; fi
    if (( na < nb )); then return 2; fi
  done

  return 0
}

# version_at_least <actual> <required>
version_at_least() {
  version_compare "$1" "$2"
  local rc=$?
  (( rc == 0 || rc == 1 ))
}

# ---------------------------------------------------------------------------
# DOWNLOAD WITH PROGRESS
# ---------------------------------------------------------------------------
# download_file <url> <dest_path> [<description>]
download_file() {
  local url="$1"
  local dest="$2"
  local description="${3:-$(basename "${dest}")}"

  log_info "Downloading ${description}..."

  local dest_dir
  dest_dir=$(dirname "${dest}")
  mkdir -p "${dest_dir}"

  if command -v curl &>/dev/null; then
    if curl -fsSL --progress-bar "${url}" -o "${dest}" 2>&1; then
      log_success "Downloaded: ${description}"
      return 0
    fi
  elif command -v wget &>/dev/null; then
    if wget -q --show-progress -O "${dest}" "${url}" 2>&1; then
      log_success "Downloaded: ${description}"
      return 0
    fi
  else
    log_error "Neither curl nor wget is available."
    return 1
  fi

  log_warn "Download failed: ${description}"
  rm -f "${dest}"
  return 1
}

# ---------------------------------------------------------------------------
# EXTRACT ARCHIVE
# ---------------------------------------------------------------------------
# extract_archive <file> [<dest_dir>]
extract_archive() {
  local file="$1"
  local dest="${2:-.}"

  if [[ ! -f "${file}" ]]; then
    log_error "Archive not found: ${file}"
    return 1
  fi

  mkdir -p "${dest}"

  local filename
  filename=$(basename "${file}")

  case "${filename}" in
    *.tar.gz|*.tgz)   tar -xzf "${file}" -C "${dest}"  ;;
    *.tar.bz2|*.tbz2) tar -xjf "${file}" -C "${dest}"  ;;
    *.tar.xz)          tar -xJf "${file}" -C "${dest}"  ;;
    *.tar.zst)         tar --use-compress-program=unzstd -xf "${file}" -C "${dest}" ;;
    *.zip)             unzip -q "${file}" -d "${dest}"  ;;
    *.gz)              gunzip -c "${file}" > "${dest}/${filename%.gz}" ;;
    *.bz2)             bunzip2 -k "${file}" && mv "${file%.bz2}" "${dest}/" ;;
    *.xz)              xz -dk "${file}" && mv "${file%.xz}" "${dest}/" ;;
    *.7z)              7z x "${file}" -o"${dest}" >/dev/null ;;
    *)                 log_warn "Unknown archive format: ${file}"; return 1 ;;
  esac

  log_debug "Extracted: ${file} → ${dest}"
}

# ---------------------------------------------------------------------------
# CLONE OR UPDATE GIT REPO
# ---------------------------------------------------------------------------
# git_clone_or_update <url> <dest_dir> [<branch>]
git_clone_or_update() {
  local url="$1"
  local dest="$2"
  local branch="${3:-}"

  if [[ -d "${dest}/.git" ]]; then
    log_debug "  ↷ Updating: ${dest}"
    git -C "${dest}" pull --ff-only --quiet 2>/dev/null || \
      log_warn "Failed to update ${dest} (may be modified)"
    return 0
  fi

  log_debug "  → Cloning: ${url} → ${dest}"
  local clone_args=("--depth=1" "--quiet")
  [[ -n "${branch}" ]] && clone_args+=("--branch" "${branch}")

  if git clone "${clone_args[@]}" "${url}" "${dest}" 2>/dev/null; then
    log_debug "  ✔ Cloned: ${dest}"
    return 0
  else
    log_warn "Failed to clone: ${url}"
    return 1
  fi
}

# ---------------------------------------------------------------------------
# CHECK BROKEN SYMLINKS
# ---------------------------------------------------------------------------
find_broken_symlinks() {
  local dir="${1:-${HOME}}"
  find "${dir}" -maxdepth 5 -type l ! -e 2>/dev/null
}

# ---------------------------------------------------------------------------
# STRING UTILITIES
# ---------------------------------------------------------------------------
str_trim() {
  local s="$*"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "${s}"
}

str_upper() { printf '%s' "$1" | tr '[:lower:]' '[:upper:]'; }
str_lower() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }

str_contains() {
  local haystack="$1"
  local needle="$2"
  [[ "${haystack}" == *"${needle}"* ]]
}

# ---------------------------------------------------------------------------
# TEMP FILE / DIR WITH AUTO CLEANUP
# ---------------------------------------------------------------------------
_TEMP_FILES=()

make_temp_file() {
  local tmp
  tmp=$(mktemp)
  _TEMP_FILES+=("${tmp}")
  printf '%s' "${tmp}"
}

make_temp_dir() {
  local tmp
  tmp=$(mktemp -d)
  _TEMP_FILES+=("${tmp}")
  printf '%s' "${tmp}"
}

cleanup_temp_files() {
  local f
  for f in "${_TEMP_FILES[@]}"; do
    rm -rf "${f}" 2>/dev/null || true
  done
  _TEMP_FILES=()
}

trap cleanup_temp_files EXIT

# ---------------------------------------------------------------------------
# APPEND TO FILE (idempotent — only if line not already present)
# ---------------------------------------------------------------------------
append_if_missing() {
  local file="$1"
  local line="$2"

  if [[ ! -f "${file}" ]]; then
    mkdir -p "$(dirname "${file}")"
    touch "${file}"
  fi

  if ! grep -qxF "${line}" "${file}" 2>/dev/null; then
    printf '%s\n' "${line}" >> "${file}"
    log_debug "  ✔ Appended to ${file}: ${line}"
  else
    log_debug "  ↷ Already in ${file}: ${line}"
  fi
}

# ---------------------------------------------------------------------------
# HUMAN READABLE SIZES
# ---------------------------------------------------------------------------
human_size() {
  local bytes="$1"
  if   (( bytes >= 1073741824 )); then printf '%.1fGB' "$(echo "scale=1; ${bytes}/1073741824" | bc)"
  elif (( bytes >= 1048576    )); then printf '%.1fMB' "$(echo "scale=1; ${bytes}/1048576"    | bc)"
  elif (( bytes >= 1024       )); then printf '%.1fKB' "$(echo "scale=1; ${bytes}/1024"       | bc)"
  else  printf '%dB' "${bytes}"
  fi
}

# ---------------------------------------------------------------------------
# GET SCRIPT ROOT DIRECTORY
# ---------------------------------------------------------------------------
get_script_root() {
  local source="${BASH_SOURCE[0]}"
  local dir
  while [[ -L "${source}" ]]; do
    dir=$(cd -P "$(dirname "${source}")" && pwd)
    source=$(readlink "${source}")
    [[ "${source}" != /* ]] && source="${dir}/${source}"
  done
  cd -P "$(dirname "${source}")" && pwd
}
