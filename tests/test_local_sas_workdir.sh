#!/usr/bin/env bash
set -euo pipefail

export PATH="/usr/bin:$PATH"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_root="$(mktemp -d)"
trap 'rm -rf "$test_root"' EXIT

mkdir -p "$test_root/results"
printf '%s\n' 'proc means;' > "$test_root/input.sas"
cat > "$test_root/fake-sas" <<'FAKE_SAS'
#!/bin/sh
set -eu
printf '%s\n' "$PWD" > fake_sas_cwd.txt
while [ "$#" -gt 0 ]; do
  case "$1" in
    -log)
      printf '%s\n' 'NOTE: fake SAS success' > "$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done
printf '%s\n' '<html>fake SAS result</html>' > fake_sas_result.html
FAKE_SAS
chmod +x "$test_root/fake-sas"

(
  cd "$test_root"
  MCP4SAS_LOCAL_SAS_EXE="$test_root/fake-sas" \
  MCP4SAS_LOCAL_SAS_PLATFORM=linux \
    bash "$script_dir/RunLocalSASDirectly.sh" \
      "$test_root/input.sas" output.html.info "$test_root/results"
)

grep -Fqx "$test_root/results" "$test_root/results/fake_sas_cwd.txt"
test -f "$test_root/results/fake_sas_result.html"
test ! -e "$test_root/fake_sas_result.html"
printf '%s\n' 'Direct local SAS runs in the requested results directory: PASS'
