"""Native Python counterpart of the nested dependency/batch preparation checks."""
from pathlib import Path
import sys
import tempfile
import unittest
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT))
from MCP4SAS_Use_Python.dependencies import Plan

class Transitive(unittest.TestCase):
    def test_nested_graph_and_one_manifest(self):
        with tempfile.TemporaryDirectory() as temp:
            root=Path(temp)
            (root/'parent.sas').write_text('%macro parent; %child; %mend;')
            (root/'child.sas').write_text('%macro child; %if 0 %then %sysexec echo test; %mend;')
            file=root/'data.tsv';file.write_text('x\n1\n')
            plan=Plan(f'%parent; %parent; filename inp "{file.as_posix()}";',macro_dir=root)
            scratch=root/'scratch';scratch.mkdir()
            prepared,manifest=plan.prepare(scratch,'/actual/target/home')
            self.assertEqual({Path(u['local_path']).name for u in manifest},{'parent.sas','child.sas','data.tsv'})
            self.assertEqual(plan.remote_macros,[])
            self.assertIn('%include "/actual/target/home/child.sas"',prepared)
            self.assertIn('filename inp "/actual/target/home/data.tsv"',prepared)
    def test_colliding_names_fail(self):
        with tempfile.TemporaryDirectory() as temp:
            root=Path(temp);(root/'a').mkdir();(root/'b').mkdir()
            for p in ('a','b'):(root/p/'same.tsv').write_text(p)
            with self.assertRaisesRegex(ValueError,'same remote basename'):
                Plan(f'filename a "{(root/"a/same.tsv").as_posix()}";filename b "{(root/"b/same.tsv").as_posix()}";')

if __name__=='__main__':unittest.main()
