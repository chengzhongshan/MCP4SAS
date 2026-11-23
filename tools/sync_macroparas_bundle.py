#!/usr/bin/env python3
"""Embed the maintained query utility in the self-contained SAS macro loader.

Run without arguments after editing macroparas_portable.sas; --check verifies
the tracked bundle without changing files. No SAS login or network is needed.
"""
import argparse
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
BEGIN='/* MCP4SAS_BUNDLED_MACROPARAS_BEGIN -- generated; edit examples/sas_macros/macroparas_portable.sas */'
END='/* MCP4SAS_BUNDLED_MACROPARAS_END */'


def expected_bundle(loader,portable):
    if BEGIN in loader:
        before,rest=loader.split(BEGIN,1)
        if END not in rest: raise ValueError('Incomplete portable macroparas bundle marker')
        _,after=rest.split(END,1)
    else:
        before=loader.rstrip()+'\n\n'
        after='\n'
    return before+BEGIN+'\n'+portable.rstrip()+'\n'+END+after


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check',action='store_true')
    args=parser.parse_args()
    path=ROOT/'MCPDeps/importallmacros_ue.sas'
    loader=path.read_text(encoding='utf-8-sig')
    portable=(ROOT/'examples/sas_macros/macroparas_portable.sas').read_text(encoding='utf-8-sig')
    wanted=expected_bundle(loader,portable)
    if args.check:
        if loader!=wanted: parser.exit(1,'Bundled macroparas is stale; run tools/sync_macroparas_bundle.py\n')
        print('PASS: self-contained loader matches the maintained portable macroparas.')
    else:
        path.write_text(wanted,encoding='utf-8',newline='\n')
        print('Updated self-contained importallmacros_ue.sas bundle.')


if __name__=='__main__': main()
