#!/usr/bin/env python3
"""Native Python counterpart of tools/build_covid19_validation_corpus.pl; no Perl runtime required."""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from MCP4SAS_Use_Python.corpus import build_main

if __name__=='__main__':
    raise SystemExit(build_main())
