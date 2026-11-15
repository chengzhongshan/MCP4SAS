#!/usr/bin/env python3
"""Native Python counterpart of run_live_examples.pl; execution requires --live."""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from MCP4SAS_Use_Python.basic_examples import main

if __name__=='__main__':
    raise SystemExit(main())
