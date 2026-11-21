"""Directory entries must be visible in the human CLI, as in the Perl runner."""
import contextlib
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from MCP4SAS_Use_Python.cli import main


class DirectoryListingCLITests(unittest.TestCase):
    def invoke(self, files, *, path='~', json_output=False, persistent=False, error=None):
        requested=[]
        class FakeRunner:
            def __init__(self, **kwargs): pass
            def __enter__(self): return self
            def __exit__(self, *args): pass
            def dirlist(self, value):
                requested.append(value)
                if error: raise error
                return files
        with tempfile.TemporaryDirectory() as directory:
            output=Path(directory)/'listing'
            args=['--dir4listing',path,'--output-prefix',str(output),'--skip-sas-oda-auth-bootstrap']
            if persistent: args+=['--persistent','--session-id','listing_test']
            if json_output: args+=['--json']
            with patch('MCP4SAS_Use_Python.runner.Runner',FakeRunner),contextlib.redirect_stdout(io.StringIO()) as terminal:
                status=main(args)
            return (status, terminal.getvalue(), (output/'output.html.info.txt').read_text(),
                    json.loads((output/'result.json').read_text()), requested,
                    json.loads((output/'output.html.run.status.json').read_text()))

    def test_listing_is_visible_in_terminal_and_retained_text_log(self):
        entries=['Macros/','spaced file.sas','result.json']
        status, terminal, log, result, requested, state=self.invoke(entries)
        block='Files in the directory: ~\nMacros/\nspaced file.sas\nresult.json\n'
        self.assertEqual(status,0)
        self.assertIn(block,terminal)
        self.assertIn(block,log)
        self.assertEqual(result['files'],entries)
        self.assertEqual(requested,['~'])
        self.assertTrue(state['success'])

    def test_empty_listing_is_still_reported(self):
        status, terminal, log, result, *_=self.invoke([])
        self.assertEqual(status,0)
        self.assertIn('Files in the directory: ~\n',terminal)
        self.assertIn('Files in the directory: ~\n',log)
        self.assertEqual(result['files'],[])

    def test_persistent_listing_identifies_the_selected_session(self):
        status, terminal, *_=self.invoke(['one.sas'],persistent=True)
        self.assertEqual(status,0)
        self.assertIn("Using persistent SAS ODA session 'listing_test' for remote dir listing...",terminal)

    def test_json_mode_stays_machine_readable(self):
        status, terminal, log, result, *_=self.invoke(['one.sas'],json_output=True)
        self.assertEqual(status,0)
        self.assertEqual(json.loads(terminal)['files'],['one.sas'])
        self.assertIn('Files in the directory: ~\none.sas\n',log)

    def test_remote_paths_are_not_reinterpreted_by_the_formatter(self):
        path=r'\~'
        status, terminal, _, _, requested, _=self.invoke(['one.sas'],path=path)
        self.assertEqual(status,0)
        self.assertEqual(requested,[path])
        self.assertIn('Files in the directory: '+path+'\n',terminal)

    def test_failed_listing_does_not_claim_success(self):
        status, terminal, log, result, _, state=self.invoke([],error=OSError('directory unavailable'))
        self.assertEqual(status,1)
        self.assertNotIn('Files in the directory:',terminal)
        self.assertIn('directory unavailable',terminal)
        self.assertFalse(state['success'])


if __name__=='__main__': unittest.main()
