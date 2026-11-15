#!/usr/bin/env bash
# Read-only probe. Never run Cygwin's package manager from an active Bash.
cygwin_missing_prerequisites() {
  local bin="${1:-/usr/bin}" cert="${2:-}" pair exe package flag
  for pair in bash:bash perl:perl git:git curl:curl gcc:gcc-core g++:gcc-g++ make:make unzip:unzip wget:wget zip:zip; do
    exe="${pair%%:*}"; package="${pair#*:}"
    flag=--version; [[ "$exe" == unzip ]] && flag=-v
    if [[ ! -x "$bin/$exe" ]] || ! "$bin/$exe" "$flag" >/dev/null 2>&1; then
      printf '%s\n' "$package"
    fi
  done
  if [[ ! -x "$bin/python3" ]] || ! "$bin/python3" - <<'PY' >/dev/null 2>&1
import sys
assert sys.version_info >= (3, 10)
PY
  then
    printf '%s\n' python3 python312 python312-devel python312-pip
  else
    "$bin/python3" -c 'import pip' >/dev/null 2>&1 || printf '%s\n' python312-pip
    "$bin/python3" - <<'PY' >/dev/null 2>&1 || printf '%s\n' python312-devel
import os, sysconfig
assert os.path.isfile(os.path.join(sysconfig.get_path('include'), 'Python.h'))
PY
  fi
  if [[ -n "$cert" ]]; then
    [[ -s "$cert" ]] || printf '%s\n' ca-certificates
  else
    [[ -s /etc/pki/tls/certs/ca-bundle.crt || -s /usr/ssl/certs/ca-bundle.crt ]] || printf '%s\n' ca-certificates
  fi
}
