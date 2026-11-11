#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(/usr/bin/dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
MCP4SAS_ROOT="$(cd "${TEST_DIR}/.." && pwd)"
. "${MCP4SAS_ROOT}/install/common.sh"

temp_dir="$(mktemp -d)"
saspy_dir="${temp_dir}/saspy"
iom_dir="${temp_dir}/sas-iom"
cleanup() {
  rm -f "${saspy_dir}/java/saspyiom.jar" \
    "${iom_dir}/sas.rutil.jar" \
    "${iom_dir}/sas.rutil.nls.jar" \
    "${iom_dir}/sastpj.rutil.jar"
  rmdir "${saspy_dir}/java/iomclient" "${saspy_dir}/java" "${saspy_dir}" \
    "${iom_dir}" "${temp_dir}"
}
trap cleanup EXIT

mkdir -p "${saspy_dir}/java/iomclient" "${iom_dir}"
touch "${saspy_dir}/java/saspyiom.jar"
for jar in "${MCP4SAS_SASPY_IOM_JARS[@]}"; do
  touch "${iom_dir}/${jar}"
done

MCP4SAS_SASPY_IOM_DIR="${iom_dir}"
classpath="$(build_saspy_classpath "${saspy_dir}")"

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
expected_bridge="$(classpath_path "${saspy_dir}/java/saspyiom.jar")"
[[ "${classpath}" == *"${expected_bridge}"* ]] || {
  printf 'SASPy bridge JAR is missing from classpath\n' >&2
  exit 1
}

printf 'SAS-provided IOM classpath selection: PASS\n'
