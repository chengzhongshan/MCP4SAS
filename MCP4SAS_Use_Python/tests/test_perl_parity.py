import json
from pathlib import Path
import unittest
from MCP4SAS_Use_Python import source_analysis,diagnostics,remote_cleanup

class PerlParityTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.fixture=json.loads((Path(__file__).parent/'fixtures/perl_reference.json').read_text(encoding='utf-8'))
    def test_source_contexts_match_original_perl(self):
        for index,(source,expected) in enumerate(zip(self.fixture['cases'],self.fixture['expected']['source'])):
            for function in self.fixture['functions']:
                with self.subTest(case=index,function=function):
                    self.assertEqual(getattr(source_analysis,function)(source),expected[function])
    def test_diagnostics_match_original_perl(self):
        for text,expected in zip(self.fixture['logs'],self.fixture['expected']['logs']):
            with self.subTest(log=text):
                self.assertEqual(diagnostics.summarize(text),expected)
    def test_guarded_sas_cleanup_matches_original(self):
        for args,expected in zip(self.fixture['cleanup'],self.fixture['expected']['cleanup']):
            with self.subTest(args=args):
                self.assertEqual(remote_cleanup.build_code(**args),expected)

if __name__=='__main__':
    unittest.main()
