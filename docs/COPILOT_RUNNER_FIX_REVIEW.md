# Review of the author's local runner fixes

The author requested review of Copilot's edits in a separate Windows test
installation, followed by integration into the maintained MCP4SAS repository.
The comparison baseline was `b7e3f7e63ebbaa09dd4fb747b19742a614e41a85`.
Sixteen candidate files were reviewed. The original test installation was read
without being modified; its source hashes are retained in the manifest.

## Accepted changes and resulting behavior

| Area | Reviewed behavior |
|---|---|
| Python environment | The direct CLI can select an already installed compatible project environment when its active Python lacks SASPy. It does not install packages or guess a different SAS target. Help, dry runs and log classification remain offline. |
| HTML output | Normal text reports retain the SAS log and link to a separate HTML file instead of dumping HTML markup into the terminal. Structured JSON remains an explicit option. |
| Browser opening | Interactive CLI results open by default; `OPEN_RESULT=0`/`false` disables this. MCP workers and JSON calls suppress opening. Browser-launch failure is an advisory and does not change a successful SAS result into a failed job. |
| Macro directory | An explicitly supplied missing/unreadable local macro directory falls back to the process working directory, with a recorded warning, in both runtimes. |
| Windows error 67 | Both runtimes identify an actual SAS runtime network-path error, retain its nonzero result and explain what to check on the SAS host. The expected-error evaluator does not mistake it for a successful intentional program-error test. |
| CLI usability | No-argument help, descriptive option text, legacy cleanup 0/1 forms and authentication-skip behavior are supported. Empty explicit submissions and negative timeouts remain errors. |
| Timeout grace | The Python CLI forwards its configured grace period to timeout termination. Normal shutdown does not acquire an extra 15-second delay. Timeout recovery does not replay the failed submission. |

## Changes corrected during review

**Windows interpreter handoff required a real process test.** The candidate used
`os.execv` to relaunch Python. A live Windows check showed SAS text containing
spaces being split into separate command-line arguments. The mocked test had
passed. Windows now launches the selected interpreter with a subprocess argument
list, preserving quoting and the actual exit status. Unix retains `execv`. A
cross-platform subprocess regression now tests the handoff with spaces, quotes
and a Windows path without requiring a SAS account.

**Literal escape conversion is opt-in.** Unconditionally converting `\n` and
`\t` could damage `C:\new\table.tsv`, regular expressions or quoted SAS text.
Python preserves those characters by default. `--decode-code-escapes` explicitly
enables legacy-style conversion for direct `--code` text; files and stdin are
never decoded. The existing Perl conversion behavior is unchanged.

**An explicit interpreter must be honored.** An invalid `PIPELINE_PYTHON_BIN`
produces an actionable error rather than silently choosing another environment.
Automatic candidates must match the active platform and provide Python 3.10+
with SASPy. The MCP server and other Python utilities still need an explicitly
selected/activated environment, as described in the setup guide.

**Shutdown must retain ownership information.** The candidate's Windows wait
could lose descendants when the parent exited. The reviewed implementation
records the owned tree before requesting termination, checks process creation
times before force-stopping survivors and targets the authenticated backend PID.
It also guards against a negative sleep at the grace deadline. A real Windows
parent/child test and a simulated PID-reuse test verify these paths. Ordinary
forced cleanup retains its fast path.

**Diagnostics must come from runtime output.** The candidate's Perl submission
check searched for the error text anywhere in the report. The reviewed helper
anchors it to SAS error lines and excludes source/output sections. Saved-log
classification uses the same rule. Windows error 67 is not automatically a SAS
programming error, and changing local `--macro-dir` cannot repair a server-side
UNC reference in `FILENAME`, `LIBNAME` or `SASAUTOS`.

## Actual validation

The final native Windows Python suite passed **64 tests**, including real MCP
stdio/HTTP clients, backend persistence, browser-output controls, the actual
interpreter handoff and owned-process shutdown. The process-termination test
requires permission to terminate its own children; it failed in the restricted
local sandbox and passed outside that sandbox. It is skipped on non-Windows
systems, where the remaining tests exercise the applicable runtime behavior.

Six Perl regression scripts passed **91 assertions**, and both compatibility
entry points passed syntax checks and remain byte-identical. The new Perl
macro-directory regression also has a Python counterpart.

The opt-in live review completed **nine operations** against SAS ODA:

| Operation | Observed result |
|---|---|
| Python macro fallback | Local macro uploaded/compiled, warning retained, SASHELP.CLASS count = 19, exit 0 |
| Python environment handoff | Started with site packages disabled, selected the installed environment, preserved the complete SAS argument and returned count = 19 |
| Perl macro fallback | Same SAS program/local macro returned count = 19, exit 0 |
| Perl missing dataset | Required real SAS missing-table diagnostic and exit 1 |
| Python missing dataset | Required real SAS missing-table diagnostic, failed status and exit 1 |
| Python literal path | Exact `C:\new\table.tsv` string preserved in SAS output |
| Python timeout | 20-second sleep with a 2-second operation limit and 1-second grace returned 124 in approximately 4.1 seconds |
| Python recovery | A fresh session returned count = 19 after timeout, without replaying the failed sleep |
| Python session close | Selected review session closed, exit 0 |

In the reviewed Python macro run, HTML occupied 33,284 bytes, while terminal
output occupied 1,805 bytes and the text log 1,564 bytes. This records output
separation, not measured model-token or monetary savings. The live runs mix
startup, transfers and session reuse; their timings are not a paired performance
benchmark between Perl and Python.

Complete local logs, submitted code and execution records remain under the
Git-ignored `MCP4SAS_Use_Python/test-results/copilot-review*` directories. Early
failed trials are retained: the first exposed Windows handoff quoting and a
Cygwin path error in the comparison harness. The harness now passes forward-slash
paths and the same explicit SASPy configuration to both runners, and it requires
the intended SAS error rather than accepting any nonzero result.

## Scope and cross-platform checks

The six-job Python matrix and three-job Perl regression matrix cover Windows,
macOS and Ubuntu. Their actual branch results will be recorded before merging.
Live SAS in this review used Windows Python/Cygwin Perl connecting to SAS ODA;
it does not establish live SAS compatibility on every platform or rerun all
research figures. Windows network-share availability remains a configuration
matter on the computer running SAS.

Original research/SAS programs, the VS Code plugin version 0.1.5, proprietary
JARs and account settings are unchanged. Pre-existing unrelated backend whitespace
edits and the local debug log were excluded from these changes.
