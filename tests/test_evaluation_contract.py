"""Python counterpart of test_evaluation_contract.pl."""
import sys
from pathlib import Path
import unittest
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from MCP4SAS_Use_Python.evaluation import checked_contract,contract_fingerprint


class EvaluationContractTests(unittest.TestCase):
    def test_changed_oracles_do_not_inherit_evidence(self):
        case=dict(id='J3501',expected_failure=0,expected=3,tolerance='1e-6',diagnostic=None)
        fingerprint=contract_fingerprint(case)
        self.assertTrue(checked_contract(case,fingerprint))
        self.assertFalse(checked_contract(case,None))
        for key,value in [('expected',4),('tolerance','1e-3'),('diagnostic','different error'),('expected_failure',1)]:
            with self.subTest(key=key),self.assertRaisesRegex(ValueError,'contract mismatch J3501'):
                checked_contract(dict(case,**{key:value}),fingerprint)
        for invalid in ('','not-a-hash'):
            with self.assertRaises(ValueError):checked_contract(case,invalid)
        self.assertEqual(contract_fingerprint(dict(case,diagnostic='')),fingerprint)
        self.assertEqual(contract_fingerprint(dict(case,expected_failure=None)),fingerprint)
        self.assertEqual(contract_fingerprint(dict(case,evidence={'book_title':'another title'})),fingerprint)
        negative=dict(id='J3951',expected_failure=1,diagnostic='more than one row',expected=None)
        with self.assertRaises(ValueError):checked_contract(dict(negative,diagnostic='.*'),contract_fingerprint(negative))


if __name__=='__main__':unittest.main()
