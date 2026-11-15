# Python runtime validation

Baseline: `796c37b39e5c3017493de227b244413f8e684141`; migration branch:
`feature/python-port`. Runtime and utilities are in scope; developer corpus builders
and legacy harnesses remain deferred. Existing Perl sources were not rewritten.

## Observed results

| Check | Result |
|---|---|
| Offline Python tests | 30 passed on native Windows Python 3.13 |
| Original-Perl source-analysis references | 308 comparisons passed across 44 lexical cases and seven operations |
| Reused lexical-analysis views | 220 additional reference comparisons passed |
| Original-Perl diagnostics | Five reference logs matched |
| Guarded remote cleanup | Two generated SAS programs matched the Perl output exactly |
| Actual MCP stdio and HTTP clients | Discovery, four tools, completion, failure and unknown-PID checks passed |
| Native backend subprocess | Authenticated RPC, fragmented frames, Windows venv interpreter PID and persistent reuse/close passed |
| SAS ODA known-data check | SASHELP.CLASS N=19, minimum age=11, maximum age=16; no warnings |
| Local dependency graph on SAS ODA | Include file, two macro files and data file uploaded in a batch; independently checked sum=30 |
| Batched downloads | CSV values 10 and 20 and exact text marker verified |
| Error and recovery | Deliberately absent dataset returned exit 1; corrected code reused the session and recovered sum=30 |
| Redirected SAS log | PRINTTO-hidden error surfaced and returned exit 1 |
| Timeout | A 20-second sleep with a 2-second limit returned 124; subsequent code started a fresh working session |
| Live Python MCP / SAS ODA | Actual SDK stdio calls returned COMPLETE/exit 0 for N=19 and FAILED/isError/exit 1 for an absent dataset |
| Local Windows SAS COM | Actual Python/SASPy execution returned N=19, age 11–16; zero SAS errors/warnings |
| Direct local Windows SAS | Actual SAS executable returned exit 0 and N=19 without SASPy, Bash or Perl |

## Original scientific examples

All six saved SAS programs ran through the new Python runner on SAS ODA. The
input datasets, macros and plotting programs were unchanged.

| Example | Independent checks | Preserved SAS warning lines |
|---|---:|---:|
| SASHELP.CLASS | 3 | 0 |
| Expression clustergram and branch review | 509 | 8 |
| Gene/transcript GTF | 59 | 8 |
| Mutation oncoprint | 33 | 2 |
| Forest plot | 30 | 0 |
| Multi-GWAS local GTF | 11,295 | 5 |
| Total | 11,929 | 23 |

These checks cover file signatures/dimensions, row counts and independently
computed quantities: expression standardization, transcript identifiers/coordinates,
mutation denominators/event totals, effect/SE reconstruction, association heights
and signed LD. They do not establish that a full research pipeline was rerun or
that every rendered label is publication-ready. The original warnings include
large graphics sizes, recursive CREATE TABLE and inactive output destinations;
they were retained rather than suppressed or silently fixed in scientific code.

Complete submitted programs, logs, CSV/PNG/SVG outputs and execution records are
retained locally under `test-results/oda-native-python-v3/`. Private runtime state,
account configuration, licensed JARs and the environment are excluded from Git.

## Debugging findings retained for maintenance

1. Native Windows virtual-environment launchers can have a different PID from the
   interpreter hosting the backend. Startup now authenticates the RPC reply and
   records both interpreter and launcher PIDs. Shutdown waits for both so the
   launcher does not retain a Windows log-file lock.
2. Python 3.13's Windows mode-0700 directory semantics can isolate a generated
   config created by a restricted installer account. The credential-free project
   config inherits the writable project's Windows ACL; Unix private-directory
   permissions are retained. No user directory ACL was modified.
3. SAS COM work must remain on its owning thread. The Python backend serializes
   RPC requests and keeps COM submission on that thread. A separate IOM heartbeat
   worker remains available; the parent enforces the wall-clock timeout.
4. A successful worker exit with no result log is not accepted blindly. Local
   classifier output or preflight failures are preserved from worker stdout;
   absent completion records remain UNKNOWN.
5. macOS case-insensitive filesystems can accept a differently cased path while
   pathlib retains the supplied spelling. Macro discovery now inspects directory
   entries so uploads retain the actual source filename. The initial two macOS
   CI failures were corrected and their full matrix rerun passed.
6. Position-based regular-expression matching avoids copying the remaining source
   for every token. Dependency discovery and CLI advisories reuse one lexical
   analysis per source. Before/after result hashes matched for all three profiler
   operations on the 816,114-byte multi-GWAS program; this is a local source-scan
   observation, not evidence of end-to-end speed or cost savings.

## Cross-platform evidence and limits

The [Python workflow](https://github.com/chengzhongshan/MCP4SAS/actions/workflows/python-runtime.yml)
installs dependencies and exercises real Python backend processes and MCP stdio/HTTP
clients on Windows, macOS and Ubuntu with Python 3.10 and 3.13. All six jobs passed
in [run 43657296733](https://github.com/chengzhongshan/MCP4SAS/actions/runs/43657296733)
at code commit `458bb485c5792182c7a846f82088c5938079c907`. All 30 tests passed in
each of the six jobs, including the final file-deletion guard regression test.

No new Python runtime connection to SAS from macOS/Linux is claimed.
The old Perl and VS Code workflows remain independent. Python defaults to targeted
macro loading; its CLI compatibility differences are documented in README.md.
There has been no paired speed benchmark, model trial, token measurement or cost
study for this port. The observed execution times are not evidence of savings.

`VALIDATION_MANIFEST.json` records numerical checks, dependencies, source/output
hashes and the observed execution summaries. The complete private logs remain
local. Original SAS warnings and Python/Perl compatibility differences are explicit;
this is not a claim that every historical edge case has been proven equivalent.
