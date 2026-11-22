# SASPy discovery failure on Windows/Cygwin ? 22 November 2026

## Reproduction and cause

Both `--code 'proc print data=sashelp.class;run;'` and `--dir4listing '~'`
failed before SAS connection with `ModuleNotFoundError: No module named 'saspy'`.
The bootstrap queried native Windows Python for its site-packages directory.
Perl `chomp` removed LF but left CR. The directory check therefore tested a
path ending in a carriage return and rejected an installed SASPy environment.
The CLI then selected a different executable without SASPy.

## Correction

The package-path probe and interpreter-record readers now remove both CR and
LF; Windows package paths are normalized to forward slashes before filesystem
checks. A failed probe cannot be accepted as a usable package directory.
Discovery also recognizes the installed Python runtime under
`MCP4SAS_Use_Python/.venv`. The two public Perl entry points remain identical.
No SAS login, Java installation, extension version or credentials were changed.

## Regression and execution evidence

`tests/test_saspy_python_discovery.pl` uses a CRLF interpreter record and an
isolated SASPy fixture. Its 15 assertions exercise actual code submission and
file listing through both public Perl entry points, including saved HTML.
The fixture requires no SAS account or scientific data. It tests environment
selection, not a real SAS calculation.

The broader offline selection passed 188 assertions across
12 scripts. Real SAS ODA PRINT and home-listing calls also returned
exit 0 without setting `PIPELINE_PYTHON_BIN` or activating a virtual environment.
PRINT independently confirmed 19 SASHELP.CLASS rows and platform LIN, with its
full SAS log and HTML retained. These live checks used the configured private
ODA runtime; credentials are excluded from tracked reports.

Raw local evidence: `SAS_Output_RandID_python_discovery_20261122/` (ignored).
Earlier attempts used an incorrectly loaded private test configuration and
reported an ODA login error; they are retained separately and are not counted
as successful execution. Browser opening was deliberately disabled for tests.

## User commands

After updating the checkout, run the usual commands from Cygwin:

```bash
./run_sas_codes_or_files_in_ODA.pl --code 'proc print data=sashelp.class;run;'
./run_sas_codes_or_files_in_ODA.pl --dir4listing '~'
```

Use the literal `'~'`, without a backslash inside the quotes. A working SASPy
installation and SAS connection configuration are still required. If no
SASPy environment is installed, use the supplied installer rather than
installing a second unrelated Python environment.

The native Python counterpart, `tests/test_saspy_python_discovery.py`, passed three tests for CRLF records/probes and rejection of missing SASPy. Unavailable mapped-drive entries in the host PATH were excluded only from test subprocess environments; the system PATH was preserved.
