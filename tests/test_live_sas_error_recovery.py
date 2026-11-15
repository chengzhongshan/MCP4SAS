"""Native Python functional counterpart of test_live_sas_error_recovery.pl."""
import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from MCP4SAS_Use_Python.live_regressions import main
if __name__=="__main__":raise SystemExit(main("sas_error_recovery"))
