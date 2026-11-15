#!/usr/bin/env python3
"""Native SDK counterpart of check_library_diagnostics_live.pl."""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from MCP4SAS_Use_Python.mcp_regressions import main
if __name__=='__main__':raise SystemExit(main(diagnostics_only=True))
