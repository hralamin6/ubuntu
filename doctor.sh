#!/usr/bin/env bash
# =============================================================================
# doctor.sh — Self-healing diagnostics and auto-fix
# =============================================================================
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/core.sh"
source "${SCRIPT_DIR}/lib/detect.sh"
source "${SCRIPT_DIR}/lib/ui.sh"
source "${SCRIPT_DIR}/lib/utils.sh"

readonly BOOTSTRAP_VERSION="$(cat "${SCRIPT_DIR}/VERSION" 2>/dev/null || echo '1.0.0')"
: "${CLI_INSTALL_DIR:="${HOME}/.cli-bootstrap"}"
: "${FIX_MODE:=0}"
: "${VERBOSE:=0}"

_TOTAL_CHECKS=0
_PASSED_CHECKS=0
_WARNED_CHECKS=0
_FAILED_CHECKS=0

# ---------------------------------------------------------------------------
# CHECK HELPERS
# ---------------------------------------------------------------------------
check_pass() {
  local name="$1"
  local detail="${2:-}"
  (( _TOTAL_CHECKS++ )); (( _PASSED_CHECKS++ ))
  printf "  %b✔%b  %-40s %b%s%b\n" \
    "${CLR_BOLD_GREEN}" "${CLR_RESET}" "${name}" \
    "${CLR_DIM}" "${detail}" "${CLR_RESET}" >&2
}

check_warn() {
  local name="$1"
  local detail="${2:-}"
  (( _TOTAL_CHECKS++ )); (( _WARNED_CHECKS++ ))
  printf "  %b⚠%b  %-40s %b%s%b\n" \
    "${CLR_BOLD_YELLOW}" "${CLR_RESET}" "${name}" \
    "${CLR_YELLOW}" "${detail}" "${CLR_RESET}" >&2
}

check_fail() {
  local name="$1"
  local detail="${2:-}"
  local fix="${3:-}"
  (( _TOTAL_CHECKS++ )); (( _FAILED_CHECKS++ ))
  printf "  %b✖%b  %-40s %b%s%b\n" \
    "${CLR_BOLD_RED}" "${CLR_RESET}" "${name}" \
    "${CLR_RED}" "${detail}" "${CLR_RESET}" >&2

  if [[ -n "${fix}" && "${FIX_MODE}" -eq 1 ]]; then
    printf "     %b→ Fixing: %s%b\n" "${CLR_DIM}" "${fix}" "${CLR_RESET}" >&2
    eval "${fix}" 2>/dev/null && \
      printf "     %b✔ Fixed%b\n" "${CLR_GREEN}" "${CLR_RESET}" >&2 || \
      printf "     %b✖ Fix failed%b\n" "${CLR_RED}" "${CLR_RESET}" >&2
  elif [[ -n "${fix}" ]]; then
    printf "     %bFix: %s%b\n" "${CLR_DIM}" "${fix}" "${CLR_RESET}" >&2
  fi
}

# ---------------------------------------------------------------------------
# CHECK: REQUIRED BINARIES
# ---------------------------------------------------------------------------
check_binaries() {
  log_section "Required Binaries"

  local -A required_binaries=(
    [zsh]=""
    [git]=""
    [curl]=""
    [tmux]=""
    [fzf]=""
    [jq]=""
    [python3]=""
    [ssh]=""
    [rsync]=""
  )

  local -A recommended_binaries=(
    [starship]="curl -fsSL https://starship.rs/install.sh | sh -s -- --yes"
    [bat]="sudo apt-get install -y bat || sudo apt-get install -y batcat"
    [eza]="sudo apt-get install -y eza"
    [fd]="sudo apt-get install -y fd-find"
    [rg]="sudo apt-get install -y ripgrep"
    [zoxide]="curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh"
    [atuin]="curl --proto '=https' --tlsv1.2 -sSf https://setup.atuin.sh | sh"
    [lazygit]="see bootstrap.sh"
    [delta]="see bootstrap.sh"
    [yazi]="see bootstrap.sh"
    [gh]="sudo apt-get install gh"
    [btop]="sudo apt-get install -y btop"
    [tldr]="sudo apt-get install -y tldr"
    [direnv]="sudo apt-get install -y direnv"
    [thefuck]="sudo apt-get install -y thefuck"
  )

  for bin in "${!required_binaries[@]}"; do
    if command -v "${bin}" &>/dev/null; then
      check_pass "${bin}" "$(command -v "${bin}")"
    else
      check_fail "${bin}" "MISSING — required" "sudo apt-get install -y ${bin}"
    fi
  done

  for bin in "${!recommended_binaries[@]}"; do
    if command -v "${bin}" &>/dev/null; then
      check_pass "${bin}" "$(command -v "${bin}")"
    elif [[ "${bin}" == "bat" ]] && command -v batcat &>/dev/null; then
      check_warn "${bin}" "installed as 'batcat'"
    elif [[ "${bin}" == "fd" ]] && command -v fdfind &>/dev/null; then
      check_warn "${bin}" "installed as 'fdfind'"
    else
      check_warn "${bin}" "not found (optional)" # "${recommended_binaries[${bin}]}"
    fi
  done
}

# ---------------------------------------------------------------------------
# CHECK: ZSH CONFIGURATION
# ---------------------------------------------------------------------------
check_zsh_config() {
  log_section "Zsh Configuration"

  # .zshrc
  if [[ -f "${HOME}/.zshrc" ]]; then
    if zsh -n "${HOME}/.zshrc" 2>/dev/null; then
      check_pass ".zshrc" "syntax OK"
    else
      check_fail ".zshrc" "SYNTAX ERROR" ""
    fi
  else
    check_fail ".zshrc" "MISSING" "cp ${SCRIPT_DIR}/configs/zshrc ${HOME}/.zshrc"
  fi

  # .zshenv
  if [[ -f "${HOME}/.zshenv" ]]; then
    check_pass ".zshenv" "exists"
  else
    check_warn ".zshenv" "missing" # "cp ${SCRIPT_DIR}/configs/zshenv ${HOME}/.zshenv"
  fi

  # Default shell
  local current_shell
  current_shell=$(getent passwd "${USER}" | cut -d: -f7)
  if [[ "${current_shell}" =~ zsh ]]; then
    check_pass "Default shell" "zsh (${current_shell})"
  else
    check_warn "Default shell" "${current_shell} (not zsh)"
  fi

  # ZSH plugins
  local plugin_dir="${CLI_INSTALL_DIR}/plugins"
  for plugin in zsh-autosuggestions zsh-syntax-highlighting fzf-tab \
                zsh-history-substring-search zsh-completions; do
    if [[ -d "${plugin_dir}/${plugin}" ]]; then
      check_pass "Plugin: ${plugin}" ""
    else
      check_fail "Plugin: ${plugin}" "NOT INSTALLED" \
        "bash ${SCRIPT_DIR}/plugins/install.sh install"
    fi
  done
}

# ---------------------------------------------------------------------------
# CHECK: STARSHIP
# ---------------------------------------------------------------------------
check_starship() {
  log_section "Starship Prompt"

  if ! command -v starship &>/dev/null; then
    check_fail "starship binary" "not found" \
      "curl -fsSL https://starship.rs/install.sh | sh -s -- --yes"
    return
  fi

  check_pass "starship binary" "$(starship --version 2>/dev/null | awk 'NR==1')"

  local config="${HOME}/.config/starship.toml"
  if [[ -f "${config}" ]]; then
    if starship config 2>/dev/null | grep -q "format" 2>/dev/null || true; then
      check_pass "starship.toml" "exists"
    else
      check_warn "starship.toml" "may have issues"
    fi
  else
    check_fail "starship.toml" "MISSING" \
      "cp ${SCRIPT_DIR}/configs/starship.toml ${config}"
  fi
}

# ---------------------------------------------------------------------------
# CHECK: GIT CONFIGURATION
# ---------------------------------------------------------------------------
check_git() {
  log_section "Git Configuration"

  local name email
  name=$(git config --global user.name 2>/dev/null || echo "")
  email=$(git config --global user.email 2>/dev/null || echo "")

  if [[ -n "${name}" ]]; then
    check_pass "git user.name" "${name}"
  else
    check_warn "git user.name" "not set — run: git config --global user.name 'Your Name'"
  fi

  if [[ -n "${email}" ]]; then
    check_pass "git user.email" "${email}"
  else
    check_warn "git user.email" "not set — run: git config --global user.email 'you@example.com'"
  fi

  local pager
  pager=$(git config --global core.pager 2>/dev/null || echo "")
  if [[ "${pager}" == "delta" ]]; then
    check_pass "git pager" "delta"
  else
    check_warn "git pager" "${pager:-not configured}"
  fi
}

# ---------------------------------------------------------------------------
# CHECK: FZF
# ---------------------------------------------------------------------------
check_fzf() {
  log_section "FZF Integration"

  if command -v fzf &>/dev/null; then
    check_pass "fzf binary" "$(fzf --version 2>/dev/null)"
  else
    check_fail "fzf binary" "not found" "sudo apt-get install -y fzf"
  fi

  if [[ -f "${HOME}/.fzf.zsh" ]]; then
    check_pass "fzf zsh integration" "${HOME}/.fzf.zsh"
  else
    check_warn "fzf zsh integration" "not found (may use fzf --zsh)"
  fi
}

# ---------------------------------------------------------------------------
# CHECK: BROKEN SYMLINKS
# ---------------------------------------------------------------------------
check_symlinks() {
  log_section "Broken Symlinks"

  local dirs_to_check=(
    "${HOME}/.local/bin"
    "${HOME}/.config"
    "${CLI_INSTALL_DIR}"
  )

  local found=0
  for dir in "${dirs_to_check[@]}"; do
    [[ -d "${dir}" ]] || continue
    while IFS= read -r link; do
      check_warn "Broken symlink" "${link}"
      (( found++ ))
    done < <(find "${dir}" -maxdepth 3 -type l ! -e 2>/dev/null)
  done

  (( found == 0 )) && check_pass "Symlinks" "no broken symlinks found"
}

# ---------------------------------------------------------------------------
# CHECK: ATUIN
# ---------------------------------------------------------------------------
check_atuin() {
  log_section "Atuin History"

  if ! command -v atuin &>/dev/null; then
    check_warn "atuin" "not installed"
    return
  fi

  check_pass "atuin binary" "$(atuin --version 2>/dev/null)"

  local db="${HOME}/.local/share/atuin/history.db"
  if [[ -f "${db}" ]]; then
    check_pass "atuin database" "${db}"
  else
    check_warn "atuin database" "not initialized yet"
  fi

  local config="${HOME}/.config/atuin/config.toml"
  if [[ -f "${config}" ]]; then
    check_pass "atuin config" "${config}"
  else
    check_warn "atuin config" "missing"
  fi
}

# ---------------------------------------------------------------------------
# SUMMARY
# ---------------------------------------------------------------------------
print_summary() {
  printf "\n%b%s%b\n" "${CLR_BOLD_CYAN}" \
    "─────────────────────────────────────────────────────" "${CLR_RESET}" >&2
  printf "%b  Doctor Summary%b\n" "${CLR_BOLD_WHITE}" "${CLR_RESET}" >&2
  printf "  %b✔  Passed:  %d%b\n" "${CLR_GREEN}"  "${_PASSED_CHECKS}"  "${CLR_RESET}" >&2
  printf "  %b⚠  Warned:  %d%b\n" "${CLR_YELLOW}" "${_WARNED_CHECKS}"  "${CLR_RESET}" >&2
  printf "  %b✖  Failed:  %d%b\n" "${CLR_RED}"    "${_FAILED_CHECKS}"  "${CLR_RESET}" >&2
  printf "  %b   Total:   %d%b\n" "${CLR_DIM}"    "${_TOTAL_CHECKS}"   "${CLR_RESET}" >&2
  printf "%b%s%b\n\n" "${CLR_BOLD_CYAN}" \
    "─────────────────────────────────────────────────────" "${CLR_RESET}" >&2

  if (( _FAILED_CHECKS > 0 || _WARNED_CHECKS > 0 )); then
    printf "%bRun with --fix to attempt automatic repairs:%b\n" \
      "${CLR_DIM}" "${CLR_RESET}" >&2
    printf "  ./doctor.sh --fix\n\n" >&2
  else
    printf "%b✔  All systems operational!%b\n\n" "${CLR_BOLD_GREEN}" "${CLR_RESET}" >&2
  fi
}

# ---------------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------------
parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --fix)     FIX_MODE=1 ;;
      --verbose) VERBOSE=1; CLI_LOG_LEVEL="${LOG_LEVEL_DEBUG}" ;;
      --help)
        echo "Usage: doctor.sh [--fix] [--verbose]"
        echo "  --fix     Attempt automatic fixes for failed checks"
        echo "  --verbose Show debug information"
        exit 0 ;;
    esac
    shift
  done
}

main() {
  parse_args "$@"

  detect_all

  printf "\n%b  CLI Bootstrap Doctor v%s%b\n\n" \
    "${CLR_BOLD_CYAN}" "${BOOTSTRAP_VERSION}" "${CLR_RESET}" >&2

  [[ "${FIX_MODE}" -eq 1 ]] && \
    printf "%b  Auto-fix mode enabled%b\n\n" "${CLR_BOLD_YELLOW}" "${CLR_RESET}" >&2

  check_binaries
  check_zsh_config
  check_starship
  check_git
  check_fzf
  check_symlinks
  check_atuin

  print_summary

  # Exit with non-zero if failures
  (( _FAILED_CHECKS > 0 )) && exit 1 || exit 0
}

main "$@"
