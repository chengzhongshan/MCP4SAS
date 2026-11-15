#!/usr/bin/env python3
"""Python regression counterpart for unreachable local macro directories."""
from pathlib import Path
import sys
import unittest
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from MCP4SAS_Use_Python.tests.test_runtime import DependencyTests

if __name__=='__main__':
    suite=unittest.TestSuite([DependencyTests('test_unreachable_macro_dir_falls_back_to_process_working_directory')])
    raise SystemExit(0 if unittest.TextTestRunner(verbosity=2).run(suite).wasSuccessful() else 1)
