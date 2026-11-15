"""Python semantic counterpart of test_helper_entrypoint_parity.pl; reuses focused native checks."""
import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from MCP4SAS_Use_Python.counterpart_checks import run_selected
if __name__=="__main__":raise SystemExit(run_selected(['MCP4SAS_Use_Python.counterpart_checks.AdditionalChecks.test_helper_aliases_are_identical']))
