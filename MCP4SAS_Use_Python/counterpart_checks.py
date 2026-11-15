"""Focused Python semantic checks selected by paired regression entry points.

Selections reuse existing native tests where they already cover the behavior;
they do not run Perl or pretend that Perl-specific internals exist in Python.
"""
import contextlib
import hashlib
import io
from pathlib import Path
import subprocess
import sys
import tempfile
import threading
import unittest
from unittest.mock import patch
from . import source_analysis as sa
from .dependencies import targeted_loader,find_macro
from .runner import guard_printto
from .evaluation import evaluate
from .java_help import instructions,JARS

ROOT=Path(__file__).resolve().parents[1]


class AdditionalChecks(unittest.TestCase):
    def test_case_insensitive_loader(self):
        code=targeted_loader(['mIxEd_name'])
        for text in ("wanted='mIxEd_name.sas'",'do phase=1 to 2','selected=candidate','if matches>1 then do','ERROR: Ambiguous case-insensitive macro filename'):
            self.assertIn(text,code)
        self.assertFalse(sa.analyze_source(code)['findings'])
        self.assertEqual(targeted_loader([]),'')
        with tempfile.TemporaryDirectory() as temp:
            actual=Path(temp)/'Mixed_Name.SAS';actual.write_text('%macro Mixed_Name;%mend;')
            self.assertEqual(find_macro('mixed_name',[Path(temp)]),actual.resolve())
            self.assertIsNone(find_macro('left',[Path(temp)]))

    def test_helper_aliases_are_identical(self):
        self.assertEqual((ROOT/'run_sas_codes_or_files_in_ODA.py').read_bytes(),(ROOT/'run_sas_codes_or_script_in_ODA.py').read_bytes())

    def test_java_help(self):
        for text in ('An exception was thrown during the encryption key exchange','NoClassDefFoundError: com/sas/services/security/encryption/Cipher'):
            help=instructions(text)
            self.assertIn('pid=2494',help);self.assertIn('SAS Profile',help)
            for name in JARS:self.assertIn(name,help)
        for text in ('SSPIAuthException: SEC_E_NO_CREDENTIALS','java.net.ConnectException: refused','SSLHandshakeException'):
            self.assertNotIn('pid=2494',instructions(text))
        self.assertIn('SASPY_JAVA',instructions('FileNotFoundError: /missing/java'))
        self.assertIn('Java bridge',instructions('java.lang.ClassNotFoundException: pyiom.saspy2j'))
        self.assertEqual(instructions('No SAS process attached'),'')

    def test_credential_recovery_help(self):
        help=instructions('ODA credentials are not configured')
        for text in ('--prompt-sas-oda-auth','--check-saspy-connection-only','privately','--saspy-cfgfile'):
            self.assertIn(text,help)
        self.assertNotIn('password=',help)

    def test_printto_guard(self):
        for source in ('data x;value=1;run;',"/* proc printto; */data x;run;","data x;value='proc printto;';run;",'data x;input;datalines;\nproc printto;\n;\nrun;'):
            self.assertEqual(guard_printto(source),source)
        source='proc printto log=ownlog;run;data x;set absent;run;proc printto;run;'
        guarded=guard_printto(source)
        self.assertTrue(guarded.startswith('%let syscc=0;'));self.assertIn(source,guarded)
        self.assertIn('&syscc >= 8',guarded);self.assertIn('%put ERROR:',guarded)

    def test_path_boundary(self):
        with tempfile.TemporaryDirectory(prefix='python path boundary ') as temp:
            source=Path(temp)/'input with spaces.txt';target=Path(temp)/'output with spaces.txt'
            source.write_text('path boundary ok\n')
            proc=subprocess.run([sys.executable,'-c','import pathlib,sys;pathlib.Path(sys.argv[2]).write_bytes(pathlib.Path(sys.argv[1]).read_bytes())',str(source),str(target)],capture_output=True)
            self.assertEqual(proc.returncode,0,proc.stderr);self.assertEqual(target.read_bytes(),source.read_bytes())

    def test_poc_input_boundaries(self):
        for name in ('analysis.sas','a folder/test.sas'):self.assertTrue(sa.is_local_file_candidate(name))
        for text in ('data a;\nrun;','bad\0file','x'*4097):self.assertFalse(sa.is_local_file_candidate(text))
        for name in ('&BOOK_OUT/x.sas','%sysget(HOME)/x.sas'):self.assertTrue(sa.include_target_needs_runtime_resolution(name))
        for name in ('~/Macros/x.sas','Macros/x.sas'):self.assertFalse(sa.include_target_needs_runtime_resolution(name))

    def test_expected_failure_gate(self):
        def check(log,**extra):
            args=dict(report='=== SAS Log ===\n'+log+'\n=== Output ===\n',marker='ROUND4_PASS',expected=['F1951'],expected_failure=True,diagnostic='ambiguous',exit_code=1)
            args.update(extra);return evaluate(**args)['passes']['F1951']
        self.assertTrue(check('ERROR: Ambiguous reference to column x.'))
        for log in ('12 ERROR: Ambiguous reference','WARNING: Ambiguous reference','ERROR: Connection refused','ERROR: ambiguous\nROUND4_PASS=F1951','ERROR: Windows error code: 67 in hx_disk_access'):
            self.assertFalse(check(log))
        for code in (0,73,74,124,143,None):self.assertFalse(check('ERROR: ambiguous',exit_code=code))
        self.assertFalse(check('ERROR: ambiguous',require_status=True))
        self.assertTrue(check('ERROR: ambiguous',require_status=True,status=dict(complete=True,state='failed',success=False)))

    def test_com_thread_ownership(self):
        from .backend import session_backend as backend
        class Session:
            def __init__(self,module):self._io=type('IO',(),{'__module__':module})();self.owner=threading.get_ident();self.called=None
            def submit(self,code):self.called=threading.get_ident();return {'LOG':'NOTE: '+code}
        with patch.object(backend,'SUBMIT_HEARTBEAT_SECONDS',20):
            com=Session('saspy.sasiocom');backend.submit_with_heartbeat(com,'COM probe','test')
            self.assertEqual(com.called,com.owner)
            iom=Session('saspy.sasioiom');backend.submit_with_heartbeat(iom,'IOM probe','test')
            self.assertNotEqual(iom.called,iom.owner)
        with patch.object(backend,'SUBMIT_HEARTBEAT_SECONDS',0):
            stdio=Session('saspy.sasiostdio');backend.submit_with_heartbeat(stdio,'STDIO probe','test')
            self.assertEqual(stdio.called,stdio.owner)


def run_selected(names):
    suite=unittest.defaultTestLoader.loadTestsFromNames(names)
    result=unittest.TextTestRunner(verbosity=2).run(suite)
    return int(not result.wasSuccessful())
