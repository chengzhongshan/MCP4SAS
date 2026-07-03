#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage:
  RunLocalSASDirectly.sh input.sas [output_prefix] [workdir]

Runs a local SAS executable directly, without SASPy. This is a batch runner:
each invocation starts a new SAS process and cannot preserve WORK tables,
macro variables, librefs, options, or loaded macros for later invocations.

Configuration:
  MCP4SAS_LOCAL_SAS_EXE       Preferred SAS executable path for Linux or Windows
  MCP4SAS_LINUX_SAS_EXE       Linux SAS executable path
  MCP4SAS_WINDOWS_SAS_EXE     Windows sas.exe path, useful from Cygwin/MSYS
  SAS_EXE                     Generic fallback SAS executable path
  MCP4SAS_LOCAL_SAS_PLATFORM  Optional platform override: linux or windows
EOF
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

[ "$#" -ge 1 ] || {
  usage
  exit 2
}

sas_file="$1"
output_prefix="${2:-output.html.info}"
workdir="${3:-.}"

[ -s "${sas_file}" ] || die "SAS input file not found or empty: ${sas_file}"
mkdir -p "${workdir}"

detect_platform() {
  if [ -n "${MCP4SAS_LOCAL_SAS_PLATFORM:-}" ]; then
    local platform_override
    platform_override="$(printf '%s' "${MCP4SAS_LOCAL_SAS_PLATFORM}" | tr '[:upper:]' '[:lower:]')"
    case "${platform_override}" in
      win|windows|cygwin|msys|mingw) printf 'windows\n'; return 0 ;;
      linux|unix|posix) printf 'linux\n'; return 0 ;;
      *) die "Unsupported MCP4SAS_LOCAL_SAS_PLATFORM=${MCP4SAS_LOCAL_SAS_PLATFORM}" ;;
    esac
  fi

  case "$(uname -s 2>/dev/null || printf unknown)" in
    CYGWIN*|MINGW*|MSYS*) printf 'windows\n' ;;
    *) printf 'linux\n' ;;
  esac
}

path_exists() {
  [ -n "$1" ] && { [ -x "$1" ] || [ -f "$1" ]; }
}

resolve_command_or_path() {
  local candidate="$1"
  [ -n "${candidate}" ] || return 1

  if [[ "${candidate}" == */* || "${candidate}" == *\\* || "${candidate}" == *:* ]]; then
    path_exists "${candidate}" && {
      printf '%s\n' "${candidate}"
      return 0
    }
    return 1
  fi

  command -v "${candidate}" 2>/dev/null || return 1
}

first_existing_sas_exe() {
  local candidate
  local resolved
  for candidate in "$@"; do
    if resolved="$(resolve_command_or_path "${candidate}")"; then
      printf '%s\n' "${resolved}"
      return 0
    fi
  done
  return 1
}

find_sas_exe() {
  local platform="$1"

  if [ "${platform}" = "windows" ]; then
    first_existing_sas_exe \
      "${MCP4SAS_LOCAL_SAS_EXE:-}" \
      "${MCP4SAS_WINDOWS_SAS_EXE:-}" \
      "${WINDOWS_SAS_EXE:-}" \
      "${SAS_EXE:-}" \
      "/cygdrive/c/Program Files/SASHome/SASFoundation/9.4/sas.exe" \
      "/cygdrive/c/Program Files/SASHome/SASFoundation/9.4/sas_u8.exe" \
      "/cygdrive/c/Program Files/SAS/SASFoundation/9.4/sas.exe" \
      "/cygdrive/c/Program Files/SAS/SAS 9.4/sas.exe"
    return $?
  fi

  first_existing_sas_exe \
    "${MCP4SAS_LOCAL_SAS_EXE:-}" \
    "${MCP4SAS_LINUX_SAS_EXE:-}" \
    "${SAS_EXE:-}" \
    sas_u8 \
    sas \
    "/opt/sasinside/SASHome/SASFoundation/9.4/bin/sas_u8" \
    "/opt/sasinside/SASHome/SASFoundation/9.4/bin/sas" \
    "/usr/local/SASHome/SASFoundation/9.4/bin/sas_u8" \
    "/usr/local/SASHome/SASFoundation/9.4/bin/sas"
}

absolute_path() {
  local path="$1"
  local dir
  local base
  dir="$(cd "$(dirname "${path}")" && pwd)"
  base="$(basename "${path}")"
  printf '%s/%s\n' "${dir}" "${base}"
}

target_path() {
  local platform="$1"
  local path="$2"

  if [ "${platform}" = "windows" ] && command -v cygpath >/dev/null 2>&1; then
    cygpath -w "${path}"
  else
    printf '%s\n' "${path}"
  fi
}

platform="$(detect_platform)"
sas_exe="$(find_sas_exe "${platform}")" || {
  if [ "${platform}" = "windows" ]; then
    die "Could not find local Windows SAS. Set MCP4SAS_LOCAL_SAS_EXE or MCP4SAS_WINDOWS_SAS_EXE to sas.exe."
  fi
  die "Could not find local Linux SAS. Set MCP4SAS_LOCAL_SAS_EXE or MCP4SAS_LINUX_SAS_EXE to the sas/sas_u8 executable."
}

abs_sas_file="$(absolute_path "${sas_file}")"
abs_workdir="$(cd "${workdir}" && pwd)"
log_file="${abs_workdir}/${output_prefix}.log"
lst_file="${abs_workdir}/${output_prefix}.lst"

sysin_arg="$(target_path "${platform}" "${abs_sas_file}")"
log_arg="$(target_path "${platform}" "${log_file}")"
lst_arg="$(target_path "${platform}" "${lst_file}")"

if [ "${platform}" = "windows" ]; then
  sas_args=(-sysin "${sysin_arg}" -log "${log_arg}" -print "${lst_arg}" -nosplash -noterminal)
else
  sas_args=(-sysin "${sysin_arg}" -log "${log_arg}" -print "${lst_arg}" -nodms -noterminal)
fi

printf 'Running local SAS directly without SASPy\n'
printf 'Platform: %s\n' "${platform}"
printf 'SAS executable: %s\n' "${sas_exe}"
printf 'SAS program: %s\n' "${abs_sas_file}"
printf 'Log file: %s\n' "${log_file}"
printf 'Listing file: %s\n\n' "${lst_file}"

set +e
"${sas_exe}" "${sas_args[@]}"
status=$?
set -e

printf '\nSAS process exit status: %s\n' "${status}"

if [ -f "${log_file}" ]; then
  printf '\n===== SAS LOG: %s =====\n' "${log_file}"
  cat "${log_file}"
else
  printf '\nNo SAS log file was created at: %s\n' "${log_file}"
fi

if [ -f "${lst_file}" ]; then
  printf '\n===== SAS LISTING: %s =====\n' "${lst_file}"
  cat "${lst_file}"
fi

exit "${status}"
