#!/usr/bin/env bash
set -euo pipefail

CHECK_DIR="$(cd "$(/usr/bin/dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
MCP4SAS_ROOT="$(cd "${CHECK_DIR}/.." && pwd)"
cd "${MCP4SAS_ROOT}"

perl_base="${MCP4SAS_ROOT}/local/perl5/lib/perl5"
if [[ -d "${perl_base}" ]]; then
  export PERL5LIB="${perl_base}${PERL5LIB:+:${PERL5LIB}}"
fi

python_bin="${MCP4SAS_ROOT}/.venv-pipeline/bin/python"
if [[ ! -x "${python_bin}" ]]; then
  python_bin="${MCP4SAS_ROOT}/.venv-pipeline/Scripts/python.exe"
fi
if [[ ! -x "${python_bin}" && -s "${MCP4SAS_ROOT}/.venv-pipeline/.python-bin" ]]; then
  IFS= read -r python_bin < "${MCP4SAS_ROOT}/.venv-pipeline/.python-bin"
fi
[[ -x "${python_bin}" ]] || {
  printf 'MCP4SAS install check: Python environment is missing; run an installer first.\n' >&2
  exit 1
}

"${python_bin}" - <<'PY'
import os
import shutil
import subprocess
import sys

import saspy
import saspy.sascfg_personal as personal_cfg

print("saspy import: PASS")
if "oda" not in getattr(personal_cfg, "SAS_config_names", []):
    raise SystemExit("MCP4SAS install check: installed SASPy profile has no oda configuration")
oda = getattr(personal_cfg, "oda", {})
classpath = oda.get("classpath", "")
if "saspyiom.jar" not in classpath:
    raise SystemExit("MCP4SAS install check: installed SASPy profile has no IOM classpath")

def local_path(path):
    if sys.platform == "cygwin" and len(path) > 2 and path[1] == ":":
        return subprocess.check_output(["cygpath", "-u", path], text=True).strip()
    return path

java = local_path(oda.get("java", ""))
if not os.path.isfile(java) and not shutil.which(java):
    raise SystemExit("MCP4SAS install check: configured Java executable does not exist: " + java)
separator = ";" if sys.platform in ("cygwin", "win32") else ":"
for jar in classpath.split(separator):
    if jar and not os.path.isfile(local_path(jar)):
        raise SystemExit("MCP4SAS install check: configured classpath JAR is missing: " + jar)
print("saspy ODA Java/classpath: PASS")
PY
"${python_bin}" -m py_compile MCPDeps/sas_oda_session_server.py install/sascfg_personal.template.py

perl -I MCPDeps -c MCPDeps/SAS_ODA_Runner.pm >/dev/null
perl -I MCPDeps -c run_sas_codes_or_script_in_ODA.pl >/dev/null
perl -I MCPDeps -c run_sas_codes_or_files_in_ODA.pl >/dev/null
perl -I MCPDeps -c server.pl >/dev/null

./run_sas_codes_or_script_in_ODA.pl --help >/dev/null
./run_sas_codes_or_files_in_ODA.pl --help >/dev/null

cmp -s run_sas_codes_or_script_in_ODA.pl run_sas_codes_or_files_in_ODA.pl || {
  printf 'MCP4SAS install check: helper compatibility entry points differ.\n' >&2
  exit 1
}

perl MCPDeps/test_sas_oda_debug_macro_guard.pl
perl MCPDeps/test_sas_oda_connection_lifecycle.pl

printf 'MCP4SAS installation smoke check: PASS\n'
