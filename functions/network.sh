#!/usr/bin/env zsh
# =============================================================================
# functions/network.sh — Networking functions (20+)
# =============================================================================

# Show all IP addresses
myip() {
  echo "=== Public IP ==="
  curl -fsSL --max-time 3 https://ifconfig.me && echo
  echo ""
  echo "=== Local IPs ==="
  ip addr show | awk '/inet /{print $2, "(" $NF ")"}'
}

# Check if a port is open
findport() {
  local port="$1"
  ss -tulpn | grep ":${port}"
}

# Kill process on a specific port
killport() {
  local port="$1"
  if [[ -z "${port}" ]]; then
    echo "Usage: killport <port>" >&2
    return 1
  fi

  local pid
  pid=$(lsof -ti tcp:"${port}" 2>/dev/null)

  if [[ -z "${pid}" ]]; then
    echo "No process found on port ${port}"
    return 0
  fi

  echo "Killing process(es) on port ${port}: ${pid}"
  echo "${pid}" | xargs kill -9
  echo "Done."
}

# Show all listening ports
ports() {
  echo "=== Listening Ports ==="
  ss -tulpn | sort -k5
}

# Show established connections
connections() {
  ss -tn state established | sort
}

# DNS lookup with multiple record types
dns-lookup() {
  local domain="$1"
  if [[ -z "${domain}" ]]; then
    echo "Usage: dns-lookup <domain>" >&2
    return 1
  fi

  if command -v doggo &>/dev/null; then
    doggo "${domain}"
  else
    echo "=== A Records ==="
    dig +short A "${domain}"
    echo "=== AAAA Records ==="
    dig +short AAAA "${domain}"
    echo "=== MX Records ==="
    dig +short MX "${domain}"
    echo "=== NS Records ==="
    dig +short NS "${domain}"
    echo "=== TXT Records ==="
    dig +short TXT "${domain}"
  fi
}

# Check SSL certificate expiry
ssl-expiry() {
  local host="$1"
  local port="${2:-443}"

  if [[ -z "${host}" ]]; then
    echo "Usage: ssl-expiry <host> [port]" >&2
    return 1
  fi

  echo | openssl s_client -connect "${host}:${port}" 2>/dev/null | \
    openssl x509 -noout -dates 2>/dev/null || \
    echo "Could not get SSL info for ${host}:${port}"
}

# Check if a site is up
is-up() {
  local url="$1"
  if [[ -z "${url}" ]]; then
    echo "Usage: is-up <url>" >&2
    return 1
  fi

  local http_code
  http_code=$(curl -fsSL -o /dev/null -w "%{http_code}" --max-time 10 "${url}" 2>/dev/null)

  if (( http_code >= 200 && http_code < 400 )); then
    printf "\033[32m✔  %s is UP (HTTP %s)\033[0m\n" "${url}" "${http_code}"
  else
    printf "\033[31m✖  %s is DOWN (HTTP %s)\033[0m\n" "${url}" "${http_code}"
  fi
}

# Measure website response time
curl-time() {
  local url="$1"
  curl -o /dev/null -s \
    -w "DNS: %{time_namelookup}s\nConnect: %{time_connect}s\nSSL: %{time_appconnect}s\nTTFB: %{time_starttransfer}s\nTotal: %{time_total}s\nSize: %{size_download} bytes\n" \
    "${url}"
}

# Port scan (quick)
portscan() {
  local host="${1:-localhost}"
  local start="${2:-1}"
  local end="${3:-1024}"

  if command -v nmap &>/dev/null; then
    nmap -T4 --open -p "${start}-${end}" "${host}"
  else
    echo "nmap not available. Install: sudo apt-get install nmap" >&2
  fi
}

# SSH tunnel shortcut
ssh-tunnel() {
  local local_port="$1"
  local remote_host="$2"
  local remote_port="${3:-${local_port}}"
  local ssh_host="$4"

  if [[ -z "${local_port}" || -z "${remote_host}" || -z "${ssh_host}" ]]; then
    echo "Usage: ssh-tunnel <local_port> <remote_host> [remote_port] <ssh_host>" >&2
    return 1
  fi

  ssh -N -L "${local_port}:${remote_host}:${remote_port}" "${ssh_host}"
}

# SOCKS proxy via SSH
ssh-socks() {
  local port="${1:-1080}"
  local ssh_host="$2"

  if [[ -z "${ssh_host}" ]]; then
    echo "Usage: ssh-socks [port] <ssh_host>" >&2
    return 1
  fi

  ssh -N -D "${port}" "${ssh_host}"
}

# Show network interfaces and IPs in clean format
netinfo() {
  ip -o addr show | awk '!/^[0-9]*: ?lo/ {gsub(/\/.*/, "", $4); print $2 "\t" $4}' | column -t
}

# HTTP headers for a URL
http-headers() {
  local url="$1"
  curl -D - -o /dev/null -s "${url}" 2>/dev/null
}

# Download file with progress
dl() {
  local url="$1"
  local output="${2:-$(basename "${url}")}"
  curl -L --progress-bar -o "${output}" "${url}"
  echo "Downloaded: ${output}"
}

# Watch network traffic
net-watch() {
  local interface="${1:-$(ip route | awk '/default/{print $5; exit}')}"
  if command -v bmon &>/dev/null; then
    bmon -p "${interface}"
  else
    cat /proc/net/dev | grep "${interface}" | awk '{print "RX:", $2, "TX:", $10}'
    watch -n1 "cat /proc/net/dev | grep ${interface}"
  fi
}

# Bandwidth test
speed-test() {
  if command -v speedtest-cli &>/dev/null; then
    speedtest-cli
  elif command -v fast &>/dev/null; then
    fast
  else
    echo "Testing download speed..."
    curl -o /dev/null -w "%{speed_download}" https://speed.hetzner.de/100MB.bin 2>/dev/null | \
      awk '{printf "Download: %.2f MB/s\n", $1/1048576}'
  fi
}

# Traceroute with better formatting
trace() {
  local host="$1"
  if command -v mtr &>/dev/null; then
    mtr --report-cycles=3 "${host}"
  else
    traceroute "${host}"
  fi
}

# Check DNS propagation
dns-propagation() {
  local domain="$1"
  local record="${2:-A}"

  local -a servers=(
    "8.8.8.8:Google"
    "1.1.1.1:Cloudflare"
    "9.9.9.9:Quad9"
    "208.67.222.222:OpenDNS"
    "8.26.56.26:Comodo"
  )

  echo "DNS Propagation for ${domain} (${record}):"
  for server_info in "${servers[@]}"; do
    local server="${server_info%%:*}"
    local name="${server_info##*:}"
    local result
    result=$(dig @"${server}" +short "${record}" "${domain}" 2>/dev/null | tr '\n' ' ')
    printf "  %-15s %-20s %s\n" "${name}" "${server}" "${result:-<empty>}"
  done
}
