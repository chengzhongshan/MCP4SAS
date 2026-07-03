#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(/usr/bin/dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
. "${SCRIPT_DIR}/common.sh"

if [[ "${MCP4SAS_SKIP_APT:-0}" != "1" ]]; then
  SUDO=()
  [ "$(id -u)" -eq 0 ] || SUDO=(sudo)
  log "Installing Ubuntu packages"
  DEBIAN_FRONTEND=noninteractive "${SUDO[@]}" apt-get update
  DEBIAN_FRONTEND=noninteractive "${SUDO[@]}" apt-get install -y \
    bash build-essential ca-certificates curl default-jre-headless git make \
    perl python3 python3-dev python3-pip python3-venv unzip wget zip
fi

PYTHON_BIN="$(find_python)" || die "Python >= 3.8 not found"
create_python_venv "${PYTHON_BIN}"
install_perl_deps
finish_install
