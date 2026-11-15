#!/usr/bin/env bash
# VS Code invokes this wrapper using literal ProcessExecution arguments.
set -uo pipefail
logfile="$1"; shift
mkdir -p "$(/usr/bin/dirname "$logfile")" || exit 1
umask 077
bash --noprofile --norc "$@" 2>&1 | tee "$logfile"
statuses=("${PIPESTATUS[@]}")
status=${statuses[0]}
[[ "$status" -ne 0 || "${statuses[1]}" -eq 0 ]] || status=${statuses[1]}
printf '\nMCP4SAS installer exit code: %s\nInstaller log: %s\n' "$status" "$logfile"
exit "$status"
