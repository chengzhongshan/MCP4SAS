"""Python counterpart: selectors and modified executable bodies fail closed."""
import hashlib
import sys
from pathlib import Path
import unittest
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from MCP4SAS_Use_Python.evaluation import select_cases,checked_source,behavior_fingerprint


class CorpusIntegrityTests(unittest.TestCase):
    def setUp(self):
        self.source="/* test */\ndata b3001o; actual=2; put 'ROUND7_PASS=B3001'; run;\n"
        body=self.source.split('\n',1)[1].replace('b3001','bCASE').replace('B3001','bCASE')
        self.a=dict(id='B3001',file='B3001.sas',expected=2,body_sha256=hashlib.sha256(body.encode()).hexdigest())
        self.b=dict(self.a,id='B3002',file='B3002.sas')
        self.manifest=dict(count=2,cases=[self.a,self.b])

    def test_selection(self):
        self.assertEqual(select_cases(self.manifest),[self.a,self.b])
        self.assertEqual(select_cases(self.manifest,' B3002 , B3001 '),[self.a,self.b])
        for bad in ('B3001,B3001','B3009','B3001,',','):
            with self.subTest(bad=bad),self.assertRaises(ValueError):select_cases(self.manifest,bad)
        for bad in (dict(count=2,cases=[self.a,self.a]),dict(count=3,cases=[self.a,self.b]),
                    dict(count=1,cases=[dict(self.a,file='../outside.sas')]),
                    dict(count=1,cases=[dict(self.a,expected_failure=1)]),dict(count=1,cases=[dict(self.a,expected=None)])):
            with self.assertRaises(ValueError):select_cases(bad)

    def test_source(self):
        self.assertEqual(checked_source(self.a,self.source),self.source)
        crlf=self.source.replace('\n','\r\n');self.assertEqual(checked_source(self.a,crlf),crlf)
        for changed in ('',self.source.replace('actual=2','actual=3')):
            with self.assertRaises(ValueError):checked_source(self.a,changed)
        self.assertEqual(behavior_fingerprint(self.a,self.source),behavior_fingerprint(self.a,crlf))


if __name__=='__main__':unittest.main()
