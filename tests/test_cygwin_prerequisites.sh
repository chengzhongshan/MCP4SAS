#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$root/install/cygwin_prerequisites.sh"
temp_parent="$(cd "${TMPDIR:-/tmp}" && pwd -P)"
fixture="$(mktemp -d "$temp_parent/mcp4sas-prereq.XXXXXX")"
cleanup() {
  [[ -n "$fixture" && -d "$fixture/bin" && -f "$fixture/owned" ]] || return 0
  [[ "$(cd "$fixture/.." && pwd -P)" == "$temp_parent" && "${fixture##*/}" == mcp4sas-prereq.* ]] || return 1
  rm -rf -- "$fixture"
}
trap cleanup EXIT
mkdir "$fixture/bin"; touch "$fixture/owned"; printf 'test certificate\n' > "$fixture/ca.pem"
for exe in bash perl git curl gcc g++ make unzip wget zip; do
  printf '#!/usr/bin/env bash\nexit 0\n' > "$fixture/bin/$exe";chmod +x "$fixture/bin/$exe"
done
cat > "$fixture/bin/python3" <<'PYTHON'
#!/usr/bin/env bash
if [[ "${1:-}" == -c ]]; then [[ "${MCP4SAS_TEST_PIP_MISSING:-0}" == 0 ]];exit;fi
script="$(cat)"
if [[ "$script" == *Python.h* ]]; then [[ "${MCP4SAS_TEST_HEADERS_MISSING:-0}" == 0 ]];else exit 0;fi
PYTHON
chmod +x "$fixture/bin/python3"
[[ -z "$(cygwin_missing_prerequisites "$fixture/bin" "$fixture/ca.pem")" ]]
printf 'ok 1 - ready environment needs no setup or upgrades\n'
rm "$fixture/bin/gcc"
[[ "$(cygwin_missing_prerequisites "$fixture/bin" "$fixture/ca.pem")" == gcc-core ]]
printf 'ok 2 - only missing compiler package requested\n'
export MCP4SAS_TEST_PIP_MISSING=1 MCP4SAS_TEST_HEADERS_MISSING=1
result="$(cygwin_missing_prerequisites "$fixture/bin" "$fixture/ca.pem")"
[[ "$result" == $'gcc-core\npython312-pip\npython312-devel' ]]
printf 'ok 3 - pip and development headers checked independently\n'
cmp "$root/install/cygwin_prerequisites.sh" "$root/integrations/vscode/src/cygwin_prerequisites.sh"
printf 'ok 4 - shell and extension use identical prerequisite probe\n'
! grep -q 'setup-x86_64.exe' "$root/install/install_cygwin.sh"
printf 'ok 5 - Bash installer cannot launch a DLL upgrade in its own runtime\n'
printf '#!/usr/bin/env bash\nprintf "fixture installer failure\\n"\nexit 17\n' > "$fixture/fail.sh"
set +e
bash "$root/integrations/vscode/src/installer-task.sh" "$fixture/failure.log" "$fixture/fail.sh" > "$fixture/wrapper.log"
status=$?
set -e
[[ "$status" == 17 ]];grep -q 'fixture installer failure' "$fixture/failure.log"
printf 'ok 6 - logged installer preserves actual failing exit code\n'
printf '1..6\n'
