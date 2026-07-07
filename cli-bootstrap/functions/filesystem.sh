#!/usr/bin/env zsh
# =============================================================================
# functions/filesystem.sh — Filesystem functions (30+)
# =============================================================================

# Create directory and cd into it
mkcd() {
  mkdir -p "$@" && cd "${@: -1}"
}

# Extract any archive format
extract() {
  if [[ -z "$1" ]]; then
    echo "Usage: extract <archive>" >&2
    return 1
  fi
  for file in "$@"; do
    if [[ ! -f "${file}" ]]; then
      echo "extract: '${file}' is not a file" >&2
      continue
    fi
    case "${file}" in
      *.tar.bz2)   tar -xjvf "${file}"   ;;
      *.tar.gz)    tar -xzvf "${file}"   ;;
      *.tar.xz)    tar -xJvf "${file}"   ;;
      *.tar.zst)   tar --use-compress-program=unzstd -xvf "${file}" ;;
      *.tar)       tar -xvf  "${file}"   ;;
      *.bz2)       bunzip2   "${file}"   ;;
      *.gz)        gunzip    "${file}"   ;;
      *.rar)       unrar x   "${file}"   ;;
      *.zip)       unzip     "${file}"   ;;
      *.Z)         uncompress "${file}"  ;;
      *.7z)        7z x      "${file}"   ;;
      *.deb)       ar x      "${file}"   ;;
      *.tar.lz)    tar --lzip -xvf "${file}" ;;
      *.lz4)       lz4 -d    "${file}"   ;;
      *.zst)       zstd -d   "${file}"   ;;
      *.xz)        xz -d     "${file}"   ;;
      *)           echo "extract: '${file}' cannot be extracted (unknown format)" >&2 ;;
    esac
  done
}

# Compress a file or directory
compress() {
  local name="${1%/}"
  local format="${2:-tar.gz}"
  local output="${name}.${format}"

  case "${format}" in
    tar.gz)  tar -czvf "${output}" "${1}" ;;
    tar.bz2) tar -cjvf "${output}" "${1}" ;;
    tar.xz)  tar -cJvf "${output}" "${1}" ;;
    zip)     zip -r "${output}" "${1}"    ;;
    7z)      7z a "${output}" "${1}"      ;;
    *)       echo "compress: unknown format '${format}'" >&2; return 1 ;;
  esac

  echo "Compressed: ${output} ($(du -sh "${output}" | cut -f1))"
}

# Find large files
find-large-files() {
  local dir="${1:-.}"
  local min_size="${2:-100M}"
  find "${dir}" -type f -size +"${min_size}" -exec du -sh {} \; 2>/dev/null | sort -rh | head -20
}

# Disk usage report
disk-report() {
  echo ""
  echo "=== Disk Usage Report ==="
  echo ""
  df -h
  echo ""
  echo "=== Top 10 Large Directories ==="
  du -h --max-depth=2 "${1:-.}" 2>/dev/null | sort -rh | head -10
}

# Find files modified in last N minutes
find-recent() {
  local minutes="${1:-60}"
  local dir="${2:-.}"
  find "${dir}" -type f -mmin -"${minutes}" 2>/dev/null | sort
}

# Create a backup of a file
backup-file() {
  local file="$1"
  local ts
  ts=$(date '+%Y%m%d_%H%M%S')
  cp -v "${file}" "${file}.bak.${ts}"
}

# Show file size in human-readable format
fsize() {
  du -sh "$@" 2>/dev/null
}

# Count files in directory
count-files() {
  local dir="${1:-.}"
  find "${dir}" -type f | wc -l
}

# Show directory tree with sizes
treeds() {
  if command -v dust &>/dev/null; then
    dust "${1:-.}"
  else
    du -sh "${1:-.}"/* 2>/dev/null | sort -rh
  fi
}

# Quick serve a directory via HTTP
serve() {
  local port="${1:-8000}"
  local dir="${2:-.}"
  echo "Serving ${dir} on http://localhost:${port}"
  if command -v python3 &>/dev/null; then
    python3 -m http.server "${port}" --directory "${dir}"
  elif command -v npx &>/dev/null; then
    npx -y serve -l "${port}" "${dir}"
  else
    echo "No HTTP server available. Install python3 or node." >&2
    return 1
  fi
}

# Create a temp directory and cd into it
tmpdir() {
  local dir
  dir=$(mktemp -d -t "tmp.XXXXXX")
  echo "Created: ${dir}"
  cd "${dir}"
}

# Remove empty directories recursively
rmempty() {
  find "${1:-.}" -type d -empty -delete 2>/dev/null
  echo "Empty directories removed."
}

# Fix permissions (directories 755, files 644)
fix-permissions() {
  local dir="${1:-.}"
  find "${dir}" -type d -exec chmod 755 {} \;
  find "${dir}" -type f -exec chmod 644 {} \;
  echo "Permissions fixed in ${dir}"
}

# Fix web permissions (for www-data)
fix-web-permissions() {
  local dir="${1:-.}"
  local user="${2:-www-data}"
  sudo chown -R "${user}:${user}" "${dir}"
  find "${dir}" -type d -exec chmod 755 {} \;
  find "${dir}" -type f -exec chmod 644 {} \;
  echo "Web permissions set for ${user} in ${dir}"
}

# Duplicate a file with auto-incrementing name
dup() {
  local file="$1"
  local base="${file%.*}"
  local ext="${file##*.}"
  local n=1
  local newfile

  while true; do
    newfile="${base}_${n}.${ext}"
    [[ ! -f "${newfile}" ]] && break
    (( n++ ))
  done

  cp "${file}" "${newfile}"
  echo "Duplicated: ${newfile}"
}

# Watch a directory for changes
watch-dir() {
  local dir="${1:-.}"
  if command -v inotifywait &>/dev/null; then
    inotifywait -mr --format "%T %w%f %e" --timefmt "%H:%M:%S" "${dir}"
  else
    echo "inotifywait not found. Install: sudo apt-get install inotify-tools" >&2
  fi
}

# Find and replace in files
find-replace() {
  local search="$1"
  local replace="$2"
  local dir="${3:-.}"
  local ext="${4:-*}"

  if command -v rg &>/dev/null; then
    rg -l --glob "${ext}" "${search}" "${dir}" | \
      xargs -I{} sed -i "s/${search}/${replace}/g" {}
  else
    find "${dir}" -name "${ext}" -type f -exec \
      sed -i "s/${search}/${replace}/g" {} +
  fi
  echo "Replaced '${search}' with '${replace}' in ${dir}"
}

# Show disk IOPS
disk-iops() {
  iostat -x 1 5 2>/dev/null || vmstat -d 1 5
}

# List all open files by process
open-files() {
  lsof -n -P "${1:+"-p $1"}" 2>/dev/null | head -50
}
