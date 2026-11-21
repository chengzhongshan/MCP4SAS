"""The human CLI should expose the Perl completion contract, not echo SAS source."""
import contextlib
import io
import json
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from MCP4SAS_Use_Python.cli import main
from MCP4SAS_Use_Python import diagnostics


class TerminalOutputTests(unittest.TestCase):
    def run_cli(self, *, html='<html>macro source</html>', log='NOTE: macroparas ran.\n', extra=()):
        class FakeRunner:
            def __init__(self, **kwargs): pass
            def __enter__(self): return self
            def __exit__(self, *args): pass
            def run(self, *args, **kwargs):
                return dict(log=log,lst=html,diagnostics=diagnostics.classify(log))
        with tempfile.TemporaryDirectory() as temp:
            output=(Path(temp)/'result').resolve()
            with patch('MCP4SAS_Use_Python.runner.Runner',FakeRunner),patch.dict(os.environ,{'OPEN_RESULT':'0'}),contextlib.redirect_stdout(io.StringIO()) as terminal:
                status=main(['--code','%macroparas(macrorgx=GTEx);proc print;run;','--skip-sas-oda-auth-bootstrap','--output-prefix',str(output),*extra])
            return status,terminal.getvalue(),(output/'output.html.info.txt').read_text(),str(output)

    def test_macro_terminal_uses_perl_completion_messages_and_keeps_full_report(self):
        status,text,report,output=self.run_cli()
        self.assertEqual(status,0)
        expected=('HTML output saved to: '+str(Path(output)/'output.html')+'\n'
                  'SAS log for debug saved to: '+str(Path(output)/'output.html.info.txt')+'\n\n'
                  'SAS job is completed!\n\n'
                  "if using AI agent gemini CLI, please press the keyboard 'ESCAPE' key to exit and type 'Check results' !\n")
        self.assertEqual(text,expected)
        self.assertIn('HTML output saved to: '+str(Path(output)/'output.html'),text)
        self.assertIn('SAS log for debug saved to: '+str(Path(output)/'output.html.info.txt'),text)
        self.assertIn('SAS job is completed!',text)
        self.assertIn("if using AI agent gemini CLI, please press the keyboard 'ESCAPE' key to exit and type 'Check results' !",text)
        self.assertNotIn('=== SAS Log ===',text)
        self.assertNotIn('NOTE: macroparas ran.',text)
        self.assertIn('NOTE: macroparas ran.',report)

    def test_full_terminal_report_is_explicit(self):
        status,text,report,_=self.run_cli(extra=['--print-sas-log'])
        self.assertEqual(status,0)
        self.assertIn('=== SAS Log ===',text)
        self.assertIn('NOTE: macroparas ran.',text)
        self.assertIn(report,text)

    def test_no_html_program_uses_perl_no_artifact_message(self):
        status,text,_,_=self.run_cli(html='')
        self.assertEqual(status,0)
        self.assertIn('SAS job completed without a downloadable HTML artifact.',text)
        self.assertNotIn('HTML output saved to:',text)

    def test_json_contract_is_unchanged(self):
        status,text,_,_=self.run_cli(extra=['--json'])
        self.assertEqual(status,0)
        result=json.loads(text)
        self.assertEqual(result['log'],'NOTE: macroparas ran.\n')
        self.assertEqual(result['lst'],'<html>macro source</html>')

    def test_sas_program_error_is_visible_without_a_false_completion(self):
        status,text,report,_=self.run_cli(log='ERROR: File WORK.MISSING.DATA does not exist.\n')
        self.assertEqual(status,1)
        self.assertIn('ERROR: File WORK.MISSING.DATA does not exist.',text)
        self.assertNotIn('SAS job is completed!',text)
        self.assertNotIn('HTML output saved to:',text)
        self.assertIn('ERROR: File WORK.MISSING.DATA does not exist.',report)


if __name__=='__main__': unittest.main()
