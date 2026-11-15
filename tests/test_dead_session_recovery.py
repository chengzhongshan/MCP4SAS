"""Regression for raised SASPy termination and source-echo false positives."""
import contextlib
import io
import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import Mock,patch
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from MCP4SAS_Use_Python import cli,diagnostics,transport


class DeadSessionTests(unittest.TestCase):
    def test_raised_termination_retains_infrastructure_status(self):
        class FailedRunner:
            def __init__(self,**kwargs):pass
            def __enter__(self):return self
            def __exit__(self,*args):pass
            def run(self,*args,**kwargs):raise RuntimeError('SASIOConnectionTerminated: No SAS process attached. SAS process has terminated unexpectedly.')
        with tempfile.TemporaryDirectory() as temp,patch('MCP4SAS_Use_Python.runner.Runner',FailedRunner),contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(cli.main(['--code','data x;run;','--output-prefix',temp]),74)
            status=json.loads((Path(temp)/'output.html.run.status.json').read_text())
            self.assertEqual(status['failure_class'],'sas_oda_remote_session_termination')
            self.assertTrue(status['complete']);self.assertFalse(status['success'])

    def test_dead_bridge_is_discarded_without_replay(self):
        backend=object.__new__(transport.Backend)
        backend.session_id='only_this_session';backend.local_home=None
        backend.port=1;backend.token='fixture-token';backend.timeout=1
        backend.timeout_grace_seconds=15;backend.pid=123;backend.process=None;backend.record=Mock()
        with patch.object(transport,'request',side_effect=RuntimeError('No SAS process attached')) as request,patch.object(transport,'stop_owned_pid') as stop:
            with self.assertRaises(RuntimeError):backend.call('submit',code='data x;run;')
            request.assert_called_once();stop.assert_called_once_with(123,0,process=None)
            backend.record.unlink.assert_called_once_with(missing_ok=True)

    def test_source_echo_cannot_fabricate_remote_termination(self):
        for line in ('12 put "No SAS process attached";','MPRINT(X): put "No SAS process attached";','SYMBOLGEN: variable resolves to No SAS process attached'):
            self.assertEqual(diagnostics.classify(line)['exit_code'],0)


if __name__=='__main__':unittest.main()
