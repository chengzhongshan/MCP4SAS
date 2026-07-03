#!/usr/bin/env bash
set -euo pipefail

MCP4SAS_INSTALL_DIR="$(cd "$(/usr/bin/dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
MCP4SAS_ROOT="$(cd "${MCP4SAS_INSTALL_DIR}/.." && pwd)"
MCP4SAS_VENV="${MCP4SAS_ROOT}/.venv-pipeline"
MCP4SAS_LOCAL_PERL="${MCP4SAS_ROOT}/local/perl5"
MCP4SAS_SASPY_IOM_JARS=(sas.rutil.jar sas.rutil.nls.jar sastpj.rutil.jar)

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
  install_saspy_iom_encryption_jars || true
}

saspy_iomclient_dir() {
  local candidate
  for candidate in \
    "${MCP4SAS_VENV}"/lib/python*/site-packages/saspy/java/iomclient \
    "${MCP4SAS_VENV}"/Lib/site-packages/saspy/java/iomclient; do
    if [ -d "$candidate" ]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 1
}

dir_has_iom_encryption_jars() {
  local dir="$1"
  local jar
  [ -d "$dir" ] || return 1
  for jar in "${MCP4SAS_SASPY_IOM_JARS[@]}"; do
    [ -s "${dir}/${jar}" ] || return 1
  done
  return 0
}

candidate_iom_jar_dirs() {
  if [ -n "${MCP4SAS_SASPY_IOM_JAR_DIR:-}" ]; then
    printf '%s\n' "${MCP4SAS_SASPY_IOM_JAR_DIR}"
  fi
  if [ -n "${MCP4SAS_MULTIGWAS_ROOT:-}" ]; then
    printf '%s\n' "${MCP4SAS_MULTIGWAS_ROOT}/install/saspy-java-supplement/java/iomclient"
    printf '%s\n' "${MCP4SAS_MULTIGWAS_ROOT}/.venv-pipeline/lib/python3.8/site-packages/saspy/java/iomclient"
  fi
  printf '%s\n' \
    "${MCP4SAS_ROOT}/install/saspy-java-supplement/java/iomclient" \
    "${MCP4SAS_ROOT}/../MultiGWAS-Explorer/install/saspy-java-supplement/java/iomclient" \
    "${MCP4SAS_ROOT}/../MultiGWAS-Explorer-main/MultiGWAS-Explorer/install/saspy-java-supplement/java/iomclient"
}

install_saspy_iom_encryption_jars() {
  local dst src jar
  dst="$(saspy_iomclient_dir)" || {
    log "SASPy iomclient directory not found yet; skipping SAS ODA encryption jar copy"
    return 0
  }

  if dir_has_iom_encryption_jars "$dst"; then
    log "SAS ODA IOM encryption jars already installed in ${dst}"
    return 0
  fi

  while IFS= read -r src; do
    [ -n "$src" ] || continue
    if dir_has_iom_encryption_jars "$src"; then
      log "Installing SAS ODA IOM encryption jars from ${src}"
      mkdir -p "$dst"
      for jar in "${MCP4SAS_SASPY_IOM_JARS[@]}"; do
        cp -f "${src}/${jar}" "${dst}/${jar}"
      done
      log "Installed SAS ODA IOM encryption jars into ${dst}"
      return 0
    fi
  done < <(candidate_iom_jar_dirs)

  log "WARNING: SAS ODA IOM encryption jars were not found."
  log "SAS ODA on SAS 9.4M7 requires: ${MCP4SAS_SASPY_IOM_JARS[*]}"
  log "Set MCP4SAS_SASPY_IOM_JAR_DIR=/path/to/iomclient or MCP4SAS_MULTIGWAS_ROOT=/path/to/MultiGWAS-Explorer and rerun install/install_saspy_iom_jars.sh."
  return 0
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
