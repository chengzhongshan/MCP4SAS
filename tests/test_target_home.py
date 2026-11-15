"""Every backend must resolve local SAS HOME without borrowing ODA credentials."""
import ast
import os
from pathlib import Path
import re
import unittest
ROOT=Path(__file__).resolve().parents[1]

def functions():
    for name in ('MCPDeps/sas_oda_session_server.py','MCP4SAS_Use_Python/backend/session_backend.py','MCPDeps/SAS_ODA_Runner.pm'):
        source=(ROOT/name).read_text(encoding='utf-8')
        for match in re.finditer(r'^def (session_home|_session_home_value)\(sess\):.*?(?=^def \w)',source,re.M|re.S):
            namespace={'os':os};exec(compile(ast.parse(match[0]),name,'exec'),namespace)
            yield name,namespace[match[1]]

class Session:
    def __init__(self,host,home):
        cfg=type('Config',(),{'iomhost':host,'omruser':'oda.account','authkey':''})()
        self._io=type('IO',(),{'sascfg':cfg})();self.home=home;self.code=[]
    def submit(self,code):self.code.append(code);return {'LOG':'NOTE: test fixture'}
    def symget(self,name):
        if name=='_mg_homepath':return self.home
        raise AssertionError('Local HOME must not be inferred from a SAS username')

class TargetHome(unittest.TestCase):
    def test_windows_linux_and_oda(self):
        seen=0
        for filename,home in functions():
            seen+=1
            for host,path in [('localhost','C:/Users/test'),([],'/srv/users/test')]:
                with self.subTest(source=filename,host=host):
                    s=Session(host,path);self.assertEqual(home(s),path)
                    self.assertIn('USERPROFILE',s.code[0]);self.assertIn("filename('HOME'",s.code[0])
            s=Session(['odaws01-usw2.oda.sas.com'],'unused')
            self.assertEqual(home(s),'/home/oda.account');self.assertEqual(s.code,[])
            s=Session('localhost','unused');s._pipeline_local_home='C:/explicit'
            self.assertEqual(home(s),'C:/explicit');self.assertEqual(s.code,[])
        self.assertEqual(seen,4,'one-shot, embedded persistent, standalone Perl backend, native Python backend')
    def test_missing_home_is_actionable(self):
        for filename,home in functions():
            with self.subTest(source=filename):
                with self.assertRaisesRegex(RuntimeError,'dir4local_sas_home'):home(Session('localhost',''))

if __name__=='__main__':unittest.main()
