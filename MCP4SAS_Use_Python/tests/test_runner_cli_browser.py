"""Cross-platform browser-launch regressions; no SAS login or browser required."""
import base64
import contextlib
import io
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
import unittest
from unittest.mock import patch

from MCPDeps import result_browser as browser
from MCP4SAS_Use_Python import cli, diagnostics


class BrowserTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='SAS browser & labels ')
        self.addCleanup(self.temp.cleanup)
        self.html = Path(self.temp.name) / "result 'one' & two.html"
        self.html.write_text('<html><body>SAS output</body></html>', encoding='utf-8')
        env = patch.dict(os.environ)
        env.start()
        self.addCleanup(env.stop)
        os.environ.pop('OPEN_RESULT_BROWSER', None)

    def test_mac_uses_checked_native_open_without_firefox(self):
        with patch.object(browser.sys, 'platform', 'darwin'), patch.object(browser, '_find', return_value='/usr/bin/open'), patch.object(browser, '_checked') as run, patch.object(browser.webbrowser, 'open') as fallback:
            self.assertTrue(browser.open_result_html(self.html))
        run.assert_called_once_with(['/usr/bin/open', str(self.html.resolve())], None)
        fallback.assert_not_called()

    def test_failed_mac_launcher_is_not_reported_as_success(self):
        with patch.object(browser.sys, 'platform', 'darwin'), patch.object(browser, '_find', return_value='/usr/bin/open'), patch.object(browser, '_checked', side_effect=OSError('open exited 1')), patch.object(browser.webbrowser, 'open', return_value=False), contextlib.redirect_stderr(io.StringIO()) as errors, contextlib.redirect_stdout(io.StringIO()) as output:
            self.assertFalse(browser.open_result_html(self.html))
        self.assertIn('open exited 1', errors.getvalue())
        self.assertIn('Firefox is not required', errors.getvalue())
        self.assertNotIn('Requested', output.getvalue())

    def test_native_windows_uses_file_association(self):
        with patch.object(browser.sys, 'platform', 'win32'), patch.object(browser.os, 'startfile', create=True) as start, patch.object(browser.webbrowser, 'open') as fallback:
            self.assertTrue(browser.open_result_html(self.html))
        start.assert_called_once_with(str(self.html.resolve()))
        fallback.assert_not_called()

    def test_cygwin_without_cygstart_uses_converted_path_not_shell_code(self):
        native = "C:\\Users\\Reader & Co\\result 'one'.html"
        def find(name, system_path=None):
            return {'powershell.exe': 'powershell.exe', 'cygpath': '/usr/bin/cygpath'}.get(name)
        with patch.object(browser.sys, 'platform', 'cygwin'), patch.object(browser, '_find', side_effect=find), patch.object(browser, '_checked', side_effect=[native, '']) as run, patch.object(browser.webbrowser, 'open') as fallback:
            self.assertTrue(browser.open_result_html(self.html))
        command, env = run.call_args_list[1].args
        script = base64.b64decode(command[-1]).decode('utf-16le')
        self.assertNotIn(native, script)
        self.assertIn('$env:MCP4SAS_RESULT_FILE', script)
        self.assertEqual(env['MCP4SAS_RESULT_FILE'], native)
        fallback.assert_not_called()

    def test_cygstart_failure_falls_back_instead_of_stopping_after_fork(self):
        def find(name, system_path=None):
            return name
        with patch.object(browser.sys, 'platform', 'cygwin'), patch.object(browser, '_find', side_effect=find), patch.object(browser, '_checked', side_effect=[OSError('cygstart failed'), 'C:\\result.html', '']) as run:
            self.assertTrue(browser.open_result_html(self.html))
        self.assertEqual(run.call_count, 3)

    def test_headless_cygwin_does_not_send_unix_uri_to_windows(self):
        with patch.object(browser.sys, 'platform', 'cygwin'), patch.object(browser, '_find', return_value=None), patch.object(browser.webbrowser, 'open') as fallback, contextlib.redirect_stderr(io.StringIO()) as errors:
            self.assertFalse(browser.open_result_html(self.html))
        fallback.assert_not_called()
        self.assertIn('Open this saved HTML file manually', errors.getvalue())

    def test_linux_default_launcher_precedes_named_browser_fallback(self):
        with patch.dict(os.environ, DISPLAY=':0'), patch.object(browser.sys, 'platform', 'linux'), patch.object(browser, '_find', return_value='/usr/bin/xdg-open'), patch.object(browser, '_checked') as run:
            self.assertTrue(browser.open_result_html(self.html))
        self.assertEqual(run.call_args.args[0][0], '/usr/bin/xdg-open')

    def test_headless_linux_never_blocks_on_a_text_browser(self):
        with patch.dict(os.environ, {}, clear=True), patch.object(browser.sys, 'platform', 'linux'), patch.object(browser, '_checked') as run, patch.object(browser.webbrowser, 'open') as fallback, contextlib.redirect_stderr(io.StringIO()):
            self.assertFalse(browser.open_result_html(self.html))
        run.assert_not_called()
        fallback.assert_not_called()

    def test_checked_launcher_reports_exit_and_limits_wait(self):
        result = subprocess.CompletedProcess(['open'], 1, '', 'No application registered')
        with patch.object(browser.subprocess, 'run', return_value=result) as run:
            with self.assertRaisesRegex(OSError, 'exited 1'):
                browser._checked(['open', str(self.html)])
        self.assertEqual(run.call_args.kwargs['timeout'], 15)
        self.assertNotIn('shell', run.call_args.kwargs)

    def test_missing_file_is_advisory_and_diagnostic_opens_nothing(self):
        with contextlib.redirect_stderr(io.StringIO()):
            self.assertFalse(browser.open_result_html(self.html.with_name('missing.html')))
        with patch.object(browser, 'open_result_html') as opener, contextlib.redirect_stdout(io.StringIO()) as output:
            self.assertEqual(browser.main(['--check']), 0)
        opener.assert_not_called()
        self.assertFalse(json.loads(output.getvalue())['firefox_required'])

    def test_false_environment_values_are_consistent(self):
        for value in ('0', 'false', 'FALSE', 'no', 'off'):
            self.assertFalse(browser.auto_open_enabled(value))
        self.assertTrue(browser.auto_open_enabled('1'))


class OptionParityTests(unittest.TestCase):
    def test_all_public_perl_getoptions_names_are_in_python_parser(self):
        root = Path(__file__).resolve().parents[2]
        source = (root/'run_sas_codes_or_files_in_ODA.pl').read_text(encoding='utf-8')
        block = source.split('GetOptions(', 1)[1].split(') or die', 1)[0]
        available = cli.parser()._option_string_actions
        for spec in re.findall(r"'([^']+)'\s*=>", block):
            if spec.startswith('_internal-'):
                continue
            for name in re.split(r'[=!:]', spec, maxsplit=1)[0].split('|'):
                flag = ('-' if len(name) == 1 else '--') + name
                self.assertIn(flag, available, f'Missing Perl option {flag}')

    def test_both_python_entry_points_print_readable_examples(self):
        help_text = cli.parser().format_help()
        for text in ('Examples (run from your MCP4SAS folder)', '--no-open-html', 'proc print data=sashelp.class', 'Firefox is not required'):
            self.assertIn(text, help_text)
        self.assertTrue(cli.parser().parse_args(['--open-html']).open_html)
        self.assertFalse(cli.parser().parse_args(['--no-open-html']).open_html)

    def test_negative_aliases_and_repeatable_transfer_arguments(self):
        args = cli.parser().parse_args([
            '--no-persistent', '--no-archive-transfers', '--no-skip-upload-if-same',
            '--no-check-saspy-connection-only', '--no-kill-saspy-session-server',
            '--no-prompt-sas-oda-auth', '--no-skip-sas-oda-auth-bootstrap',
            '--no-cleanup-empty-output-dir', '--upload-file', 'a.csv', '-u', 'b.csv',
            '--download-file', '~/a.csv', '-d', '~/b.csv',
            '--download-local-path', './a.csv', '--download-local-path', './b.csv'])
        self.assertFalse(args.persistent)
        self.assertFalse(args.archive_transfers)
        self.assertFalse(args.skip_upload_if_same)
        self.assertEqual(args.upload_file, ['a.csv', 'b.csv'])
        self.assertEqual(args.download_file, ['~/a.csv', '~/b.csv'])
        self.assertEqual(len(args.download_local_path), 2)

    def test_open_control_keeps_saved_html_and_json_stays_noninteractive(self):
        class FakeRunner:
            def __init__(self, **kwargs): pass
            def __enter__(self): return self
            def __exit__(self, *args): pass
            def run(self, *args, **kwargs):
                return dict(log='NOTE: completed', lst='<html>saved</html>', diagnostics=diagnostics.classify(''))
        for option, setting, expected, json_mode in [('--no-open-html', '1', False, False), ('--open-html', '0', True, False), ('--open-html', '0', False, True)]:
            with self.subTest(option=option, json_mode=json_mode), tempfile.TemporaryDirectory() as temp, patch('MCP4SAS_Use_Python.runner.Runner', FakeRunner), patch.object(cli, 'open_result_html') as opener, patch.dict(os.environ, OPEN_RESULT=setting), contextlib.redirect_stdout(io.StringIO()):
                args = ['--code', 'proc print data=sashelp.class;run;', option, '--output-prefix', temp]
                self.assertEqual(cli.main(args + (['--json'] if json_mode else [])), 0)
                self.assertTrue((Path(temp)/'output.html').is_file())
                self.assertEqual(opener.called, expected)
