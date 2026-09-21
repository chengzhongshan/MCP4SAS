#!/usr/bin/env bash
set -euo pipefail

MCP4SAS_INSTALL_DIR="$(cd "$(/usr/bin/dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
MCP4SAS_ROOT="$(cd "${MCP4SAS_INSTALL_DIR}/.." && pwd)"
MCP4SAS_VENV="${MCP4SAS_ROOT}/.venv-pipeline"
MCP4SAS_LOCAL_PERL="${MCP4SAS_ROOT}/local/perl5"
MCP4SAS_SASPY_IOM_JARS=(sas.rutil.jar sas.rutil.nls.jar sastpj.rutil.jar)
MCP4SAS_SASPY_CONFIG_TEMPLATE="${MCP4SAS_INSTALL_DIR}/sascfg_personal.template.py"
MCP4SAS_SASPY_JAVA_SUPPLEMENT="${MCP4SAS_INSTALL_DIR}/saspy-java-supplement"
MCP4SAS_BASE_PYTHON=""

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
  MCP4SAS_BASE_PYTHON="$python_bin"
  log "Creating Python virtual environment at ${MCP4SAS_VENV}"
  if command_exists uname && uname -s | grep -qi '^CYGWIN'; then
    "$python_bin" -m venv --system-site-packages "${MCP4SAS_VENV}"
  else
    "$python_bin" -m venv "${MCP4SAS_VENV}"
  fi
  "${MCP4SAS_VENV}/bin/python" -m pip install --upgrade pip setuptools wheel
  "${MCP4SAS_VENV}/bin/python" -m pip install -r "${MCP4SAS_INSTALL_DIR}/requirements.txt"
  printf '%s\n' "${MCP4SAS_VENV}/bin/python" > "${MCP4SAS_VENV}/.python-bin"
  install_saspy_java_assets
  install_saspy_config_template
  configure_installed_saspy_profile
}

install_saspy_config_template() {
  local dst="${MCP4SAS_ROOT}/sascfg_personal.py"
  local home_config="${HOME:-}/.config/saspy/sascfg_personal.py"
  local home_legacy="${HOME:-}/sascfg_personal.py"

  [ -s "${MCP4SAS_SASPY_CONFIG_TEMPLATE}" ] || {
    log "SASPy config template not found: ${MCP4SAS_SASPY_CONFIG_TEMPLATE}"
    return 0
  }

  if [ "${MCP4SAS_OVERWRITE_SASPY_CONFIG:-0}" = "1" ]; then
    cp -f "${MCP4SAS_SASPY_CONFIG_TEMPLATE}" "${dst}"
    log "Wrote SASPy config template to ${dst}"
    return 0
  fi

  if [ -s "${dst}" ]; then
    log "SASPy config already exists at ${dst}"
    return 0
  fi
  if [ -n "${HOME:-}" ] && { [ -s "${home_config}" ] || [ -s "${home_legacy}" ]; }; then
    log "Existing user SASPy config found; not writing repo-local sascfg_personal.py"
    return 0
  fi

  cp "${MCP4SAS_SASPY_CONFIG_TEMPLATE}" "${dst}"
  log "Wrote SASPy config template to ${dst}"
}

saspy_package_dir() {
  local candidate
  for candidate in \
    "${MCP4SAS_VENV}"/lib/python*/site-packages/saspy \
    "${MCP4SAS_VENV}"/Lib/site-packages/saspy; do
    if [ -d "$candidate" ]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 1
}

resolve_windows_java_for_saspy() {
  local candidate unix_candidate
  for candidate in \
    "${SASPY_JAVA_WIN:-}" \
    "${SASPY_JAVA:-}" \
    "${JAVA_HOME:+${JAVA_HOME}/bin/java.exe}" \
    'C:\Program Files\Microsoft\jdk-17.0.13.11-hotspot\bin\java.exe' \
    'C:\Program Files\Eclipse Adoptium\jdk-17.0.13.11-hotspot\bin\java.exe' \
    'C:\Program Files\Java\jdk-17\bin\java.exe' \
    'C:\Program Files\Java\jdk-11\bin\java.exe'; do
    [ -n "$candidate" ] || continue
    if command_exists cygpath; then
      unix_candidate="$(cygpath -u "$candidate" 2>/dev/null || true)"
      if [ -n "$unix_candidate" ] && [ -f "$unix_candidate" ]; then
        cygpath -w "$unix_candidate"
        return 0
      fi
    elif [ -f "$candidate" ]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 1
}

resolve_unix_java_for_saspy() {
  local candidate base_python_dir=""
  if [ -n "${MCP4SAS_BASE_PYTHON:-}" ]; then
    base_python_dir="$(cd "$(/usr/bin/dirname "${MCP4SAS_BASE_PYTHON}")" 2>/dev/null && pwd || true)"
  fi
  for candidate in \
    "${SASPY_JAVA:-}" \
    "${MCP4SAS_JAVA:-}" \
    "${JAVA_HOME:+${JAVA_HOME}/bin/java}" \
    "${base_python_dir:+${base_python_dir}/java}" \
    /opt/homebrew/opt/openjdk/bin/java \
    /usr/local/opt/openjdk/bin/java \
    /usr/bin/java \
    /usr/local/bin/java \
    java; do
    [ -n "$candidate" ] || continue
    if [ -x "$candidate" ]; then
      printf '%s\n' "$candidate"
      return 0
    fi
    if command_exists "$candidate"; then
      command -v "$candidate"
      return 0
    fi
  done
  return 1
}

build_saspy_classpath() {
  local saspy_dir="$1" jar rel separator=':' is_cygwin=0
  local -a jars=() classpath_parts=()
  local preferred_rel=(
    java/saspyiom.jar
    java/iomclient/log4j-1.2-api-2.12.4.jar
    java/iomclient/log4j-api-2.12.4.jar
    java/iomclient/log4j-core-2.12.4.jar
    java/iomclient/sas.security.sspi.jar
    java/iomclient/sas.core.jar
    java/iomclient/sas.svc.connection.jar
    java/iomclient/sas.rutil.jar
    java/iomclient/sas.rutil.nls.jar
    java/iomclient/sastpj.rutil.jar
    java/thirdparty/glassfish-corba-internal-api.jar
    java/thirdparty/glassfish-corba-omgapi.jar
    java/thirdparty/glassfish-corba-orb.jar
    java/thirdparty/pfl-basic.jar
    java/thirdparty/pfl-tf.jar
  )

  if command_exists uname && uname -s | grep -qi '^CYGWIN'; then
    is_cygwin=1
    separator=';'
  fi
  for rel in "${preferred_rel[@]}"; do
    jar="${saspy_dir}/${rel}"
    [ -f "$jar" ] && jars+=("$jar")
  done
  for jar in "${jars[@]}"; do
    if [ "$is_cygwin" -eq 1 ]; then
      classpath_parts+=("$(cygpath -w "$jar")")
    else
      classpath_parts+=("$jar")
    fi
  done
  local IFS="$separator"
  printf '%s\n' "${classpath_parts[*]}"
}

install_saspy_java_assets() {
  local saspy_dir source_dir
  saspy_dir="$(saspy_package_dir)" || die "Installed SASPy package directory was not found"
  source_dir="${MCP4SAS_SASPY_JAVA_SUPPLEMENT}/java"
  [ -d "$source_dir" ] || die "Bundled SASPy Java supplement is missing: ${source_dir}"
  mkdir -p "${saspy_dir}/java"
  cp -Rf "${source_dir}/." "${saspy_dir}/java/"
  [ -s "${saspy_dir}/java/saspyiom.jar" ] || die "SASPy Java bridge was not installed"
  dir_has_iom_encryption_jars "${saspy_dir}/java/iomclient" || die "SAS ODA encryption jars were not installed"
  log "Installed the bundled SASPy Java runtime into ${saspy_dir}/java"
}

configure_installed_saspy_profile() {
  local saspy_dir cfg_file java_bin classpath_value
  saspy_dir="$(saspy_package_dir)" || die "Installed SASPy package directory was not found"
  cfg_file="${saspy_dir}/sascfg_personal.py"
  if command_exists uname && uname -s | grep -qi '^CYGWIN'; then
    java_bin="$(resolve_windows_java_for_saspy || true)"
  else
    java_bin="$(resolve_unix_java_for_saspy || true)"
  fi
  [ -n "$java_bin" ] || die "Java runtime not found; install a JDK or set SASPY_JAVA"
  classpath_value="$(build_saspy_classpath "$saspy_dir")"
  [[ "$classpath_value" == *saspyiom.jar* ]] || die "Could not construct the SASPy IOM classpath"

  cp -f "${MCP4SAS_SASPY_CONFIG_TEMPLATE}" "$cfg_file"
  cat >> "$cfg_file" <<PY

# Values provisioned by the MCP4SAS installer for this isolated environment.
_MCP4SAS_JAVA = r'${java_bin}'
_MCP4SAS_CLASSPATH = r'${classpath_value}'
for _mcp4sas_iom_profile in (oda, winlocal, winiomwin, iomlinux, iomwin):
    _mcp4sas_iom_profile['java'] = os.environ.get(
        'SASPY_JAVA_WIN', os.environ.get('SASPY_JAVA', _MCP4SAS_JAVA)
    )
    _mcp4sas_iom_profile['classpath'] = os.environ.get(
        'SASPY_ODA_CLASSPATH', _MCP4SAS_CLASSPATH
    )
PY
  log "Configured the installed SASPy profile at ${cfg_file}"
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

install_saspy_iom_encryption_jars() {
  install_saspy_java_assets
  configure_installed_saspy_profile
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
           "${MCP4SAS_ROOT}/run_sas_codes_or_script_in_ODA.pl" \
           "${MCP4SAS_INSTALL_DIR}/check_mcp4sas_install.sh"
  bash "${MCP4SAS_INSTALL_DIR}/check_mcp4sas_install.sh"
  log "MCP4SAS installation completed"
  log "Validate with: ./run_sas_codes_or_files_in_ODA.pl --check-sas-oda-login-only"
  log "Start MCP server with: perl server.pl daemon -m production -l http://127.0.0.1:8080"
}
