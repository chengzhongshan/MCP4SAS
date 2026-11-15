"""Native Python counterpart of test_library500_round8.pl."""
import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from MCP4SAS_Use_Python.corpus_regression import verify
if __name__=="__main__":raise SystemExit(verify("library500_round8"))
