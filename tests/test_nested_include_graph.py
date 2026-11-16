"""Native Python counterpart of the recursive-include regression, without SAS."""
from pathlib import Path
import sys
import tempfile
import unittest
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT))
from MCP4SAS_Use_Python.dependencies import Plan

class IncludeGraph(unittest.TestCase):
    def test_relative_children_rewritten_in_staged_parent_and_sources_preserved(self):
        with tempfile.TemporaryDirectory(prefix='include graph ') as temporary:
            root=Path(temporary);folder=root/'with spaces';folder.mkdir()
            parent=folder/'parent.sas';child=folder/'child.sas'
            original="%include 'child.sas'; %put PARENT_FINISHED;"
            parent.write_text(original);child.write_text('%let fixture=42;')
            source=f'%include "{parent.as_posix()}"; %include "{parent.as_posix()}";'
            plan=Plan(source);scratch=root/'scratch';scratch.mkdir()
            prepared,uploads=plan.prepare(scratch,'/sas-home')
            self.assertEqual(len(uploads),2)
            contents={Path(v['local_path']).name:Path(v['local_path']).read_text() for v in uploads}
            self.assertIn("%include '/sas-home/child.sas'",contents['parent.sas'])
            self.assertEqual(prepared.count('/sas-home/parent.sas'),2)
            self.assertEqual(parent.read_text(),original)
    def test_duplicate_basenames_and_cycles_are_explicit(self):
        with tempfile.TemporaryDirectory() as temporary:
            root=Path(temporary);(root/'a').mkdir();(root/'b').mkdir()
            for folder in ('a','b'):(root/folder/'same.sas').write_text('%let x=1;')
            with self.assertRaisesRegex(ValueError,'same remote basename'):
                Plan(f'%include "{(root/"a/same.sas").as_posix()}" "{(root/"b/same.sas").as_posix()}";')
            (root/'cycle.sas').write_text("%include 'cycle.sas';")
            with self.assertRaisesRegex(ValueError,'Cyclic'):
                Plan(f'%include "{(root/"cycle.sas").as_posix()}";')

if __name__=='__main__':unittest.main()
