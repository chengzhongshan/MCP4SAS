"""Regression for local oncoprint's uploaded ~/template.sas input."""
import sys
from pathlib import Path
import unittest
import tempfile
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from MCP4SAS_Use_Python.runner import Runner

class DetectedHomeTests(unittest.TestCase):
    def test_local_detected_home_controls_path_expansion_and_backend_setup(self):
        class Backend:
            def __init__(self,**kwargs):self.local_home=kwargs['local_home'];self.submissions=[]
            def call(self,command,**kwargs):
                if command=='gethome':return {'home':r'C:\Users\reader','local':True}
                if command=='submit':self.submissions.append(kwargs['code']);return {'log':'NOTE: complete','lst':''}
                raise AssertionError(command)
        runner=Runner(backend_factory=Backend)
        with tempfile.TemporaryDirectory() as folder:
            source=Path(folder)/'submitted.sas'
            result=runner.run('filename input "~/template.sas"; /* β */',submitted_path=source)
            self.assertEqual(source.read_bytes(),result['processed_code'].encode('utf-8'))
        self.assertEqual(runner.local_home,'C:/Users/reader')
        self.assertEqual(runner.backend.local_home,'C:/Users/reader')
        self.assertIn('"%superq(PIPELINE_SAS_HOME)/template.sas"',result['processed_code'])
        self.assertEqual(runner.backend.submissions,[result['processed_code']])

    def test_oda_and_older_home_responses_preserve_remote_literals(self):
        for response in [{'home':'/home/reader','local':False},{'home':'/home/reader'}]:
            class Backend:
                def __init__(self,**kwargs):self.local_home=kwargs['local_home']
                def call(self,command,**kwargs):return response
            runner=Runner(backend_factory=Backend)
            self.assertEqual(runner.home(),'/home/reader')
            self.assertIsNone(runner.local_home);self.assertIsNone(runner.backend.local_home)

if __name__=='__main__':unittest.main()
