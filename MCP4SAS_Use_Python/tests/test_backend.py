import os
from pathlib import Path
import tempfile
import unittest
from MCP4SAS_Use_Python.transport import Backend,request

class RealBackendProcessTests(unittest.TestCase):
    def test_python_backend_authentication_and_interpreter_pid(self):
        with tempfile.TemporaryDirectory(prefix='mcp4sas-native-backend-') as temp:
            directory=Path(temp)
            (directory/'saspy.py').write_text('class SASsession: pass\n',encoding='utf-8')
            backend=Backend(timeout=10,env={'PYTHONPATH':temp},state_dir=directory/'state')
            try:
                self.assertGreater(backend.pid,0)
                self.assertEqual(backend.call('ping')['pid'],backend.pid)
                with self.assertRaisesRegex(RuntimeError,'Invalid Python backend token'):
                    request(backend.port,'wrong-token',dict(cmd='ping'),timeout=3)
                self.assertEqual(backend.call('ping')['status'],'ok')
            finally:
                backend.close()
            self.assertFalse(backend.record.exists())

    def test_persistent_backend_reuses_interpreter_then_explicitly_closes(self):
        with tempfile.TemporaryDirectory(prefix='mcp4sas-native-reuse-') as temp:
            directory=Path(temp)
            (directory/'saspy.py').write_text('class SASsession: pass\n',encoding='utf-8')
            first=Backend(session_id='reuse',timeout=10,env={'PYTHONPATH':temp},state_dir=directory/'state')
            pid=first.pid
            first.close()
            self.assertTrue(first.record.exists())
            second=Backend(session_id='reuse',timeout=10,env={'PYTHONPATH':temp},state_dir=directory/'state')
            try:
                self.assertEqual(second.pid,pid)
            finally:
                second.close(force=True)
                first.process.wait(timeout=10)
            self.assertFalse(second.record.exists())

if __name__=='__main__':
    unittest.main()
