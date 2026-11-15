"""Regressions discovered using the author's compressed-file import macros."""
from pathlib import Path
import sys
import tempfile
import unittest
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT))
from MCP4SAS_Use_Python.dependencies import Plan,rewrite_paths,macro_calls

class InputPaths(unittest.TestCase):
    def test_assignment_comma_boundaries(self):
        local='E:/fixtures/file.tsv.gz';remote='/home/test/file.tsv.gz'
        code=f'%read(zip={local},obs=max); %read({local});\n/* zip={local} */'
        result=rewrite_paths(code,{local:remote})
        self.assertEqual(result,f'%read(zip={remote},obs=max); %read({remote});\n/* zip={local} */')

    def test_no_substring_rewrites(self):
        self.assertEqual(rewrite_paths('%x(zip=beforefile.tsv,other=file.tsv.more);',{'file.tsv':'/home/file.tsv'}),
                         '%x(zip=beforefile.tsv,other=file.tsv.more);')

    def test_discovery_and_preparation_agree(self):
        with tempfile.TemporaryDirectory() as temp:
            root=Path(temp);file=root/'small.tsv.gz';file.write_bytes(b'fixture')
            code=f'%import_archive(zip={file.as_posix()},obs=10);'
            plan=Plan(code)
            scratch=root/'scratch';scratch.mkdir()
            prepared,uploads=plan.prepare(scratch,'/home/test')
            self.assertIn('zip=/home/test/small.tsv.gz,obs=10',prepared)
            self.assertEqual(len(uploads),1)

    def test_sysexec_is_not_remote_custom_macro(self):
        self.assertEqual(macro_calls('%macro x; %if 0 %then %sysexec echo test; %mend; %custom;'),['custom'])

if __name__=='__main__':unittest.main()
