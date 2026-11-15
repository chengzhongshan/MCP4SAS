"""Native counterpart: preserve quoted/deferred filenames during upload staging."""
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import Mock,patch
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from MCP4SAS_Use_Python.dependencies import Plan,rewrite_paths
from MCP4SAS_Use_Python.source_analysis import include_targets
from MCP4SAS_Use_Python.backend import sas_archive_transfer as archive


class QuotedFilenameTests(unittest.TestCase):
    def test_single_apostrophe_upload_uses_safe_zip_path(self):
        for enabled in (True,False):
            with self.subTest(enabled=enabled),patch.object(archive,'upload_files_archive',return_value=([{'remote_path':"/home/test/author's.sas"}],None)) as upload:
                result=archive.transfer_many(Mock(),dict(uploads=[dict(local_path="author's.sas")],archive_transfers=enabled),'/home/test',Mock())
                upload.assert_called_once()
                self.assertEqual(result['uploads'][0]['remote_path'],"/home/test/author's.sas")

    def test_apostrophe_and_deferred_rewrite(self):
        source="%include 'author''s.sas'; rc=dosubl('%include ''author''''s.sas'';');"
        actual=rewrite_paths(source,{"author's.sas":"/home/user/author's.sas"})
        self.assertIn("%include '/home/user/author''s.sas'",actual)
        self.assertIn("%include ''/home/user/author''''s.sas''",actual)
        self.assertEqual(include_targets(actual),["/home/user/author's.sas"]*2)

    def test_no_repeated_replacement_or_comment_rewrite(self):
        source='%include "file.sas"; /* file.sas */'
        self.assertEqual(rewrite_paths(source,{'file.sas':'/home/file.sas'}),'%include "/home/file.sas"; /* file.sas */')

    def test_plan_preserves_actual_local_filename(self):
        with tempfile.TemporaryDirectory() as temp:
            child=Path(temp)/"author's file.sas";child.write_text('data child;value=27;run;')
            plan=Plan('%include "'+child.as_posix()+'";')
            self.assertEqual(list(plan.files.values()),[child.resolve()])
            scratch=Path(temp)/'scratch';scratch.mkdir()
            code,uploads=plan.prepare(scratch,'/home/test')
            self.assertEqual(include_targets(code),["/home/test/author's file.sas"])
            self.assertEqual(Path(uploads[0]['local_path']).name,child.name)


if __name__=='__main__':unittest.main()
