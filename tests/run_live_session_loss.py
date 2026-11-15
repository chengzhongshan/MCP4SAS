#!/usr/bin/env python3
"""Opt-in live regression: end only an isolated test SAS session, then recover.

The interrupted program must fail as infrastructure exit 74 and must not be
replayed. A later explicit submission using that ID obtains a fresh session.
"""
from pathlib import Path
import argparse
import sys
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from MCP4SAS_Use_Python.live_regressions import Harness,ROOT
import secrets


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--live',action='store_true',required=True);p.add_argument('--out',type=Path)
    args=p.parse_args();out=(args.out or ROOT/'MCP4SAS_Use_Python/test-results'/('session_loss_'+secrets.token_hex(5))).resolve()
    h=Harness(out)
    try:
        h.submit('endsas','options notes;data before_loss;value=42;run;endsas;',expected=74)
        h.submit('fresh_session',"options notes;data _null_;if not exist('work.before_loss') then put 'PY_FRESH_SESSION_OK';else put 'ERROR: stale WORK unexpectedly survived';run;",marker='PY_FRESH_SESSION_OK')
    finally:h.close()
    return 0


if __name__=='__main__':raise SystemExit(main())
