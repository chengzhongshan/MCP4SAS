"""Offline regression for the ordinary one-line macroparas command.

Live result/persistence checks: tests/macroparas_autoload_regression.sas, submitted
through either runner with --persistent in an isolated, configured SAS session.
"""
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT))
from MCP4SAS_Use_Python.dependencies import Plan, targeted_loader


class MacroparasAutoload(unittest.TestCase):
    def test_fallback_recompiles_without_legacy_dependencies(self):
        with tempfile.TemporaryDirectory() as folder, patch('pathlib.Path.cwd',return_value=Path(folder)):
            plan=Plan('%macroparas(macrorgx=GTEx);proc print;run;')
            code,uploads=plan.prepare(Path(folder),'C:/sas-home')
        self.assertEqual(uploads,[])
        self.assertIn('%macro macroparas(',code)
        self.assertIn('options _last_=&output_macropara_dsd;',code)
        self.assertNotIn('FileOrDirExist.sas',code)
        self.assertNotIn('stjude',code.casefold())
        self.assertEqual(code.count('%macro macroparas('),1)

    def test_explicit_directory_definition_wins(self):
        with tempfile.TemporaryDirectory() as folder:
            directory=Path(folder)
            macro=directory/'macroparas.sas'
            macro.write_text('%macro macroparas(macrorgx=); %put USER_VERSION; %mend;')
            plan=Plan('%macroparas(macrorgx=GTEx);',macro_dir=directory)
            code,uploads=plan.prepare(directory,'/home/test')
            self.assertIn(macro.resolve(),plan.macros)
            self.assertNotIn('portable macroparas fallback',code)
            self.assertEqual(len(uploads),1)

    def test_explicit_include_definition_wins(self):
        with tempfile.TemporaryDirectory() as folder:
            directory=Path(folder)
            macro=directory/'my_custom_utility.sas'
            macro.write_text('%macro macroparas(macrorgx=); %put USER_VERSION; %mend;')
            plan=Plan('%include "my_custom_utility.sas"; %macroparas(macrorgx=GTEx);',directory/'job.sas')
            code,uploads=plan.prepare(directory,'/home/test')
            self.assertNotIn('portable macroparas fallback',code)
            self.assertEqual(len(uploads),1)

    def test_inline_definition_wins(self):
        plan=Plan('%macro macroparas(macrorgx=); %put USER_VERSION; %mend; %macroparas(macrorgx=GTEx);')
        self.assertEqual(plan.remote_macros,[])

    def test_other_macros_keep_remote_loader(self):
        code=targeted_loader(['MyResearchMacro'])
        self.assertIn('MyResearchMacro.sas',code)
        self.assertNotIn('portable macroparas fallback',code)


if __name__=='__main__': unittest.main(verbosity=2)
