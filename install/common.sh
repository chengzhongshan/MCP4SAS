#!/usr/bin/env bash
set -euo pipefail

MCP4SAS_INSTALL_DIR="$(cd "$(/usr/bin/dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
MCP4SAS_ROOT="$(cd "${MCP4SAS_INSTALL_DIR}/.." && pwd)"
MCP4SAS_VENV="${MCP4SAS_ROOT}/.venv-pipeline"
MCP4SAS_LOCAL_PERL="${MCP4SAS_ROOT}/local/perl5"

log() {
  printf '[MCP4SAS install] %s\n' "$*"
}

die() {
  printf '[MCP4SAS install] ERROR: %s\n' "$*" >&2
  exit 1
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

find_python() {
  local cand
  for cand in \
    "${MCP4SAS_PYTHON_BIN:-}" \
    /usr/bin/python3 \
    /usr/local/bin/python3 \
    /opt/homebrew/bin/python3 \
    python3.12 python3.11 python3.10 python3.9 python3.8 \
    python3 python; do
    [ -n "$cand" ] || continue
    if command_exists "$cand"; then
      "$cand" - <<'PY' >/dev/null 2>&1 || continue
import sys
raise SystemExit(0 if sys.version_info >= (3, 8) else 1)
PY
      command -v "$cand"
      return 0
    fi
  done
  return 1
}

create_python_venv() {
  local python_bin="$1"
  log "Creating Python virtual environment at ${MCP4SAS_VENV}"
  "$python_bin" -m venv "${MCP4SAS_VENV}"
  "${MCP4SAS_VENV}/bin/python" -m pip install --upgrade pip setuptools wheel
  "${MCP4SAS_VENV}/bin/python" -m pip install -r "${MCP4SAS_INSTALL_DIR}/requirements.txt"
  printf '%s\n' "${MCP4SAS_VENV}/bin/python" > "${MCP4SAS_VENV}/.python-bin"
}

install_perl_deps() {
  log "Installing Perl dependencies under ${MCP4SAS_LOCAL_PERL}"
  mkdir -p "${MCP4SAS_ROOT}/local"
  if ! command_exists cpanm; then
    curl -L https://cpanmin.us -o "${MCP4SAS_ROOT}/local/cpanm"
    chmod +x "${MCP4SAS_ROOT}/local/cpanm"
    CPANM="${MCP4SAS_ROOT}/local/cpanm"
  else
    CPANM="$(command -v cpanm)"
  fi
  "$CPANM" --notest --local-lib-contained "${MCP4SAS_LOCAL_PERL}" --installdeps "${MCP4SAS_ROOT}"
}

finish_install() {
  chmod +x "${MCP4SAS_ROOT}/server.pl" \
           "${MCP4SAS_ROOT}/run_sas_codes_or_files_in_ODA.pl" \
           "${MCP4SAS_ROOT}/run_sas_codes_or_script_in_ODA.pl"
  log "MCP4SAS installation completed"
  log "Validate with: ./run_sas_codes_or_files_in_ODA.pl --check-sas-oda-login-only"
  log "Start MCP server with: perl server.pl daemon -m production -l http://127.0.0.1:8080"
}
