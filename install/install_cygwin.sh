#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(/usr/bin/dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
. "${SCRIPT_DIR}/common.sh"
export PATH="/usr/bin:/bin:$PATH"
. "${SCRIPT_DIR}/cygwin_prerequisites.sh"

command_exists cygpath || die "Run this script inside a Cygwin terminal"

if [[ "${MCP4SAS_SKIP_CYGWIN_SETUP:-0}" != "1" ]]; then
  missing="$(cygwin_missing_prerequisites)"
  if [[ -n "$missing" ]]; then
    log "Missing Cygwin prerequisites: $(printf '%s' "$missing" | tr '\n' ' ')"
    die "Run MCP4SAS: Quick Setup to install missing packages from Windows, or close Cygwin programs and add those packages using official Cygwin setup. This Bash installer will not upgrade DLLs used by your terminals or SAS sessions."
  fi
  log "Cygwin prerequisites already work; reusing them without package upgrades."
fi

PYTHON_BIN="$(find_python)" || die "Python >= 3.8 not found"
create_python_venv "${PYTHON_BIN}"
install_perl_deps
finish_install
