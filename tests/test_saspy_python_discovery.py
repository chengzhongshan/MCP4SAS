"""Native Python counterpart: interpreter records/probe output accept CRLF."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from MCP4SAS_Use_Python import cli


class DiscoveryTests(unittest.TestCase):
    def test_crlf_record_and_space_containing_project(self):
        with tempfile.TemporaryDirectory(prefix='SASPy discovery ') as directory:
            root = Path(directory)
            environment = root / '.venv-pipeline'
            environment.mkdir()
            (environment / '.python-bin').write_bytes((sys.executable + '\r\n').encode())
            with patch.object(cli, '__file__', str(root / 'MCP4SAS_Use_Python' / 'cli.py')), \
                    patch.dict(os.environ, {'PIPELINE_PYTHON_BIN': ''}):
                candidates = list(cli._python_candidates())
            self.assertTrue(candidates)
            self.assertEqual(candidates[0], Path(sys.executable))

    def test_crlf_native_probe_json(self):
        record = dict(version=[3, 13], platform=sys.platform, prefix=sys.prefix, saspy=True)
        result = subprocess.CompletedProcess([], 0, json.dumps(record) + '\r\n', '')
        with patch.object(cli.subprocess, 'run', return_value=result):
            self.assertEqual(cli._probe_python(Path(sys.executable)), record)

    def test_missing_saspy_is_rejected(self):
        record = dict(version=[3, 13], platform=sys.platform, prefix=sys.prefix, saspy=False)
        result = subprocess.CompletedProcess([], 0, json.dumps(record) + '\r\n', '')
        with patch.object(cli.subprocess, 'run', return_value=result):
            self.assertIsNone(cli._probe_python(Path(sys.executable)))


if __name__ == '__main__':
    unittest.main()
