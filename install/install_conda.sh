#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(/usr/bin/dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
. "${SCRIPT_DIR}/common.sh"

command_exists conda || die "conda not found. Install Miniconda/Anaconda first."

ENV_NAME="${MCP4SAS_CONDA_ENV:-mcp4sas}"
log "Creating/updating conda environment ${ENV_NAME}"
conda create -y -n "${ENV_NAME}" -c conda-forge python=3.11 perl openjdk curl make compilers cpanminus

CONDA_PYTHON="$(conda run -n "${ENV_NAME}" python - <<'PY'
import sys
print(sys.executable)
PY
)"
CONDA_PYTHON="$(printf '%s\n' "${CONDA_PYTHON}" | tail -n 1)"

create_python_venv "${CONDA_PYTHON}"
install_perl_deps
finish_install
