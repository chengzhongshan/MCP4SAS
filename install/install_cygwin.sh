#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(/usr/bin/dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
. "${SCRIPT_DIR}/common.sh"

command_exists cygpath || die "Run this script inside a Cygwin terminal"

if [[ "${MCP4SAS_SKIP_CYGWIN_SETUP:-0}" != "1" ]]; then
  SETUP_EXE="${MCP4SAS_CYGWIN_SETUP_EXE:-${MCP4SAS_ROOT}/local/setup-x86_64.exe}"
  mkdir -p "$(/usr/bin/dirname "${SETUP_EXE}")"
  if [ ! -s "${SETUP_EXE}" ]; then
    log "Downloading Cygwin setup"
    curl -L https://cygwin.com/setup-x86_64.exe -o "${SETUP_EXE}"
    chmod +x "${SETUP_EXE}"
  fi
  CYGROOT="$(cygpath -w /)"
  MIRROR="${MCP4SAS_CYGWIN_MIRROR:-https://mirrors.kernel.org/sourceware/cygwin/}"
  log "Installing Cygwin packages"
  "${SETUP_EXE}" -q -B -g -n -N -d --no-write-registry -R "${CYGROOT}" -s "${MIRROR}" \
    -P bash,ca-certificates,curl,gcc-core,gcc-g++,make,perl,python3,python312,python312-devel,python312-pip,unzip,wget,zip
fi

PYTHON_BIN="$(find_python)" || die "Python >= 3.8 not found"
create_python_venv "${PYTHON_BIN}"
install_perl_deps
finish_install
