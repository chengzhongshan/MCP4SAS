#!/usr/bin/env python3
import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[2]))
from MCP4SAS_Use_Python.poc import run_main
if __name__=='__main__':
    raise SystemExit(run_main())
