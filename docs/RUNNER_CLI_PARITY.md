# Perl/Python runner parameters and HTML opening

Reviewed 21 November 2026. Both entry points run SAS through SASPy:

```bash
perl run_sas_codes_or_files_in_ODA.pl --help
python run_sas_codes_or_files_in_ODA.py --help
```

The Python parser accepts every public option explicitly declared in the Perl
runner's `GetOptions` block: **39 option groups, 54 names and aliases** after
adding the shared `--open-html` control. Internal worker arguments are excluded.
Generated negative forms such as `--no-open-html` are tested separately from
this count. This is parser coverage, not a claim that all runtime behavior is
identical. Python help now includes executable examples and browser diagnostics.

## Corresponding options

| Task | Options available in both runners |
|---|---|
| Submit a program | `--code`, `--codes`, `-c`; `--file`, `-f`; `--macro-dir`, `-m` |
| Keep/reuse a session | `--persistent`, `--no-persistent`, `--session-id`, `-s` |
| Save results | `--output-prefix`, `-p`; `--keep-intermediate-files`; `--cleanup-empty-output-dir 0\|1` |
| Open saved HTML | `--open-html`, `--no-open-html`; suppress HTML saving with `--no-html-info` or `--no-html_info` |
| Upload/download | Repeatable `--upload-file`, `-u`; `--download-file`, `-d`; paired `--download-local-path`; `--archive-transfers`; `--skip-upload-if-same` and their negative forms |
| Inspect remote files | `--dir4listing`, `-l`; repeatable `--file-info` |
| Delete remote files/directories | `--delete-file`, `-k`; `--delete-file-rgx`; `--delete-directory-rgx`; `--delete-directory-dry-run`; `--delete-dir` |
| Select a SAS target | `--saspy-cfgname`, `--saspy-cfgfile`, `--dir4local_sas_home` |
| Configure/check ODA access | `--prompt-sas-oda-auth`, `--sas-oda-account`, `--sas-oda-password`, `--skip-sas-oda-auth-bootstrap`; `--check-sas-oda-login-only` / `--check-saspy-connection-only` |
| Inspect progress/logs | `--classify-sas-log`, `--monitor-status-file`, `--monitor-interval-seconds` |
| Limit execution | `--run-timeout-seconds`, `--run-timeout-grace-seconds`, `--no-run-timeout` |
| Close a session | `--kill-saspy-sessions`, `--kill-sas-oda-sessions`, `--kill-saspy-session-server` |
| Offline inspection/help | `--dry-run`, `--help`, `-h` |

Use the private credential prompt rather than entering passwords in shell
history. Quote remote paths such as `'~/Macros'` so the local shell does not
expand the remote home directory. Repeated download destinations pair with
remote files by position.

## Intentional differences to consider when translating a command

* **Code strings:** Perl expands literal `\n`, `\r\n`, `\r`, and `\t` in direct
  `--code` strings. Python preserves them, protecting Windows paths and regular
  expressions. Use Python's `--decode-code-escapes` explicitly when expansion is
  intended. Both accept `--code -` for literal multiline stdin and `--file` for
  saved programs. Do not decode files or stdin.
* **Output/preflight:** Python adds `--json` and `--submission-preflight` /
  `--no-submission-preflight`. Its dry-run reports a dependency plan as JSON;
  Perl's CLI dry-run prints session settings. Output filenames and status/log
  formats differ. Both preserve the SAS log and output artifacts. Normal Python
  submissions now use the same compact terminal completion messages as Perl:
  HTML path, retained SAS-log path, and completion/no-HTML status. Python does
  not dump the complete SAS source/log into the terminal by default. Use
  `--print-sas-log` to explicitly print the retained report, or `--json` for
  structured output. Directory listings are visible in the terminal and saved
  text log as well as `result.json`.
* **Timeout scope:** the Perl wrapper has an overall watchdog. Python bounds
  individual backend operations, so startup, several transfers and shutdown can
  add elapsed time beyond one operation's limit. The same option name does not
  imply an identical end-to-end deadline.
* **Session cleanup:** Python's kill option targets its selected runtime/session.
  Perl's historical option searches for broader local SASPy/ODA wrapper jobs.
  It must not be assumed to mean the same process scope.
* **Macro loading:** both inspect submitted local macro dependencies. The Python
  orchestration defaults global `SAS_ODA_AUTOLOAD_MACROS` to `0`; the Perl engine
  has a default-on global bootstrap subject to its submission-specific guards.
  Set the variable explicitly for a controlled comparison. The live comparison
  below used `SAS_ODA_AUTOLOAD_MACROS=0` in both runs.
* **Regex engines:** Python's CLI file-name deletion filter uses Python `re`;
  Perl's CLI uses Perl regex matching and its legacy file-regex operation can
  also remove matching child directories recursively. Python's file-regex filter
  skips directories; use its explicit guarded `--delete-directory-rgx` operation
  for directories. Directory cleanup is SAS code with SAS PRX syntax. Review
  both the engine and deletion scope before translating a cleanup command.

No public option was removed. Uncommon Getopt::Long abbreviations and implicit
single-dash long-option spellings are not promised by Python's strict parser;
use the documented long names or short aliases above.

## Browser investigation and fix

Firefox is **not a prerequisite**. Native Windows uses the configured `.html`
file association; Cygwin can use `cygstart`; macOS has its native `open` service.
Linux graphical sessions can use `xdg-open`. If the associated application is an
editor, choose a browser as the default application for `.html` files.

The former Perl function forked a launcher, discarded its errors and immediately
reported success. It could therefore claim a launch even when `open`,
`cygstart`, or the Python fallback failed. Its fallback also did not communicate
the boolean result of `webbrowser.open`. The previous Python Cygwin launcher
likewise treated process creation as success without checking the launcher exit.

Both CLIs now share `MCPDeps/result_browser.py`, a standard-library-only helper:

1. Resolve the saved HTML path and confirm the file exists.
2. Use the native platform launcher. Check command exits and capture errors;
   launcher subprocesses have a 15-second limit.
3. In Cygwin, if `cygstart` is missing or fails, convert the path with `cygpath`
   and use Windows PowerShell `Start-Process`. The filename is passed through an
   environment variable, not inserted into PowerShell source code.
4. Preserve the saved HTML and warn on failure. A display problem does not turn
   a successful SAS calculation into a failed calculation.

There is no Firefox-specific detection or requirement. A minimal Cygwin runtime
does not need another package upgrade merely to try the Windows fallback.
Headless Linux avoids falling into an interactive text browser that could block
the runner. `OPEN_RESULT_BROWSER` still supports an explicit browser executable.

### Open, save without opening, or diagnose

```bash
perl run_sas_codes_or_files_in_ODA.pl --code 'proc print data=sashelp.class;run;' --open-html
python run_sas_codes_or_files_in_ODA.py --code 'proc print data=sashelp.class;run;' --open-html

# Save the HTML, without requesting a browser window:
perl run_sas_codes_or_files_in_ODA.pl --file analysis.sas --no-open-html
python run_sas_codes_or_files_in_ODA.py --file analysis.sas --no-open-html

# No SAS login and no window opened:
python MCPDeps/result_browser.py --check

# Test opening a previously generated result, without rerunning SAS:
python MCPDeps/result_browser.py /path/to/output.html
```

Without an explicit open flag, `OPEN_RESULT=0`, `false`, `no`, or `off` disables
opening. `--open-html` and `--no-open-html` override this setting. Python `--json`
stays noninteractive even with `--open-html`. `--no-html-info` prevents HTML
saving; use `--no-open-html` when the goal is to keep a file for later viewing.

**Background MCP jobs suppress browser opening by design.** A command run inside
an AI job, SSH connection, remote workspace, container, or service is not
equivalent to the same command in a local interactive terminal. Run the explicit
CLI test in that local terminal to distinguish a launcher failure from expected
background behavior. No browser on a remote server can be assumed to appear on
the user's own desktop.

## Actual validation and limits

The Windows host ran the same `PROC PRINT` plus independent `COUNT(*)` query
through both runners against SAS ODA. Both exited 0, reported **19 rows**, saved
HTML, and received an accepted default-browser launch request. `OPEN_RESULT=0`
was deliberately set so `--open-html` also tested the explicit override.

| Runner | Elapsed time | HTML bytes | Count | Launch request |
|---|---:|---:|---:|---|
| Python | 11.037 s | 36,491 | 19 | Accepted |
| Perl | 13.865 s | 35,205 | 19 | Accepted |

These two runs are functional checks, not a performance benchmark. SASPy can
produce different HTML wrappers without changing the table's row count. The
real Cygwin-to-PowerShell fallback also succeeded with `cygstart` deliberately
hidden from the helper; no Firefox invocation was used.

All 79 Python tests passed, including 15 option/browser tests; those 15 also
passed under real Cygwin Python. Four Perl compatibility checks passed. An initial
sandboxed run could not terminate its own Windows test processes; the full suite
passed when run with the required process permissions. No runner shutdown code
was changed to bypass that environmental restriction.

Regression tests cover all declared public option spellings, help examples,
HTML retention, explicit open/no-open overrides, JSON suppression, native
Windows association, macOS launch failure, Cygwin path conversion, missing
launchers, filename quoting, and headless operation. Both Perl compatibility
entry points remain byte-identical. Machine-readable evidence is in
[runner-cli-browser-20261115.json](validation/runner-cli-browser-20261115.json).

The reported Mac and separate Windows 11 machines were not available for live
inspection. Their exact failure cause remains unconfirmed. macOS launcher
behavior is covered by simulated platform tests and GitHub macOS regression
jobs, not by a visible-browser test on the author's Mac. An OS-accepted request
does not itself prove that a browser window became visible.

References: [Python browser-controller documentation](https://docs.python.org/3/library/webbrowser.html),
[Python Windows file-association API](https://docs.python.org/3/library/os.html#os.startfile),
and [Cygwin's cygutils package containing cygstart](https://cygwin.com/packages/summary/cygutils.html).
