#!/usr/bin/env bash
# install.sh — Thin wrapper for bootstrap.sh
set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec bash "${SCRIPT_DIR}/bootstrap.sh" --mode=install "$@"
