#!/usr/bin/env python3
"""Native Python counterpart of tests/run_live_new_examples_30.pl; no Perl runtime required."""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from MCP4SAS_Use_Python.live_examples import main

if __name__=='__main__':
    raise SystemExit(main())
