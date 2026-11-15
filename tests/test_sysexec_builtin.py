"""Native counterpart of test_sysexec_builtin.pl."""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from MCP4SAS_Use_Python.source_analysis import is_builtin_macro_name
assert is_builtin_macro_name('sysexec')
assert is_builtin_macro_name('SySeXeC')
assert not is_builtin_macro_name('my_sysexec')
print('3 builtin checks passed')
