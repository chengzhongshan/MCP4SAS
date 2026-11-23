"""Verify the CLI reports final remote state when operations are combined.

Uses a stateful fake transport, not SAS credentials or a network connection.
The live ODA counterpart is documented in LIVE_ODA_ACCEPTANCE_20261123.md.
"""
import contextlib
import io
import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from MCP4SAS_Use_Python import cli


class CombinedFileOperationsTests(unittest.TestCase):
    def run_cli(self, options, files):
        class Remote:
            def __init__(self, **kwargs):
                self.files = set(files)
                self.events = []

            def __enter__(self):
                return self

            def __exit__(self, *args):
                return False

            def transfer(self, downloads):
                self.events.append('download')
                for item in downloads:
                    if item['remote_path'].removeprefix('~/') not in self.files:
                        raise FileNotFoundError(item['remote_path'])
                return {'downloaded': len(downloads)}

            def delete(self, path, parent):
                name = path.removeprefix('~/')
                self.events.append('delete:' + name)
                self.files.discard(name)
                return {'status': 'ok'}

            def dirlist(self, parent):
                self.events.append('list')
                return sorted(self.files)

            def fileinfo(self, path):
                self.events.append('info:' + path)
                return {'exists': path.removeprefix('~/') in self.files}

        remote = Remote()
        with tempfile.TemporaryDirectory() as tmp:
            with patch('MCP4SAS_Use_Python.runner.Runner', return_value=remote), contextlib.redirect_stdout(io.StringIO()):
                result = cli.main(['--skip-sas-oda-auth-bootstrap', '--no-open-html',
                                   '--output-prefix', tmp, *options])
            outcome = json.loads((Path(tmp) / 'result.json').read_text())
        self.assertEqual(result, 0)
        return outcome, remote.events

    def test_download_then_delete_then_final_listing_and_info(self):
        outcome, events = self.run_cli(
            ['--download-file', '~/remove.txt', '--download-local-path', 'unused.txt',
             '--delete-file', '~/remove.txt', '--dir4listing', '~',
             '--file-info', '~/remove.txt', '--file-info', '~/keep.txt'],
            ['remove.txt', 'keep.txt'])
        self.assertEqual(events, ['download', 'delete:remove.txt', 'list',
                                  'info:~/remove.txt', 'info:~/keep.txt'])
        self.assertEqual(outcome['files'], ['keep.txt'])
        self.assertFalse(outcome['file_info']['~/remove.txt']['exists'])
        self.assertTrue(outcome['file_info']['~/keep.txt']['exists'])

    def test_regex_listing_selects_files_before_final_observation(self):
        outcome, events = self.run_cli(
            ['--delete-file-rgx', r'^owned_.*', '--dir4listing', '~',
             '--file-info', '~/owned_a.txt', '--file-info', '~/keep.txt'],
            ['owned_a.txt', 'owned_folder/', 'keep.txt'])
        self.assertEqual(events, ['list', 'delete:owned_a.txt', 'list',
                                  'info:~/owned_a.txt', 'info:~/keep.txt'])
        self.assertEqual(outcome['files'], ['keep.txt', 'owned_folder/'])
        self.assertEqual(len(outcome['deleted']), 1)
        self.assertFalse(outcome['file_info']['~/owned_a.txt']['exists'])

    def test_inspection_only_does_not_delete(self):
        outcome, events = self.run_cli(
            ['--dir4listing', '~', '--file-info', '~/keep.txt'], ['keep.txt'])
        self.assertEqual(events, ['list', 'info:~/keep.txt'])
        self.assertEqual(outcome['deleted'], [])
        self.assertTrue(outcome['file_info']['~/keep.txt']['exists'])


if __name__ == '__main__':
    unittest.main()
