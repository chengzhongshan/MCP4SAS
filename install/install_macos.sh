#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(/usr/bin/dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
. "${SCRIPT_DIR}/common.sh"

if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install || true
  die "Install Xcode Command Line Tools, then rerun this script"
fi

if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

if ! command_exists brew; then
  log "Installing Homebrew"
  NONINTERACTIVE=1 /bin/bash -c "$(/usr/bin/curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

log "Installing macOS packages"
brew install curl cpanminus openjdk perl python
homebrew_prefix="$(brew --prefix)"
export PATH="${homebrew_prefix}/opt/perl/bin:${homebrew_prefix}/opt/curl/bin:${homebrew_prefix}/bin:${PATH}"
if [ -x "${homebrew_prefix}/bin/python3" ]; then
  MCP4SAS_PYTHON_BIN="${homebrew_prefix}/bin/python3"
  export MCP4SAS_PYTHON_BIN
fi

PYTHON_BIN="$(find_python)" || die "Python >= 3.8 not found"
create_python_venv "${PYTHON_BIN}"
install_perl_deps
finish_install
