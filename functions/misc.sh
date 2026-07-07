#!/usr/bin/env zsh
# =============================================================================
# functions/misc.sh — Miscellaneous fun and utility functions (15+)
# =============================================================================

# Get weather for a location
weather() {
  local location="${1:-}"
  if command -v curl &>/dev/null; then
    curl -fsSL --max-time 10 "https://wttr.in/${location}?format=v2" 2>/dev/null || \
    echo "Weather unavailable."
  else
    echo "curl not available." >&2
  fi
}

# Get weather in compact format
weather-short() {
  local location="${1:-}"
  curl -fsSL --max-time 10 "https://wttr.in/${location}?format=3" 2>/dev/null || echo "N/A"
}

# Get exchange rate
rate() {
  local from="${1:-USD}"
  local to="${2:-EUR}"
  curl -fsSL "https://api.exchangerate-api.com/v4/latest/${from}" 2>/dev/null | \
    python3 -c "import json,sys; d=json.load(sys.stdin); print(f'1 ${from} = {d[\"rates\"].get(\"${to}\", \"N/A\")} ${to}')" 2>/dev/null || \
    echo "Exchange rate unavailable."
}

# Show a random tip from tldr
random-tip() {
  if command -v tldr &>/dev/null; then
    local cmd
    cmd=$(tldr --list 2>/dev/null | shuf -n 1)
    echo "Random tip: ${cmd}"
    tldr "${cmd}"
  fi
}

# Calendar
cal() {
  if command -v ncal &>/dev/null; then
    ncal -b "$@"
  else
    command cal "$@"
  fi
}

# Countdown to a date
days-until() {
  local target_date="${1:-}"
  if [[ -z "${target_date}" ]]; then
    echo "Usage: days-until <YYYY-MM-DD>" >&2
    return 1
  fi

  local target
  target=$(date -d "${target_date}" +%s 2>/dev/null)
  local now
  now=$(date +%s)

  if [[ -z "${target}" ]]; then
    echo "Invalid date: ${target_date}" >&2
    return 1
  fi

  local diff=$(( (target - now) / 86400 ))

  if (( diff > 0 )); then
    echo "${diff} days until ${target_date}"
  elif (( diff < 0 )); then
    echo "${target_date} was $(( -diff )) days ago"
  else
    echo "That's today!"
  fi
}

# Show the current week number
week() {
  date +%V
}

# ASCII art header
ascii-header() {
  local text="${*:-Hello}"
  if command -v figlet &>/dev/null; then
    figlet -f slant "${text}"
  elif command -v toilet &>/dev/null; then
    toilet -f future "${text}"
  else
    echo "=== ${text} ==="
  fi
}

# Open browser (best effort)
open-browser() {
  local url="${1:-https://google.com}"
  if command -v xdg-open &>/dev/null; then
    xdg-open "${url}" 2>/dev/null &
  elif command -v open &>/dev/null; then
    open "${url}" &
  elif command -v wslview &>/dev/null; then
    wslview "${url}" &
  else
    echo "No browser opener found." >&2
  fi
}

# Quick QR code for a URL (requires qrencode)
qr() {
  local data="$1"
  if command -v qrencode &>/dev/null; then
    qrencode -t ansi "${data}"
  else
    echo "qrencode not found. Install: sudo apt-get install qrencode" >&2
  fi
}

# Show color palette
colors() {
  for i in {0..255}; do
    printf "\033[38;5;%dm%3d\033[0m " "${i}" "${i}"
    (( (i + 1) % 16 == 0 )) && echo
  done
  echo
}

# Show 24-bit/truecolor test
truecolor-test() {
  local cols
  cols=$(tput cols)
  local r g b
  for i in $(seq 0 "${cols}"); do
    r=$(( 255 * i / cols ))
    g=$(( 0 ))
    b=$(( 255 - 255 * i / cols ))
    printf "\033[48;2;%d;%d;%dm " "${r}" "${g}" "${b}"
  done
  printf "\033[0m\n"
}

# Calculate expression
calc() {
  echo "$@" | bc -l
}

# Convert seconds to HH:MM:SS
seconds-to-time() {
  local total="${1:-0}"
  printf "%02d:%02d:%02d\n" \
    "$(( total / 3600 ))" \
    "$(( (total % 3600) / 60 ))" \
    "$(( total % 60 ))"
}

# Show Unicode codepoint for a character
unicode() {
  local char="$1"
  python3 -c "
c = '${char}'
for ch in c:
    print(f'U+{ord(ch):04X}  {ch}  {ch.encode(\"utf-8\").hex()}')
"
}

# Check if inside a git repo
in-git-repo() {
  git rev-parse --is-inside-work-tree &>/dev/null
}

# Remind me in N minutes
remind() {
  local minutes="${1:-5}"
  local message="${*:2:-Reminder!}"
  echo "Reminder set for ${minutes} minutes: ${message}"
  (
    sleep "$(( minutes * 60 ))"
    if command -v notify-send &>/dev/null; then
      notify-send "⏰ Reminder" "${message}"
    fi
    echo -e "\a\033[1;33m⏰  ${message}\033[0m"
  ) &
  echo "Reminder PID: $!"
}

# Speak text (TTS — requires espeak or say)
speak() {
  local text="$*"
  if command -v espeak-ng &>/dev/null; then
    espeak-ng "${text}"
  elif command -v espeak &>/dev/null; then
    espeak "${text}"
  elif command -v say &>/dev/null; then
    say "${text}"
  else
    echo "No TTS engine found." >&2
  fi
}

# Show a matrix-style animation
matrix() {
  if command -v cmatrix &>/dev/null; then
    cmatrix -s
  else
    echo "cmatrix not installed. Install: sudo apt-get install cmatrix" >&2
  fi
}

# Print a startup message with system info
motd() {
  echo ""
  printf "\033[1;36m  Welcome back, %s!\033[0m\n" "${USER}"
  printf "\033[2m  %s | %s\033[0m\n" \
    "$(date '+%A, %B %-d %Y %H:%M')" \
    "$(uptime -p)"
  echo ""
}
