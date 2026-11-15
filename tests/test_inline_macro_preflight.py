"""Native Python differential counterpart of test_inline_macro_preflight.pl."""
import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from MCP4SAS_Use_Python.regression_replay import main
if __name__=='__main__':raise SystemExit(main('inline_macro_preflight'))
