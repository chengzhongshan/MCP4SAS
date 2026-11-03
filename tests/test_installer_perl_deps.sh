#!/usr/bin/env bash
set -euo pipefail
export PATH=/usr/bin:$PATH
test_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$test_dir/../install/common.sh"
temporary_root="$(cd "${TMPDIR:-/tmp}" && pwd -P)"
fixture="$(mktemp -d "$temporary_root/mcp4sas-cpan-test.XXXXXX")"
cleanup() {
  [[ -d "$fixture" && "${fixture##*/}" == mcp4sas-cpan-test.* ]] || return 0
  [[ "$(cd "$fixture/.." && pwd -P)" == "$temporary_root" ]] || return 1
  rm -rf -- "$fixture"
}
trap cleanup EXIT
mkdir -p "$fixture/bin"
export MCP4SAS_TEST_ARGS_LOG="$fixture/args"
export MCP4SAS_TEST_CURL_LOG="$fixture/curl"
cat > "$fixture/bin/cpanm" <<'MOCK'
#!/usr/bin/env bash
printf '%s\n' "$@" > "$MCP4SAS_TEST_ARGS_LOG"
exit "${MCP4SAS_TEST_INSTALL_EXIT:-0}"
MOCK
chmod +x "$fixture/bin/cpanm"
export PATH="$fixture/bin:$PATH"
curl() {
  printf '%s\n' "$@" > "$MCP4SAS_TEST_CURL_LOG"
  local output=''
  while (($#)); do
    if [[ "$1" == -o ]]; then output="$2"; break; fi
    shift
  done
  cp "$fixture/bin/cpanm" "$output"
}
uname() { printf '%s\n' "$test_platform"; }
count=0
assert() {
  count=$((count+1))
  if "$@"; then printf 'ok %s\n' "$count";
  else printf 'not ok %s\n' "$count"; exit 1; fi
}
run_case() {
  test_platform="$1"
  MCP4SAS_ROOT="$fixture/project with spaces/$test_platform"
  MCP4SAS_LOCAL_PERL="$MCP4SAS_ROOT/local/perl5"
  install_perl_deps >/dev/null
  args=()
  while IFS= read -r arg; do args+=("$arg"); done < "$MCP4SAS_TEST_ARGS_LOG"
  assert test "${args[0]}" = --from
  assert test "${args[1]}" = "${MCP4SAS_CPAN_MIRROR:-https://cpan.metacpan.org/}"
  assert test "${args[2]}" = --notest
  assert test "${args[3]}" = --local-lib-contained
  assert test "${args[4]}" = "$MCP4SAS_LOCAL_PERL"
  assert test "${args[5]}" = --installdeps
  assert test "${args[6]}" = "$MCP4SAS_ROOT"
}
unset MCP4SAS_CPAN_MIRROR
unset MCP4SAS_TEST_INSTALL_EXIT
run_case CYGWIN_NT-10.0
assert test "$CPANM" = "$MCP4SAS_ROOT/local/cpanm"
assert grep -qx https://cpanmin.us "$MCP4SAS_TEST_CURL_LOG"
run_case Linux
assert test "$CPANM" = "$fixture/bin/cpanm"
export MCP4SAS_CPAN_MIRROR='https://cpan.example.invalid/custom/'
run_case Linux
export MCP4SAS_TEST_INSTALL_EXIT=23
set +e
( install_perl_deps ) >/dev/null 2>&1
rc=$?
set -e
assert test "$rc" = 23
printf '1..%s\n' "$count"
