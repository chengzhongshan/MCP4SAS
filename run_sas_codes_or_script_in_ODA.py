#!/usr/bin/env python3
"""Compatibility alias; identical Python implementation, no Perl subprocess."""
from MCP4SAS_Use_Python.cli import main
if __name__ == '__main__':
    raise SystemExit(main())
