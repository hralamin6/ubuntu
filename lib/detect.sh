#!/usr/bin/env bash
# =============================================================================
# lib/detect.sh — System, environment, and capability detection
# =============================================================================

[[ -n "${_CLI_BOOTSTRAP_DETECT_LOADED:-}" ]] && return 0
readonly _CLI_BOOTSTRAP_DETECT_LOADED=1

# ---------------------------------------------------------------------------
# OS DETECTION
# ---------------------------------------------------------------------------
detect_os() {
  if [[ -f /etc/os-release ]]; then
    # shellcheck source=/dev/null
    source /etc/os-release
    DETECT_OS_ID="${ID:-unknown}"
    DETECT_OS_NAME="${NAME:-unknown}"
    DETECT_OS_VERSION="${VERSION_ID:-unknown}"
    DETECT_OS_CODENAME="${VERSION_CODENAME:-unknown}"
    DETECT_OS_LIKE="${ID_LIKE:-}"
    DETECT_OS_PRETTY="${PRETTY_NAME:-unknown}"
  elif [[ -f /etc/debian_version ]]; then
    DETECT_OS_ID="debian"
    DETECT_OS_NAME="Debian GNU/Linux"
    DETECT_OS_VERSION=$(cat /etc/debian_version)
    DETECT_OS_CODENAME="unknown"
    DETECT_OS_LIKE="debian"
    DETECT_OS_PRETTY="Debian ${DETECT_OS_VERSION}"
  else
    DETECT_OS_ID="unknown"
    DETECT_OS_NAME="Unknown"
    DETECT_OS_VERSION="unknown"
    DETECT_OS_CODENAME="unknown"
    DETECT_OS_LIKE="unknown"
    DETECT_OS_PRETTY="Unknown Linux"
  fi

  export DETECT_OS_ID DETECT_OS_NAME DETECT_OS_VERSION
  export DETECT_OS_CODENAME DETECT_OS_LIKE DETECT_OS_PRETTY
}

# Check if OS is supported
is_supported_os() {
  case "${DETECT_OS_ID}" in
    ubuntu) [[ "${DETECT_OS_VERSION}" =~ ^(22|24)\. ]] && return 0 ;;
    debian) [[ "${DETECT_OS_VERSION}" =~ ^(12|13)$  ]] && return 0 ;;
  esac
  return 1
}

# Check if apt is available (Debian/Ubuntu family)
is_apt_based() {
  [[ "${DETECT_OS_ID}" == "ubuntu" || "${DETECT_OS_ID}" == "debian" || "${DETECT_OS_LIKE}" =~ "debian" ]]
}

# ---------------------------------------------------------------------------
# ARCHITECTURE DETECTION
# ---------------------------------------------------------------------------
detect_arch() {
  local raw
  raw=$(uname -m)
  case "${raw}" in
    x86_64)          DETECT_ARCH="amd64";  DETECT_ARCH_RAW="${raw}" ;;
    aarch64|arm64)   DETECT_ARCH="arm64";  DETECT_ARCH_RAW="${raw}" ;;
    armv7l|armv6l)   DETECT_ARCH="arm";    DETECT_ARCH_RAW="${raw}" ;;
    i386|i686)       DETECT_ARCH="i386";   DETECT_ARCH_RAW="${raw}" ;;
    *)               DETECT_ARCH="${raw}";  DETECT_ARCH_RAW="${raw}" ;;
  esac
  export DETECT_ARCH DETECT_ARCH_RAW
}

is_arm64() { [[ "${DETECT_ARCH}" == "arm64" ]]; }
is_amd64() { [[ "${DETECT_ARCH}" == "amd64" ]]; }

# ---------------------------------------------------------------------------
# KERNEL DETECTION
# ---------------------------------------------------------------------------
detect_kernel() {
  DETECT_KERNEL=$(uname -r)
  DETECT_KERNEL_VERSION=$(uname -r | grep -oP '^\d+\.\d+')
  export DETECT_KERNEL DETECT_KERNEL_VERSION
}

# ---------------------------------------------------------------------------
# SHELL DETECTION
# ---------------------------------------------------------------------------
detect_shell() {
  DETECT_CURRENT_SHELL=$(basename "${SHELL:-/bin/sh}")
  DETECT_SHELL_VERSION=$("${SHELL:-/bin/sh}" --version 2>/dev/null | awk 'NR==1' || echo "unknown")
  DETECT_ZSH_PATH=$(command -v zsh 2>/dev/null || echo "")
  DETECT_ZSH_VERSION=$(zsh --version 2>/dev/null | awk '{print $2}' || echo "not installed")
  export DETECT_CURRENT_SHELL DETECT_SHELL_VERSION
  export DETECT_ZSH_PATH DETECT_ZSH_VERSION
}

is_zsh() { [[ "${DETECT_CURRENT_SHELL}" == "zsh" ]]; }
zsh_installed() { [[ -n "${DETECT_ZSH_PATH}" ]]; }

# ---------------------------------------------------------------------------
# TERMINAL DETECTION
# ---------------------------------------------------------------------------
detect_terminal() {
  DETECT_TERM="${TERM:-unknown}"
  DETECT_TERM_PROGRAM="${TERM_PROGRAM:-}"
  DETECT_TERMINAL="unknown"

  # Detect from environment variables
  if [[ -n "${TERM_PROGRAM:-}" ]]; then
    DETECT_TERMINAL="${TERM_PROGRAM}"
  elif [[ -n "${KITTY_WINDOW_ID:-}" ]]; then
    DETECT_TERMINAL="kitty"
  elif [[ -n "${ALACRITTY_LOG:-}" || -n "${ALACRITTY_SOCKET:-}" ]]; then
    DETECT_TERMINAL="alacritty"
  elif [[ -n "${VTE_VERSION:-}" ]]; then
    DETECT_TERMINAL="vte-based"
  elif [[ "${TERM:-}" == "xterm-256color" ]]; then
    DETECT_TERMINAL="xterm-256color"
  fi

  DETECT_TRUECOLOR=0
  [[ "${COLORTERM:-}" =~ ^(truecolor|24bit)$ ]] && DETECT_TRUECOLOR=1

  export DETECT_TERM DETECT_TERM_PROGRAM DETECT_TERMINAL DETECT_TRUECOLOR
}

# ---------------------------------------------------------------------------
# PACKAGE MANAGER DETECTION
# ---------------------------------------------------------------------------
detect_package_manager() {
  if command -v apt-get &>/dev/null; then
    DETECT_PKG_MANAGER="apt"
    DETECT_PKG_MANAGER_VERSION=$(apt-get --version 2>/dev/null | awk 'NR==1{print $2}')
  elif command -v apt &>/dev/null; then
    DETECT_PKG_MANAGER="apt"
    DETECT_PKG_MANAGER_VERSION=$(apt --version 2>/dev/null | awk 'NR==1{print $2}')
  else
    DETECT_PKG_MANAGER="unknown"
    DETECT_PKG_MANAGER_VERSION="unknown"
  fi
  export DETECT_PKG_MANAGER DETECT_PKG_MANAGER_VERSION
}

# ---------------------------------------------------------------------------
# ROOT / PRIVILEGE DETECTION
# ---------------------------------------------------------------------------
detect_privileges() {
  DETECT_EUID="${EUID}"
  DETECT_IS_ROOT=0
  DETECT_HAS_SUDO=0
  DETECT_SUDO_USER="${SUDO_USER:-}"

  [[ "${EUID}" -eq 0 ]] && DETECT_IS_ROOT=1

  if command -v sudo &>/dev/null; then
    if sudo -n true 2>/dev/null; then
      DETECT_HAS_SUDO=1
    fi
  fi

  export DETECT_EUID DETECT_IS_ROOT DETECT_HAS_SUDO DETECT_SUDO_USER
}

is_root()      { [[ "${DETECT_IS_ROOT}" -eq 1 ]]; }
has_sudo()     { [[ "${DETECT_HAS_SUDO}" -eq 1 ]]; }
can_escalate() { is_root || has_sudo; }

# ---------------------------------------------------------------------------
# VIRTUAL MACHINE DETECTION
# ---------------------------------------------------------------------------
detect_vm() {
  DETECT_IS_VM=0
  DETECT_VM_TYPE="none"

  if command -v systemd-detect-virt &>/dev/null; then
    local virt
    virt=$(systemd-detect-virt 2>/dev/null || echo "none")
    if [[ "${virt}" != "none" ]]; then
      DETECT_IS_VM=1
      DETECT_VM_TYPE="${virt}"
    fi
  elif [[ -f /proc/cpuinfo ]]; then
    if grep -qi "hypervisor" /proc/cpuinfo 2>/dev/null; then
      DETECT_IS_VM=1
      DETECT_VM_TYPE="unknown-hypervisor"
    fi
  fi

  # DMI-based detection (requires root or dmi access)
  if [[ "${DETECT_IS_VM}" -eq 0 ]] && [[ -r /sys/class/dmi/id/product_name ]]; then
    local product
    product=$(cat /sys/class/dmi/id/product_name 2>/dev/null | tr '[:upper:]' '[:lower:]')
    case "${product}" in
      *virtualbox*)  DETECT_IS_VM=1; DETECT_VM_TYPE="virtualbox" ;;
      *vmware*)      DETECT_IS_VM=1; DETECT_VM_TYPE="vmware"     ;;
      *"kvm"*)       DETECT_IS_VM=1; DETECT_VM_TYPE="kvm"        ;;
      *"xen"*)       DETECT_IS_VM=1; DETECT_VM_TYPE="xen"        ;;
      *"hyper-v"*)   DETECT_IS_VM=1; DETECT_VM_TYPE="hyper-v"    ;;
    esac
  fi

  export DETECT_IS_VM DETECT_VM_TYPE
}

is_vm() { [[ "${DETECT_IS_VM}" -eq 1 ]]; }

# ---------------------------------------------------------------------------
# CLOUD PROVIDER DETECTION
# ---------------------------------------------------------------------------
detect_cloud() {
  DETECT_CLOUD="none"
  DETECT_IS_CLOUD=0

  # AWS: check IMDSv2 metadata service
  if curl -sf --max-time 0.5 -o /dev/null \
       -H "X-aws-ec2-metadata-token-ttl-seconds: 1" \
       http://169.254.169.254/latest/meta-data/ 2>/dev/null; then
    DETECT_CLOUD="aws"
    DETECT_IS_CLOUD=1
  # GCP: check metadata server
  elif curl -sf --max-time 0.5 -o /dev/null \
       -H "Metadata-Flavor: Google" \
       http://metadata.google.internal/computeMetadata/v1/ 2>/dev/null; then
    DETECT_CLOUD="gcp"
    DETECT_IS_CLOUD=1
  # Azure: check metadata
  elif curl -sf --max-time 0.5 -o /dev/null \
       -H "Metadata: true" \
       "http://169.254.169.254/metadata/instance?api-version=2021-02-01" 2>/dev/null; then
    DETECT_CLOUD="azure"
    DETECT_IS_CLOUD=1
  # DigitalOcean
  elif curl -sf --max-time 0.5 -o /dev/null \
       http://169.254.169.254/metadata/v1/ 2>/dev/null; then
    DETECT_CLOUD="digitalocean"
    DETECT_IS_CLOUD=1
  # Hetzner
  elif [[ -f /sys/class/dmi/id/product_name ]] && \
       grep -qi "hetzner" /sys/class/dmi/id/product_name 2>/dev/null; then
    DETECT_CLOUD="hetzner"
    DETECT_IS_CLOUD=1
  fi

  export DETECT_CLOUD DETECT_IS_CLOUD
}

is_cloud()    { [[ "${DETECT_IS_CLOUD}" -eq 1 ]]; }
is_aws()      { [[ "${DETECT_CLOUD}" == "aws" ]]; }
is_gcp()      { [[ "${DETECT_CLOUD}" == "gcp" ]]; }
is_azure()    { [[ "${DETECT_CLOUD}" == "azure" ]]; }

# ---------------------------------------------------------------------------
# WSL DETECTION
# ---------------------------------------------------------------------------
detect_wsl() {
  DETECT_IS_WSL=0
  DETECT_WSL_VERSION=0

  if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
    DETECT_IS_WSL=1
    DETECT_WSL_VERSION=2
  elif [[ -f /proc/version ]] && grep -qi "microsoft\|wsl" /proc/version 2>/dev/null; then
    DETECT_IS_WSL=1
    grep -qi "wsl2" /proc/version 2>/dev/null && DETECT_WSL_VERSION=2 || DETECT_WSL_VERSION=1
  fi

  export DETECT_IS_WSL DETECT_WSL_VERSION
}

is_wsl()  { [[ "${DETECT_IS_WSL}" -eq 1 ]]; }
is_wsl2() { [[ "${DETECT_WSL_VERSION}" -eq 2 ]]; }

# ---------------------------------------------------------------------------
# SSH SESSION DETECTION
# ---------------------------------------------------------------------------
detect_ssh() {
  DETECT_IS_SSH=0
  if [[ -n "${SSH_CLIENT:-}" || -n "${SSH_TTY:-}" || -n "${SSH_CONNECTION:-}" ]]; then
    DETECT_IS_SSH=1
  fi
  export DETECT_IS_SSH
}

is_ssh() { [[ "${DETECT_IS_SSH}" -eq 1 ]]; }

# ---------------------------------------------------------------------------
# CONTAINER DETECTION
# ---------------------------------------------------------------------------
detect_container() {
  DETECT_IS_CONTAINER=0
  DETECT_CONTAINER_TYPE="none"

  # Docker
  if [[ -f /.dockerenv ]]; then
    DETECT_IS_CONTAINER=1
    DETECT_CONTAINER_TYPE="docker"
  # Podman
  elif [[ -f /run/.containerenv ]]; then
    DETECT_IS_CONTAINER=1
    DETECT_CONTAINER_TYPE="podman"
  # LXC
  elif [[ -f /proc/1/environ ]] && \
       grep -qa "container=lxc" /proc/1/environ 2>/dev/null; then
    DETECT_IS_CONTAINER=1
    DETECT_CONTAINER_TYPE="lxc"
  # Systemd-nspawn
  elif systemd-detect-virt --container &>/dev/null; then
    local ct
    ct=$(systemd-detect-virt --container 2>/dev/null || echo "none")
    if [[ "${ct}" != "none" ]]; then
      DETECT_IS_CONTAINER=1
      DETECT_CONTAINER_TYPE="${ct}"
    fi
  # cgroup-based check
  elif [[ -f /proc/1/cgroup ]] && \
       grep -q "docker\|lxc\|kubepods" /proc/1/cgroup 2>/dev/null; then
    DETECT_IS_CONTAINER=1
    DETECT_CONTAINER_TYPE="container"
  fi

  export DETECT_IS_CONTAINER DETECT_CONTAINER_TYPE
}

is_container() { [[ "${DETECT_IS_CONTAINER}" -eq 1 ]]; }
is_docker()    { [[ "${DETECT_CONTAINER_TYPE}" == "docker" ]]; }

# ---------------------------------------------------------------------------
# DISPLAY SYSTEM DETECTION
# ---------------------------------------------------------------------------
detect_display() {
  DETECT_IS_WAYLAND=0
  DETECT_IS_X11=0
  DETECT_DISPLAY_SERVER="none"

  if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
    DETECT_IS_WAYLAND=1
    DETECT_DISPLAY_SERVER="wayland"
  elif [[ -n "${DISPLAY:-}" ]]; then
    DETECT_IS_X11=1
    DETECT_DISPLAY_SERVER="x11"
  fi

  export DETECT_IS_WAYLAND DETECT_IS_X11 DETECT_DISPLAY_SERVER
}

# ---------------------------------------------------------------------------
# HARDWARE DETECTION
# ---------------------------------------------------------------------------
detect_hardware() {
  # CPU info
  DETECT_CPU_MODEL=$(grep -m1 "^model name" /proc/cpuinfo 2>/dev/null | cut -d: -f2 | sed 's/^ *//' || echo "unknown")
  DETECT_CPU_CORES=$(nproc 2>/dev/null || grep -c "^processor" /proc/cpuinfo 2>/dev/null || echo "1")

  # Memory
  if [[ -f /proc/meminfo ]]; then
    local mem_kb
    mem_kb=$(grep "^MemTotal:" /proc/meminfo | awk '{print $2}')
    DETECT_MEM_MB=$(( mem_kb / 1024 ))
    DETECT_MEM_GB=$(( mem_kb / 1024 / 1024 ))
  else
    DETECT_MEM_MB=0
    DETECT_MEM_GB=0
  fi

  export DETECT_CPU_MODEL DETECT_CPU_CORES DETECT_MEM_MB DETECT_MEM_GB
}

# ---------------------------------------------------------------------------
# NETWORK DETECTION
# ---------------------------------------------------------------------------
detect_network() {
  DETECT_HAS_INTERNET=0
  if curl -sf --max-time 3 -o /dev/null https://1.1.1.1 2>/dev/null || \
     wget -q --timeout=3 --spider https://1.1.1.1 2>/dev/null; then
    DETECT_HAS_INTERNET=1
  fi
  export DETECT_HAS_INTERNET
}

has_internet() { [[ "${DETECT_HAS_INTERNET}" -eq 1 ]]; }

# ---------------------------------------------------------------------------
# RUN ALL DETECTIONS
# ---------------------------------------------------------------------------
detect_all() {
  detect_os
  detect_arch
  detect_kernel
  detect_shell
  detect_terminal
  detect_package_manager
  detect_privileges
  detect_vm
  detect_wsl
  detect_ssh
  detect_container
  detect_display
  detect_hardware
  detect_cloud
  detect_network
}

# Print system summary
detect_print_summary() {
  # shellcheck disable=SC2154
  printf "\n%b  System Profile%b\n" "${CLR_BOLD_CYAN}" "${CLR_RESET}" >&2
  kv_print "OS"             "${DETECT_OS_PRETTY}"
  kv_print "Version"        "${DETECT_OS_VERSION} (${DETECT_OS_CODENAME})"
  kv_print "Kernel"         "${DETECT_KERNEL}"
  kv_print "Architecture"   "${DETECT_ARCH} (${DETECT_ARCH_RAW})"
  kv_print "CPU"            "${DETECT_CPU_MODEL} (${DETECT_CPU_CORES} cores)"
  kv_print "Memory"         "${DETECT_MEM_GB}GB (${DETECT_MEM_MB}MB)"
  kv_print "Shell"          "${DETECT_CURRENT_SHELL} | zsh: ${DETECT_ZSH_VERSION}"
  kv_print "Terminal"       "${DETECT_TERMINAL} (${DETECT_TERM})"
  kv_print "Package Mgr"    "${DETECT_PKG_MANAGER} ${DETECT_PKG_MANAGER_VERSION}"
  kv_print "Privileges"     "root=${DETECT_IS_ROOT} sudo=${DETECT_HAS_SUDO}"
  kv_print "Container"      "${DETECT_CONTAINER_TYPE}"
  kv_print "VM"             "${DETECT_VM_TYPE}"
  kv_print "WSL"            "v${DETECT_WSL_VERSION}"
  kv_print "SSH"            "${DETECT_IS_SSH}"
  kv_print "Cloud"          "${DETECT_CLOUD}"
  kv_print "Display"        "${DETECT_DISPLAY_SERVER}"
  kv_print "Internet"       "${DETECT_HAS_INTERNET}"
  printf "\n" >&2
}
