#!/usr/bin/env bash
set -euo pipefail
if ! command -v code >/dev/null 2>&1; then
  printf '%s\n' 'VS Code command not found. Use Extensions -> Install from VSIX in VS Code.' 
  printf '%s\n' 'Download: https://github.com/chengzhongshan/MCP4SAS/releases/tag/vscode-v0.1.0'
  exit 1
fi
archive="$(mktemp "${TMPDIR:-/tmp}/mcp4sas-XXXXXX.vsix")"
sums="$(mktemp "${TMPDIR:-/tmp}/mcp4sas-XXXXXX.sha256")"
trap 'rm -f -- "$archive" "$sums"' EXIT
base='https://github.com/chengzhongshan/MCP4SAS/releases/download/vscode-v0.1.0'
curl --fail --location --proto '=https' --proto-redir '=https' "$base/mcp4sas-0.1.0.vsix" -o "$archive"
curl --fail --location --proto '=https' --proto-redir '=https' "$base/SHA256SUMS" -o "$sums"
expected="$(awk '$2 == "mcp4sas-0.1.0.vsix" {print $1}' "$sums")"
if command -v sha256sum >/dev/null 2>&1; then
  actual="$(sha256sum "$archive" | cut -d ' ' -f 1)"
else
  actual="$(shasum -a 256 "$archive" | cut -d ' ' -f 1)"
fi
[[ ${#expected} -eq 64 && "$actual" == "$expected" ]] || { printf '%s\n' 'Release checksum mismatch; not installed.' >&2; exit 1; }
code --install-extension "$archive"
printf '%s\n' 'Open your SAS folder in VS Code, then run MCP4SAS: Quick Setup.'
