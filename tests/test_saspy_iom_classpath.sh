#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(/usr/bin/dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
MCP4SAS_ROOT="$(cd "${TEST_DIR}/.." && pwd)"
. "${MCP4SAS_ROOT}/install/common.sh"

temporary_root="$(cd "${TMPDIR:-/tmp}" && pwd -P)"
temp_dir="$(mktemp -d "$temporary_root/mcp4sas-iom-test.XXXXXX")"
fixture_saspy_dir="${temp_dir}/saspy"
iom_dir="${temp_dir}/sas-iom"
incomplete_dir="${temp_dir}/incomplete-iom"
cleanup() {
  [[ -d "$temp_dir" && "${temp_dir##*/}" == mcp4sas-iom-test.* ]] || return 0
  [[ "$(cd "$temp_dir/.." && pwd -P)" == "$temporary_root" ]] || return 1
  [[ "$fixture_saspy_dir" == "$temp_dir/saspy" && "$iom_dir" == "$temp_dir/sas-iom" \
     && "$incomplete_dir" == "$temp_dir/incomplete-iom" ]] || return 1
  rm -f "${fixture_saspy_dir}/java/saspyiom.jar" \
    "${iom_dir}/sas.rutil.jar" \
    "${iom_dir}/sas.rutil.nls.jar" \
    "${iom_dir}/sastpj.rutil.jar" \
    "${incomplete_dir}/sas.rutil.jar"
  rmdir "${fixture_saspy_dir}/java/iomclient" "${fixture_saspy_dir}/java" "${fixture_saspy_dir}" \
    "${iom_dir}" "${incomplete_dir}" "${temp_dir}"
}
trap cleanup EXIT

mkdir -p "${fixture_saspy_dir}/java/iomclient" "${iom_dir}" "${incomplete_dir}"
# Plain-text test fixtures, not third-party Java archives.
printf 'fixture\n' > "${fixture_saspy_dir}/java/saspyiom.jar"
for jar in "${MCP4SAS_SASPY_IOM_JARS[@]}"; do
  printf 'fixture\n' > "${iom_dir}/${jar}"
done

saspy_package_dir() { printf '%s\n' "$fixture_saspy_dir"; }

unset MCP4SAS_SASPY_IOM_DIR
printf '' > "${fixture_saspy_dir}/java/saspyiom.jar"
if (validate_saspy_java_assets) >/dev/null 2>&1; then
  printf 'Missing/empty SASPy Java bridge was accepted\n' >&2
  exit 1
fi
printf 'fixture\n' > "${fixture_saspy_dir}/java/saspyiom.jar"
printf 'Missing SASPy Java bridge rejected: PASS\n'
classpath="$(build_saspy_classpath "$fixture_saspy_dir")"
[[ "$classpath" == *saspyiom.jar* && "$classpath" != *sas.rutil.jar* ]] || {
  printf 'Package-only classpath should work without optional SAS encryption JARs\n' >&2
  exit 1
}
validate_saspy_java_assets
printf 'Installation without optional SAS encryption JARs: PASS\n'

printf 'fixture\n' > "${incomplete_dir}/sas.rutil.jar"
if (MCP4SAS_SASPY_IOM_DIR="$incomplete_dir"; validate_saspy_java_assets) >/dev/null 2>&1; then
  printf 'Incomplete explicitly supplied SAS encryption directory was accepted\n' >&2
  exit 1
fi
if (MCP4SAS_SASPY_IOM_DIR="$temp_dir/missing"; validate_saspy_java_assets) >/dev/null 2>&1; then
  printf 'Missing explicitly supplied SAS encryption directory was accepted\n' >&2
  exit 1
fi
printf 'Invalid explicit SAS encryption directories rejected: PASS\n'

MCP4SAS_SASPY_IOM_DIR="${iom_dir}"
validate_saspy_java_assets
classpath="$(build_saspy_classpath "${fixture_saspy_dir}")"

classpath_path() {
  if uname -s | grep -qi '^CYGWIN'; then
    cygpath -w "$1"
  else
    printf '%s' "$1"
  fi
}

for jar in "${MCP4SAS_SASPY_IOM_JARS[@]}"; do
  expected="$(classpath_path "${iom_dir}/${jar}")"
  [[ "${classpath}" == *"${expected}"* ]] || {
    printf 'SAS IOM JAR is missing from classpath: %s\n' "${jar}" >&2
    exit 1
  }
done
expected_bridge="$(classpath_path "${fixture_saspy_dir}/java/saspyiom.jar")"
[[ "${classpath}" == *"${expected_bridge}"* ]] || {
  printf 'SASPy bridge JAR is missing from classpath\n' >&2
  exit 1
}

printf 'SAS-provided IOM classpath selection: PASS\n'
