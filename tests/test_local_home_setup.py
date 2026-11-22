"""Execute the actual setup functions without a SAS license or connection."""
import ast
import os
from pathlib import Path
import tempfile
import types
import unittest

ROOT = Path(__file__).resolve().parents[1]

class LocalHomeSetupTests(unittest.TestCase):
    def test_detected_home_is_cached_and_explicit_home_takes_precedence(self):
        inline=(ROOT/'MCPDeps/SAS_ODA_Runner.pm').read_text().split("<<'END_PYTHON';",1)[1].split('\nEND_PYTHON',1)[0]
        for source,name in [(inline,'_session_home_value'),
                            ((ROOT/'MCPDeps/sas_oda_session_server.py').read_text(),'session_home'),
                            ((ROOT/'MCP4SAS_Use_Python/backend/session_backend.py').read_text(),'session_home')]:
            node=next(n for n in ast.parse(source).body if isinstance(n,ast.FunctionDef) and n.name==name)
            scope={};exec(compile(ast.Module(body=[node],type_ignores=[]),name,'exec'),scope)
            class Session:
                _io=types.SimpleNamespace(sascfg=types.SimpleNamespace(iomhost=None))
                def __init__(self):self.calls=[]
                def submit(self,code,**kwargs):
                    self.calls.append(('submit',kwargs));return {'LOG':''}
                def symget(self,name):self.calls.append(('symget',name));return '/tmp/test-home'
            sess=Session();detect=scope[name]
            self.assertEqual(detect(sess),'/tmp/test-home')
            self.assertEqual(detect(sess),'/tmp/test-home')
            self.assertEqual(sess.calls,[('submit',{'results':'text'}),('symget','_mg_homepath')])
            sess._pipeline_local_home='/tmp/explicit-home'
            self.assertEqual(detect(sess),'/tmp/explicit-home')
            self.assertEqual(len(sess.calls),2)

    def test_local_template_store_is_writable_and_oda_is_untouched(self):
        for relative in ('MCPDeps/sas_oda_session_server.py',
                         'MCP4SAS_Use_Python/backend/session_backend.py'):
            with self.subTest(backend=relative):
                tree=ast.parse((ROOT/relative).read_text(encoding='utf-8'))
                node=next(n for n in tree.body if isinstance(n,ast.FunctionDef) and n.name=='configure_local_templates')
                scope={};exec(compile(ast.Module(body=[node],type_ignores=[]),relative,'exec'),scope)
                class Session:
                    def __init__(self,host=None):
                        self._io=types.SimpleNamespace(sascfg=types.SimpleNamespace(iomhost=host))
                        self.calls=[];self.log='NOTE: configured'
                    def submit(self,code,**kwargs):
                        self.calls.append((code,kwargs));return {'LOG':self.log}
                local=Session();setup=scope['configure_local_templates']
                setup(local);setup(local)
                self.assertEqual(local.calls,[('ods path (prepend) work.templat(update);',{'results':'text'})])
                oda=Session(['odaws01-usw2.oda.sas.com']);setup(oda)
                self.assertFalse(oda.calls,'remote template paths must not change')
                bad=Session();bad.log='ERROR: fixture failure'
                with self.assertRaises(RuntimeError): setup(bad)
                self.assertFalse(hasattr(bad,'_pipeline_local_templates_ready'))

    def test_text_setup_cache_and_errors_in_both_backends(self):
        for relative in ('MCPDeps/sas_oda_session_server.py',
                         'MCP4SAS_Use_Python/backend/session_backend.py'):
            with self.subTest(backend=relative), tempfile.TemporaryDirectory() as home:
                tree=ast.parse((ROOT/relative).read_text(encoding='utf-8'))
                node=next(n for n in tree.body if isinstance(n,ast.FunctionDef) and n.name=='configure_local_home')
                scope={'os':os}
                exec(compile(ast.Module(body=[node],type_ignores=[]),relative,'exec'),scope)
                configure=scope['configure_local_home']
                class Session:
                    def __init__(self,host=None):
                        self._io=types.SimpleNamespace(sascfg=types.SimpleNamespace(iomhost=host))
                        self.calls=[]
                        self.log='NOTE: configured'
                    def submit(self,code,**kwargs):
                        self.calls.append((code,kwargs))
                        return {'LOG':self.log}
                sess=Session()
                configure(sess,home)
                self.assertEqual(sess.calls[0][1],{'results':'text'})
                self.assertIn('filename HOME ',sess.calls[0][0])
                self.assertIn('PIPELINE_SAS_HOME',sess.calls[0][0])
                configure(sess,home)
                self.assertEqual(len(sess.calls),1,'unchanged HOME must not submit SAS')
                with tempfile.TemporaryDirectory() as other:
                    configure(sess,other)
                    self.assertEqual(len(sess.calls),2,'explicit HOME changes remain effective')
                with self.assertRaises(ValueError): configure(Session(['remote.example']),home)
                with self.assertRaises(ValueError): configure(Session(),'nonexistent/relative')
                bad=Session(); bad.log='ERROR: fixture setup failure'
                with self.assertRaises(RuntimeError): configure(bad,home)
                self.assertFalse(hasattr(bad,'_pipeline_local_home'),'failed setup must not be cached')

if __name__=='__main__': unittest.main()
