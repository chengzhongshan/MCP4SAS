"""Reject incomplete or misleading numerical evidence without connecting to SAS."""
import csv
from pathlib import Path
import tempfile
import unittest
from run_new_workflows import verify

class Evaluation(unittest.TestCase):
    def check(self,rows,expected):
        with tempfile.TemporaryDirectory() as temp:
            file=Path(temp)/'values.csv'
            with file.open('w',newline='') as handle:
                writer=csv.writer(handle);writer.writerow(['metric','value']);writer.writerows(rows)
            return verify(dict(expected=expected,tolerance=1e-8),file)[0]
    def test_complete_values_and_missing(self):
        self.assertEqual(self.check([['a',1.25],['b','.']],{'a':1.25,'b':None}),[])
    def test_absent_missing_metric_is_not_a_pass(self):
        self.assertTrue(self.check([] ,{'a':None}))
    def test_duplicate_key_is_not_a_pass(self):
        self.assertTrue(self.check([['a',1],['a',1]],{'a':1}))
    def test_unexpected_metric_is_not_a_pass(self):
        self.assertTrue(self.check([['a',1],['extra',2]],{'a':1}))
    def test_nan_and_wrong_values_fail(self):
        for value in ('NaN','inf','bad','2'):
            with self.subTest(value=value):self.assertTrue(self.check([['a',value]],{'a':1}))
    def test_absent_file_fails(self):
        with tempfile.TemporaryDirectory() as temp:
            self.assertTrue(verify(dict(expected={'a':1},tolerance=1e-8),Path(temp)/'absent.csv')[0])
    def test_small_nonzero_probability_cannot_be_zero(self):
        self.assertTrue(self.check([['p',0]],{'p':1e-10}))

if __name__=='__main__':unittest.main()
