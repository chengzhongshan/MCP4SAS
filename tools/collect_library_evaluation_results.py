#!/usr/bin/env python3
"""Native Python counterpart of collect_library_evaluation_results.pl."""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from MCP4SAS_Use_Python.collect_evaluations import main
if __name__=='__main__':raise SystemExit(main())
