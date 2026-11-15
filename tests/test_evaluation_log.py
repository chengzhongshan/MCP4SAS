"""Python counterpart of test_evaluation_log.pl; uses no Perl interpreter."""
import sys
from pathlib import Path
import unittest
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from MCP4SAS_Use_Python.evaluation import evaluate


class EvaluationLogTests(unittest.TestCase):
    def check(self,log,**extra):
        args=dict(report='=== Submitted SAS Codes or file ===\nROUND2_PASS=R501\n=== SAS Log ===\n'+log+'\n=== Output ===\nROUND2_PASS=R502\n',marker='ROUND2_PASS',expected=['R501'],exit_code=0)
        args.update(extra)
        return evaluate(**args)

    def test_runtime_markers(self):
        self.assertTrue(self.check('ROUND2_PASS=R501')['passes']['R501'])
        for log in ('','12 ROUND2_PASS=R501\nMPRINT(X): ROUND2_PASS=R501',
                    'ROUND2_PASS=R501\nROUND2_PASS=R501','ROUND2_PASS=R501\nROUND2_PASS=R999',
                    'ROUND2_PASS=R501\nROUND2_PASS=malformed','ROUND2_PASS=R501\nERROR: calculation failed',
                    'ROUND2_PASS=R501\n  ERROR 22-322: bad syntax'):
            with self.subTest(log=log):self.assertFalse(self.check(log)['passes']['R501'])
        self.assertFalse(self.check('ROUND2_PASS=R501',exit_code=1)['passes']['R501'])
        self.assertFalse(self.check('',report='ROUND2_PASS=R501')['passes']['R501'])
        self.assertTrue(self.check('ROUND2_PASS=R501\nWARNING: advisory only')['passes']['R501'])
        self.assertTrue(self.check('',report='=== SAS Log ===\r\nROUND2_PASS=R501\r\n=== Output ===\r\n')['passes']['R501'])

    def test_infrastructure_cannot_validate_negative(self):
        for status,code in (({'state':'timeout'},1),({'failure_class':'sas_oda_space_exhaustion'},1),({},73),({},74)):
            with self.subTest(status=status,code=code):
                result=self.check('ERROR: intentional diagnostic',exit_code=code,expected_failure=True,diagnostic='intentional',status=status)
                self.assertFalse(result['passes']['R501']);self.assertTrue(result['infrastructure_failure'])

    def test_status_and_warning_gates(self):
        self.assertFalse(self.check('ROUND2_PASS=R501',require_status=True)['passes']['R501'])
        self.assertTrue(self.check('ROUND2_PASS=R501',require_status=True,status=dict(complete=True,success=True,state='completed'))['passes']['R501'])
        self.assertFalse(self.check('ROUND2_PASS=R501',warning_pattern='required')['passes']['R501'])
        self.assertTrue(self.check('ROUND2_PASS=R501\nWARNING: required',warning_pattern='required')['passes']['R501'])


if __name__=='__main__':unittest.main()
