#!/usr/bin/env python3
"""Native Python counterpart of MCPDeps/test_sas_oda_debug_macro_guard.pl; no Perl runtime required."""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from MCP4SAS_Use_Python.homepage_checks import checks_main

if __name__=='__main__':
    raise SystemExit(checks_main('macro_guard'))
