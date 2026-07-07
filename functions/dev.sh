#!/usr/bin/env zsh
# =============================================================================
# functions/dev.sh — Developer tools functions (20+)
# =============================================================================

# Fuzzy command history search (zsh native + fzf)
fuzzy-history() {
  local cmd
  cmd=$(history -n 1 | fzf --tac --no-sort --query="${LBUFFER}" \
    --preview 'echo {}' --preview-window=down:3:wrap \
    --bind '?:toggle-preview')
  if [[ -n "${cmd}" ]]; then
    LBUFFER="${cmd}"
    zle redisplay
  fi
}

# Fuzzy cd using zoxide or fd
fuzzy-cd() {
  local dir
  if command -v zoxide &>/dev/null; then
    dir=$(zoxide query -l | fzf --preview 'eza --tree --color=always {} | head -50')
  elif command -v fd &>/dev/null; then
    dir=$(fd --type d --hidden --follow --exclude .git | \
      fzf --preview 'eza --tree --color=always {} | head -50')
  else
    dir=$(find . -type d 2>/dev/null | fzf)
  fi

  [[ -n "${dir}" ]] && cd "${dir}"
}

# JSON pretty printer
json-pretty() {
  if command -v jq &>/dev/null; then
    if [[ -f "$1" ]]; then
      jq '.' "$1"
    else
      echo "$1" | jq '.'
    fi
  else
    python3 -m json.tool "$@"
  fi
}

# YAML pretty printer / validator
yaml-pretty() {
  if command -v yq &>/dev/null; then
    yq eval '.' "$@"
  elif command -v python3 &>/dev/null; then
    python3 -c "
import yaml, sys, json
with open('$1') as f:
    data = yaml.safe_load(f)
print(yaml.dump(data, default_flow_style=False, indent=2))
"
  fi
}

# JSON to YAML converter
json2yaml() {
  if command -v yq &>/dev/null; then
    yq -o yaml eval '.' "${1:-/dev/stdin}"
  else
    python3 -c "
import sys, json, yaml
print(yaml.dump(json.load(open('${1:-/dev/stdin}')), default_flow_style=False))
"
  fi
}

# YAML to JSON converter
yaml2json() {
  if command -v yq &>/dev/null; then
    yq -o json eval '.' "${1:-/dev/stdin}"
  else
    python3 -c "
import sys, json, yaml
print(json.dumps(yaml.safe_load(open('${1:-/dev/stdin}')), indent=2))
"
  fi
}

# Base64 encode/decode
b64encode() { echo -n "$@" | base64; }
b64decode() { echo -n "$@" | base64 --decode; }

# URL encode/decode
url-encode() {
  python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "${1:-}"
}
url-decode() {
  python3 -c "import urllib.parse, sys; print(urllib.parse.unquote(sys.argv[1]))" "${1:-}"
}

# Hash a string with various algorithms
hashit() {
  local input="$1"
  echo "Input: ${input}"
  echo "MD5:    $(echo -n "${input}" | md5sum | cut -d' ' -f1)"
  echo "SHA1:   $(echo -n "${input}" | sha1sum | cut -d' ' -f1)"
  echo "SHA256: $(echo -n "${input}" | sha256sum | cut -d' ' -f1)"
  echo "SHA512: $(echo -n "${input}" | sha512sum | cut -d' ' -f1)"
}

# Environment variable manager (show/set/unset)
env-var() {
  local action="${1:-show}"
  local name="$2"
  local value="$3"

  case "${action}" in
    show)   env | grep -i "${name}" | sort ;;
    set)    export "${name}=${value}"; echo "Set: ${name}=${value}" ;;
    unset)  unset "${name}"; echo "Unset: ${name}" ;;
    *)      echo "Usage: env-var [show|set|unset] [name] [value]" ;;
  esac
}

# Run a script and measure its performance
profile-script() {
  local script="$1"
  shift

  if [[ ! -f "${script}" ]]; then
    echo "File not found: ${script}" >&2
    return 1
  fi

  echo "Profiling: ${script}"
  /usr/bin/time -v "${script}" "$@" 2>&1 | \
    grep -E "wall clock|Maximum resident|Elapsed"
}

# Create a quick note
note() {
  local notes_dir="${HOME}/.notes"
  mkdir -p "${notes_dir}"

  if [[ -z "$1" ]]; then
    ls "${notes_dir}" | head -20
    return 0
  fi

  case "$1" in
    ls|list)   ls "${notes_dir}" ;;
    rm|delete) rm "${notes_dir}/${2}.md" && echo "Deleted: ${2}" ;;
    *)
      local note_file="${notes_dir}/${1}.md"
      if [[ -z "$2" ]]; then
        [[ -f "${note_file}" ]] && cat "${note_file}" || echo "Note '${1}' not found"
      else
        shift
        echo "$(date): $*" >> "${note_file}"
        echo "Appended to note '${1%.*}'"
      fi
      ;;
  esac
}

# Quick port checker
port-check() {
  local host="${1:-localhost}"
  local port="$2"

  if [[ -z "${port}" ]]; then
    echo "Usage: port-check <host> <port>" >&2
    return 1
  fi

  if timeout 3 bash -c ">/dev/tcp/${host}/${port}" 2>/dev/null; then
    echo "✔ ${host}:${port} is OPEN"
  else
    echo "✖ ${host}:${port} is CLOSED"
  fi
}

# Generate random data
random-data() {
  local type="${1:-hex}"
  local length="${2:-32}"

  case "${type}" in
    hex)    openssl rand -hex "${length}" ;;
    base64) openssl rand -base64 "${length}" ;;
    num)    python3 -c "import random; print(random.randint(0, 10**${length}))" ;;
    uuid)   cat /proc/sys/kernel/random/uuid ;;
    *)      openssl rand -hex "${length}" ;;
  esac
}

# Show all available cheatsheets (tldr)
cheatsheet() {
  local command="${1:-}"
  if command -v tldr &>/dev/null; then
    if [[ -n "${command}" ]]; then
      tldr "${command}"
    else
      tldr --list 2>/dev/null | fzf --preview 'tldr {}' | xargs tldr
    fi
  elif command -v cheat &>/dev/null; then
    cheat "${command}"
  else
    man "${command}" 2>/dev/null || echo "No cheatsheet tool found." >&2
  fi
}

# Multi-line heredoc JSON maker
make-json() {
  echo -n "Enter JSON (Ctrl+D when done):"
  local input
  input=$(cat)
  echo "${input}" | python3 -m json.tool
}

# Show startup time of current shell
shell-startup-time() {
  local times=5
  echo "Measuring zsh startup time (${times} runs)..."
  for i in $(seq 1 "${times}"); do
    /usr/bin/time -f "%e" zsh -i -c exit 2>&1
  done
}

# Create a simple HTTP mock server
mock-server() {
  local port="${1:-3000}"
  local response="${2:-{\"status\":\"ok\"}}"

  echo "Mock server on http://localhost:${port}"
  echo "Response: ${response}"
  while true; do
    { echo -e "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\n\r\n${response}"; } | \
      nc -l "${port}" 2>/dev/null
  done
}

# Decode a JWT token (without verification)
jwt-decode() {
  local token="$1"
  if [[ -z "${token}" ]]; then
    echo "Usage: jwt-decode <token>" >&2
    return 1
  fi

  echo "=== Header ==="
  echo "${token}" | cut -d. -f1 | base64 --decode 2>/dev/null | python3 -m json.tool

  echo ""
  echo "=== Payload ==="
  echo "${token}" | cut -d. -f2 | base64 --decode 2>/dev/null | python3 -m json.tool
}

# Find duplicate files
find-duplicates() {
  local dir="${1:-.}"
  find "${dir}" -type f -exec md5sum {} + 2>/dev/null | \
    sort | awk 'BEGIN{prev=""} prev==$1{print $2} {prev=$1}' | head -20
}

# Colorize output of a command
colorize() {
  if command -v grc &>/dev/null; then
    grc "$@"
  elif command -v bat &>/dev/null; then
    "$@" | bat --style=plain --paging=never
  else
    "$@"
  fi
}

# Watch a URL and alert on status change
watch-url() {
  local url="$1"
  local interval="${2:-30}"
  local prev_status=""

  echo "Watching: ${url} (every ${interval}s)"

  while true; do
    local status
    status=$(curl -o /dev/null -s -w "%{http_code}" --max-time 10 "${url}")

    if [[ "${status}" != "${prev_status}" ]]; then
      if [[ -n "${prev_status}" ]]; then
        echo "$(date '+%H:%M:%S') Status changed: ${prev_status} → ${status}"
      else
        echo "$(date '+%H:%M:%S') Status: ${status}"
      fi
      prev_status="${status}"
    fi

    sleep "${interval}"
  done
}
