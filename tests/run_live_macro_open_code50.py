#!/usr/bin/env python3
"""Native counterpart; --raw explicitly bypasses preflight to test SAS itself."""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'tests'))
from run_live_library500 import main
if __name__=='__main__':
    args=sys.argv[1:]
    if '--raw' not in args:raise SystemExit('Use --live --raw to request actual SAS compiler diagnostics')
    args.remove('--raw')
    raise SystemExit(main(['--round','9','--batch-size','1',*args]))
