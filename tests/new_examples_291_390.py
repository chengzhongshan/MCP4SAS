#!/usr/bin/env python3
"""Original batch 6 SAS catalog; inspect JSON or generate with --out DIR."""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from MCP4SAS_Use_Python.demo_catalogs import catalog,catalog_main

def cases():
    return catalog(6)

if __name__=='__main__':
    raise SystemExit(catalog_main(6))
