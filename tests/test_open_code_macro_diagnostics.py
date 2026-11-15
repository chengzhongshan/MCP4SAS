"""Native Python differential counterpart of test_open_code_macro_diagnostics.pl."""
import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from MCP4SAS_Use_Python.regression_replay import main
if __name__=='__main__':raise SystemExit(main('open_code_macro_diagnostics'))
