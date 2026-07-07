#!/usr/bin/env bash
# =============================================================================
# lib/core.sh — Core framework: colors, logging, error handling, rollback
# =============================================================================

[[ -n "${_CLI_BOOTSTRAP_CORE_LOADED:-}" ]] && return 0
readonly _CLI_BOOTSTRAP_CORE_LOADED=1

# ---------------------------------------------------------------------------
# TERMINAL CAPABILITY DETECTION
# ---------------------------------------------------------------------------
__detect_color_support() {
  if [[ -t 1 ]] && command -v tput &>/dev/null; then
    local n; n=$(tput colors 2>/dev/null || echo 0)
    (( n >= 256 )) && echo "256" && return
    (( n >= 8   )) && echo "8"   && return
  fi
  echo "0"
}

__detect_truecolor() {
  [[ "${COLORTERM:-}" =~ ^(truecolor|24bit)$ ]] && echo "1" || echo "0"
}

readonly CLI_COLOR_SUPPORT=$(__detect_color_support)
readonly CLI_TRUECOLOR=$(__detect_truecolor)

# ---------------------------------------------------------------------------
# COLOR SYSTEM
# ---------------------------------------------------------------------------
if (( CLI_COLOR_SUPPORT >= 8 )); then
  readonly CLR_RESET='\033[0m'
  readonly CLR_RED='\033[0;31m'    CLR_GREEN='\033[0;32m'   CLR_YELLOW='\033[0;33m'
  readonly CLR_BLUE='\033[0;34m'   CLR_MAGENTA='\033[0;35m' CLR_CYAN='\033[0;36m'
  readonly CLR_WHITE='\033[0;37m'
  readonly CLR_BOLD_RED='\033[1;31m'    CLR_BOLD_GREEN='\033[1;32m'
  readonly CLR_BOLD_YELLOW='\033[1;33m' CLR_BOLD_BLUE='\033[1;34m'
  readonly CLR_BOLD_MAGENTA='\033[1;35m' CLR_BOLD_CYAN='\033[1;36m'
  readonly CLR_BOLD_WHITE='\033[1;37m'
  readonly CLR_BOLD='\033[1m' CLR_DIM='\033[2m' CLR_ITALIC='\033[3m'
  readonly CLR_UNDERLINE='\033[4m' CLR_STRIKETHROUGH='\033[9m'
else
  readonly CLR_RESET='' CLR_RED='' CLR_GREEN='' CLR_YELLOW=''
  readonly CLR_BLUE='' CLR_MAGENTA='' CLR_CYAN='' CLR_WHITE=''
  readonly CLR_BOLD_RED='' CLR_BOLD_GREEN='' CLR_BOLD_YELLOW=''
  readonly CLR_BOLD_BLUE='' CLR_BOLD_MAGENTA='' CLR_BOLD_CYAN='' CLR_BOLD_WHITE=''
  readonly CLR_BOLD='' CLR_DIM='' CLR_ITALIC='' CLR_UNDERLINE='' CLR_STRIKETHROUGH=''
fi

if (( CLI_COLOR_SUPPORT >= 256 )); then
  readonly CLR_ORANGE='\033[38;5;208m' CLR_PURPLE='\033[38;5;135m'
  readonly CLR_PINK='\033[38;5;213m'   CLR_TEAL='\033[38;5;51m'
  readonly CLR_LIME='\033[38;5;154m'   CLR_GOLD='\033[38;5;220m'
  readonly CLR_CORAL='\033[38;5;203m'  CLR_INDIGO='\033[38;5;63m'
  readonly CLR_GRAY='\033[38;5;245m'   CLR_DARK_GRAY='\033[38;5;236m'
  readonly CLR_LIGHT_GRAY='\033[38;5;252m'
  readonly CLR_EMERALD='\033[38;5;48m' CLR_SKY='\033[38;5;117m'
else
  readonly CLR_ORANGE='' CLR_PURPLE='' CLR_PINK='' CLR_TEAL=''
  readonly CLR_LIME='' CLR_GOLD='' CLR_CORAL='' CLR_INDIGO=''
  readonly CLR_GRAY='' CLR_DARK_GRAY='' CLR_LIGHT_GRAY=''
  readonly CLR_EMERALD='' CLR_SKY=''
fi

# ---------------------------------------------------------------------------
# LOGGING SYSTEM
# ---------------------------------------------------------------------------
readonly LOG_LEVEL_DEBUG=0
readonly LOG_LEVEL_INFO=1
readonly LOG_LEVEL_WARN=2
readonly LOG_LEVEL_ERROR=3
readonly LOG_LEVEL_SILENT=4
: "${CLI_LOG_LEVEL:=${LOG_LEVEL_INFO}}"
: "${CLI_LOG_FILE:=}"

__log_timestamp() { date '+%Y-%m-%d %H:%M:%S'; }

__log() {
  local level="$1" level_num="$2" color="$3" icon="$4"; shift 4
  (( level_num < CLI_LOG_LEVEL )) && return 0
  printf "%b%s%b %b%s%b\n" "${color}" "${icon}" "${CLR_RESET}" "${color}" "$*" "${CLR_RESET}" >&2
  [[ -n "${CLI_LOG_FILE}" ]] && printf "[%s] [%s] %s\n" "$(__log_timestamp)" "${level}" "$*" >> "${CLI_LOG_FILE}" 2>/dev/null || true
}

log_debug()   { __log "DEBUG" "${LOG_LEVEL_DEBUG}" "${CLR_DIM}"          "  ·" "$@"; }
log_info()    { __log "INFO"  "${LOG_LEVEL_INFO}"  "${CLR_BOLD_BLUE}"    "  ●" "$@"; }
log_success() { __log "OK"    "${LOG_LEVEL_INFO}"  "${CLR_BOLD_GREEN}"   "  ✔" "$@"; }
log_warn()    { __log "WARN"  "${LOG_LEVEL_WARN}"  "${CLR_BOLD_YELLOW}"  "  ⚠" "$@"; }
log_error()   { __log "ERROR" "${LOG_LEVEL_ERROR}" "${CLR_BOLD_RED}"     "  ✖" "$@"; }

log_section() {
  local title="$1"
  local line; line=$(printf '─%.0s' {1..68})
  printf "\n%b%s%b\n" "${CLR_BOLD_CYAN}" "${line}" "${CLR_RESET}" >&2
  printf "%b  ◆  %s%b\n" "${CLR_BOLD_CYAN}" "${title}" "${CLR_RESET}" >&2
  printf "%b%s%b\n\n" "${CLR_BOLD_CYAN}" "${line}" "${CLR_RESET}" >&2
}

log_step() {
  local step="$1" total="$2" desc="$3"
  printf "\n%b  [%s/%s]%b %b%s%b\n" \
    "${CLR_BOLD_MAGENTA}" "${step}" "${total}" "${CLR_RESET}" \
    "${CLR_BOLD_WHITE}" "${desc}" "${CLR_RESET}" >&2
}

kv_print() {
  printf "  %b%-30s%b %b%s%b\n" \
    "${CLR_BOLD_WHITE}" "${1}:" "${CLR_RESET}" \
    "${CLR_CYAN}" "${2}" "${CLR_RESET}" >&2
}

# ---------------------------------------------------------------------------
# ROLLBACK STACK
# ---------------------------------------------------------------------------
declare -a _ROLLBACK_STACK=()

rollback_push() { _ROLLBACK_STACK+=("$*"); }

rollback_execute() {
  (( ${#_ROLLBACK_STACK[@]} == 0 )) && return 0
  log_warn "Executing rollback (${#_ROLLBACK_STACK[@]} actions)..."
  local i
  for (( i=${#_ROLLBACK_STACK[@]}-1; i>=0; i-- )); do
    log_debug "Rollback: ${_ROLLBACK_STACK[$i]}"
    eval "${_ROLLBACK_STACK[$i]}" 2>/dev/null || log_warn "Rollback failed: ${_ROLLBACK_STACK[$i]}"
  done
  _ROLLBACK_STACK=()
  log_info "Rollback complete."
}

rollback_clear() { _ROLLBACK_STACK=(); }

# ---------------------------------------------------------------------------
# ERROR HANDLING & TRAPS
# ---------------------------------------------------------------------------
_CLI_ERROR_HANDLED=0

__err_handler() {
  local exit_code=$?
  local line_no="${BASH_LINENO[0]:-?}"
  local func="${FUNCNAME[1]:-main}"
  local file="${BASH_SOURCE[1]:-unknown}"
  (( _CLI_ERROR_HANDLED )) && return
  _CLI_ERROR_HANDLED=1
  printf "\n%b╔══════════════════════════════════════════════════╗\n" "${CLR_BOLD_RED}" >&2
  printf "║  ✖  CLI Bootstrap — Fatal Error                  ║\n" >&2
  printf "╠══════════════════════════════════════════════════╣\n" >&2
  printf "║  Exit code : %-34s ║\n" "${exit_code}" >&2
  printf "║  Function  : %-34s ║\n" "${func}" >&2
  printf "║  Line      : %-34s ║\n" "${line_no}" >&2
  printf "║  File      : %-34s ║\n" "$(basename "${file}")" >&2
  printf "╚══════════════════════════════════════════════════╝%b\n" "${CLR_RESET}" >&2
  rollback_execute
  exit "${exit_code}"
}

__exit_handler() {
  printf "\n%b✖  Signal %s received. Cleaning up...%b\n" "${CLR_BOLD_YELLOW}" "$1" "${CLR_RESET}" >&2
  rollback_execute
  exit 130
}

trap '__err_handler'         ERR
trap '__exit_handler INT'    INT
trap '__exit_handler TERM'   TERM

# ---------------------------------------------------------------------------
# UTILITY HELPERS
# ---------------------------------------------------------------------------
die()              { log_error "$@"; exit 1; }
require_root()     { [[ "${EUID}" -ne 0 ]] && die "Requires root. Run with sudo." || true; }
require_nonroot()  { [[ "${EUID}" -eq 0 ]] && die "Do not run as root." || true; }
is_interactive()   { [[ -t 0 && -t 1 ]]; }
command_exists()   { command -v "$1" &>/dev/null; }
is_ci()            { [[ -n "${CI:-}${GITHUB_ACTIONS:-}${GITLAB_CI:-}" ]]; }

timeit() {
  local start end elapsed
  start=$(date +%s%N)
  "$@"
  end=$(date +%s%N)
  elapsed=$(( (end - start) / 1000000 ))
  printf "%b  ⏱  Done in %sms%b\n" "${CLR_DIM}" "${elapsed}" "${CLR_RESET}" >&2
}

export CLI_LOG_LEVEL CLI_LOG_FILE CLI_COLOR_SUPPORT CLI_TRUECOLOR
