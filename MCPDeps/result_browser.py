"""Open saved SAS HTML using OS launch services, without requiring Firefox.

This standard-library-only helper is shared by the Perl and Python CLIs.
An accepted OS launch request is not proof that a browser window was displayed.
"""
import argparse
import base64
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import webbrowser


def auto_open_enabled(value=None):
    value = os.environ.get('OPEN_RESULT', '1') if value is None else value
    return str(value).strip().lower() not in ('0', 'false', 'no', 'off')


def _find(name, system_path=None):
    found = shutil.which(name)
    return found or (system_path if system_path and Path(system_path).is_file() else None)


def _checked(command, env=None):
    if env is None and os.environ.get('OPEN_RESULT_DISPLAY'):
        env = dict(os.environ, DISPLAY=os.environ['OPEN_RESULT_DISPLAY'])
        if os.environ.get('OPEN_RESULT_XAUTHORITY'):
            env['XAUTHORITY'] = os.environ['OPEN_RESULT_XAUTHORITY']
    result = subprocess.run(command, stdin=subprocess.DEVNULL, stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE, text=True, errors='replace',
                            timeout=15, check=False, env=env)
    if result.returncode:
        raise OSError(f'{Path(command[0]).name} exited {result.returncode}: '
                      f'{result.stderr.strip()[:500]}')
    return result.stdout.strip()


def open_result_html(path):
    path = Path(path).resolve()
    if not path.is_file():
        print(f'WARNING: HTML file does not exist: {path}', file=sys.stderr)
        return False
    failures = []

    def attempt(command, env=None):
        try:
            _checked(command, env)
            print(f'Requested default-browser open: {path}')
            return True
        except (OSError, subprocess.TimeoutExpired) as exc:
            failures.append(str(exc))
            return False

    override = os.environ.get('OPEN_RESULT_BROWSER')
    if override:
        executable = shutil.which(override)
        if executable:
            try:
                process = subprocess.Popen([executable, path.as_uri()], stdin=subprocess.DEVNULL,
                                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                                           start_new_session=True)
                try:
                    status = process.wait(timeout=0.25)
                except subprocess.TimeoutExpired:
                    status = 0  # Browser remains running, as expected.
                if status == 0:
                    print(f'Requested browser open: {path}')
                    return True
                failures.append(f'OPEN_RESULT_BROWSER exited {status}')
            except OSError as exc:
                failures.append(str(exc))
        else:
            failures.append('OPEN_RESULT_BROWSER executable was not found')

    if sys.platform.startswith('cygwin'):
        cygstart = _find('cygstart', '/usr/bin/cygstart.exe')
        if cygstart and attempt([cygstart, str(path)]):
            return True
        # Minimal Cygwin installs need not contain cygutils/cygstart. Windows
        # PowerShell can request the normal file association after conversion.
        powershell = _find('powershell.exe', '/cygdrive/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe')
        cygpath = _find('cygpath', '/usr/bin/cygpath.exe')
        if powershell and cygpath:
            try:
                native = _checked([cygpath, '-aw', str(path)])
                if not native:
                    raise OSError('cygpath returned an empty Windows path')
                script = "$ErrorActionPreference='Stop'; Start-Process -FilePath $env:MCP4SAS_RESULT_FILE -ErrorAction Stop | Out-Null"
                encoded = base64.b64encode(script.encode('utf-16le')).decode('ascii')
                if attempt([powershell, '-NoProfile', '-NonInteractive', '-EncodedCommand', encoded],
                           dict(os.environ, MCP4SAS_RESULT_FILE=native)):
                    return True
            except (OSError, subprocess.TimeoutExpired) as exc:
                failures.append(str(exc))
        # Unix file:///cygdrive/... URLs are invalid to native Windows browsers.
        # Do not report a misleading success through that fallback.
    elif sys.platform == 'win32':
        try:
            os.startfile(str(path))
            print(f'Requested default-browser open: {path}')
            return True
        except (AttributeError, OSError) as exc:
            failures.append(str(exc))
    elif sys.platform == 'darwin':
        opener = _find('open', '/usr/bin/open')
        if opener and attempt([opener, str(path)]):
            return True
    elif os.environ.get('DISPLAY') or os.environ.get('WAYLAND_DISPLAY') or os.environ.get('OPEN_RESULT_DISPLAY'):
        opener = _find('xdg-open')
        if opener and attempt([opener, str(path)]):
            return True

    graphical = (sys.platform in ('win32', 'darwin') or os.environ.get('DISPLAY')
                 or os.environ.get('WAYLAND_DISPLAY') or os.environ.get('OPEN_RESULT_DISPLAY'))
    if not sys.platform.startswith('cygwin') and graphical:
        try:
            if webbrowser.open(path.as_uri()):
                print(f'Requested browser open: {path}')
                return True
        except (OSError, webbrowser.Error) as exc:
            failures.append(str(exc))
    detail = '; '.join(failures)
    print(f'WARNING: Could not auto-open {path} with the system default browser. '
          'Open this saved HTML file manually, or set a default application for .html files. '
          'A local interactive desktop is required; SSH, containers and background agents '
          'may not display a window. Firefox is not required. '
          'Set OPEN_RESULT=0 to suppress this attempt.' + (' ' + detail if detail else ''),
          file=sys.stderr)
    return False


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('html', nargs='?', help='Saved HTML file to open.')
    parser.add_argument('--check', action='store_true', help='Report available launchers without opening a browser or connecting to SAS.')
    args = parser.parse_args(argv)
    if args.check:
        print(json.dumps(dict(platform=sys.platform, auto_open_enabled=auto_open_enabled(),
                              launchers={name: shutil.which(name) for name in ('cygstart', 'cygpath', 'powershell.exe', 'open', 'xdg-open')},
                              native_startfile=hasattr(os, 'startfile'), firefox_required=False), indent=2))
        return 0
    if not args.html:
        parser.error('Supply an HTML file or --check')
    return 0 if open_result_html(args.html) else 1


if __name__ == '__main__':
    raise SystemExit(main())
