"""An error word in a filename or source echo must not verify a failed SAS job."""
import json
from pathlib import Path
import sys
import tempfile
import unittest
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from MCP4SAS_Use_Python.live_examples import assess


class CatalogFailureTests(unittest.TestCase):
    def test_only_runtime_diagnostics_verify_intentional_errors(self):
        case=dict(id='26',name='abort_cancel',fail=1,diagnostic='abort|cancel')
        with tempfile.TemporaryDirectory() as temp:
            log=Path(temp)/'abort_cancel.info.txt'
            def check(body,code):
                log.write_text('=== Submitted SAS Codes or file ===\n26_abort_cancel.sas\n=== SAS Log ===\n'+body+'\n=== Output ===\n')
                response=dict(isError=True,structuredContent=dict(status='FAILED',exit_code=code,log_path=str(log),diagnostics={}))
                return assess(case,response,1)['passed']
            self.assertFalse(check('',74))
            self.assertFalse(check('',1))
            self.assertFalse(check('12 data _null_;abort cancel;run;',1))
            self.assertFalse(check('ERROR: ABORT CANCEL',74))
            self.assertTrue(check('ERROR: Execution terminated by an ABORT CANCEL statement.',1))


if __name__=='__main__':unittest.main()
