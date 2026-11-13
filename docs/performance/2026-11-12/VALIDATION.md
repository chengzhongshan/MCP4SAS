# Validation of the performance fixes and debugging tools

Date: 12 November 2026. Runtime changes through
`fdc6d0f1fcd840d6a87174a5ec6ce36c89e5fa82`, plus the subsequent one-shot
status-path correction and documentation/profiler additions in this directory's
publication commit. Checks ran with Cygwin Perl and native Windows Python
3.13.11 / SASPy 5.104.0. No credentials or account-specific logs are included.

## Publication checks

| Check | Actual outcome |
|---|---|
| All non-live Test::More files selected by VALIDATION_TASKS.md | PASS: 52 files, 5,329 assertions, 151 seconds |
| Independently numbered adversarial and upstream-corpus batches | PASS: 2 files, 600 assertions, 4 seconds |
| Persistent archive Python unit suite | PASS: 10 tests, including integrity/failure and metadata cases |
| Standalone macro-bootstrap guard diagnostic | PASS |
| Standalone connection-lifecycle diagnostic | PASS |
| Git synchronization integration tests using temporary local repositories | PASS: dry-run/exclusions, pull/reapply, divergent merge and conflict preservation |
| Real Cygwin/native-Python path I/O and CLI Java-failure diagnostic | PASS: included in the complete offline suite; focused rerun 49 assertions |
| New source profiler, three repeated samples for each operation on three frozen plotting programs | PASS: stable hashes for all nine operations; the six dependency/include hashes agree with retained accepted evidence |
| Changed Perl source and both compatibility helpers | Syntax PASS; helper byte-identity test PASS |
| Installer shell and Python session/archive sources | Syntax/compilation PASS |
| Git whitespace check | PASS |
| Local installer smoke check | NOT PASSED: existing global SASPy oda profile has no IOM classpath; stopped at prerequisite gate before code smoke tests |

The installation check used its supported interpreter-record mechanism to
select the existing installed Python, not a fresh installer-created runtime.
The temporary ignored interpreter record was removed afterward. The retained
live evaluation used a separately configured SASPy profile; this local
prerequisite failure is not evidence that those completed jobs failed. Fresh
platform installation is covered separately by the repository's Installation
workflow. Its results must be read from the actual GitHub Actions run.

## Failures found and corrected during publication checks

The first full offline run failed one of 5,327 assertions. In the real CLI
Java-error fixture, native Windows Python received an unconverted Cygwin status
path. A FileNotFoundError hid the intended Java recovery message. Both one-shot
launch paths now normalize SAS_ODA_STATUS_FILE for the selected interpreter.
Two assertions were added to the actual CLI fixture to protect the diagnostic.
The complete rerun passed all 5,329 assertions; the earlier failure was not
reclassified as success.

An initial local shell invocation selected Windows' WSL bash instead of the
Cygwin runtime and failed before testing the install script. Selecting Cygwin
explicitly reached the separate IOM prerequisite failure described above.
The Git-sync integration test likewise passed after selecting Cygwin Bash in
the test environment. These launcher failures are not counted as product tests.

## Retained live evidence

The accepted four-family comparison is direct SASPy trial 2 versus optimized
MCP trial 11. All 72 checks passed, including numerical tables at tolerance
1e-10 and seven identical decoded PNG arrays. Original warnings were retained.
Full-workflow observations were 164.27 seconds directly and 149.49 seconds
through optimized MCP; the earlier unoptimized MCP observation was 816.52
seconds. Runs occurred at different times and used individual versus archive
transfers, so these are not controlled repeated estimates of general speed.

The evidence is summarized in [measurements.json](measurements.json), including
the original source/input hashes, timing stages and unchanged dependency
results. The new status-path correction affects one-shot diagnostic handling;
it does not change these persistent-run timings. No fresh large live SAS job
was run merely to publish the debugging guide.

No autonomous agent token/cost trial, full scientific validation or exhaustive
platform validation is claimed. See [the debugging guide](../../PERFORMANCE_DEBUGGING.md)
for commands, causes, protocol checks and remaining measurement limits.
