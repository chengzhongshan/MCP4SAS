"""Offline regressions for empty Java overrides in SASPy configurations."""
import os
from pathlib import Path
import runpy
import shutil
import subprocess
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
TEMPLATE = ROOT / 'install/sascfg_personal.template.py'
PROFILES = ('oda', 'winlocal', 'winiomwin', 'iomlinux', 'iomwin')


class JavaEnvironmentTests(unittest.TestCase):
    def environment(self, **overrides):
        env = {k: v for k, v in os.environ.items() if k not in (
            'SASPY_JAVA_WIN', 'SASPY_JAVA', 'MCP4SAS_JAVA', 'MCP4SAS_SASPY_IOM_DIR')}
        env.update(overrides)
        return env

    def test_template_empty_overrides_and_precedence(self):
        cases = (
            ({'SASPY_JAVA_WIN': '', 'SASPY_JAVA': '', 'MCP4SAS_JAVA': ''}, None),
            ({'SASPY_JAVA_WIN': '', 'SASPY_JAVA': 'selected-java'}, 'selected-java'),
            ({'SASPY_JAVA_WIN': '', 'SASPY_JAVA': '', 'MCP4SAS_JAVA': 'fallback-java'}, 'fallback-java'),
            ({'SASPY_JAVA_WIN': 'windows-java', 'SASPY_JAVA': 'other-java'}, 'windows-java'),
        )
        for overrides, expected in cases:
            with self.subTest(overrides=overrides), patch.dict(os.environ, self.environment(**overrides), clear=True):
                cfg = runpy.run_path(str(TEMPLATE))
                self.assertEqual(cfg['oda']['java'], expected or cfg['_DEFAULT_JAVA'])
                for profile in PROFILES:
                    self.assertTrue(cfg[profile]['java'], profile)

    @unittest.skipUnless(shutil.which('bash'), 'Bash is required by the installer')
    def test_generated_profile_ignores_empty_overrides(self):
        with tempfile.TemporaryDirectory(prefix='mcp4sas-java-') as temp:
            env = self.environment(SASPY_JAVA_WIN='', SASPY_JAVA='', MCP4SAS_JAVA='')
            env['MCP4SAS_TEST_PACKAGE'] = temp
            # Exercise the actual config writer with isolated package/Java discovery.
            script = '''source "$1"
saspy_package_dir() { printf '%s\\n' "$MCP4SAS_TEST_PACKAGE"; }
resolve_unix_java_for_saspy() { printf '%s\\n' '/fixture/bin/java'; }
resolve_windows_java_for_saspy() { printf '%s\\n' '/fixture/bin/java'; }
build_saspy_classpath() { printf '%s\\n' '/fixture/saspyiom.jar'; }
configure_installed_saspy_profile
'''
            result = subprocess.run(['bash', '-c', script, 'test', str(ROOT / 'install/common.sh')],
                                    env=env, text=True, capture_output=True, timeout=15)
            self.assertEqual(result.returncode, 0, result.stderr)
            for overrides, expected in (({}, '/fixture/bin/java'),
                                        ({'SASPY_JAVA': 'selected-java'}, 'selected-java'),
                                        ({'SASPY_JAVA_WIN': 'windows-java', 'SASPY_JAVA': 'selected-java'}, 'windows-java')):
                with self.subTest(overrides=overrides), patch.dict(os.environ, dict(env, **overrides), clear=True):
                    cfg = runpy.run_path(str(Path(temp) / 'sascfg_personal.py'))
                    for profile in PROFILES:
                        self.assertEqual(cfg[profile]['java'], expected, profile)


if __name__ == '__main__':
    unittest.main()
