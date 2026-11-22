"""Large-source transport executes once; small requests remain unchanged."""
import ast
import hashlib
import os
from pathlib import Path
import re
import types
import unittest
from unittest.mock import patch

ROOT=Path(__file__).resolve().parents[1]

class StagedSourceTests(unittest.TestCase):
    def functions(self):
        for relative in ['MCPDeps/sas_oda_session_server.py','MCP4SAS_Use_Python/backend/session_backend.py']:
            node=next(n for n in ast.parse((ROOT/relative).read_text()).body if isinstance(n,ast.FunctionDef) and n.name=='submit_user_code')
            ns={};exec(compile(ast.Module(body=[node],type_ignores=[]),relative,'exec'),ns)
            yield relative,ns['submit_user_code']

    def test_small_code_and_explicit_disable_preserve_submission(self):
        for relative,submit in self.functions():
            with self.subTest(backend=relative):
                class Session:
                    workpath='/saswork/test/'
                    def __init__(self):self.calls=[]
                    def submit(self,code):self.calls.append(code);return {'LOG':'original','LST':'table'}
                for threshold,code in [('262144','proc print;run;'),('0','x'*300000)]:
                    sess=Session()
                    with patch.dict(os.environ,MCP4SAS_STAGE_SOURCE_BYTES=threshold):res=submit(sess,code)
                    self.assertEqual(sess.calls,[code]);self.assertEqual(res,{'LOG':'original','LST':'table'})

    def test_local_source_is_exact_and_temporary(self):
        for relative,submit in self.functions():
            with self.subTest(backend=relative):
                code='/* UTF-8: β */\ndata a; x=1;run;\n'+'/*macro library*/\n'*2200
                class Session:
                    workpath='C:/SAS/work/'
                    _io=types.SimpleNamespace(sascfg=types.SimpleNamespace(iomhost=None,ssh=None))
                    def __init__(self):self.calls=[]
                    def submit(self,stub):
                        self.calls.append(stub)
                        self.path=Path(re.search(r"filename \w+ '([^']+)' encoding",stub)[1])
                        self.assert_bytes=self.path.read_bytes()
                        return {'LOG':'NOTE: DATA created WORK.A','LST':'html'}
                    def upload(self,*args,**kwargs):raise AssertionError('local source should not transfer through SASPy')
                sess=Session();result=submit(sess,code)
                self.assertEqual(sess.assert_bytes,code.encode('utf-8'))
                self.assertEqual(len(sess.calls),1);self.assertLess(len(sess.calls[0]),1500)
                self.assertIn('%include ',sess.calls[0]);self.assertIn('abort cancel',sess.calls[0])
                self.assertIn(str(len(code.encode('utf-8'))),sess.calls[0])
                self.assertIn(hashlib.sha256(code.encode('utf-8')).hexdigest(),result['LOG'])
                self.assertEqual(result['LST'],'html');self.assertFalse(sess.path.exists())

    def test_remote_source_upload_and_failure_never_resubmit(self):
        for relative,submit in self.functions():
            with self.subTest(backend=relative):
                class Session:
                    workpath='/saswork/test/'
                    _io=types.SimpleNamespace(sascfg=types.SimpleNamespace(iomhost=['oda.example']))
                    def __init__(self,ok=True):self.ok=ok;self.calls=[];self.uploads=[]
                    def upload(self,source,target,overwrite):
                        self.uploads.append((Path(source).read_bytes(),target,overwrite))
                        return {'Success':self.ok}
                    def submit(self,stub):self.calls.append(stub);return {'LOG':'NOTE: complete','LST':''}
                code='x'*300000;sess=Session();submit(sess,code)
                self.assertEqual(len(sess.uploads),1);self.assertEqual(sess.uploads[0][0],code.encode())
                self.assertTrue(sess.uploads[0][1].startswith('/saswork/test/mcp4sas_source_'))
                self.assertEqual(len(sess.calls),1);self.assertIn('fdelete(',sess.calls[0])
                failed=Session(False)
                with self.assertRaises(IOError):submit(failed,code)
                self.assertFalse(failed.calls)

if __name__=='__main__':unittest.main()
