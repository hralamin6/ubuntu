#!/usr/bin/env zsh
# =============================================================================
# functions/system.sh — System management functions (25+)
# =============================================================================

# Detailed system information
sysinfo() {
  echo ""
  printf "\033[1;36m=== System Information ===\033[0m\n"
  printf "  %-20s %s\n" "Hostname:"    "$(hostname -f 2>/dev/null || hostname)"
  printf "  %-20s %s\n" "OS:"          "$(lsb_release -ds 2>/dev/null || cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
  printf "  %-20s %s\n" "Kernel:"      "$(uname -r)"
  printf "  %-20s %s\n" "Architecture:" "$(uname -m)"
  printf "  %-20s %s\n" "CPU:"         "$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | sed 's/^ *//')"
  printf "  %-20s %s\n" "CPU Cores:"   "$(nproc)"
  printf "  %-20s %s\n" "Memory:"      "$(free -h | awk '/^Mem/{print $2 " total, " $3 " used, " $4 " free"}')"
  printf "  %-20s %s\n" "Swap:"        "$(free -h | awk '/^Swap/{print $2 " total, " $3 " used, " $4 " free"}')"
  printf "  %-20s %s\n" "Disk (/):"    "$(df -h / | awk 'NR==2{print $2 " total, " $3 " used, " $4 " free (" $5 " used)"}')"
  printf "  %-20s %s\n" "Uptime:"      "$(uptime -p)"
  printf "  %-20s %s\n" "Load Avg:"    "$(cat /proc/loadavg | awk '{print $1, $2, $3}')"
  printf "  %-20s %s\n" "Shell:"       "${SHELL}"
  printf "  %-20s %s\n" "Terminal:"    "${TERM}"
  printf "  %-20s %s\n" "User:"        "$(whoami) (UID: ${UID})"
  echo ""
}

# Process tree (modern netstat-like)
process-tree() {
  if command -v procs &>/dev/null; then
    procs --tree
  else
    ps axjf | head -50
  fi
}

# Kill process by name
killname() {
  local name="$1"
  if [[ -z "${name}" ]]; then
    echo "Usage: killname <process-name>" >&2
    return 1
  fi

  local pids
  pids=$(pgrep -la "${name}" 2>/dev/null | awk '{print $1}')

  if [[ -z "${pids}" ]]; then
    echo "No processes matching '${name}' found."
    return 0
  fi

  pgrep -la "${name}"
  echo ""
  echo -n "Kill these processes? [y/N]: "
  read -r answer
  if [[ "${answer}" =~ ^[Yy]$ ]]; then
    pkill -9 "${name}" && echo "Killed."
  fi
}

# Monitor a command's resource usage
monitor-cmd() {
  local cmd="$@"
  /usr/bin/time -v "${cmd}" 2>&1
}

# Quick benchmark — run command N times
benchmark() {
  local n="${1:-10}"
  shift
  local cmd="$@"

  if command -v hyperfine &>/dev/null; then
    hyperfine --runs "${n}" "${cmd}"
  else
    local start end total
    total=0
    for (( i=1; i<=n; i++ )); do
      start=$(date +%s%N)
      eval "${cmd}" &>/dev/null
      end=$(date +%s%N)
      elapsed=$(( (end - start) / 1000000 ))
      total=$(( total + elapsed ))
      printf "Run %d: %dms\n" "${i}" "${elapsed}"
    done
    printf "Average: %dms\n" "$(( total / n ))"
  fi
}

# Timer
timer() {
  local msg="${1:-Timer}"
  local start
  start=$(date +%s)

  echo "${msg} started. Press Enter to stop..."
  read -r

  local end
  end=$(date +%s)
  local elapsed=$(( end - start ))

  printf "%s: %02d:%02d:%02d\n" "${msg}" \
    "$(( elapsed / 3600 ))" \
    "$(( (elapsed % 3600) / 60 ))" \
    "$(( elapsed % 60 ))"
}

# Countdown timer
countdown() {
  local seconds="${1:-60}"
  echo "Counting down ${seconds} seconds..."
  for (( i=seconds; i>=0; i-- )); do
    printf "\r\033[33m%02d:%02d\033[0m" "$(( i/60 ))" "$(( i%60 ))"
    sleep 1
  done
  printf "\n\033[32mDone!\033[0m\n"
}

# Memory usage by process name
mem-usage() {
  local process="${1:-}"
  if [[ -n "${process}" ]]; then
    ps aux | grep "${process}" | grep -v grep | awk '{sum += $4} END {printf "Memory: %.1f%%\n", sum}'
  else
    free -h && echo "" && ps aux --sort=-%mem | head -15
  fi
}

# CPU temperature
cpu-temp() {
  if [[ -f /sys/class/thermal/thermal_zone0/temp ]]; then
    local temp
    temp=$(cat /sys/class/thermal/thermal_zone0/temp)
    printf "CPU Temperature: %.1f°C\n" "$(echo "scale=1; ${temp}/1000" | bc)"
  elif command -v sensors &>/dev/null; then
    sensors
  else
    echo "Temperature reading not available." >&2
  fi
}

# Show system load averages
loadavg() {
  local load
  load=$(cat /proc/loadavg)
  local cores
  cores=$(nproc)
  echo "Load average (1m/5m/15m): ${load%% *} / $(echo "${load}" | awk '{print $2}') / $(echo "${load}" | awk '{print $3}')"
  echo "CPU cores: ${cores}"
}

# Watch system resources in real time
watch-resources() {
  watch -n1 "
    echo '=== CPU & Memory ===';
    free -h;
    echo '';
    echo '=== Load Average ===';
    cat /proc/loadavg;
    echo '';
    echo '=== Top Processes ===';
    ps aux --sort=-%cpu | head -8;
    echo '';
    echo '=== Disk Usage ===';
    df -h | grep -v tmpfs;
  "
}

# Find and kill zombie processes
kill-zombies() {
  local zombies
  zombies=$(ps aux | awk '$8=="Z"')
  if [[ -z "${zombies}" ]]; then
    echo "No zombie processes found."
    return 0
  fi
  echo "Zombie processes:"
  echo "${zombies}"
  echo ""
  echo "Zombie processes cannot be killed directly — killing parent processes..."
  ps aux | awk '$8=="Z"{print $3}' | xargs -I{} kill -9 {} 2>/dev/null || true
}

# List top memory consumers
mem-top() {
  local n="${1:-10}"
  ps aux --sort=-%mem | head -$(( n + 1 ))
}

# List top CPU consumers
cpu-top() {
  local n="${1:-10}"
  ps aux --sort=-%cpu | head -$(( n + 1 ))
}

# Show systemd boot time analysis
boot-analysis() {
  systemd-analyze
  echo ""
  echo "=== Top 15 Boot-Time Units ==="
  systemd-analyze blame | head -15
}

# Reboot with delay
reboot-in() {
  local minutes="${1:-5}"
  echo "System will reboot in ${minutes} minutes..."
  sudo shutdown -r +"${minutes}"
}

# Cancel scheduled shutdown/reboot
cancel-shutdown() {
  sudo shutdown -c && echo "Scheduled shutdown cancelled."
}

# Check failed services
failed-services() {
  systemctl list-units --state=failed
}

# Clean system caches and temp files
system-clean() {
  echo "Cleaning system..."
  sudo apt-get autoremove --purge -y -q
  sudo apt-get clean -q
  sudo journalctl --vacuum-time=7d
  rm -rf ~/.cache/thumbnails/*
  rm -rf /tmp/*  2>/dev/null || true
  echo "Done."
}

# Show environment summary
env-summary() {
  echo "=== Shell Environment ==="
  printf "  %-20s %s\n" "Shell:" "${SHELL}"
  printf "  %-20s %s\n" "User:" "$(whoami)"
  printf "  %-20s %s\n" "Home:" "${HOME}"
  printf "  %-20s %s\n" "Editor:" "${EDITOR:-not set}"
  printf "  %-20s %s\n" "Term:" "${TERM}"
  printf "  %-20s %s\n" "Lang:" "${LANG}"
  printf "  %-20s %s\n" "Timezone:" "$(timedatectl show --property=Timezone --value 2>/dev/null || cat /etc/timezone 2>/dev/null)"
  echo ""
  echo "PATH:"
  echo "${PATH}" | tr ':' '\n' | sed 's/^/  /'
}

# Sudo with current environment
sudoenv() {
  sudo -E "$@"
}

# Generate a strong random password
genpasswd() {
  local length="${1:-32}"
  openssl rand -base64 "${length}" | tr -dc 'A-Za-z0-9!@#$%^&*' | head -c "${length}"
  echo
}
