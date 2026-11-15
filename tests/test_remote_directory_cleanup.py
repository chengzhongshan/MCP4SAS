"""Python semantic counterpart of test_remote_directory_cleanup.pl; reuses focused native checks."""
import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from MCP4SAS_Use_Python.counterpart_checks import run_selected
if __name__=="__main__":raise SystemExit(run_selected(['MCP4SAS_Use_Python.tests.test_runtime.UtilityTests.test_remote_cleanup_guards_and_preview', 'MCP4SAS_Use_Python.tests.test_perl_parity.PerlParityTests.test_guarded_sas_cleanup_matches_original']))
