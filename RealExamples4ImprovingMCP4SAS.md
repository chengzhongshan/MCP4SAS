# Real Examples for Improving MCP4SAS

Validation date: October 12, 2026.

This record describes real SAS OnDemand for Academics (ODA) runs, the failures
they exposed, and the resulting MCP4SAS changes. The commands and maintained
test drivers use Perl or Bash in Cygwin. SASPy still uses Python internally;
you do not need to write Python to run these examples.

## 1. Cygwin setup

Open Cygwin and enter this checkout:

```bash
export PATH=/usr/bin:$PATH
cd '/mnt/e/LongCOVID_HGI_GWAS/PGC_Large_GWASs/Manuscript4AI_with_PGC_GWASs/FR_Reviewers_Comments/perlMCP4Gemini_Paper/MCP4SAS'
```

This machine mounts drive E at `/mnt/e`. On a standard Cygwin installation,
the equivalent may be `/cygdrive/e`. Use the path for your checkout.

The live tests use the existing SASPy/ODA configuration and credentials.
They do not embed passwords. All the SAS examples here are self-contained,
so global remote macro autoload can be disabled for these tests:

```bash
export SAS_ODA_AUTOLOAD_MACROS=0
export OPEN_RESULT=0
```

Other programs that depend on your remote macro library may need macro
autoload enabled. The test server runs on loopback only.

## 2. Generated SAS examples and CLI commands

### Basic summary: establish a successful baseline

File: [examples/basic_summary.sas](examples/basic_summary.sas).

```sas
proc means data=sashelp.class n mean;
    var age height weight;
run;
```

```bash
perl run_sas_codes_or_files_in_ODA.pl \
  --file examples/basic_summary.sas \
  --output-prefix SAS_Output_basic_summary \
  --run-timeout-seconds 180
echo "Exit code: $?"
```

Observed: exit 0, `success=1` in the status JSON, and nonempty HTML output.
`--output-prefix` specifies an output **directory**; the CLI writes
`output.html.info.txt` and `output.run.status.json` inside that directory.

### Macro control flow: reproduce a false failure

File: [examples/macro_control_flow.sas](examples/macro_control_flow.sas).

```sas
options mprint;
%macro checked_result;
%if 1=0 %then %do;
    %put ERROR: This branch must never execute.;
%end;
%goto finished;
%put ERROR: This statement must be skipped.;
%finished:
data control_result;
    length message $80;
    message="ERROR: is ordinary data here";
run;
proc print data=control_result; run;
%mend;
%checked_result;
```

```bash
perl run_sas_codes_or_files_in_ODA.pl \
  --file examples/macro_control_flow.sas \
  --output-prefix SAS_Output_macro_control \
  --run-timeout-seconds 180
echo "Exit code: $?"
```

Before repair, SAS produced valid HTML but the CLI exited 1. It misclassified
this source trace as a fatal SAS diagnostic:

```text
MPRINT(CHECKED_RESULT):   message="ERROR: is ordinary data here";
```

The dependency scanner also generated a remote loader for `finished.sas`,
mistaking `%finished:` for an external macro invocation.

Improvements:

- Fatal error matching now requires a diagnostic at the start of a log line,
  allowing leading whitespace. Numbered source listings remain excluded.
- Macro label declarations are excluded from external-macro detection.
- Real external macro calls and actual SAS errors remain detectable.

After repair: exit 0, successful status JSON, valid HTML, and no spurious loader.
Both CLI entry points received the log-classification fix.

### Missing table: confirm genuine failures are retained

File: [examples/expected_missing_table.sas](examples/expected_missing_table.sas).

```sas
proc print data=work.mcp4sas_missing_table; run;
```

```bash
perl run_sas_codes_or_files_in_ODA.pl \
  --file examples/expected_missing_table.sas \
  --output-prefix SAS_Output_expected_failure \
  --run-timeout-seconds 180
echo "Expected exit code 1; actual: $?"
```

Observed: exit 1, `success=0`, and the missing-table diagnostic preserved in
the SAS log. This guards against weakening error detection while fixing the
false positive above.

### GTEx: validate the data, not only HTTP connectivity

File: [examples/gtex_eqtl.sas](examples/gtex_eqtl.sas).

```bash
perl run_sas_codes_or_files_in_ODA.pl \
  --file examples/gtex_eqtl.sas \
  --output-prefix SAS_Output_gtex \
  --run-timeout-seconds 180
```

The earlier APOBEC3A request returned HTTP 200 but an empty `data` array.
The gene identifier and dataset annotation did not match the API default.
The example now explicitly pairs `ENSG00000128383.12` with `gtex_v8`.

The SAS example checks HTTP status, JSON paging metadata, empty results,
and the existence of the data table. It rejects results needing more than
one 100,000-record page instead of silently using an incomplete result.

Observed live result: **201 significant eQTL records across 14 tissues**.
This is the significant-eQTL endpoint, not a query for every tested association.
See the [GTEx API documentation](https://gtexportal.org/api/v2/redoc).

The example encodes its own expectation of nonempty data. MCP4SAS cannot
generically decide whether an empty scientific result is correct.

## 3. Run the CLI example suite

```bash
perl tests/run_live_examples.pl --live
```

This runs all four SAS files above, checking exit codes, status JSON, HTML,
and the expected error diagnostic. It retains artifacts under a unique
`SAS_Output_examples_*` directory. The completed validation passed **21 assertions**.

The validated run retained its artifacts in:

```text
SAS_Output_examples_pjAVw6/
```

## 4. New MCP HTTP examples

These tests exercise submission and PID polling through the actual MCP server,
including file-only operations and reuse of a persistent SAS session.

### Start the test server in Cygwin terminal 1

```bash
export PATH=/usr/bin:$PATH
SAS_ODA_AUTOLOAD_MACROS=0 OPEN_RESULT=0 \
  perl server.pl daemon -m production -l http://127.0.0.1:18089
```

Use an unused port. If you choose another port, pass the corresponding URL to
the client test. Stop this test HTTP server with Ctrl+C when testing is finished.

### Run the Perl client suite in Cygwin terminal 2

From the same checkout:

```bash
export PATH=/usr/bin:$PATH
perl tests/run_live_mcp_examples.pl --live \
  --url http://127.0.0.1:18089/mcp
```

The client uses `Mojo::UserAgent` from Mojolicious, which MCP4SAS already
requires. It polls every 30 seconds. Generated CSV files, downloaded copies,
and MCP responses are saved under `SAS_Output_http_*`.

| New scenario | Generated input | Validation |
| --- | --- | --- |
| Custom log and failed SAS job | `proc print data=work.mcp_http_missing_table; run;` | Failed MCP status, exit 1, `isError=true`, complete SAS log at a path containing a space |
| Persistent session creation | WORK table containing `value=8675309` | Successful MCP response and SAS output |
| Persistent session reuse | Print that table in a second call, then delete it | HTML contains the value created by the first call |
| Archive round trip | Two tiny CSV files, one with a space in its filename | Upload/download complete and both local files match the originals byte-for-byte |
| Remote cleanup | Exact unique filenames created by this test | Successful deletion of the test fixtures |
| Missing remote download | Unique nonexistent remote CSV path | Nonzero exit and MCP failure even without a SAS submission-status file |

Each run creates unique session IDs and remote filenames. The upload fixtures
are cleaned up even if the transfer assertions fail. The WORK test table is
deleted, but its named persistent session remains reusable. Shared SASPy
services and unrelated sessions are not shut down by the test.

### Automatic local scratch cleanup

MCP jobs now write their deliverables to a unique `SAS_Output_MCP4SAS_*`
directory. Generated SAS input, wrapper stdout, and other worker scratch files
stay in a separate `tmp*` directory, which is removed automatically when the
worker finishes. SASPy helper scripts, result JSON, transfer staging archives,
and temporary rendered HTML are also directed into this worker scratch. Polling
still finds the PID marker in the results directory;
after polling, MCP4SAS removes that marker and its completion JSON while
retaining the SAS log, HTML, and status JSON when one is produced. A
caller-supplied `output_file` continues to receive a copy of the SAS log.

This is automatic for both MCP tools (SASPy/ODA and direct local SAS). A
forcibly terminated worker may leave its scratch directory for debugging. A
normal command-line SAS run continues to preserve its requested output
directory; it now removes timeout-wrapper JSON, temporary code, and debug
sidecars on timeout or if a child process cannot be started. Direct local SAS
polling now reports the actual helper exit code and flags nonzero exits as MCP
errors instead of always returning `COMPLETE`.

After starting and polling a job, verify that the completed job no longer has
a worker scratch directory while its result artifacts remain:

```bash
find . -maxdepth 1 -type d -name 'SAS_Output_MCP4SAS_*' -print
find . -maxdepth 1 -type d -name 'tmp*' -print
```

These Cygwin checks use Bash `find`; no Python cleanup script is needed.

### Failures found through the real HTTP interface

Before repair, the missing-table job returned:

```text
STATUS: COMPLETE
```

There was no MCP `isError` flag even though the SAS runner failed. The server
also advertised the wrong log path: it interpreted the CLI output-directory
argument as a filename prefix. Polling fell back to wrapper stdout instead
of returning the full SAS log. Custom output paths were not tracked correctly.

The repaired server:

1. Runs the CLI with the job directory as its output directory.
2. Supervises the CLI process and records its exit status, including signals.
3. Writes `worker.result.json` atomically with the exit code and actual log path.
4. Copies the full log to a requested custom path when the job completes.
5. Returns `FAILED` and `isError=true` on nonzero exit, or `COMPLETE` and
   `isError=false` on exit 0.
6. Returns `UNKNOWN` with an error flag if a worker stopped without a completion
   record, instead of guessing that the job succeeded.

File-only operations use the same completion record. They therefore do not
depend on the SAS submission-status JSON existing. Wrapper stdout remains
available when a failure occurs before a SAS log can be written.

The live HTTP validation passed all six scenarios and **24 assertions**,
including the cleanup changes. Its artifacts are in:

```text
SAS_Output_http_3jAHC2/
```

A fresh verification of the current checkout also passed all **24 assertions**
using the maintained Perl driver. The exact client command was:

```bash
perl tests/run_live_mcp_examples.pl --live \
  --url http://127.0.0.1:18090/mcp
```

That test server used the same startup command above with port `18090`.
The retained client artifacts are in `SAS_Output_http_9JbmpD/`. This run
confirmed successful archive transfers, persistent WORK reuse, custom logs,
remote cleanup, and correct failure reporting for a nonexistent remote file.

During the first reruns, the Perl HTTP client sometimes reported
`Request timeout` or `Premature connection close` after its 30-second
polling delay. Each test
request now sends `Connection: close` instead of reusing a potentially stale
keep-alive socket. Request and inactivity timeouts are both 240 seconds,
while polling remains every 30 seconds. These client safeguards passed the
fresh live run; the exact cause of the earlier socket failures was not established.

## 5. Offline regression commands

These commands do not connect to ODA:

```bash
perl MCPDeps/test_sas_log_and_labels.pl
perl tests/test_mcp_job_reporting.pl
bash tests/test_local_sas_workdir.sh
perl MCPDeps/test_sas_oda_debug_macro_guard.pl
perl MCPDeps/test_sas_oda_connection_lifecycle.pl
perl MCPDeps/test_sas_oda_macro_helper_reuse.pl
perl MCPDeps/test_sas_oda_include_lookup.pl
perl -c server.pl
perl -c run_sas_codes_or_files_in_ODA.pl
perl -c run_sas_codes_or_script_in_ODA.pl
perl -c tests/run_live_mcp_examples.pl
git -c core.whitespace=cr-at-eol diff --check
```

The log/label test passed **30 assertions**. The MCP reporting test passed
**44 assertions**, including offline SASPy and direct-SAS completion checks,
an MCP worker run, scratch-directory removal, retained SAS logs and HTML,
completed PID-marker cleanup, exit codes 0, 1, 73, 74, 127, and 143, custom
logs, and missing completion records. Macro/bootstrap and include-lookup
checks are included in the offline set.

`tests/test_local_sas_workdir.sh` also passed. It uses a small fake SAS
executable to verify working-directory and output placement; it does not
validate a licensed local SAS installation. The live suites above use real
SAS ODA sessions.

## 6. Final code improvements and scope

### Standalone CLI cleanup improvement

Both CLI entry points now place intermediate files in an owned
`.mcp4sas_work_*` directory under the current working directory. The Perl
cleanup manager removes that directory when the owning process exits,
including after exceptions and handled timeouts. Forked workers cannot remove
their parent's scratch. SAS logs, status files, HTML, and downloaded results
stay in their requested output directories.

When MCP supplies a worker scratch directory, the CLI uses it and leaves
cleanup to the MCP server. The long-lived SASPy session server uses a stable
temporary directory instead of inheriting the short-lived CLI scratch path.
This prevents session reuse from depending on a directory already removed by
the previous call.

Normal usage needs no extra cleanup command:

```bash
perl run_sas_codes_or_files_in_ODA.pl \
  --file examples/basic_summary.sas --output-prefix SAS_Output_summary
```

For debugging, retain any remaining intermediates:

```bash
perl run_sas_codes_or_files_in_ODA.pl \
  --file examples/basic_summary.sas --output-prefix SAS_Output_debug \
  --keep-intermediate-files
```

`MCP4SAS_KEEP_INTERMEDIATES=1` provides the same default for standalone CLI
invocations. Regular per-file cleanup still occurs inside helpers; the option
retains the scratch directory and surviving files, rather than every temporary
file a helper has already removed.

For interrupted or retained standalone scratch, preview and then apply:

```bash
perl cleanup_mcp4sas_intermediates.pl --directory . --older-than-hours 24
perl cleanup_mcp4sas_intermediates.pl --directory . --older-than-hours 24 --apply
```

The maintenance tool checks the ownership marker, resolved parent directory,
age, and PID. Active processes, unmarked directories, symlinks, and result
directories are preserved. Legacy `tmp*` directories are handled by the MCP
server's existing worker lifecycle; this maintenance command specifically
targets the new marked `.mcp4sas_work_*` directories. A forced kill can bypass
Perl exit cleanup, so the maintenance command covers that case.

Cleanup regression commands, all using Perl in Cygwin:

```bash
perl tests/test_cli_cleanup.pl
perl tests/run_live_cli_cleanup.pl --live
```

The offline test passed **15 assertions** for exit/exception cleanup,
ownership, active-PID protection, debug retention, preview/apply behavior,
preservation of final results, and termination of descendant processes.

The four-case live suite passed **14 assertions** for normal, failing,
timed-out, and retained ODA runs. Its artifacts are in
`SAS_Output_cli_cleanup_XCgs5w/`. Inspection of that first timeout log exposed
a further race: a helper survived the timeout and tried to write its JSON
after its scratch directory had been removed.

The original termination code killed the parent first and passed a Cygwin
PID to Windows `taskkill`. Termination now snapshots descendants, translates
the root PID using Cygwin's `WINPID` column, and runs Windows process-tree
termination before the parent disappears. Unix uses the captured descendant
PIDs, terminating children before the root. This targets only the timed-out
worker tree.

After the correction, these targeted live reruns each passed two assertions:

```bash
perl tests/run_live_cli_cleanup.pl --live --only timeout
perl tests/run_live_cli_cleanup.pl --live --only timeout --timeout-seconds 12
```

Artifacts: `SAS_Output_cli_cleanup_UC6dny/` and
`SAS_Output_cli_cleanup_YpSSFa/`. The 12-second case established a SAS
connection before timeout, exited with the expected failure, removed its
scratch, and preserved its diagnostic log and status JSON. No late helper
write or surviving helper for that run was found. Normal and failing CLI
logs, final HTML, and debug-retention behavior were also checked in the
four-case run.

| File | Improvement |
| --- | --- |
| `MCPDeps/SAS_ODA_Runner.pm` | Do not treat macro jump labels as external macros |
| Both `run_sas_codes_or_*_in_ODA.pl` entry points | Distinguish actual fatal diagnostics from source/trace text containing `ERROR:` |
| `server.pl` | Accurate SASPy and direct-SAS completion/error flags; durable log/HTML output separated from auto-removed job scratch |
| `MCPDeps/SAS_ODA_Runner.pm` | Redirect Perl helper scripts, JSON, archives, and transient HTML into the MCP worker scratch directory |
| Both CLI entry points | Remove timeout-worker JSON, generated code, and debug sidecars on timeout or fork failure |
| `RunLocalSASDirectly.sh` | Run SAS with the requested result directory as its working directory, preventing relative ODS artifacts from leaking into the MCP checkout |
| `.gitignore` | Exclude the runtime session-server log under `MCPDeps/` |
| `MCPDeps/MCP4SAS_Temp.pm` and both CLI entry points | Owned standalone scratch with automatic exit cleanup and optional debug retention |
| `cleanup_mcp4sas_intermediates.pl` | Preview/apply cleanup for marked, inactive retained scratch |
| `MCPDeps/MCP4SAS_Temp.pm` and both CLI timeout handlers | Terminate the correct worker process tree before deleting its scratch; translate Cygwin PIDs to Windows PIDs |
| `examples/` and `tests/` | Repeatable SAS examples, Perl live drivers, and offline regression tests |

Runtime output directories and logs remain local and excluded from source
commits. These results validate ODA on this configured machine, not every
local SAS installation or platform. Live API counts can change; revalidate
against the selected dataset when reusing the examples. No GitHub push was
performed as part of these tests.

To review and publish the source changes when desired:

```bash
bash update_github_upload.sh --dry-run
bash update_github_upload.sh 'Improve MCP4SAS using real SAS and MCP examples'
```
