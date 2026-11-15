"""Python counterpart; checks preflight locally and must never open SAS."""
import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from MCP4SAS_Use_Python.cli import main
ROOT=Path(__file__).resolve().parents[1]


class PreflightTests(unittest.TestCase):
    def test_structural_errors_leave_terminal_evidence_without_sas(self):
        with tempfile.TemporaryDirectory() as temp,patch('MCP4SAS_Use_Python.runner.Runner',side_effect=AssertionError('SAS must not start')):
            for case in ('M4026','M4027','M4034','M4035','M4036'):
                with self.subTest(case=case):
                    out=Path(temp)/case
                    self.assertEqual(main(['--file',str(ROOT/'tests/macro_open_code50'/(case+'.sas')),'--output-prefix',str(out)]),1)
                    status=json.loads((out/'output.html.run.status.json').read_text())
                    self.assertTrue(status['complete']);self.assertFalse(status['success'])
                    self.assertEqual(status['failure_class'],'submission_preflight')
                    self.assertIn('skipped SAS submit',status['message'])

    def test_invalid_include_is_checked_before_sas(self):
        with tempfile.TemporaryDirectory() as temp,patch('MCP4SAS_Use_Python.runner.Runner',side_effect=AssertionError('SAS must not start')):
            child=Path(temp)/'child.sas';child.write_text("data x; value='unfinished;")
            self.assertEqual(main(['--code','%include "'+child.as_posix()+'";','--output-prefix',str(Path(temp)/'out')]),1)


if __name__=='__main__':unittest.main(argv=[sys.argv[0]])
