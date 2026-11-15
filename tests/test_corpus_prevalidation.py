"""Python semantic counterpart: late generation failure leaves no partial files."""
import sys
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from MCP4SAS_Use_Python import demo_catalogs


class GenerationPrevalidationTests(unittest.TestCase):
    def test_late_reference_failure_preserves_previous_outputs(self):
        cases=demo_catalogs.catalog(1)
        cases[-1]['source_ref']='E:missing-source-fixture.sas'
        with tempfile.TemporaryDirectory() as temp,patch.object(demo_catalogs,'catalog',return_value=cases):
            out=Path(temp)/'output'
            with self.assertRaises(KeyError):demo_catalogs.generate(1,out)
            self.assertFalse(out.exists())
            out.mkdir();prior=out/'catalog.json';prior.write_text('previous valid fixture')
            with self.assertRaises(FileExistsError):demo_catalogs.generate(1,out)
            self.assertEqual(prior.read_text(),'previous valid fixture')
            self.assertEqual([v.name for v in out.iterdir()],['catalog.json'])


if __name__=='__main__':unittest.main()
