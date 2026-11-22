"""Exercise actual embedded/native metadata functions and count SAS calls."""
import ast
from pathlib import Path
import re
import unittest

ROOT=Path(__file__).resolve().parents[1]

class MetadataTests(unittest.TestCase):
    def test_one_roundtrip_and_no_stale_macro_reads(self):
        inline=(ROOT/'MCPDeps/SAS_ODA_Runner.pm').read_text().split("<<'END_PYTHON';",1)[1].split('\nEND_PYTHON',1)[0]
        sources=[inline,(ROOT/'MCPDeps/sas_oda_session_server.py').read_text(),
                 (ROOT/'MCP4SAS_Use_Python/backend/session_backend.py').read_text()]
        for index,source in enumerate(sources):
            with self.subTest(backend=index):
                node=next(n for n in ast.parse(source).body if isinstance(n,ast.FunctionDef) and n.name=='run_fileinfo')
                scope=dict(resolve_remote_path=lambda path,sess:path,_coerce_epoch=lambda value:None)
                exec(compile(ast.Module(body=[node],type_ignores=[]),'metadata','exec'),scope)
                class Session:
                    def __init__(self,exists='1',size='0'):
                        self.calls=[]
                        self.log='\n'.join(['MCP4SAS_META_EXISTS='+exists,'MCP4SAS_META_SIZE='+size,
                                             'MCP4SAS_META_CREATED=','MCP4SAS_META_MODIFIED='])
                    def submit(self,code,**kwargs):
                        self.calls.append((code,kwargs));return {'LOG':self.log}
                    def symget(self,name): raise AssertionError('extra SAS roundtrip')
                sess=Session();info=scope['run_fileinfo'](sess,'/safe/empty.txt')
                self.assertTrue(info['exists']);self.assertEqual(info['size'],0)
                self.assertEqual(len(sess.calls),1);self.assertEqual(sess.calls[0][1],{'results':'text'})
                self.assertIsNone(info['created']);self.assertEqual(info['path'],'/safe/empty.txt')
                missing=Session('0','');info=scope['run_fileinfo'](missing,'/safe/missing')
                self.assertFalse(info['exists']);self.assertIsNone(info['size'])
                for log in ['ERROR: metadata failed','MCP4SAS_META_EXISTS=1']:
                    bad=Session();bad.log=log
                    with self.assertRaises(RuntimeError):scope['run_fileinfo'](bad,'/safe/file')

if __name__=='__main__':unittest.main()
