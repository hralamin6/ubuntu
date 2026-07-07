#!/usr/bin/env bash
# =============================================================================
# lib/ui.sh — Terminal UI: banners, spinners, progress bars, prompts
# =============================================================================

[[ -n "${_CLI_BOOTSTRAP_UI_LOADED:-}" ]] && return 0
readonly _CLI_BOOTSTRAP_UI_LOADED=1

# ---------------------------------------------------------------------------
# BANNER
# ---------------------------------------------------------------------------
ui_banner() {
  local version="${1:-1.0.0}"
  printf "\n" >&2
  printf "%b" "${CLR_BOLD_CYAN}" >&2
  cat >&2 <<'BANNER'
   ██████╗██╗     ██╗    ██████╗  ██████╗  ██████╗ ████████╗
  ██╔════╝██║     ██║    ██╔══██╗██╔═══██╗██╔═══██╗╚══██╔══╝
  ██║     ██║     ██║    ██████╔╝██║   ██║██║   ██║   ██║
  ██║     ██║     ██║    ██╔══██╗██║   ██║██║   ██║   ██║
  ╚██████╗███████╗██║    ██████╔╝╚██████╔╝╚██████╔╝   ██║
   ╚═════╝╚══════╝╚═╝    ╚═════╝  ╚═════╝  ╚═════╝    ╚═╝
BANNER
  printf "%b" "${CLR_RESET}" >&2
  printf "%b  %-30s  %s%b\n\n" \
    "${CLR_DIM}" \
    "Linux CLI Bootstrap Framework" \
    "v${version}" \
    "${CLR_RESET}" >&2
  printf "%b  %s%b\n\n" \
    "${CLR_DIM}" \
    "Production-quality CLI environment for developers & DevOps engineers" \
    "${CLR_RESET}" >&2
}

# ---------------------------------------------------------------------------
# SPINNER
# ---------------------------------------------------------------------------
_SPINNER_PID=0

ui_spinner_start() {
  local message="${1:-Working...}"
  local frames=('⣾' '⣽' '⣻' '⢿' '⡿' '⣟' '⣯' '⣷')

  # Don't run spinner in non-interactive or CI
  if ! is_interactive || is_ci; then
    printf "%b  ·  %s...%b\n" "${CLR_DIM}" "${message}" "${CLR_RESET}" >&2
    return 0
  fi

  {
    local i=0
    while true; do
      printf "\r%b  %s  %s%b" \
        "${CLR_BOLD_CYAN}" "${frames[$((i % ${#frames[@]}))]}" "${message}" "${CLR_RESET}" >&2
      sleep 0.08
      (( i++ ))
    done
  } &
  _SPINNER_PID=$!
  disown "${_SPINNER_PID}"
}

ui_spinner_stop() {
  local status="${1:-0}"  # 0=success, 1=fail
  if (( _SPINNER_PID > 0 )); then
    kill "${_SPINNER_PID}" 2>/dev/null || true
    wait "${_SPINNER_PID}" 2>/dev/null || true
    _SPINNER_PID=0
  fi

  if (( status == 0 )); then
    printf "\r%b  ✔  Done%-40s%b\n" "${CLR_BOLD_GREEN}" "" "${CLR_RESET}" >&2
  else
    printf "\r%b  ✖  Failed%-38s%b\n" "${CLR_BOLD_RED}" "" "${CLR_RESET}" >&2
  fi
}

# Run a command with spinner
ui_run_with_spinner() {
  local message="$1"
  shift

  ui_spinner_start "${message}"
  local exit_code=0
  "$@" &>/dev/null || exit_code=$?
  ui_spinner_stop "${exit_code}"

  return "${exit_code}"
}

# ---------------------------------------------------------------------------
# PROGRESS BAR
# ---------------------------------------------------------------------------
ui_progress() {
  local current="$1"
  local total="$2"
  local label="${3:-}"
  local width=40

  if ! is_interactive || is_ci; then
    return 0
  fi

  local pct=$(( current * 100 / total ))
  local filled=$(( current * width / total ))
  local empty=$(( width - filled ))

  local bar=""
  bar+=$(printf '█%.0s' $(seq 1 "${filled}"))
  bar+=$(printf '░%.0s' $(seq 1 "${empty}"))

  printf "\r  %b[%s]%b %b%3d%%%b  %s" \
    "${CLR_CYAN}" "${bar}" "${CLR_RESET}" \
    "${CLR_BOLD_WHITE}" "${pct}" "${CLR_RESET}" \
    "${label}" >&2

  (( current >= total )) && printf "\n" >&2
}

# ---------------------------------------------------------------------------
# CONFIRMATION PROMPT
# ---------------------------------------------------------------------------
ui_confirm() {
  local message="${1:-Continue?}"
  local default="${2:-y}"  # y or n

  if ! is_interactive || is_ci; then
    log_debug "Non-interactive mode: auto-confirming '${message}'"
    return 0
  fi

  local prompt
  if [[ "${default}" == "y" ]]; then
    prompt="${message} [Y/n]: "
  else
    prompt="${message} [y/N]: "
  fi

  local reply
  printf "%b  ?  %s%b" "${CLR_BOLD_YELLOW}" "${prompt}" "${CLR_RESET}" >&2
  read -r reply </dev/tty || reply="${default}"
  reply="${reply:-${default}}"

  case "${reply}" in
    [Yy]|[Yy][Ee][Ss]) return 0 ;;
    *)                  return 1 ;;
  esac
}

# ---------------------------------------------------------------------------
# SELECTION MENU
# ---------------------------------------------------------------------------
ui_select() {
  local prompt="$1"
  shift
  local options=("$@")

  if ! is_interactive; then
    UI_SELECT_RESULT="${options[0]}"
    return 0
  fi

  printf "\n%b  %s%b\n" "${CLR_BOLD_WHITE}" "${prompt}" "${CLR_RESET}" >&2
  local i=1
  for opt in "${options[@]}"; do
    printf "  %b%d)%b %s\n" "${CLR_BOLD_CYAN}" "${i}" "${CLR_RESET}" "${opt}" >&2
    (( i++ ))
  done

  local choice
  printf "\n%b  Enter choice [1-%d]: %b" "${CLR_BOLD_YELLOW}" "${#options[@]}" "${CLR_RESET}" >&2
  read -r choice </dev/tty || choice=1

  if [[ "${choice}" =~ ^[0-9]+$ ]] && \
     (( choice >= 1 && choice <= ${#options[@]} )); then
    UI_SELECT_RESULT="${options[$(( choice - 1 ))]}"
  else
    UI_SELECT_RESULT="${options[0]}"
  fi
}

# ---------------------------------------------------------------------------
# STATUS TABLE
# ---------------------------------------------------------------------------
# Print a summary table of component status
ui_status_table() {
  local -n _table_items="$1"  # nameref to associative array (name → status_string)
  local title="${2:-Status}"

  printf "\n%b  %-35s %s%b\n" "${CLR_BOLD_WHITE}" "${title}" "Status" "${CLR_RESET}" >&2
  printf "%b  %s%b\n" "${CLR_DIM}" "$(printf '─%.0s' {1..55})" "${CLR_RESET}" >&2

  local name status
  for name in "${!_table_items[@]}"; do
    status="${_table_items[${name}]}"
    local color="${CLR_GREEN}"
    local icon="✔"
    case "${status}" in
      ok|installed|active|found)
        color="${CLR_BOLD_GREEN}"; icon="✔" ;;
      warn|missing|degraded)
        color="${CLR_BOLD_YELLOW}"; icon="⚠" ;;
      error|broken|failed)
        color="${CLR_BOLD_RED}"; icon="✖" ;;
      skip|skipped|na)
        color="${CLR_DIM}"; icon="○" ;;
    esac
    printf "  %-35s %b%s  %s%b\n" \
      "${name}" "${color}" "${icon}" "${status}" "${CLR_RESET}" >&2
  done
  printf "\n" >&2
}

# ---------------------------------------------------------------------------
# SUCCESS SUMMARY
# ---------------------------------------------------------------------------
ui_success_summary() {
  local elapsed_ms="${1:-0}"

  printf "\n%b" "${CLR_BOLD_GREEN}" >&2
  cat >&2 <<'DONE'
  ╔══════════════════════════════════════════════════════════════╗
  ║                                                              ║
  ║    ✔  CLI Bootstrap — Installation Complete!                ║
  ║                                                              ║
  ╚══════════════════════════════════════════════════════════════╝
DONE
  printf "%b" "${CLR_RESET}" >&2

  printf "\n  %bNext steps:%b\n" "${CLR_BOLD_WHITE}" "${CLR_RESET}" >&2
  printf "  %b1.%b  Reload your shell:  %bexec zsh%b\n" \
    "${CLR_CYAN}" "${CLR_RESET}" "${CLR_BOLD_WHITE}" "${CLR_RESET}" >&2
  printf "  %b2.%b  Run diagnostics:   %b./doctor.sh%b\n" \
    "${CLR_CYAN}" "${CLR_RESET}" "${CLR_BOLD_WHITE}" "${CLR_RESET}" >&2
  printf "  %b3.%b  Read the docs:     %bREADME.md%b\n" \
    "${CLR_CYAN}" "${CLR_RESET}" "${CLR_BOLD_WHITE}" "${CLR_RESET}" >&2

  if (( elapsed_ms > 0 )); then
    local elapsed_s=$(( elapsed_ms / 1000 ))
    printf "\n  %bCompleted in %ds%b\n" "${CLR_DIM}" "${elapsed_s}" "${CLR_RESET}" >&2
  fi
  printf "\n" >&2
}

# ---------------------------------------------------------------------------
# DIVIDER / LABEL HELPERS
# ---------------------------------------------------------------------------
ui_divider() {
  local char="${1:--}"
  local width="${2:-68}"
  printf "%b%s%b\n" "${CLR_DARK_GRAY}" "$(printf "${char}%.0s" $(seq 1 "${width}"))" "${CLR_RESET}" >&2
}

ui_label() {
  local label="$1"
  local value="${2:-}"
  printf "  %b%-28s%b  %b%s%b\n" \
    "${CLR_BOLD_WHITE}" "${label}" "${CLR_RESET}" \
    "${CLR_CYAN}" "${value}" "${CLR_RESET}" >&2
}

# Tag-style status badge
ui_badge() {
  local label="$1"
  local status="$2"
  local color="${CLR_GREEN}"
  case "${status}" in
    ok|pass|installed) color="${CLR_BOLD_GREEN}" ;;
    warn|skip)         color="${CLR_BOLD_YELLOW}" ;;
    fail|error)        color="${CLR_BOLD_RED}"    ;;
  esac
  printf "%b[%s: %s]%b" "${color}" "${label}" "${status}" "${CLR_RESET}" >&2
}
