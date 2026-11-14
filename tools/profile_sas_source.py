#!/usr/bin/env python3
import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from MCP4SAS_Use_Python.utilities import profile_main
if __name__=='__main__':
    raise SystemExit(profile_main())
