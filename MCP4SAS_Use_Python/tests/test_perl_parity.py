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
    def test_shared_analysis_preserves_dependency_and_advisory_views(self):
        for index,(text,expected) in enumerate(zip(self.fixture['cases'],self.fixture['expected']['source'])):
            analysis=source_analysis.analyze_source(text)
            for function in ('include_targets','macro_dependency_view'):
                with self.subTest(case=index,function=function,shared=True):
                    self.assertEqual(getattr(source_analysis,function)(text,analysis),expected[function])
            for function in ('open_code_macro_issues','format_name_issues','fileref_name_issues'):
                with self.subTest(case=index,function=function,shared=True):
                    self.assertEqual(getattr(source_analysis,function)(text,analysis['masked']),expected[function])
    def test_guarded_sas_cleanup_matches_original(self):
        for args,expected in zip(self.fixture['cleanup'],self.fixture['expected']['cleanup']):
            with self.subTest(args=args):
                self.assertEqual(remote_cleanup.build_code(**args),expected)

if __name__=='__main__':
    unittest.main()
