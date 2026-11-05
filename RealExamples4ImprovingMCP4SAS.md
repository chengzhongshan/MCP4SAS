# Real Examples for Improving MCP4SAS

Validation dates: October 12-13, 2026.

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

## 7. Thirty additional generated real examples

This October 12, 2026 validation adds **30 distinct examples**, separate from
the previous basic-summary, macro-label, missing-table, GTEx, file-transfer,
and cross-call WORK-state scenarios. Each case has a different SAS source
body and checks a different calculation, procedure, import, diagnostic, or
syntax condition. Reverification of these same cases is not counted as
additional examples. The generator rejects duplicate IDs and source hashes.

The maintained Perl source is
[tests/run_live_new_examples_30.pl](tests/run_live_new_examples_30.pl).
It generates all thirty `.sas` files and `catalog.json` in a unique local
`SAS_Output_real30_*` directory. No Python test driver is needed. The examples
use generated data, SAS procedures, and temporary filerefs; they do not
query an external scientific API or upload research datasets.

### Exact Cygwin commands

From the MCP4SAS checkout, start a fresh test server in terminal 1:

```bash
export PATH=/usr/bin:$PATH
SAS_ODA_AUTOLOAD_MACROS=0 OPEN_RESULT=0 \
  perl server.pl daemon -m production -l http://127.0.0.1:18131
```

In terminal 2, run the new batch:

```bash
export PATH=/usr/bin:$PATH
perl tests/run_live_new_examples_30.pl --live \
  --url http://127.0.0.1:18131/mcp > new_real30_verified.log 2>&1
```

The original discovery pass used port `18130` and
`> new_real30_initial.log 2>&1`. It completed with 26/30 case validations
passing. After editing `server.pl`, restart the HTTP server before testing
the new response fields. An attempted rerun reached the old server process
and was stopped because it lacked the new structured status. This was a
test-server lifecycle problem, not another SAS calculation failure. The
complete verification used the fresh server on port `18131`.

Generate the sources without contacting SAS ODA, or rerun a selected case:

```bash
perl tests/run_live_new_examples_30.pl --generate-only
perl tests/run_live_new_examples_30.pl --live --only 29 \
  --url http://127.0.0.1:18131/mcp
```

To execute a generated file directly with either CLI entry point:

```bash
SAS_ODA_AUTOLOAD_MACROS=0 OPEN_RESULT=0 \
  perl run_sas_codes_or_files_in_ODA.pl \
  --file SAS_Output_real30_hEvUVx/29_macro_after_statement.sas \
  --output-prefix SAS_Output_real30_case29 --run-timeout-seconds 180
```

Replace the generated directory with the one printed by your run. Stop your
test HTTP server with Ctrl+C when finished. The driver uses a unique named
persistent ODA session for short cases; the ABORT case uses a separate
one-shot session. It never calls the global SASPy process-kill command or
shuts down unrelated sessions. Named persistent sessions remain reusable.

### Case inventory and expected outcomes

All generated files are named `<ID>_<name>.sas`. "Expected failure" means
the test passes only if MCP returns `FAILED`, a nonzero exit code,
`isError=true`, and the expected diagnostic. Successful calculations must
emit their case-specific `MCP30_OK_<ID>` marker in the actual SAS log.

| ID | Generated example name | Calculation or condition validated | Expected job |
| --- | --- | --- | --- |
| 01 | `sql_join_cardinality` | Three joined rows; weighted total 80 | Complete |
| 02 | `transpose_duplicate_id` | PROC TRANSPOSE rejects duplicate IDs | Expected failure |
| 03 | `transpose_after_aggregation` | Aggregation resolves duplicates; values 15 and 30 | Complete |
| 04 | `invalid_numeric_input` | Invalid text becomes missing; sum 20, one missing; quality diagnostic | Complete |
| 05 | `unsorted_by_group` | BY processing rejects unsorted input | Expected failure |
| 06 | `missing_custom_format` | FMTERR rejects an unknown format | Expected failure |
| 07 | `custom_format_mapping` | Two correct age-band labels | Complete |
| 08 | `json_array_import` | JSON engine reads two rows; sum 24 | Complete |
| 09 | `quoted_csv_import` | Embedded comma and doubled quote preserved | Complete |
| 10 | `gzip_write_read` | Compressed CSV written and read; sum 42 | Complete |
| 11 | `quoted_macro_literal` | Quoted percent text remains ordinary data | Complete |
| 12 | `macro_local_scope` | Local variable does not replace global value | Complete |
| 13 | `hash_missing_key` | Hash match returns 99; missing key remains missing | Complete |
| 14 | `left_join_unmatched` | Three rows retained, two unmatched | Complete |
| 15 | `summary_missing_class` | Missing class retained; two groups, sum 37 | Complete |
| 16 | `weighted_frequency` | Weighted frequency total 10 | Complete |
| 17 | `regression_parameter_capture` | ODS parameter table contains slope 3 | Complete |
| 18 | `binomial_logistic_model` | Two nonmissing estimated parameters | Complete |
| 19 | `rank_tie_handling` | Duplicate minima receive mean rank 1.5 | Complete |
| 20 | `compare_detects_difference` | PROC COMPARE signals a known difference | Complete |
| 21 | `log_only_success` | Sum 10; HTML is not required | Complete |
| 22 | `sgplot_two_series` | Generated two-series plot produces HTML | Complete |
| 23 | `report_computed_column` | PROC REPORT completes with computed net column | Complete |
| 24 | `utf8_csv_roundtrip` | Export/import preserves both UTF-8 label values | Complete |
| 25 | `incomplete_assignment` | Incomplete assignment produces syntax error | Expected failure |
| 26 | `abort_cancel` | ABORT CANCEL reported as failure | Expected failure |
| 27 | `unique_index_violation` | Unique index rejects duplicate values | Expected failure |
| 28 | `append_type_conflict` | FORCE append substitutes missing for a type conflict; warning surfaced | Complete |
| 29 | `macro_after_statement` | Macro after another statement on the same line produces value 29 | Complete |
| 30 | `division_by_zero_note` | Ratio becomes missing; quality diagnostic surfaced | Complete |

Each completed poll also checks structured status, exit code, retained full
log, and removal of PID/completion markers. Success cases requiring a table
or graphic must have nonempty HTML. Cases 22 and 23 check procedure completion
and output existence; they do not perform pixel-by-pixel graphics validation.

### Failures encountered and resulting improvements

**Case 29: valid SAS rejected before submission.** The old preflight counted
`%macro` and `%mend` only at the beginning of physical lines. This valid SAS
was incorrectly rejected with "Macro end statement %mend appears outside a
%macro/%mend block":

```sas
options mprint; %macro e29inline;
data e29; value=29; run;
%mend;
%e29inline;
```

Both CLI entry points now scan control tokens in source order rather than
assuming one statement per line. Quoted text and comments remain masked,
and genuinely unclosed definitions, stray `%mend`, and open-code `%goto`
remain detectable. Source line numbers are retained. The new
`tests/test_inline_macro_preflight.pl` regression covers those positive and
negative cases for both entry points.

**Cases 04 and 30: diagnostics suppressed by SAS options.** Their calculated
missing values were correct, but the first test expected NOTES while the
session used NONOTES. The generator now explicitly begins each example
with `options notes nosyntaxcheck obs=max;`. This is a test setup correction;
MCP4SAS does not override a user's explicit SAS logging options.

The new Perl module `MCPDeps/SAS_Log_Diagnostics.pm` separately summarizes
runtime warnings, data-quality NOTES, and DATA-step `_ERROR_=1` diagnostics.
Completed MCP ODA polls expose `structuredContent.status`, `exit_code`,
`log_path`, and `diagnostics`, and place a short diagnostic summary ahead of
the full log. Source listings, MPRINT/SYMBOLGEN traces, routine NOTES, and
text outside the SAS-log section are excluded. Duplicate diagnostic lines
are deduplicated. These diagnostics do not change a successful exit into a
failure; the worker exit status remains the authority for job success.
Case 28 validates this behavior with a real warning-producing FORCE append.

**Case 24: a test compared attributes instead of values.** PROC IMPORT
inferred a shorter character length and added formats. The original
`SYSINFO=0` assertion therefore failed even though the UTF-8 cell values
were preserved. The corrected example compares the two IDs and label values
using SQL and prints the imported table. This corrects the scientific test
expectation rather than hiding a runner error.

The six intentionally failing examples continue to require genuine failed
job reporting. The new warning summary does not weaken fatal-error handling.

### Final verification and retained evidence

The complete fresh-server run exited **0** and passed **30/30 case
validations**: 24 successful jobs and six intentional failed jobs reported
correctly. The final generated SAS files, catalog, start/poll MCP responses,
`results.json`, and saved suite log are under
`SAS_Output_real30_hEvUVx/`. Each entry in `results.json` points to its retained
`SAS_Output_MCP4SAS_*` directory with the full log and available HTML.
The original 26/30 discovery pass is retained in
`SAS_Output_real30_QAaWmj/`; the interrupted stale-server attempt is retained
separately in `SAS_Output_real30_EJAl56/`. It is not counted as a completed
validation. Shell logs were moved into these ignored artifact directories
after their processes finished.

The live structured responses surfaced two data-quality diagnostics in case
04, one warning in case 28, and three data-quality diagnostics in case 30.
Case 29 completed in four seconds after the preflight repair and produced
its result marker and HTML. All thirty completed jobs removed their own
PID/completion markers. Existing retained result directories and unrelated
scratch from earlier runs were not deleted.

The following offline commands passed after the live batch:

```bash
perl tests/test_mcp_job_reporting.pl           # 48 assertions
perl MCPDeps/test_sas_log_and_labels.pl        # 30 assertions
perl tests/test_inline_macro_preflight.pl     # 16 assertions
perl tests/test_sas_log_diagnostics.pl         # 7 assertions
perl -c run_sas_codes_or_files_in_ODA.pl
perl -c run_sas_codes_or_script_in_ODA.pl
perl -c server.pl
perl -c tests/run_live_new_examples_30.pl
git -c core.whitespace=cr-at-eol diff --check
```

This is **101 offline assertions**, separate from the thirty real case
validations. The fresh loopback HTTP test server was stopped after the batch.
Source changes, commands, and examples are maintained in Perl/Bash/SAS;
SASPy remains the existing internal ODA bridge. No GitHub push was performed
for this thirty-example update.

## 8. Another thirty new real examples: cases 31-60

The subsequent request was handled as a new batch, rather than rerunning
cases 01-30 and counting them again. Batch 2 has thirty additional source
bodies and scenarios. The generator checks source hashes against batch 1
as well as checking unique IDs and sources within batch 2. The catalog is
maintained in [tests/new_examples_31_60.pl](tests/new_examples_31_60.pl),
and uses the same Perl HTTP harness with `--batch 2`.

### Cygwin commands used

Start the separate loopback test server:

```bash
export PATH=/usr/bin:$PATH
SAS_ODA_AUTOLOAD_MACROS=0 OPEN_RESULT=0 \
  perl server.pl daemon -m production -l http://127.0.0.1:18132
```

The first discovery run and corrected verification used:

```bash
perl tests/run_live_new_examples_30.pl --live --batch 2 \
  --url http://127.0.0.1:18132/mcp > new_real30_batch2_initial.log 2>&1

perl tests/run_live_new_examples_30.pl --live --batch 2 \
  --url http://127.0.0.1:18132/mcp > new_real30_batch2_verified.log 2>&1
```

Generate the new sources offline, or rerun only the apostrophe example:

```bash
perl tests/run_live_new_examples_30.pl --generate-only --batch 2
perl tests/run_live_new_examples_30.pl --live --batch 2 --only 31 \
  --url http://127.0.0.1:18132/mcp
```

### New case inventory

The generated filenames are `<ID>_<name>.sas`. Cases 58-60 pass validation
only when the job fails with the corresponding genuine diagnostic. All
other cases require successful status and their individual result marker.

| ID | New example name | Validation |
| --- | --- | --- |
| 31 | `datalines_apostrophe` | Raw surname `O'Brien` preserved |
| 32 | `datalines4_comment_tokens` | Raw `*/`, `/*`, and embedded semicolons preserved |
| 33 | `sort_duplicate_keys` | NODUPKEY retains three keys and rejects two rows |
| 34 | `sql_union_semantics` | UNION gives three rows; UNION ALL gives four |
| 35 | `regex_variant_extraction` | PRX extracts `rs123456` |
| 36 | `leap_day_date_import` | Leap day parsed; next date is one day later |
| 37 | `numeric_function_missing` | MEAN ignores missing input; arithmetic mean propagates missing |
| 38 | `retained_group_totals` | Group totals reset correctly to 5 and 11 |
| 39 | `month_end_alignment` | INTNX returns February 29, 2024 |
| 40 | `univariate_percentile` | Median of 1-9 is 5 |
| 41 | `paired_ttest_output` | Paired test emits a finite probability within 0-1 |
| 42 | `anova_overall_table` | GLM emits three overall ANOVA rows |
| 43 | `correlation_output_dataset` | CORR returns Pearson correlation 1 |
| 44 | `fisher_exact_output` | Fisher exact ODS table exists with rows |
| 45 | `kaplan_meier_output` | Nonmissing survival estimates lie within 0-1 |
| 46 | `poisson_genmod_parameters` | Intercept and slope estimates are nonmissing |
| 47 | `mixed_model_fixed_effects` | Two fixed-effect estimates are nonmissing |
| 48 | `sql_case_missing_category` | Missing, low, and high categories mapped correctly |
| 49 | `fcmp_custom_function` | Generated FCMP function returns 37 |
| 50 | `tabulate_multidimensional_table` | TABULATE completes; underlying total is 18 |
| 51 | `temporary_array_dot_product` | Array dot product is 32 |
| 52 | `lag_by_group_reset` | Within-group differences are 4 and 9 |
| 53 | `format_cntlin_lookup` | Generated CNTLIN format maps 2 to `case` |
| 54 | `dictionary_column_metadata` | One numeric and one 17-byte character column |
| 55 | `contents_variable_order` | CONTENTS returns the three declared variable positions |
| 56 | `space_in_name_literal` | Name literal `patient id` reads as 56 |
| 57 | `special_missing_values` | `.A` is missing and distinct from ordinary `.` |
| 58 | `missing_infile_resource` | Missing DATA-step input file fails |
| 59 | `sql_unknown_column` | Unknown SQL column fails |
| 60 | `array_subscript_bounds` | Array access outside its bounds fails |

Procedural output checks are intentionally described separately from
exact-value checks. For example, case 44 verifies Fisher's ODS result table,
not an independently calculated reference probability. All cases also check
the MCP status/error flag, exit code, structured status, retained log,
required HTML, and completion-marker cleanup.

### New failure and resulting repair

The original pass validated **28/30** cases. Cases 31 and 32 were rejected
before remote submission. Preflight treated raw inline data as SAS source:
the apostrophe in `O'Brien` appeared to start an unterminated quoted string,
and `*/literal` appeared to close a block comment that had not been opened.
Both are legitimate values in the generated input records.

`MCPDeps/SAS_Source_Analysis.pm` now recognizes inline-data declarations
outside SAS strings and comments. It masks the raw records, preserving
character offsets and source line numbers, until the appropriate terminator:
`;` for ordinary DATALINES/CARDS/PARMCARDS or `;;;;` for their `4` variants.
It does not alter the program submitted to SAS. Both CLI entry points use
this view for quote/comment balancing, macro lint, PUT-semicolon checks,
inline-card checks, and macro-typo warnings. Raw percent text and
declaration-like text therefore do not become preflight findings.

The scanner also diagnoses a missing inline-data terminator. Real quote,
comment, or macro errors after a terminated data block remain detectable.
Declaration-like text inside an ordinary string or comment does not start
a data block or hide later errors. The new
`tests/test_inline_data_preflight.pl` regression tests both entry points,
offset/line preservation, the accepted raw characters, and these negative
cases. This fixes preflight; it does not change SAS's own data-reading rules.

### Final batch-2 results and checks

The corrected full run exited **0** with **30/30 case validations passing**:
27 successful jobs and three genuine runtime failures correctly reported.
Cases 31 and 32 both produced their result markers and nonempty HTML after
the preflight correction. The original failed run is retained in
`SAS_Output_real30_UgeNlZ/`; the final verified run is retained in
`SAS_Output_real30_0yq737/`. Each contains generated source files, the catalog,
MCP responses, `results.json`, and the saved shell log (`suite.log`). The
results JSON identifies the separate durable log/HTML directory for every
job. The temporary loopback test server was stopped after verification.

Offline regression commands and passing assertion counts:

```bash
perl tests/test_inline_data_preflight.pl      # 48
perl tests/test_inline_macro_preflight.pl     # 16
perl tests/test_sas_log_diagnostics.pl         # 7
perl MCPDeps/test_sas_log_and_labels.pl        # 30
perl tests/test_mcp_job_reporting.pl           # 48
perl -c tests/new_examples_31_60.pl
perl -c tests/run_live_new_examples_30.pl
perl -c run_sas_codes_or_files_in_ODA.pl
perl -c run_sas_codes_or_script_in_ODA.pl
git -c core.whitespace=cr-at-eol diff --check
```

That is **149 offline assertions**, in addition to the real batch-2 cases.
Across the two new batches there are **60 distinct example scenarios**;
discovery runs, reruns, and offline assertions are not counted as new
examples. All maintained generators and new analysis/test modules are Perl.
The report retains the previous batch's findings and commands. This update
remains local and has not been pushed to GitHub.

## 9. Third independent batch: new cases 61-90

The next request adds thirty further examples rather than counting prior
runs again. Their sources are maintained in
[tests/new_examples_61_90.pl](tests/new_examples_61_90.pl). The Perl driver
accepts `--batch 3` and checks its sources against both earlier batches.
Discovery runs and verification reruns are not counted as additional cases.

### Cygwin commands

Start the isolated test HTTP server from the MCP4SAS checkout:

```bash
export PATH=/usr/bin:$PATH
SAS_ODA_AUTOLOAD_MACROS=0 OPEN_RESULT=0 \
  perl server.pl daemon -m production -l http://127.0.0.1:18133
```

Run the discovery pass, then the full verification after repair:

```bash
perl tests/run_live_new_examples_30.pl --live --batch 3 \
  --url http://127.0.0.1:18133/mcp > new_real30_batch3_initial.log 2>&1

perl tests/run_live_new_examples_30.pl --live --batch 3 \
  --url http://127.0.0.1:18133/mcp > new_real30_batch3_verified.log 2>&1
```

Generate all sources offline or select one new example:

```bash
perl tests/run_live_new_examples_30.pl --generate-only --batch 3
perl tests/run_live_new_examples_30.pl --live --batch 3 --only 61 \
  --url http://127.0.0.1:18133/mcp
```

### Thirty new examples and checks

| ID | New generated source name | Condition validated |
| --- | --- | --- |
| 61 | `quoted_comment_delimiter` | Quoted `/*` value does not hide a real macro terminator |
| 62 | `statement_comment_after_semicolon` | Inline statement comment accepts an apostrophe |
| 63 | `commented_put_example` | PUT documentation inside a block comment is not executed |
| 64 | `sql_having_group_filter` | HAVING retains group 2 with total 15 |
| 65 | `correlated_exists_filter` | EXISTS retains two keys without duplicate multiplication |
| 66 | `full_outer_join_keys` | Full join retains three distinct keys |
| 67 | `cross_join_product` | Cartesian join produces six rows |
| 68 | `merge_membership_flags` | MERGE IN flags identify all three membership patterns |
| 69 | `call_execute_generated_step` | Generated DATA step creates value 69 |
| 70 | `symputx_numeric_transfer` | Calculated total 28 transfers through a macro variable |
| 71 | `sysfunc_math_expression` | Macro-expanded square root is 9 |
| 72 | `qscan_quoted_separator` | QSCAN retains comma inside a quoted list item |
| 73 | `iso_datetime_interval` | ISO datetime interval is 90 seconds |
| 74 | `multibyte_character_slice` | KSUBSTR preserves a complete accented UTF-8 character |
| 75 | `md5_known_vector` | MD5 digest matches the known vector for `abc` |
| 76 | `compressed_dataset_rename` | Compressed data retains four rows after rename |
| 77 | `sql_view_live_data` | View reflects a later underlying update to 77 |
| 78 | `standardized_mean_variance` | Standardized mean is zero, sample SD one |
| 79 | `geographic_distance_units` | One degree at equator gives distance within 100-120 km |
| 80 | `survey_weighted_mean` | Survey weighted mean is 170/6 |
| 81 | `monthly_date_aggregation` | January has two records, February one |
| 82 | `datasets_attribute_modify` | Attribute changes preserve numeric value 82 |
| 83 | `fopen_fread_fileref` | File functions read the generated text record |
| 84 | `additional_ods_html_destination` | Additional ODS HTML file exists and contains data |
| 85 | `sql_update_delete` | Updates/deletion leave two rows with sum 103 |
| 86 | `set_character_length_warning` | Length warning surfaced; longer string truncates to `pla` |
| 87 | `unknown_numeric_function` | Undefined DATA-step function fails |
| 88 | `sql_join_type_error` | Incompatible SQL join-key types fail |
| 89 | `unknown_procedure` | Nonexistent SAS procedure fails |
| 90 | `numeric_domain_diagnostics` | Invalid LOG/SQRT inputs become missing with quality diagnostics |

Cases 87-89 require genuine failed status, nonzero exit, MCP `isError=true`,
and their expected SAS diagnostic. The other 27 require successful status
and a case-specific log marker. HTML-producing cases require a nonempty
downloaded HTML artifact. Case 86 also checks the structured warning count;
case 90 checks the structured data-quality count. All cases check structured
status, the retained log, and removal of PID/completion markers.

### Three newly reproduced preflight failures

The discovery pass validated **27/30** cases. Cases 61-63 were valid SAS
programs rejected before remote execution:

- **61:** Regex-based comment removal started inside a quoted `/*` value
  and consumed through a later real block comment. Subsequent macro lint
  incorrectly reported a missing `%mend` even though it was present.
- **62:** The quote/comment scanner only recognized a bare `*` statement
  comment at a physical line start. After `data e62;`, it interpreted the
  apostrophe in `* author's explanatory note;` as an unterminated string.
- **63:** The PUT-semicolon check scanned lines inside a block comment and
  treated a nonexecuted documentation example as a fatal compile problem.

The existing Perl `MCPDeps/SAS_Source_Analysis.pm` now analyzes quotes,
comments, statement boundaries, and previously recognized inline-data
blocks in source order. It produces a view masking both comments and quoted
strings for macro lint, and a separate comment-only view for checks needing
the original quoted text. Neither view changes the source submitted to SAS.
Both CLI entry points share this analysis instead of separately removing
comments with regular expressions or assuming comments start physical lines.

Real unterminated quotes and comments remain detectable. Inline statement
comments and macro comments preserve the surrounding statement/expression
state. PUT text and misspelled macro names inside comments do not become
findings; real unsafe PUT statements still do. Character offsets and source
line numbers are preserved. The new
`tests/test_comment_quote_preflight.pl` covers these cases and genuine errors
for both CLI entry points, including macro comments inside an expression.

### Final batch-3 verification

The corrected full run exited **0** and validated **30/30 cases**:
27 successful jobs and three intentional genuine failed jobs correctly
reported. Cases 61-63 each produced their result marker and nonempty HTML.
The discovery artifacts are retained in `SAS_Output_real30_Q_aqNP/`; the
verified artifacts are retained in `SAS_Output_real30_Mg0Je0/`. Generated
SAS sources, the catalog, MCP start/poll responses, `results.json`, and the
saved suite log (`suite.log`) are preserved. Each results entry identifies
the durable job directory containing the full SAS log and available HTML.
The temporary loopback HTTP server was stopped after verification.

The following offline regressions passed after this batch:

```bash
perl tests/test_comment_quote_preflight.pl    # 26 assertions
perl tests/test_inline_data_preflight.pl      # 48 assertions
perl tests/test_inline_macro_preflight.pl     # 16 assertions
perl tests/test_sas_log_diagnostics.pl         # 7 assertions
perl MCPDeps/test_sas_log_and_labels.pl        # 30 assertions
perl tests/test_mcp_job_reporting.pl           # 48 assertions
perl -c tests/new_examples_61_90.pl
perl -c tests/run_live_new_examples_30.pl
perl -c run_sas_codes_or_files_in_ODA.pl
perl -c run_sas_codes_or_script_in_ODA.pl
perl -c server.pl
git -c core.whitespace=cr-at-eol diff --check
```

That is **175 offline assertions**, separate from the thirty real batch-3
case validations. The three new batches contain **90 distinct example
scenarios** in total. Sources and test/analysis code remain Perl/Bash/SAS;
SASPy continues as the existing internal bridge. Runtime artifacts remain
local and ignored by Git. No GitHub push was performed for this update.

## 10. Library-based batch: 100 new real cases (91-190)

Validation date: October 13, 2026, America/Chicago. This batch adds one
hundred new scenarios, separate from cases 01-90. The generated sources are
maintained in [tests/new_examples_91_190.pl](tests/new_examples_91_190.pl),
using the existing Perl HTTP harness with `--batch 4`.

### Source study and provenance

The two requested collections contain 220 and 362 SAS files (582 total):

- `H:/F_Queens/360yunpan/SASCodesLibrary/SAS-Useful-Codes/Easy-For-Error-Codes-SAS`
- `H:/F_Queens/360yunpan/SASCodesLibrary/SAS-Useful-Codes/SAS_Code_Database`

The selected lessons were adapted into 100 small generated-data scenarios
from **80 distinct source files** across those collections. A source can
inspire more than one case when the cases exercise different behavior, such
as keeping versus removing digits or compile-time versus runtime macro
quoting. These are rewritten, self-contained examples, not execution or
publication of the original scripts with their datasets and environment
paths. The source manifest records each filename, collection, byte size,
and SHA-256 hash. The original source files were read and hashed locally;
no changes were made to either code database.

See [tests/sas_library_source_manifest.json](tests/sas_library_source_manifest.json).
The harness rejects exact source duplicates within the batch and against
all three earlier catalogs. The scenario inventory was also reviewed against
the earlier case descriptions; hash uniqueness alone is not the evidence
for different scientific/programming behavior. Reruns and supplemental
regressions are not counted as new examples.

### Exact Cygwin commands used

From the MCP4SAS checkout, the discovery server and run were:

```bash
export PATH=/usr/bin:$PATH
SAS_ODA_AUTOLOAD_MACROS=0 OPEN_RESULT=0 \
  perl server.pl daemon -m production -l http://127.0.0.1:18134
```

In a second Cygwin terminal:

```bash
perl tests/run_live_new_examples_30.pl --live --batch 4 \
  --url http://127.0.0.1:18134/mcp \
  --library-root H:/F_Queens/360yunpan/SASCodesLibrary/SAS-Useful-Codes \
  > new_library100_initial.log 2>&1
```

After the diagnostic module was changed, the test server was restarted on
port `18135`, using the same startup options. The focused repair checks and
complete verification were:

```bash
perl tests/run_live_new_examples_30.pl --live --batch 4 \
  --only 91,92,94,96,145,148,150,153,168,180,181,182 \
  --url http://127.0.0.1:18135/mcp \
  --library-root H:/F_Queens/360yunpan/SASCodesLibrary/SAS-Useful-Codes \
  > new_library100_repairs.log 2>&1

perl tests/run_live_new_examples_30.pl --live --batch 4 \
  --url http://127.0.0.1:18135/mcp \
  --library-root H:/F_Queens/360yunpan/SASCodesLibrary/SAS-Useful-Codes \
  > new_library100_verified.log 2>&1
```

The historical harness filename contains `30`; batch 4 deliberately
requires exactly 100 cases. `--library-root` verifies the selected original
files against their recorded SHA-256 hashes. It can be omitted when those
libraries are unavailable: generated SAS inputs are self-contained and
retain their source provenance from the committed manifest.

```bash
perl tests/run_live_new_examples_30.pl --generate-only --batch 4
perl tests/run_live_new_examples_30.pl --live --batch 4 --only 91 \
  --url http://127.0.0.1:18135/mcp
```

### Inventory of all 100 scenarios

In the source column, **E** denotes `Easy-For-Error-Codes-SAS` and **D**
denotes `SAS_Code_Database`. Every final case retains its collection,
filename, SHA-256 source hash, full generated SAS code, individual MCP
responses, and expected outcome in `catalog.json`/`results.json`.
The exact generated code is also available from the maintained Perl catalog.

| ID | Scenario | Expected calculation or condition | Library source |
| --- | --- | --- | --- |
| 91 | `str_escaped_apostrophe` | `value="'"` | E:demo of bquote unquote str to add single and double quote for macro variable.sas |
| 92 | `str_escaped_open_parenthesis` | `value='('` | E:escape_square_by_str_or_nrquote.sas |
| 93 | `str_escaped_close_parenthesis` | `value=')'` | E:escape_square_by_str_or_nrquote.sas |
| 94 | `nrstr_unexecuted_macro_call` | `value='%e94_not_executed()'` | D:nrstr to mask macro command and not run it.sas |
| 95 | `nrstr_deferred_ampersand` | `value='&e95name'` | E:nrbquote_will_mask_macro_var_but_resolove_it_later_without_using_unquote.sas |
| 96 | `bquote_unmatched_apostrophe` | `value="O'Brien"` | E:demo of bquote unquote str to add single and double quote for macro variable.sas |
| 97 | `nrstr_embedded_semicolon` | `value='alpha;beta'` | E:use_macro_language_generate_if_conditions..sas |
| 98 | `parmbuff_argument_count` | `n=3` | D:macro qscan syspbuff parmbuff if else eval together with array for making combinations.sas |
| 99 | `indirect_macro_lookup` | `value='beta'` | E:resolve_macro_var_with_same_prefix_and_represented_by_a_macro_var.sas |
| 100 | `macro_descending_do_by` | `total=9` | E:Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas |
| 101 | `macro_return_guard` | `value=101` | E:Macro return to stop macro but not affect other part of the program.sas |
| 102 | `dosubl_immediate_state` | `rc=0 and value=102` | D:dosubl within proc sql to access macro var within it.sas |
| 103 | `sql_into_ordered_list` | `value='1\|2\|3'` | E:Proc SQL select into with order to control macro order.sas |
| 104 | `sql_into_numbered_macros` | `total=9` | E:creat multiple macro var with proc sql with count function No need for cat function.sas |
| 105 | `macro_large_integer_precision` | `value=1234567890123` | E:Need2use_put_when_save_large_number_into_macro_var.sas |
| 106 | `countc_character_occurrences` | `n=7` | E:count all characters using countc but not countw or count.sas |
| 107 | `countw_empty_token_modifier` | `ordinary=3 and empty=5` | E:countc_demo.sas |
| 108 | `scan_missing_middle_token` | `missing(value)` | E:When infile too many missing data, need to use dsd with dlm and add m for scan.sas |
| 109 | `scan_reverse_word` | `value='last'` | D:Scan to find the first and last character of a string.sas |
| 110 | `scan_hex_tab_delimiter` | `value='second'` | E:Scan with different dilimeters.sas |
| 111 | `compress_remove_digits` | `value='AB'` | E:powerful function compress to remove black spaces and other digitor or characters.sas |
| 112 | `compress_keep_digits` | `value='123'` | E:powerful function compress to remove black spaces and other digitor or characters.sas |
| 113 | `compress_all_whitespace` | `value='ab'` | E:powerful function compress to remove black spaces and other digitor or characters.sas |
| 114 | `compress_punctuation` | `value='abc123'` | E:powerful function compress to remove black spaces and other digitor or characters.sas |
| 115 | `cats_both_end_blanks` | `value='ab'` | D:cat demo.sas |
| 116 | `catt_preserves_leading_blanks` | `value=' a b'` | D:cat demo.sas |
| 117 | `cat_preserves_field_padding` | `index(value,'B')=4` | D:cat demo.sas |
| 118 | `catx_numeric_conversion` | `value='id:12'` | E:use catx to link character and number.sas |
| 119 | `upcase_sql_filter` | `n=2` | D:Function upcase in Proc SQL.sas |
| 120 | `sysfunc_lowercase_text` | `value='mixed'` | D:Macro use base function with sysfunc for upcase and lowcase.sas |
| 121 | `lengthn_blank_difference` | `ordinary=1 and nonblank=0` | D:Length function in where conditions.sas |
| 122 | `lengthc_storage_padding` | `stored=10 and visible=3` | E:Length function in proc sql.sas |
| 123 | `substr_assignment` | `value='abXYef'` | D:reshape long line into short lines wit specific length.sas |
| 124 | `trim_strip_difference` | `a=' alpha' and b='alpha'` | E:when making numeric macro variable, need to use trim left to remove leading space.sas |
| 125 | `tranwrd_all_occurrences` | `value='bb-bb'` | E:parse_grasp_covid_database_using_transwrd_and_prxmatch.sas |
| 126 | `translate_character_mapping` | `value='123'` | D:cat demo.sas |
| 127 | `find_case_insensitive` | `position=3` | E:SAS Function Find(string,substrin) Demo.sas |
| 128 | `indexc_any_character` | `position=5 and absent=0` | E:SAS Function Find(string,substrin) Demo.sas |
| 129 | `prxchange_preserves_original` | `original='a-b' and changed='a_b'` | E:Function prxchange need to asign changed variable to a new variable.sas |
| 130 | `prxchange_strip_before_anchor` | `value='def'` | E:Need to use strip in prxchange.sas |
| 131 | `prxmatch_ignore_case` | `position=3` | E:prxmatch with modifer for case sensitive with i and match once with o.sas |
| 132 | `prxsubstr_match_bounds` | `position=2 and size=3` | D:PXRParse PRXsubstr and function quote Demo.sas |
| 133 | `prxchange_escaped_slash` | `value='a_b_c'` | E:excape path slash in prxchange for replace with prxchange.sas |
| 134 | `varying_width_input` | `width=3 and name='abc'` | D:informat Varyingw. Demo.sas |
| 135 | `input_buffer_trailing_at` | `id=1 and label='beta' and score=7 and raw='1 beta 7'` | E:use_input_trailing_at_to_add_line_as_vars_with_another_input_command.sas |
| 136 | `double_trailing_at_records` | `n=4 and total=10` | D:Function @@ with Array or Lag to select specific Rows.sas |
| 137 | `multiline_input_record` | `id=1 and score=9` | D:Multiple lines input data in Data step and Proc compare ID usage demo.sas |
| 138 | `absolute_input_pointer` | `id=1 and name='ABC'` | D:Multiple lines input data in Data step and Proc compare ID usage demo.sas |
| 139 | `ampersand_list_input` | `name='Mary Jane' and score=7` | E:Scan with different dilimeters.sas |
| 140 | `truncover_short_record` | `a='abc' and missing(b)` | D:datastep infile function Demo of truncover and scanover to omit lines that do not contain specific word.sas |
| 141 | `dsd_empty_numeric_field` | `a=1 and missing(b) and c=3` | E:When infile too many missing data, need to use dsd with dlm and add m for scan.sas |
| 142 | `scanover_skip_nonmatching` | `strip(phone)='555-1234'` | D:datastep infile function Demo of truncover and scanover to omit lines that do not contain specific word.sas |
| 143 | `infile_firstobs_obs` | `n=3 and total=9` | E:read range of lines using proc import function datarow with option obs.sas |
| 144 | `quiet_informat_failure` | `missing(value)` | D:length and informat for char and number in infile procedure.sas |
| 145 | `invalue_character_to_numeric` | `a=0 and b=1` | D:format character into number with proc format comment invalue.sas |
| 146 | `inputn_dynamic_informat` | `value=12.5` | D:Function Put and PutC demo.sas |
| 147 | `putn_dynamic_format` | `strip(value)='12.5'` | D:Function Put and PutC demo.sas |
| 148 | `putc_dynamic_character_format` | `value='YES'` | D:Function Put and PutC demo.sas |
| 149 | `hexadecimal_space_literal` | `value=32` | D:20 x as space separator.sas |
| 150 | `put_no_default_separator` | `value='AB'` | E:file function to output data without default space separator.sas |
| 151 | `tab_delimited_file_output` | `id=1 and label='gene'` | D:File function to output tab separated file.sas |
| 152 | `file_header_then_values` | `value=55` | D:Add Header to new data file with FILE function.sas |
| 153 | `put_at_concatenated_records` | `compress(value)='ab'` | D:Put all rows into one line with file and _at_ function.sas |
| 154 | `fdelete_owned_work_file` | `before=1 and rc=0 and after=0` | D:create temp file in WORK dir and then delete it with fdelete and filename function.sas |
| 155 | `fread_end_of_file_count` | `n=3 and rc ne 0 and closed=0` | E:Working with data in the Data Step input buffer.sas |
| 156 | `datasets_column_rename` | `new=156` | D:Rename column names with proc datasets.sas |
| 157 | `array_explicit_name_order` | `second='d'` | E:array_will_NOT_sort_varnames_automatically.sas |
| 158 | `call_sortn_temporary_array` | `first=1 and second=3 and last=7` | E:sortn_for_sorting_array_in_data_step.sas |
| 159 | `ranperm_permutation_invariants` | `good=1` | E:generate_random_orders4array_with_ranperm_function.sas |
| 160 | `retain_column_reordering` | `good=2` | D:Order dataset Columns according to user input order with Retain.sas |
| 161 | `by_notsorted_segments` | `n=3` | D:Function Notsorted Demo in SAS procedure proc freq.sas |
| 162 | `retain_character_accumulation` | `value='a,b,c'` | D:Powerful Retain to link multiple row elements into single row element.sas |
| 163 | `sum_statement_initialization` | `accumulator=6 and missing(ordinary)` | E:var_plus_num_in_data_step_will_retain_that_var_like_retain_function.sas |
| 164 | `until_while_initial_condition` | `a=0 and b=1` | D:Function do until vs do while with Array function Demo.sas |
| 165 | `sql_count_all_missing_column` | `rows=2 and nonmissing=0` | E:sql_count_generate_missing_value_if_whole_col_is_missing.sas |
| 166 | `sql_distinct_excludes_missing` | `n=2` | E:Count need work with Group in Proc SQL.sas |
| 167 | `sql_summary_remerge` | `n=3 and smallest=6 and largest=6` | D:Proc SQL with Sum Function.sas |
| 168 | `sql_rowwise_max_arguments` | `value=5` | D:Proc SQL Max function like numeric operator.sas |
| 169 | `sql_rowwise_min_arguments` | `total=3` | D:Function min and scan in Proc SQL.sas |
| 170 | `sql_not_in_filter` | `value=2` | D:not in function and obs function in Proc SQL.sas |
| 171 | `where_contains_operator` | `text='gene_A'` | E:contains works with where or in proc sql but not if condition.sas |
| 172 | `if_contains_is_invalid` | `Expected SAS failure: ERROR\s+\d+-\d+` | E:contains works with where or in proc sql but not if condition.sas |
| 173 | `sql_like_escape_literal_underscore` | `text='gene_A'` | E:contains works with where or in proc sql but not if condition.sas |
| 174 | `sql_except_set_difference` | `n=2 and total=4` | E:Need to assign single vairible in Except procedure_Proc SQL to select unique rows from the first table.sas |
| 175 | `sql_intersect_common_values` | `value=2` | D:Proc SQL to select unique rows from the first table.sas |
| 176 | `outer_union_corr_columns` | `n=2 and a=10 and b=20` | D:outer union corr keep all columns from other tables.sas |
| 177 | `keep_only_singleton_keys` | `value=2` | E:keep_records_with_only_one_record_not_use_nodupkeys.sas |
| 178 | `composite_index_create_delete` | `before=2 and after=0` | D:make index with proc datasets.sas |
| 179 | `composite_index_name_collision` | `Expected SAS failure: index\|same name` | D:Delete SAS Index and Tips on Create Index in Proc SQL.sas |
| 180 | `exclusive_format_boundary` | `a='unknown' and b='young' and c='middle'` | D:number range format.sas |
| 181 | `delete_then_recreate_format` | `value='new'` | E:delete previous format before creating a new format.sas |
| 182 | `character_format_other_category` | `value='unknown'` | D:Function Put and PutC demo.sas |
| 183 | `probit_probability_to_z` | `abs(center)<1e-10 and abs(upper-1.9599639845)<1e-8` | E:probit function to get Z score based on P.sas |
| 184 | `binomial_tail_probability` | `abs(value-0.3125)<1e-12` | E:calculate binomial P.sas |
| 185 | `mod_floating_remainder` | `abs(value-0.1)<1e-8` | E:mod_demo.sas |
| 186 | `mod_negative_dividend` | `value=-1` | E:mod_demo.sas |
| 187 | `normal_cdf_inverse` | `abs(center-0.5)<1e-12 and abs(restored-0.025)<1e-10` | E:probit function to get Z score based on P.sas |
| 188 | `fisher_z_inverse_formula` | `abs(z-0.5493061443)<1e-9 and abs(restored-0.5)<1e-10` | E:Fisher's Z transformation and combine correlation form different dataset.sas |
| 189 | `circle_trigonometric_identity` | `abs(x*x+y*y-1)<1e-12` | E:draw_a_circle_with_sin_and_cos.sas |
| 190 | `iml_row_sums` | `n=2 and smallest=6 and largest=15` | E:row_sum_in_iml.sas |

### Failures observed and corrections

The first complete live run passed 90/100 validations in
`SAS_Output_real30_hJ_ELz`. These were actual ODA submissions through the
HTTP MCP tool, not mocked executions. Each case checked its calculation
marker or expected error, worker exit, MCP error flag, structured status,
HTML retention where applicable, and completed-job marker cleanup.

Cases 91, 92 and 96 exposed false preflight errors for `%str(%')`,
`%str(%()` and `%bquote(O'Brien)`. The source scanner now balances macro
quoting functions and recognizes percent-escaped delimiters while retaining
real unterminated-code errors and original line offsets. Case 94 also
revealed an unnecessary macro loader injected for literal text. Dependency
analysis now excludes NRSTR bodies and ordinary single-quoted DATA text;
evaluated double-quoted calls, BQUOTE calls, CALL EXECUTE and DOSUBL code
remain visible.

Five failures (145, 148, 180, 181, 182) were mistakes in the generated
examples: their format names ended in digits. The examples were corrected,
and PROC FORMAT declarations with these names now receive a nonfatal
advisory before submission. SAS still decides validity and its errors are
reported normally. Examples 150 and 153 also needed correction: formatted
INPUT crossed short physical records and read no observations. TRUNCOVER
was added to those examples; case 150's PUT statement was corrected to the
source-library pattern `put a +(-1) b;`. The runner does not silently rewrite
users' INPUT semantics. Actual flowover and empty-dataset notes are now
available as structured advisory diagnostics.

The focused repair run passed 10/12 checks in `SAS_Output_real30_XgonGR`;
the remaining case 94 dependency issue and case 150 delimiter assertion
were corrected before the complete verification. The final run in
`SAS_Output_real30_WSPsRM` passed **100/100**, comprising **98 successful
jobs and two intentional failures**, cases 172 and 179. These deliberate
syntax/index errors verified correct failure reporting and were not
converted into success. All 80 selected library files matched their
recorded hashes. Exact SAS source was checked against the preceding 90
examples to prevent duplicate submissions.

### Supplemental live checks and regression tests

Two additional diagnostic probes passed 8/8 assertions in
`SAS_Output_library_probe_VK2dsQ`: a short physical file produced real INPUT
flowover/empty-data notes without failing the job, while an invalid format
name produced both its advisory and an actual failed SAS job. An initial
probe mistakenly used padded DATALINES and was replaced by a physical
temporary file; these probes are not counted among the 100 cases.

An additional include test uncovered a genuine transfer failure for a
filename containing an apostrophe and a space. Active `%include` discovery
now uses matching quote delimiters and ignores masked NRSTR and ordinary
single-quoted DATA literals. Apostrophe-containing upload filenames use a
safely named ZIP transfer, extract to the original remote filename and
verify the byte count. This avoids SASPy's direct single-quoted destination
handling in both session modes. The fixture is uniquely named, and only
that uploaded fixture is deleted after the test. Its final calculation,
retained HTML, ignored masked include and remote cleanup passed 5/5
assertions. This test is supplemental, not case 191.

Reproduce these checks in Cygwin from the repository root:

```bash
export PATH=/usr/bin:$PATH
perl tests/check_library_diagnostics_live.pl --live \
  --url http://127.0.0.1:18135/mcp
perl tests/test_live_include_literal_paths.pl --live
prove tests/test_comment_quote_preflight.pl \
  tests/test_inline_data_preflight.pl tests/test_inline_macro_preflight.pl \
  MCPDeps/test_sas_log_and_labels.pl tests/test_mcp_job_reporting.pl \
  tests/test_sas_log_diagnostics.pl tests/test_macro_quoting_preflight.pl \
  tests/test_format_name_advisory.pl MCPDeps/test_sas_oda_include_lookup.pl \
  tests/test_quoted_filename_upload.pl
perl -I MCPDeps -c MCPDeps/SAS_ODA_Runner.pm
perl -c run_sas_codes_or_files_in_ODA.pl
perl -c run_sas_codes_or_script_in_ODA.pl
```

The offline checks passed 238 assertions (230 across the first nine files,
plus eight upload-routing assertions). The maintained smoke example is
`examples/sas_library_macro_quote_smoke.sas`. The shared runner fixes were
also checked in the companion repository. Test generation, orchestration
and regression tests use Perl/Bash; the existing SASPy transport remains
the backend. Runtime output directories and logs remain local; publication
includes maintained source, examples, provenance, tests and this report.

## 11. Second library-derived batch: 100 new cases (191–290)

This batch responds to the request for another 100 newly generated real
examples. It adds cases 191–290 rather than repeating the preceding 190.
The Perl catalogue is `tests/new_examples_191_290.pl`, adapted from 49
additional source files in the same two library collections. The selected
files' SHA-256 hashes are recorded in `tests/sas_library_source_manifest.json`.
Original library files remain unchanged; generated examples use synthetic
data and owned WORK files rather than the original external datasets.

The examples cover nested/evaluated macro quoting, SQL set operations,
join cardinality, correlated updates, views, merge precedence, conditional
LAG queues, metadata, filesystem handles, rankings, scaling, regression,
Wilcoxon output, transpose, multiple testing, ODS, graphics, regex capture,
missing values and date/datetime units. Cases 288–290 intentionally exercise
three genuine SAS errors: duplicate transpose IDs, an ambiguous SQL column
and the nonexistent WORD function.

Duplicate checks now normalize generated IDs and whitespace, so an earlier
example cannot qualify merely through renaming. Batch 5 also rejects
unexpected structured warnings and data-quality notes on successful cases.
Expected warnings in 230, 253 and 264 are explicitly checked, preserving
the distinction between an advisory and a failed SAS job.

### Cygwin commands

Terminal 1, from the MCP4SAS repository root:

```bash
export PATH=/usr/bin:$PATH
SAS_ODA_AUTOLOAD_MACROS=0 OPEN_RESULT=0 \
  perl server.pl daemon -m production -l http://127.0.0.1:18136
```

Terminal 2:

```bash
export PATH=/usr/bin:$PATH
perl tests/run_live_new_examples_30.pl --generate-only --batch 5 \
  --library-root H:/F_Queens/360yunpan/SASCodesLibrary/SAS-Useful-Codes
perl tests/run_live_new_examples_30.pl --live --batch 5 \
  --url http://127.0.0.1:18136/mcp \
  --library-root H:/F_Queens/360yunpan/SASCodesLibrary/SAS-Useful-Codes \
  > new_library100_batch5_initial.log 2>&1
```

The `--library-root` option verifies the original library snapshot; omit
it to run the self-contained generated examples elsewhere. Test orchestration
and generation use Perl/Bash and the existing SASPy backend.

### New example catalogue

`E:` identifies Easy-For-Error-Codes-SAS; `D:` identifies SAS_Code_Database.
The oracle is a checked numerical/text condition unless the case expects
an actual failed job.

| ID | Example | Oracle | Library source |
|---|---|---|---|
| 191 | `nested_nrstr_inside_bquote` | `value='%e191_literal()'` | D:nrstr qcmpres cmpres demo.sas |
| 192 | `nrstr_inside_evaluated_double_quote` | `value='%e192_literal()'` | D:nrstr qcmpres cmpres demo.sas |
| 193 | `macro_quote_escaped_double_quote` | `value='"'` | D:Resolve Macro varible with _bquote_ and _str_ in SAS Macro.sas |
| 194 | `superq_masked_comma_arguments` | `value='left,right'` | D:nrstr qcmpres cmpres demo.sas |
| 195 | `symget_dynamic_lookup` | `total=34` | D:symget functions like that of a hash.sas |
| 196 | `symputx_local_scope` | `value='inner' and symget('e196value')='outer'` | D:symget functions like that of a hash.sas |
| 197 | `dosubl_synchronous_result` | `rc=0 and value=42` | D:Run macro repeatedly with macro dosubl.sas |
| 198 | `cards4_embedded_macro_tokens` | `n=37` | E:datalines4 demo.sas |
| 199 | `regex_literal_percent_dependency` | `value='foo'` | E:prxposn need to be used with prxparse and prxmatch.sas |
| 200 | `macro_nrstr_comment_like_text` | `index(value,'alpha;')>0` | D:nrstr qcmpres cmpres demo.sas |
| 201 | `sql_union_distinct` | `n=3 and total=6` | D:Proc SQL Except  Union Union all Intersect Demo.sas |
| 202 | `sql_union_all_bag` | `n=5 and total=10` | D:Proc SQL Except  Union Union all Intersect Demo.sas |
| 203 | `sql_except_distinct` | `n=1 and total=1` | D:Proc SQL Except  Union Union all Intersect Demo.sas |
| 204 | `sql_intersect_distinct` | `n=1 and total=2` | D:Proc SQL Except  Union Union all Intersect Demo.sas |
| 205 | `sql_except_all_bag` | `n=2 and total=3` | D:Proc SQL Except  Union Union all Intersect Demo.sas |
| 206 | `sql_intersect_all_bag` | `n=1 and total=2` | D:Proc SQL Except  Union Union all Intersect Demo.sas |
| 207 | `sql_full_join_coalesced_key` | `n=3 and total=6 and av=30 and bv=500` | D:Proc SQL Full Join with Function Coalesce.sas |
| 208 | `sql_duplicate_right_join_multiplicity` | `n=2 and total=9` | E:Be caution about Proc SQL Left Join when there are duplicates in the right table.sas |
| 209 | `sql_not_exists_antijoin` | `n=1 and total=1` | D:Proc SQL Full Join with Function Coalesce.sas |
| 210 | `sql_correlated_update` | `total=17 and n=3` | D:Proc SQL update Demo.sas |
| 211 | `sql_delete_subset` | `n=3 and total=9` | D:Proc SQL delete Demo.sas |
| 212 | `sql_view_reads_updated_base` | `answer=21` | D:Proc SQL View Demo.sas |
| 213 | `sql_case_nullable_category` | `n=3` | D:Proc SQL with conditions by using case function.sas |
| 214 | `sql_having_only_singletons` | `n=1 and value=1` | D:Proc SQL function Group with having conditions.sas |
| 215 | `sql_column_mean_missing_denominator` | `value=5 and nonmissing=2 and allrows=3` | E:different usage of avg and mean in proc sql.sas |
| 216 | `sql_row_mean_multiple_arguments` | `total=11 and n=2` | E:different usage of avg and mean in proc sql.sas |
| 217 | `sql_calculated_alias_filter` | `total=25` | D:Proc SQL with conditions by using case function.sas |
| 218 | `sql_outer_union_corr_columns` | `n=2 and total=5` | D:Proc SQL Except  Union Union all Intersect Demo.sas |
| 219 | `sql_left_join_unmatched_missing` | `n=1 and total=9` | D:Proc SQL Full Join with Function Coalesce.sas |
| 220 | `sql_select_into_trimmed_list` | `value='3&#124;2&#124;1'` | D:Proc contents output variable information without ODS print.sas |
| 221 | `merge_last_dataset_overwrites` | `value=20` | E:Merge Function IMPORTANT NOTES.sas |
| 222 | `merge_in_flags_inner_only` | `n=2 and total=5` | E:Merge Function IMPORTANT NOTES.sas |
| 223 | `conditional_lag_queue` | `value=2 and n=1` | E:lag_with_by_and_last_statement.sas |
| 224 | `by_group_lag_reset` | `total=2 and n=2` | E:lag_with_by_and_last_statement.sas |
| 225 | `by_first_last_bounds` | `total=4 and n=2` | E:output_first_and_last_record_by_grp_at_the_same_row.sas |
| 226 | `temporary_array_retention` | `a=6 and b=6` | D:temporary numeric array.sas |
| 227 | `character_array_lookup_order` | `value='alpha'` | E:assign_number_to_alphabet_word.sas |
| 228 | `special_missing_comparison_order` | `value=1 and n=2` | D:specify mssing types in data step.sas |
| 229 | `select_when_default_category` | `label='other'` | D:Select When function in data step.sas |
| 230 | `append_force_extra_variable` | `n=2 and total=3` | D:Proc Append Demo.sas |
| 231 | `contents_variable_type_counts` | `n=2 and chars=1 and width=8` | D:Proc contents output variable information without ODS print.sas |
| 232 | `dataset_nlobs_handle_closed` | `n=4 and rc=0` | D:Retrieve the number of observations in a dataset.sas |
| 233 | `view_exist_type_selector` | `isview=1 and isdata=0` | D:Verifying the existence of a SAS dataset.sas |
| 234 | `missing_dataset_open_returns_zero` | `dsid=0` | D:Verifying the existence of a SAS dataset.sas |
| 235 | `work_directory_handle_lifecycle` | `opened=1 and n>=0 and closed=0 and cleared=0` | D:SAS file function dopen dnum dread Demo.sas |
| 236 | `work_owned_directory_create_remove` | `lengthn(path)>0 and exists=1 and deleted=0` | E:create dir in sas data step with dcreate.sas |
| 237 | `work_file_rename_verified` | `rc=0 and exists=1 and deleted=0` | D:Rename file, dataset and directory Demo.sas |
| 238 | `dataset_rename_function` | `value=7 and existsold=0` | D:Rename file, dataset and directory Demo.sas |
| 239 | `contents_label_format_preservation` | `label='library value' and format='COMMA' and formatl=12 and formatd=2` | D:Proc contents output variable information without ODS print.sas |
| 240 | `dictionary_columns_work_lookup` | `n=2 and width=12` | D:Proc contents output variable information without ODS print.sas |
| 241 | `rank_ties_low` | `value=1` | E:proc rank with tiers.sas |
| 242 | `rank_ties_high` | `value=2` | E:proc rank with tiers.sas |
| 243 | `rank_ties_mean` | `value=1.5` | E:proc rank with tiers.sas |
| 244 | `rank_ties_dense` | `value=1` | E:proc rank with tiers.sas |
| 245 | `rank_groups_zero_based` | `low=0 and high=1 and total=2` | E:proc rank with tiers.sas |
| 246 | `standard_sample_zscores` | `abs(total)<1e-10 and abs(low+1)<1e-10 and abs(high-1)<1e-10` | E:colwide z score with proc standard.sas |
| 247 | `stdize_range_endpoints` | `low=0 and high=1 and abs(total-1.25)<1e-10` | E:scale data to range with proc stdize but not proc standard.sas |
| 248 | `reg_perfect_line_residuals` | `maxerr<1e-10 and n=5` | D:output residual in proc reg for simple regression.sas |
| 249 | `reg_outest_intercept_slope` | `abs(intercept-5)<1e-10 and abs(x+2)<1e-10` | D:output residual in proc reg for simple regression.sas |
| 250 | `wilcoxon_two_group_ods_capture` | `n>0` | D:Wilcoxon rank sum test_Mann Whitney U test Demo.sas |
| 251 | `transpose_wide_to_long_names` | `n=2 and total=12 and names=2` | D:SAS transpose long to wide and wide to long Demo Very useful.sas |
| 252 | `transpose_long_to_wide_id` | `x=4 and y=8` | D:SAS transpose long to wide and wide to long Demo Very useful.sas |
| 253 | `transpose_let_duplicate_last` | `v1=9` | D:SAS transpose long to wide and wide to long Demo Very useful.sas |
| 254 | `compare_equal_sysinfo` | `value=0` | D:Compare two datasets with Proc compare.sas |
| 255 | `compare_unequal_sysinfo` | `value>0` | D:Compare two datasets with Proc compare.sas |
| 256 | `multtest_bonferroni_raw_p` | `abs(low-.03)<1e-10 and abs(high-.60)<1e-10` | D:Proc Multtest for P value adjustment.sas |
| 257 | `fdr_manual_monotone_stepup` | `abs(low-.03)<1e-10 and abs(high-.20)<1e-10` | D:simple FDR for raw P values.sas |
| 258 | `cmiss_mixed_types` | `n=2` | E:cmiss_function2get_missing_variables_among_variables.sas |
| 259 | `iml_nonmissing_mask_count` | `n=4` | E:get_index_for_nonmissing_values_in_proc_iml.sas |
| 260 | `fcmp_work_function` | `value=49` | D:proc fcmp Demo.sas |
| 261 | `ods_select_none_capture_moments` | `n>0` | D:ODS alternative for NOPRINT.sas |
| 262 | `ods_recover_after_freq_suppression` | `value=1` | E:recover ods with ods select all after using ods select none.sas |
| 263 | `freq_ods_crosstab_capture` | `n=9` | E:ODS output Tables failed with noprint in Proc Freq.sas |
| 264 | `freq_noprint_ods_missing_warning` | `captured=0` | E:ODS output Tables failed with noprint in Proc Freq.sas |
| 265 | `report_nowd_computed_column` | `total=7` | D:HTML output with Proc report Demo_create link for all elements in columns.sas |
| 266 | `sgplot_scatter_group` | `y=x*grp` | D:proc sgplot demo.sas |
| 267 | `sgplot_series_sorted` | `y=x*x` | D:proc sgplot demo.sas |
| 268 | `sgplot_histogram_density` | `x>=1 and x<=20` | D:proc sgplot demo.sas |
| 269 | `sgplot_vbar_response_sum` | `value>=1 and value<=3` | D:proc sgplot demo.sas |
| 270 | `sgplot_refline_and_inset` | `x=y` | D:proc sgplot demo.sas |
| 271 | `prxposn_capture_numeric_suffix` | `matched=1 and value='42'` | E:prxposn need to be used with prxparse and prxmatch.sas |
| 272 | `prxsubstr_match_position_length` | `pos=4 and len=3` | E:prxposn need to be used with prxparse and prxmatch.sas |
| 273 | `prxnext_multiple_matches` | `total=5` | E:prxposn need to be used with prxparse and prxmatch.sas |
| 274 | `prxchange_reverse_capture_order` | `value='beta:alpha'` | E:prxchange_replace_elements_within_multiple_quotes.sas |
| 275 | `prxchange_remove_quote_pairs` | `value='one two'` | E:prxchange_replace_elements_within_multiple_quotes.sas |
| 276 | `ifc_missing_third_branch` | `value='missing'` | D:SAS Function Missing and IFC Demo.sas |
| 277 | `coalescec_first_nonblank` | `value='alpha'` | D:SAS Function Missing and IFC Demo.sas |
| 278 | `missing_numeric_char_combination` | `n=2` | D:SAS Function Missing and IFC Demo.sas |
| 279 | `vvalue_formatted_numeric_text` | `value='1,234.5'` | D:Proc contents output variable information without ODS print.sas |
| 280 | `vname_array_index_metadata` | `upcase(value)='BETA'` | D:temporary numeric array.sas |
| 281 | `intck_month_discrete_continuous` | `a=1 and b=0` | D:time format with do loop.sas |
| 282 | `intnx_leap_day_alignment` | `value='29feb2024'd` | D:time format with do loop.sas |
| 283 | `dhms_datepart_timepart_roundtrip` | `d='13oct2026'd and t=14*3600+25*60+30` | D:time format with do loop.sas |
| 284 | `mdy_leap_year_construct` | `y=2024 and m=2 and d=29` | D:time format with do loop.sas |
| 285 | `date_informat_iso_roundtrip` | `value='2026-10-13'` | D:time format with do loop.sas |
| 286 | `do_date_loop_day_step` | `n=3 and span=14` | D:time format with do loop.sas |
| 287 | `data_step_view_reexecution` | `value=14` | D:Proc SQL View Demo.sas |
| 288 | `transpose_duplicate_id_failure` | `Expected failure: occurs twice` | D:SAS transpose long to wide and wide to long Demo Very useful.sas |
| 289 | `sql_ambiguous_column_failure` | `Expected failure: ambiguous` | D:Proc SQL Full Join with Function Coalesce.sas |
| 290 | `undefined_word_function_failure` | `Expected failure: WORD.*unknown` | E:assign_number_to_alphabet_word.sas |

### Discovery results and improvements

The discovery pass in `SAS_Output_real30_5iO0gt` passed 90/100 checks.
Cases 191 and 192 computed the right values but wrongly injected targeted
macro loaders for NRSTR literals. The scanner now collects nested macro
quoting spans and recognizes macro functions evaluated inside double-quoted
SAS strings. NRSTR bodies remain masked in dependency analysis even when
nested in BQUOTE/QUOTE; actual evaluated dependencies remain visible.
Escaped macro double quotes no longer terminate the surrounding string.
Eight additional regression assertions cover these contexts and retained
real dependencies. The shared source-analysis module and regressions were
synchronized to all three active companion pipeline copies.

Three checks needed corrections in the generated test cases themselves.
Case 195's key defaulted to eight characters and truncated `e195_high`,
producing a real invalid-SYMGET NOTE and a wrong sum; `length key $32` fixes
the example. Case 198's raw text was 37 characters, not the original expected
35. Case 290 correctly failed with `ERROR 68-185`, but the original expected
phrase was `not found`; the observed message says `WORD is unknown`. Its
oracle now checks that actual diagnostic, preserving expected failure.
These are example/oracle corrections, not changes to SAS semantics.

Five discovery jobs (201–205) encountered a temporary Perl scanner syntax
error while the scanner was being edited during execution. They provide no
evidence of a SQL defect. The scanner was repaired immediately, and the
complete verification uses a frozen implementation for all 100 cases.

An offline cleanup regression initially misidentified an active live job's
scratch directory as its own leak. `test_mcp_job_reporting.pl` now runs in
an isolated temporary workspace, so its cleanup assertion checks only its
own job. Its 48 assertions pass while live jobs are active. A new five-check
regression verifies that changing generated IDs/whitespace cannot bypass
example uniqueness checks. Missing provenance and unknown source collections
are now rejected before submission. Batch 5 rejects unexpected advisory
diagnostics as well as wrong calculations and failure status.

### Verification commands

```bash
export PATH=/usr/bin:$PATH
perl tests/run_live_new_examples_30.pl --live --batch 5 \
  --url http://127.0.0.1:18136/mcp \
  --library-root H:/F_Queens/360yunpan/SASCodesLibrary/SAS-Useful-Codes \
  > new_library100_batch5_verified.log 2>&1
prove tests/test_comment_quote_preflight.pl \
  tests/test_inline_data_preflight.pl tests/test_inline_macro_preflight.pl \
  MCPDeps/test_sas_log_and_labels.pl tests/test_mcp_job_reporting.pl \
  tests/test_sas_log_diagnostics.pl tests/test_macro_quoting_preflight.pl \
  tests/test_format_name_advisory.pl MCPDeps/test_sas_oda_include_lookup.pl \
  tests/test_quoted_filename_upload.pl tests/test_example_uniqueness.pl
perl -I MCPDeps -c MCPDeps/SAS_Source_Analysis.pm
```

Offline checks passed **251 assertions across 11 Perl tests**. The companion
checks passed **113 assertions across eight Perl tests**. Its live compatibility
command was:

```bash
SAS_ODA_AUTOLOAD_MACROS=0 OPEN_RESULT=0 \
  perl run_sas_codes_or_files_in_SAS_ODA.pl \
  --file examples/sas_library_nested_quote_smoke.sas \
  --output-prefix SAS_Output_library_nested_quotes \
  --run-timeout-seconds 180
```

That live run exited 0, printed `LIBRARY_NESTED_QUOTE_OK`, injected no
targeted loaders for the literal macro names, and retained nonempty HTML
at `SAS_Output_library_nested_quotes/sas_res_8BVcF.html`. The standalone
example is also included in this repository. Runtime artifacts remain
local; source, new examples, hashes, regressions and this report are the
publication content.

### Final live outcome

The complete frozen-code rerun exited 0 and passed **100/100 validations**
in `SAS_Output_real30_Maf8p4`: **97 successful SAS jobs and three intentional
failed jobs** (288, 289, 290). All 49 original source hashes matched, and all
100 examples passed duplicate checks against the preceding 190 examples.
Successful jobs retained HTML and their computed markers, expected warnings
were surfaced as structured advisories, and intentional errors retained
failed status, nonzero exit, MCP error flags and their actual diagnostics.
Completion-marker cleanup was checked for every job.

The discovery and final terminal logs are retained locally in
`SAS_Output_library100_run_logs/new_library100_batch5_initial.log` and
`SAS_Output_library100_run_logs/new_library100_batch5_verified.log`.
Generated programs, per-job responses, diagnostics and the full results
JSON remain in the run directories. These runtime artifacts are excluded
from GitHub; the two repositories publish the maintained fixes and tests.

## 12. Third library-derived batch: 100 new cases (291–390)

Another 100 new examples were adapted from 42 additional library files.
The source catalogue is `tests/new_examples_291_390.pl`, and source hashes
are included in `tests/sas_library_source_manifest.json`. Originals remain
unchanged. All examples use synthetic data and owned WORK files rather
than original external datasets. ID/whitespace-normalized fingerprints
check the new sources against all preceding 290 examples.

The new cases cover CALL EXECUTE/DOSUBL semantics, hash mutation and
multidata iteration, held records, FILEVAR, CSV/ZIP/GZIP, array reshaping,
IML matrix operations, dataset/index management, frequency denominators,
beta distributions, FCMP/macro interaction, character functions and
redirected logs. Cases 389–390 intentionally fail: a missing dataset with
its error redirected by PRINTTO, and an undefined hash key.

### Cygwin commands

Terminal 1, from the repository root:

```bash
export PATH=/usr/bin:$PATH
SAS_ODA_AUTOLOAD_MACROS=0 OPEN_RESULT=0 \
  perl server.pl daemon -m production -l http://127.0.0.1:18137
```

Terminal 2:

```bash
export PATH=/usr/bin:$PATH
perl tests/run_live_new_examples_30.pl --generate-only --batch 6 \
  --library-root H:/F_Queens/360yunpan/SASCodesLibrary/SAS-Useful-Codes
perl tests/run_live_new_examples_30.pl --live --batch 6 \
  --url http://127.0.0.1:18137/mcp \
  --library-root H:/F_Queens/360yunpan/SASCodesLibrary/SAS-Useful-Codes \
  > new_library100_batch6_initial.log 2>&1
perl tests/run_live_new_examples_30.pl --live --batch 6 \
  --only 291,292,312,316,317,333,343,344,350,367,372,375,389,390 \
  --url http://127.0.0.1:18137/mcp \
  --library-root H:/F_Queens/360yunpan/SASCodesLibrary/SAS-Useful-Codes \
  > new_library100_batch6_repairs.log 2>&1
```

The dedicated HTTP test server was then restarted on port 18138 to load
the changed diagnostic module; the shared SASPy session service was not
stopped. With the same server startup options and port 18138:

```bash
perl tests/run_live_new_examples_30.pl --live --batch 6 \
  --only 366,367,372,389 --url http://127.0.0.1:18138/mcp \
  --library-root H:/F_Queens/360yunpan/SASCodesLibrary/SAS-Useful-Codes \
  > new_library100_batch6_guard_verified.log 2>&1
perl tests/run_live_new_examples_30.pl --live --batch 6 \
  --url http://127.0.0.1:18138/mcp \
  --library-root H:/F_Queens/360yunpan/SASCodesLibrary/SAS-Useful-Codes \
  > new_library100_batch6_verified.log 2>&1
```

The library-root option verifies the original snapshot; omit it when
running the self-contained cases without the H drive. Generation and
orchestration use Perl/Bash with the existing SASPy transport.

### Complete new case catalogue

`E:` refers to Easy-For-Error-Codes-SAS; `D:` refers to SAS_Code_Database.

| ID | Example | Oracle | Library source |
|---|---|---|---|
| 291 | `execute_nrstr_literal_dependency` | `value='%e291_literal()'` | D:dosubl vs call execut to run sas macro.sas |
| 292 | `dosubl_nrstr_literal_dependency` | `rc=0 and value='%e292_literal()'` | D:dosubl Demo with _str_ function and return var by macro.sas |
| 293 | `execute_data_step_is_deferred` | `observed='before' and symget('e293value')='after'` | D:dosubl vs call execut to run sas macro.sas |
| 294 | `dosubl_data_step_is_synchronous` | `rc=0 and observed='after'` | D:dosubl vs call execut to run sas macro.sas |
| 295 | `execute_generated_procedure` | `total=10` | D:dosubl vs call execut to run sas macro.sas |
| 296 | `dosubl_concat_split_arguments` | `rc=0 and value=23` | D:dosubl Demo with _str_ function and return var by macro.sas |
| 297 | `sysevalf_boolean_fraction` | `value=1` | D:sysevalf demo with macro SizeIt.sas |
| 298 | `sysevalf_integer_ceiling` | `value=3` | D:sysevalf demo with macro SizeIt.sas |
| 299 | `sysevalf_integer_floor` | `value=-3` | D:sysevalf demo with macro SizeIt.sas |
| 300 | `macro_sysfunc_dosubl_side_effect` | `value=31` | D:dosubl Demo with _str_ function and return var by macro.sas |
| 301 | `hash_check_does_not_load_data` | `rc=0 and value=99` | D:hash4bigdata_demo.sas |
| 302 | `hash_find_restores_data` | `rc=0 and value=10` | D:hash4bigdata_demo.sas |
| 303 | `hash_replace_existing_key` | `rc=0 and value=25` | D:hash4bigdata_demo.sas |
| 304 | `hash_remove_then_find_missing` | `removed=0 and rc ne 0 and n=0` | D:hash4bigdata_demo.sas |
| 305 | `hash_iterator_ordered_keys` | `smallest=1 and total=60` | D:hash4bigdata_demo.sas |
| 306 | `hash_multidata_find_next` | `total=11` | E:demo4hash_find_next_with_do_while_loop.sas |
| 307 | `hash_clear_all_entries` | `cleared=0 and n=0` | D:hash4bigdata_demo.sas |
| 308 | `hash_suminc_counter` | `total=3` | D:hash4bigdata_demo.sas |
| 309 | `hash_duplicate_add_rejected` | `duplicate ne 0 and value=4` | E:demo4hash_find_next_with_do_while_loop.sas |
| 310 | `hash_tree_parent_chain` | `depth=2 and root=1` | E:demo4hash_find_next_with_do_while_loop4tree_branches.sas |
| 311 | `input_at_hold_then_release` | `total=19 and n=2 and matches=2` | E:datastep_escape_columns_with_input_infile_and_scan.sas |
| 312 | `input_double_at_multiple_records` | `n=3 and total=6` | E:use @ and @@ to split data in the same line to separated rows.sas |
| 313 | `input_group_label_shared_fields` | `n=4 and total=100 and groups=2` | E:use @ and @@ to split data in the same line to separated rows.sas |
| 314 | `input_column_pointer_fixed_width` | `total=168` | E:use_double_and_single_at2read_multiple_lines_and_provide_common_variables_to_each_line.sas |
| 315 | `input_line_pointer_two_lines` | `total=46 and n=2` | E:use_double_and_single_at2read_multiple_lines_and_provide_common_variables_to_each_line.sas |
| 316 | `filevar_two_owned_files` | `n=2 and total=7` | E:Multiple files with infile statement only functional with dummy.sas |
| 317 | `csv_dsd_embedded_comma` | `word='alpha,beta' and value=7` | E:import_compressed_csv_file_with_quotes.sas |
| 318 | `csv_dsd_doubled_quote` | `word='author"s' and value=9` | E:import_compressed_csv_file_with_quotes.sas |
| 319 | `input_question_modifier_invalid_missing` | `missing(value) and _error_=0` | E:datastep_escape_columns_with_input_infile_and_scan.sas |
| 320 | `input_hexadecimal_informat` | `value=255` | E:datastep_escape_columns_with_input_infile_and_scan.sas |
| 321 | `import_csv_guessingrows_types` | `total=30 and n=2` | D:Proc Import with GuessingRows.sas |
| 322 | `import_pipe_delimited_no_headers` | `total=10` | D:very useful Proc Import with different delimiter in dbms_dlm part.sas |
| 323 | `file_dsd_export_roundtrip` | `word='a,b' and value=7` | D:export data with file function along with dlm to separate cols with specific delimiter.sas |
| 324 | `zip_member_owned_roundtrip` | `x=7 and y=11` | E:ImportFileHeadersFromZIP_works_with_variable_char_length_demo.sas |
| 325 | `gzip_owned_roundtrip` | `x=8 and y=12` | E:ImportFileHeadersFromZIP_works_with_variable_char_length_demo.sas |
| 326 | `array_wide_to_long_named_columns` | `n=2 and total=10 and names=2` | D:Use array, especially temporary array of colnames, to change wide form data into long format data.sas |
| 327 | `array_lower_bound_nonzero` | `value=10 and lower=0 and upper=2` | D:Use array, especially temporary array of colnames, to change wide form data into long format data.sas |
| 328 | `array_two_dimensional_row_major` | `value=3 and total=10` | D:Use array, especially temporary array of colnames, to change wide form data into long format data.sas |
| 329 | `array_call_sortn_order` | `low=1 and high=8` | E:randomply_select_columns_from_large_wide_table_using_temporary_array_with_ranperm.sas |
| 330 | `array_call_sortc_order` | `first='alpha' and last='zeta'` | D:Use array, especially temporary array of colnames, to change wide form data into long format data.sas |
| 331 | `ranperm_preserves_multiset` | `total=15 and low=1 and high=5` | E:randomply_select_columns_from_large_wide_table_using_temporary_array_with_ranperm.sas |
| 332 | `array_implicit_element_names` | `total=14` | E:data stop array to create variables.sas |
| 333 | `if_zero_set_nobs_without_read` | `count=7` | E:data stop array to create variables.sas |
| 334 | `genotype_sort_allele_pair` | `value='01'` | E:make_allele_columns_into_single_genotype_column.sas |
| 335 | `genotype_missing_guard` | `value='NA'` | E:make_allele_columns_into_single_genotype_column.sas |
| 336 | `iml_horizontal_concatenation` | `n=4 and total=10` | E:concatenate_vector_vertically_or_horizontally_in_iml.sas |
| 337 | `iml_vertical_concatenation` | `n=2 and total=10` | E:concatenate_vector_vertically_or_horizontally_in_iml.sas |
| 338 | `iml_shape_row_major` | `value=4` | E:concatenate_vector_vertically_or_horizontally_in_iml.sas |
| 339 | `iml_cshape_character_vector` | `value=4` | E:convert_string_into_vector_using_cshape_in_proc_iml.sas |
| 340 | `iml_loc_positive_indices` | `n=2 and total=7` | E:concatenate_vector_vertically_or_horizontally_in_iml.sas |
| 341 | `iml_matrix_product` | `value=22` | E:concatenate_vector_vertically_or_horizontally_in_iml.sas |
| 342 | `iml_inverse_identity` | `err<1e-10` | E:concatenate_vector_vertically_or_horizontally_in_iml.sas |
| 343 | `iml_determinant_trace` | `abs(determinant-3)<1e-10 and diagonal=4` | E:concatenate_vector_vertically_or_horizontally_in_iml.sas |
| 344 | `iml_current_dataset_contents` | `n=2` | E:proc_iml_to_get_sas_dataset_variable_names_using_contents.sas |
| 345 | `iml_choose_masked_values` | `total=5` | E:concatenate_vector_vertically_or_horizontally_in_iml.sas |
| 346 | `datasets_change_member_name` | `value=8 and oldexists=0` | D:Proc dataset change dataset name and copy with select to new lib.sas |
| 347 | `datasets_modify_variable_rename` | `renamed=9` | D:Delete datasets with Proc datasets.sas |
| 348 | `datasets_delete_selected_only` | `removed=1 and retained=1` | D:Delete datasets with Proc datasets.sas |
| 349 | `set_prefix_list_concatenation` | `n=2 and total=11` | D:Set multiple datasets with similar names in SAS.sas |
| 350 | `sort_dupout_counts_removed` | `kept=3 and removed=2` | D:Proc sort to output duplicates in new dataset.sas |
| 351 | `update_statement_missing_preserved` | `x=10 and y=30` | D:SAS Merge for update missing values from other dataset very useful.sas |
| 352 | `update_updatemode_nomissingcheck` | `missing(x)` | D:SAS Merge for update missing values from other dataset very useful.sas |
| 353 | `sql_ceil_bucket_assignment` | `total=9` | D:Proc SQL Works with Array Function as well as ceil index functions.sas |
| 354 | `dataset_simple_index_lookup` | `value=21` | D:SAS make Index codes.sas |
| 355 | `by_notsorted_contiguous_groups` | `n=2 and total=3` | D:SAS Function First.obs and Last.obs in datastep Demo.sas |
| 356 | `freq_by_group_percent_denominator` | `high=100 and low=50` | E:output proc freq summary with out function.sas |
| 357 | `freq_missing_category_included` | `n=3 and categories=2` | E:output proc freq summary with out function.sas |
| 358 | `freq_weighted_counts` | `n=10 and high=70` | D:ODA_fisher_test_demo_codes.sas |
| 359 | `fisher_exact_ods_rows` | `n>0` | D:ODA_fisher_test_demo_codes.sas |
| 360 | `sign_test_location_capture` | `n=3` | D:GWAS sign test with proc univariate.sas |
| 361 | `beta_uniform_cdf` | `abs(value-.3)<1e-10` | E:generate_random_beta_values.sas |
| 362 | `beta_symmetric_median` | `abs(value-.5)<1e-10` | E:generate_random_beta_values.sas |
| 363 | `beta_moments_parameter_recovery` | `alpha=2 and beta=2` | E:generate_random_beta_values.sas |
| 364 | `quantile_norm_sorted_column_means` | `total=9 and low=1.5 and high=4.5` | D:Quantile normalization demo.sas |
| 365 | `seeded_beta_draw_valid_range` | `low>0 and high<1` | E:generate_random_beta_values.sas |
| 366 | `printto_log_restore_success` | `value=12` | D:Proc Printto demo.sas |
| 367 | `printto_print_owned_listing` | `value=5` | D:Proc Printto output log to sepecific file demo.sas |
| 368 | `ods_exclude_none_restores_output` | `value=6` | E:ods select and exclude demo.sas |
| 369 | `glm_quit_before_ods_recovery` | `n=2` | E:add quit to restore ods output before using ods select none in proc glm.sas |
| 370 | `fcmp_macro_function_bridge` | `value=5` | D:proc fcmp demo with sas macro.sas |
| 371 | `ifn_missing_fourth_argument` | `value=11` | D:ifn demo for if not condition.sas |
| 372 | `ifn_uninitialized_input_advisory` | `value=11` | D:ifn demo for if not condition.sas |
| 373 | `compbl_internal_space_normalization` | `value='alpha beta'` | D:Use Strip and Compbl functions for SAS Infile Blank Space Sparated Files.sas |
| 374 | `translate_tab_to_space` | `value='a b'` | D:Use Strip and Compbl functions for SAS Infile Blank Space Sparated Files.sas |
| 375 | `compress_keep_alphabetic` | `value='abc'` | D:Use Strip and Compbl functions for SAS Infile Blank Space Sparated Files.sas |
| 376 | `scan_quoted_delimiter_modifier` | `value='"a,b"'` | E:import_compressed_csv_file_with_quotes.sas |
| 377 | `scan_empty_tokens_m_modifier` | `missing(value) and n=3` | E:import_compressed_csv_file_with_quotes.sas |
| 378 | `findw_whole_word_boundary` | `a=1 and b=0` | D:Use Strip and Compbl functions for SAS Infile Blank Space Sparated Files.sas |
| 379 | `substrn_out_of_range_nonfatal` | `missing(value)` | D:Use Strip and Compbl functions for SAS Infile Blank Space Sparated Files.sas |
| 380 | `repeat_count_is_extra_repetitions` | `value='ababab'` | D:Use Strip and Compbl functions for SAS Infile Blank Space Sparated Files.sas |
| 381 | `transtrn_remove_token` | `value='abc'` | D:Use Strip and Compbl functions for SAS Infile Blank Space Sparated Files.sas |
| 382 | `countc_character_set` | `value=3` | D:Use Strip and Compbl functions for SAS Infile Blank Space Sparated Files.sas |
| 383 | `sum_statement_missing_ignored` | `total=4` | E:data stop array to create variables.sas |
| 384 | `whichn_first_matching_position` | `value=2` | D:Use array, especially temporary array of colnames, to change wide form data into long format data.sas |
| 385 | `largest_order_statistic` | `value=7` | D:Quantile normalization demo.sas |
| 386 | `smallest_order_statistic` | `value=4` | D:Quantile normalization demo.sas |
| 387 | `geomean_positive_values` | `abs(value-4)<1e-10` | D:Quantile normalization demo.sas |
| 388 | `harmonic_mean_positive_values` | `abs(value-3)<1e-10` | D:Quantile normalization demo.sas |
| 389 | `printto_hidden_error_status` | `Expected failure: (?:E389_MISSING&#124;SYSCC)` | D:Proc Printto demo.sas |
| 390 | `hash_undefined_key_failure` | `Expected failure: (?:missing_key&#124;not.*declared)` | D:hash4bigdata_demo.sas |

### Observed failures and corrections

The discovery run in `SAS_Output_real30_AuYESW` passed 88/100 validations.
Cases 291 and 292 computed correct results but injected loaders for
NRSTR literals embedded in CALL EXECUTE/DOSUBL strings. Dependency analysis
now decodes doubled apostrophes in these code strings, analyzes their real
SAS lexical contexts and maps masking back to original offsets. Deferred
NRSTR and ordinary single-quoted DATA text remain literal, while actual
evaluated calls and active double-quoted include paths remain visible.
Twelve regressions cover those distinctions.

Case 389 exposed a real false-success bug: a missing dataset's ERROR was
redirected by PROC PRINTTO, and MCP reported COMPLETE with exit 0. Explicit
PRINTTO submissions now reset stale SYSCC before the job, restore logging
afterwards and emit a fatal summary when SYSCC is at least 8. Warning-only
condition codes remain nonfatal. The corrected live error reported
`SYSCC=1012`, a nonzero exit and failed MCP status. The redirected file itself
is not automatically downloaded; the default retained log points to it
through the condition-code summary. Ordinary submissions are unchanged.

Case 316 did not complete within the 180-second submit limit, and 317
subsequently lost that SAS process. No definitive remote log was returned,
so the remote failure's precise cause is unconfirmed. The fixture now reads
one FILEVAR path per input dataset row, with a bounded loop of at most ten
records per owned one-record file. Case 375 also had a separate remote
session-termination failure. The harness now selects a fresh session for
the next case after timeout/session-loss responses, retains the failed case
and never replays it automatically.

Other failures were generated-example corrections. Case 312 legitimately
uses DOUBLE-AT input and produces an end-of-line advisory; that note is now
explicitly expected and checked along with its correct count/sum. In 333,
automatic NOBS was not stored in the output dataset; an explicit `count=n`
retains it. The determinant in 343 needed a floating-point tolerance rather
than exact equality. Case 344 counts all elements of the IML contents vector
instead of assuming a row-vector orientation. The unsupported SELECT-list
scalar subqueries in 350 were replaced by two aggregate derived tables.
Case 367's fileref was too long; it now uses the valid `e367lst` name.

The fileref failure led to a nonfatal preflight advisory for literal
FILENAME names longer than eight characters. It excludes comments, string
data, valid names and macro-generated declarations. The uninitialized-NOBS
observation led to structured nonfatal diagnostics for actual uninitialized
variable NOTES. Case 372 now explicitly verifies that behavior; source
listing text cannot manufacture the diagnostic. Neither improvement
silently rewrites user SAS code or turns advisory notes into failed jobs.

The first focused repair pass passed 12/14 checks in
`SAS_Output_real30_iicHyH`. Its remaining failures revealed an unescaped
semicolon in the new status summary and an HTTP server still holding the
old diagnostic module. The summary was corrected and the dedicated HTTP
server restarted. All four follow-up checks passed in
`SAS_Output_real30_RI2NhS`, including both normal PRINTTO jobs, the
uninitialized-variable advisory and the actual redirected error.

### Offline and companion-runner verification

```bash
export PATH=/usr/bin:$PATH
prove tests/test_comment_quote_preflight.pl \
  tests/test_inline_data_preflight.pl tests/test_inline_macro_preflight.pl \
  MCPDeps/test_sas_log_and_labels.pl tests/test_mcp_job_reporting.pl \
  tests/test_sas_log_diagnostics.pl tests/test_macro_quoting_preflight.pl \
  tests/test_format_name_advisory.pl MCPDeps/test_sas_oda_include_lookup.pl \
  tests/test_quoted_filename_upload.pl tests/test_example_uniqueness.pl \
  tests/test_deferred_macro_literals.pl tests/test_printto_status_guard.pl \
  tests/test_fileref_name_advisory.pl
```

These checks passed **279 assertions across 14 Perl tests**. The companion
repository passed **141 assertions across 11 Perl tests**. Its public-wrapper
live checks used:

```bash
perl tests/test_live_deferred_and_printto.pl --live
```

All seven assertions passed in `SAS_Output_deferred_printto_tdbPRQ`:
deferred quoted calculations completed, no literal-name loaders were
injected, nonempty HTML was retained, and the real redirected error returned
a nonzero exit plus SYSCC summary without guard syntax errors. These are
supplemental compatibility checks, not additional numbered examples.
The portable smoke source is `examples/sas_library_deferred_quote_smoke.sas`.
Shared changes, tests and examples were synchronized to the three active
companion copies. Runtime outputs remain local.

### Final frozen-code outcome

The full rerun exited 0 and passed **100/100 validations** in
`SAS_Output_real30_Dxz4eN`: **98 successful jobs and two intentional failed
jobs** (389–390). All 42 original source hashes matched, and all new sources
passed ID/whitespace-normalized duplicate checks against the preceding
290 examples. Expected notes in 312 and 372 remained advisory; other
successful jobs had no unexpected warning/data-quality diagnostics.
Computed markers, retained HTML, full default logs, structured status,
MCP error flags, exit codes and completion-marker cleanup were validated.

The discovery, focused-repair, guard-verification and complete verification
terminal logs are retained in `SAS_Output_library100_run_logs/` with the
names `new_library100_batch6_initial.log`,
`new_library100_batch6_repairs.log`,
`new_library100_batch6_guard_verified.log` and
`new_library100_batch6_verified.log`. Program files, responses, results JSON
and HTML remain in their local run directories. Publication includes the
maintained fixes, catalogue, source hashes, Perl tests, smoke example and
this report; generated configurations, caches and runtime outputs remain
local.

## 13. Fourth library-derived batch: 100 new cases (391–490)

This batch adds 100 newly generated examples beyond cases 1–390, adapted
from 41 additional files in the same two library collections. The catalogue
is `tests/new_examples_391_490.pl`; the original file hashes are recorded
in `tests/sas_library_source_manifest.json`. The original scripts remain
unchanged. All cases use synthetic data, owned WORK files or uniquely
named local include fixtures. Normalized fingerprints reject earlier
sources changed only by generated IDs or whitespace.

The new cases cover deferred includes, name literals and attributes,
physical input and formats, libraries, SQL grouping/subqueries, comparisons,
correlation, GLM/logistic/survival output, meta-analysis formulas, IML,
reports, panels, graphics and scalar contracts. Cases 489–490 intentionally
fail for unsorted BY input and an aggregate function in a SQL WHERE clause.

### Cygwin commands

Terminal 1, from the repository root:

```bash
export PATH=/usr/bin:$PATH
SAS_ODA_AUTOLOAD_MACROS=0 OPEN_RESULT=0 \
  perl server.pl daemon -m production -l http://127.0.0.1:18139
```

Terminal 2:

```bash
export PATH=/usr/bin:$PATH
perl tests/run_live_new_examples_30.pl --generate-only --batch 7 \
  --library-root H:/F_Queens/360yunpan/SASCodesLibrary/SAS-Useful-Codes
perl tests/run_live_new_examples_30.pl --live --batch 7 \
  --url http://127.0.0.1:18139/mcp \
  --library-root H:/F_Queens/360yunpan/SASCodesLibrary/SAS-Useful-Codes \
  > new_library100_batch7_initial.log 2>&1
perl tests/run_live_new_examples_30.pl --live --batch 7 --only 391,392,394 \
  --url http://127.0.0.1:18139/mcp \
  --library-root H:/F_Queens/360yunpan/SASCodesLibrary/SAS-Useful-Codes \
  > new_library100_batch7_repairs.log 2>&1
perl tests/run_live_new_examples_30.pl --live --batch 7 \
  --url http://127.0.0.1:18139/mcp \
  --library-root H:/F_Queens/360yunpan/SASCodesLibrary/SAS-Useful-Codes \
  > new_library100_batch7_verified.log 2>&1
```

`--library-root` verifies the original files' SHA-256 hashes; omit it to
run the self-contained generated catalogue elsewhere. Perl writes local
include fixtures and substitutes their paths into the two deferred include
programs. The fixtures have unique remote basenames. Cleanup deletes only
submitted fixtures and saves `fixture_cleanup.log` and
`fixture_cleanup.json`; a cleanup failure makes the harness exit nonzero.
Local source programs, responses, calculation logs and HTML remain available.
Generation, orchestration and regressions use Perl/Bash with the existing
SASPy backend.

### Complete case catalogue

`E:` denotes Easy-For-Error-Codes-SAS; `D:` denotes SAS_Code_Database.

| ID | Example | Oracle | Library source |
|---|---|---|---|
| 391 | `dosubl_single_quoted_local_include` | `value=15` | D:import_sas_macros_with_filename.sas |
| 392 | `execute_single_quoted_local_include` | `value=17` | D:import_sas_macros_with_filename.sas |
| 393 | `validvarname_any_rename_space` | `sample_type=7` | E:rename_table_variable_name_has_spaces.sas |
| 394 | `name_literal_percent_is_not_macro` | `value=9` | E:rename_table_variable_name_has_spaces.sas |
| 395 | `macro_dynamic_symputx_names` | `total=14` | E:create_macro_vars_in_data_step_and_process_it_with_other_macro.sas |
| 396 | `symexist_after_symdel` | `value=0` | E:create_macro_vars_in_data_step_and_process_it_with_other_macro.sas |
| 397 | `dictionary_macros_custom_value` | `value='research'` | E:create_macro_vars_in_data_step_and_process_it_with_other_macro.sas |
| 398 | `vtype_numeric_character` | `nt='N' and ct='C'` | D:check variable type with function vtype demo.sas |
| 399 | `vlength_character_metadata` | `width=23 and actual=5` | E:format varibales in data step with attrib.sas |
| 400 | `attrib_length_label_format` | `labeltext='meaning' and formattext='COMMA12.2'` | E:format varibales in data step with attrib.sas |
| 401 | `import_datarow_skip_metadata` | `total=11 and n=2` | E:firstobs not functional in Proc import but datarow works.sas |
| 402 | `infile_firstobs_skip_header` | `total=8` | E:infile and length_Only asign intended length of chr in statment LENGTH.sas |
| 403 | `infile_obs_limit_records` | `n=2 and total=3` | E:infile and length_Only asign intended length of chr in statment LENGTH.sas |
| 404 | `infile_length_actual_record_bytes` | `n=3` | E:read_long_line_into_dataset.sas |
| 405 | `infile_lrecl_long_record_scan` | `n=400` | E:read_long_line_into_dataset.sas |
| 406 | `input_colon_character_no_truncation` | `key='long_identifier' and value=12` | E:infile and length_Only asign intended length of chr in statment LENGTH.sas |
| 407 | `stop_after_first_noncomment_record` | `text='payload'` | D:Stop function for infile to get specific lines.sas |
| 408 | `scanover_find_marker_in_record` | `value=42` | D:SAS data step scanover for specific rows.sas |
| 409 | `format_dosage_threshold_ranges` | `a=0 and b=1 and c=2` | D:make dosage into hard call geno demo.sas |
| 410 | `format_cntlin_dynamic_lookup` | `value='two'` | D:make dosage into hard call geno demo.sas |
| 411 | `informat_cntlin_character_to_numeric` | `a=1 and b=0` | D:make dosage into hard call geno demo.sas |
| 412 | `libname_owned_path_with_space` | `value=14` | E:libname for path with space no need to escape in Linux.sas |
| 413 | `directory_dopen_nonexistent_returns_zero` | `handle=0 and cleared=0` | D:Dir_existence_Template.sas |
| 414 | `sysget_path_nonempty` | `n>0` | D:SAS get System Path with Function sysget.sas |
| 415 | `filter_prefix_variable_mean` | `total=15` | E:filter_data_step_records_with_mean_function_and_variable_shotcut.sas |
| 416 | `sql_having_group_sum_threshold` | `grp=2 and total=3` | D:Proc SQL aggregate functions need to be used with group and having function.sas |
| 417 | `sql_where_before_grouping` | `n=4 and total=10` | D:Proc SQL aggregate functions need to be used with group and having function.sas |
| 418 | `sql_greater_than_all_subquery` | `n=2 and total=7` | D:Proc SQL subset number greate than all of number in a dataset.sas |
| 419 | `sql_equal_any_subquery` | `n=2 and total=6` | D:Proc SQL subset number greate than all of number in a dataset.sas |
| 420 | `sql_not_in_subquery_filter` | `total=5` | D:Delete rows with where conditions in proc sql without create table.sas |
| 421 | `sql_aggregate_then_scalar_max` | `value=10` | D:Proc SQL Max Demo.sas |
| 422 | `sql_group_count_distinct` | `rows=5 and uniquevals=3` | D:Proc SQL aggregate functions need to be used with group and having function.sas |
| 423 | `sql_alter_add_column_default` | `x=1 and y=8` | D:Update, modify and alter in proct SQL.sas |
| 424 | `sql_alter_drop_column_metadata` | `n=1` | D:Update, modify and alter in proct SQL.sas |
| 425 | `sql_insert_values_into_table` | `n=2 and total=13` | D:Update, modify and alter in proct SQL.sas |
| 426 | `sql_update_case_by_row` | `total=50` | D:Update, modify and alter in proct SQL.sas |
| 427 | `sql_round_value_format_independent` | `abs(x-1.2345)<1e-10 and abs(rounded-1.23)<1e-10` | E:round_numeric_var_with_format_and_case_function_demo.sas |
| 428 | `compare_absolute_tolerance_equal` | `value=0` | D:proc compare Comparing a Variable Multiple Times.sas |
| 429 | `compare_id_ignores_row_position` | `value=0` | D:proc compare to compare mult variables between two dsd with ID function.sas |
| 430 | `compare_var_with_different_names` | `value=0` | D:proc compare Comparing a Variable Multiple Times.sas |
| 431 | `set_same_dataset_twice` | `n=4 and total=6` | D:Use datastep Set function to append the same dataset.sas |
| 432 | `set_in_dataset_origin_flags` | `origins=3 and total=10` | D:Use datastep Set function to append the same dataset.sas |
| 433 | `prxmatch_case_insensitive_filter` | `value=1` | E:prxmatch with perl regular expression and modifier.sas |
| 434 | `prxmatch_negated_character_class` | `value=1 and rejected=0` | E:prxmatch with perl regular expression and modifier.sas |
| 435 | `sql_like_literal_percent_single_quote` | `n=1` | D:Proc SQL aggregate functions need to be used with group and having function.sas |
| 436 | `corr_perfect_linear_outp` | `abs(value-1)<1e-10` | E:Get corr P value based on Z, Get Z based on corr R, Get R based on Z.sas |
| 437 | `corr_covariance_sample_scale` | `abs(value-3)<1e-10` | E:Get corr P value based on Z, Get Z based on corr R, Get R based on Z.sas |
| 438 | `corr_spearman_reversed_order` | `abs(value+1)<1e-10` | E:Get corr P value based on Z, Get Z based on corr R, Get R based on Z.sas |
| 439 | `glm_solution_known_slope` | `abs(estimate-2)<1e-10` | D:ods output proc glm statistics Demo.sas |
| 440 | `glm_anova_degrees_of_freedom` | `df=4` | D:ods output proc glm statistics Demo.sas |
| 441 | `logistic_grouped_binomial_slope` | `abs(intercept)<1e-5 and abs(x-log(7/3))<1e-5` | D:Logistic_regression_with_ROC_curve.sas |
| 442 | `logistic_predicted_probabilities` | `abs(low-.3)<1e-5 and abs(high-.7)<1e-5` | D:Logistic_regression_with_ROC_curve.sas |
| 443 | `lifetest_uncensored_survival_endpoint` | `low=0 and high=1` | D:proc lifttest Demo with ODS.sas |
| 444 | `lifetest_stratified_output` | `groups=2` | D:proc lifttest Demo with ODS.sas |
| 445 | `phreg_parameter_table_capture` | `n=1` | D:proc phreg for survival analysis Demo.sas |
| 446 | `meta_inverse_variance_fixed_mean` | `abs(pooled-.24)<1e-10` | D:Meta-analysis Demo.sas |
| 447 | `meta_pooled_standard_error` | `abs(se-sqrt(.008))<1e-10` | D:Meta-analysis Demo.sas |
| 448 | `meta_cochran_q_statistic` | `abs(q-.8)<1e-10` | D:Meta-analysis Demo.sas |
| 449 | `meta_i_squared_lower_bound` | `value=0` | D:Meta-analysis Demo.sas |
| 450 | `binomial_exact_symmetric_tail` | `abs(value-.6875)<1e-10` | D:Pbinomal test with proc freq.sas |
| 451 | `binomial_probability_mass` | `abs(value-.375)<1e-10` | D:Pbinomal test with proc freq.sas |
| 452 | `odds_ratio_cross_product` | `ratio=6` | E:order_by_data_for_proc_freq_OR_calculation.sas |
| 453 | `odds_log_standard_error` | `abs(se-sqrt(25/24))<1e-10` | E:order_by_data_for_proc_freq_OR_calculation.sas |
| 454 | `fisher_z_standard_error` | `abs(se-.2)<1e-10` | E:Get corr P value based on Z, Get Z based on corr R, Get R based on Z.sas |
| 455 | `correlation_t_statistic` | `abs(t-2)<1e-10` | E:Get corr P value based on Z, Get Z based on corr R, Get R based on Z.sas |
| 456 | `iml_repeat_row_pattern` | `rows=3 and cols=2 and total=9` | D:Make matrix row_col Index with repeat and create sas dataset from IML matrix.sas |
| 457 | `iml_repeat_column_pattern` | `rows=2 and cols=3 and total=9` | D:Make matrix row_col Index with repeat and create sas dataset from IML matrix.sas |
| 458 | `iml_diagonal_extraction` | `total=5` | D:read matrix data, process it in iml, and export it into dataset.sas |
| 459 | `iml_diagonal_matrix_construction` | `total=5 and value=0` | D:read matrix data, process it in iml, and export it into dataset.sas |
| 460 | `iml_row_mean_reduction` | `total=8` | D:read matrix data, process it in iml, and export it into dataset.sas |
| 461 | `iml_column_mean_reduction` | `total=8` | D:read matrix data, process it in iml, and export it into dataset.sas |
| 462 | `iml_matrix_transpose_contract` | `rows=3 and cols=2 and value=6` | D:read matrix data, process it in iml, and export it into dataset.sas |
| 463 | `iml_solve_linear_system` | `err<1e-10` | D:read matrix data, process it in iml, and export it into dataset.sas |
| 464 | `iml_read_colname_metadata` | `n=2 and value=8` | D:IML use data to rename colname or rowname.sas |
| 465 | `iml_export_named_columns` | `value=6` | D:IML use data to rename colname or rowname.sas |
| 466 | `report_group_sum_output` | `value=7` | D:proc report compuate newvar based on know vars.sas |
| 467 | `report_compute_percentage` | `pct=50` | D:proc report compuate newvar based on know vars.sas |
| 468 | `report_url_call_define` | `gene='TESTGENE'` | D:Proc report with multiple html links Demo.sas |
| 469 | `sgpanel_vbox_by_group` | `grp in(1,2) and value>=1 and value<=5` | E:proc sgpanel to make multiple boxplots.sas |
| 470 | `sgpanel_scatter_by_panel` | `y=x+grp` | E:proc sgpanel to make multiple boxplots.sas |
| 471 | `sgplot_heart_parametric_curve` | `abs(x)<=16.000001` | E:draw_a_heart_using_proc_sgplot.sas |
| 472 | `ods_graphics_explicit_size` | `y=2*x` | E:custimze ods graphics output size.sas |
| 473 | `sgplot_highlow_interval` | `high-low=3` | E:custimze ods graphics output size.sas |
| 474 | `sgplot_band_with_series` | `upper-lower=1` | E:custimze ods graphics output size.sas |
| 475 | `sgplot_step_survival_shape` | `survival>=0 and survival<=1` | D:proc lifttest Demo with ODS.sas |
| 476 | `round_to_tenth` | `abs(value-12.3)<1e-10` | E:round_numeric_var_with_format_and_case_function_demo.sas |
| 477 | `ceilz_integer_boundary` | `value=3` | E:round_numeric_var_with_format_and_case_function_demo.sas |
| 478 | `floorz_negative_fraction` | `value=-3` | E:round_numeric_var_with_format_and_case_function_demo.sas |
| 479 | `inputn_dynamic_date_informat` | `value='13oct2026'd` | E:format varibales in data step with attrib.sas |
| 480 | `putn_dynamic_zero_padded_format` | `value='0007'` | D:make dosage into hard call geno demo.sas |
| 481 | `putc_dynamic_character_format` | `value='ALPHA'` | D:make dosage into hard call geno demo.sas |
| 482 | `datdif_actual_day_count` | `value=60` | E:format varibales in data step with attrib.sas |
| 483 | `yrdif_actual_year_fraction` | `abs(value-1)<1e-10` | E:format varibales in data step with attrib.sas |
| 484 | `anydigit_first_position` | `value=4` | E:infile and length_Only asign intended length of chr in statment LENGTH.sas |
| 485 | `anyalpha_first_position` | `value=4` | E:infile and length_Only asign intended length of chr in statment LENGTH.sas |
| 486 | `notdigit_first_position` | `value=4` | E:infile and length_Only asign intended length of chr in statment LENGTH.sas |
| 487 | `verify_allowed_character_set` | `good=0 and bad=3` | E:prxmatch with perl regular expression and modifier.sas |
| 488 | `soundex_similar_names` | `a=b` | E:prxmatch with perl regular expression and modifier.sas |
| 489 | `unsorted_by_input_failure` | `Expected failure: not properly sorted` | D:proc compare to compare mult variables between two dsd with ID function.sas |
| 490 | `sql_where_aggregate_failure` | `Expected failure: (?:Summary functions&#124;summary function)` | D:Proc SQL aggregate functions need to be used with group and having function.sas |

### Discovery failures and improvements

The first live run in `SAS_Output_real30_w2vQnT` passed 97/100 validations.
Cases 391 and 392 failed because single-quoted include paths inside
DOSUBL/CALL EXECUTE code were encoded with doubled quote delimiters.
The old extractor found no usable local path, so the file was not uploaded
and SAS could not open the local Cygwin path on its remote host.

Include discovery now decodes executable single-quoted code strings,
recursively finds their active includes and parses SAS doubled delimiters
inside each filename. Dependency rewriting preserves the source's quote
escaping when replacing local paths with remote ones. A parentheses-aware
execution-context check handles concatenated code strings and stops treating
ordinary text after a completed DOSUBL call as executable code. Eleven
regressions verify direct/deferred paths, apostrophes, active versus masked
includes, concatenation and replacement escaping.

Case 394 was a generated-fixture ordering error. Its dataset containing a
percent-sign name literal was created successfully with VALIDVARNAME=ANY,
but the fixture reset that option to V7 before the assertion/PRINT read the
dataset. The reset now happens after validation. The runner does not
silently change a user's VALIDVARNAME policy. The corrected case also checks
that the quoted name never causes a macro-loader injection.

The focused repair pass in `SAS_Output_real30_dpNJyh` passed all three cases
and remote fixture cleanup. The harness now gives include fixtures unique
basenames, deletes only fixtures submitted by the selected cases and
records the cleanup result separately. Its local input files remain for
reproduction, and cleanup failure produces a nonzero harness exit.

### Offline and companion verification

```bash
export PATH=/usr/bin:$PATH
prove tests/test_comment_quote_preflight.pl \
  tests/test_inline_data_preflight.pl tests/test_inline_macro_preflight.pl \
  MCPDeps/test_sas_log_and_labels.pl tests/test_mcp_job_reporting.pl \
  tests/test_sas_log_diagnostics.pl tests/test_macro_quoting_preflight.pl \
  tests/test_format_name_advisory.pl MCPDeps/test_sas_oda_include_lookup.pl \
  tests/test_quoted_filename_upload.pl tests/test_example_uniqueness.pl \
  tests/test_deferred_macro_literals.pl tests/test_printto_status_guard.pl \
  tests/test_fileref_name_advisory.pl tests/test_deferred_include_paths.pl
```

MCP4SAS passed **290 assertions across 15 Perl tests**; the companion
repository passed **152 assertions across 12 Perl tests**. The companion
public-wrapper live command is:

```bash
perl tests/test_live_deferred_includes.pl --live
```

That supplemental test creates one uniquely named file containing an
apostrophe and a space, calls it through both DOSUBL and CALL EXECUTE
using escaped single-quoted paths, checks its result and retained HTML,
then deletes only its own remote fixture. It is not an extra numbered
example. The shared source-analysis and runner fixes and regressions
were synchronized to all three active companion pipeline copies.

### Final live outcome for cases 391–490

The complete frozen-code rerun exited 0 and passed **100/100 validations**
in `SAS_Output_real30_WC9pBO`: **98 successful SAS jobs and two intentional
failed jobs** (489–490). All 41 original source hashes matched, and all
new cases passed normalized duplicate checks against the preceding 390.
Computed markers, nonempty HTML, retained logs, structured status, MCP error
flags, exit codes and completion-marker cleanup were checked. Successful
jobs had no unexpected structured warnings or data-quality notes.

Remote fixture cleanup also passed with exit 0, deleting only
`~/include_391_SAS_Output_real30_WC9pBO.sas` and
`~/include_392_SAS_Output_real30_WC9pBO.sas`; its evidence is in
`fixture_cleanup.json` and `fixture_cleanup.log` in that run directory.
The companion supplemental test passed all seven assertions in
`SAS_Output_deferred_includes_g6G3xm`, including deletion of its uniquely
named apostrophe-containing fixture.

Terminal logs remain local in `SAS_Output_library100_run_logs/` as
`new_library100_batch7_initial.log`, `new_library100_batch7_repairs.log`
and `new_library100_batch7_verified.log`. Generated programs, fixtures,
responses, results JSON and HTML remain in the corresponding run folders.
Publication contains maintained code, the new catalogue, hashes, Perl
regressions and this report; runtime artifacts and generated configurations
remain local.

## 14. Fifth library-derived batch: cases 491–590

This batch adds 100 synthetic, self-contained SAS examples derived from
40 previously unused files in the two original SAS libraries. Their original
filenames and raw SHA-256 hashes are retained in
`tests/sas_library_source_manifest.json`; the programs are in
`tests/new_examples_491_590.pl`. Original library files remain unchanged.
The harness rejects code duplicated across cases 1–590 after normalizing
case IDs, assertion markers and whitespace. This batch is additional to
the preceding 490 numbered cases.

The new cases cover quoted file lists, macro scope, input pointers,
word scanning, arrays, loops, lag queues, permutations, binary decoding,
POINT reads, sorting and duplicates, SQL joins, ranks, scaling, metadata,
reshaping, PROC COMPARE and ODS graphics. Assertions check calculated
values. Successful jobs must retain nonempty HTML; this does not by itself
establish visual correctness of every plotted feature. Two deliberate SAS
errors exercise failure reporting rather than count as successful SAS jobs.

### Reproduced failures and resulting changes

Cases 491 and 492 reproduced a runner defect with two quoted local files
in one `%include` statement. The dependency log showed only the first
file uploaded. SAS reported that it could not open the second local path,
and MCP correctly returned FAILED. The dependency parser now collects
each quoted filename, including decoded strings passed to DOSUBL or
CALL EXECUTE. Regression coverage also checks comment separators, mixed
quote styles, doubled apostrophes, semicolons within filenames and stopping
at statement/options boundaries; ordinary quoted data and inactive NRSTR
text remain excluded.

The Perl harness now writes multiple uniquely named fixtures for a case
and deletes only those remote fixtures after the run. It retains programs,
responses, logs, results JSON and cleanup evidence locally.

Case 502 initially failed the unexpected-data-quality-note check despite
returning the correct three input rows and weighted total of 58. Its `@@`
input intentionally scans consecutive pairs on one line, producing the SAS
note about moving to a new line when INPUT reaches past the record end.
The final case explicitly requires that note and the structured diagnostic,
while still requiring COMPLETE, exit 0, no MCP error and the computed result.
Diagnostic reporting is not suppressed.

Case 578 initially used a fileref in `TMPlOUT=`, but SGPLOT requires a
quoted output pathname. The corrected example writes its template under
its own SAS WORK directory, verifies existence, and verifies deletion and
fileref release. The original ERROR 22-322 and failed assertion are retained.

Case 590 originally used DESENDING as an intentional SORT error. This ODA
installation accepted that spelling with both one and three observations,
so it was not a reliable failure fixture. The final case supplies three
rows and a definitely absent BY variable, E590ABSENT. It must diagnose
that missing variable and return FAILED. The original discovery and
focused-run responses are retained; their successful SAS jobs are not
misreported as expected failures.

### Cygwin commands

Start the dedicated MCP test endpoint in one terminal:

```bash
export PATH=/usr/bin:$PATH
export SAS_ODA_AUTOLOAD_MACROS=0 OPEN_RESULT=0
perl server.pl daemon -m production -l http://127.0.0.1:18140
```

In another terminal from the MCP4SAS checkout:

```bash
library_root=/mnt/h/F_Queens/360yunpan/SASCodesLibrary/SAS-Useful-Codes
perl tests/run_live_new_examples_30.pl --batch 8 --generate-only \
  --library-root "$library_root"
perl tests/run_live_new_examples_30.pl --batch 8 --live \
  --url http://127.0.0.1:18140/mcp --library-root "$library_root" \
  > new_library100_batch8_initial.log 2>&1
# After fixing and verifying the reproduced dependency failure:
perl tests/run_live_new_examples_30.pl --batch 8 --live \
  --only 491,492,502,517,578,590 --url http://127.0.0.1:18140/mcp \
  --library-root "$library_root" > new_library100_batch8_repairs.log 2>&1
perl tests/run_live_new_examples_30.pl --batch 8 --live \
  --url http://127.0.0.1:18140/mcp --library-root "$library_root" \
  > new_library100_batch8_verified.log 2>&1
```

Each command creates a fresh owned run folder. Supplemental public CLI tests
run separately and do not increase the numbered example count:

```bash
prove tests/test_include_file_lists.pl tests/test_deferred_include_paths.pl
perl tests/test_live_include_file_lists.pl --live
```

The companion public wrapper uses the same supplemental Perl test with its
own dependency module directory. Shared fixes are synchronized to the
three active companion pipeline copies. No Python test driver is introduced.

Case 517 also exposed a new-example assertion error: LBOUND was referenced
from a subsequent DATA step where its temporary array was not defined.
The corrected example stores the bound in the original DATA step and
checks that retained dataset value. This is an example correction, not a
runner change; the original failed response remains in the discovery run.



### Catalogue of the 100 new examples

E and D identify the error-prone and general SAS code collections respectively.
The expected outcome column describes checks, not an unverified execution claim.

| Case | Example | Computed assertion / expected diagnostic | Library source |
| --- | --- | --- | --- |
| 491 | include_two_quoted_local_files | total=29 | E:Add quote to separate var list.sas |
| 492 | dosubl_two_quoted_local_files | total=42 | E:Add quote to separate var list.sas |
| 493 | macro_quote_word_list | text='"alpha","beta","gamma"' | E:Add quote to separate var list.sas |
| 494 | symputx_global_overwrites_shadow | value=21 | E:make_global_macro_var_with_symputx_to_overwrite_macro_vars.sas |
| 495 | symputx_local_preserves_global | local_value=13 and global_value=8 | E:symputx demo different from symput.sas |
| 496 | symputx_numeric_trim | text='1234' and n=4 | E:symputx demo different from symput.sas |
| 497 | macro_repeat_parameter_bound | n=4 and total=30 | D:A macro to Run other Macro repeatedly.sas |
| 498 | cmpres_reduces_internal_blanks | text='five plus ten' | D:Macro function cmpres and qcmpres.sas |
| 499 | array_symputx_cutpoints | total=15 | D:Make multiple macro variables with Function array and call symput in data step.sas |
| 500 | sysfunc_prxparse_then_match | value=1 | E:use prxmatch in sysfunc.sas |
| 501 | single_at_rereads_same_record | total=16 | E:evaluate_single_and_double_at_in_data_step.sas |
| 502 | double_at_paired_values | n=3 and total=58; expected INPUT note | E:evaluate_single_and_double_at_in_data_step.sas |
| 503 | colon_reads_tab_separated_identifier | gene='long_gene_name' and value=18 | E:Tell_sas_to_read_var_in_variable_length.sas |
| 504 | ampersand_reads_two_word_name | name='Ada Lovelace' and score=28 | D:tell sas to read variable until there are two or more spaces as a delimeter.sas |
| 505 | ampersand_colon_multiple_spaces | label='single label' and value=35 | D:tell sas to read variable until there are two or more spaces as a delimeter.sas |
| 506 | scan_split_comma_ids | n=3 and width=10 | D:split_elements_and_output_ids_into_each_row.sas |
| 507 | scan_min_explicit_numeric_conversion | value=-3 | D:use_scan_countc_to_get_min_value_with_loop.sas |
| 508 | scan_max_negative_tokens | value=-2 | D:use_scan_countc_to_get_min_value_with_loop.sas |
| 509 | scan_preserves_empty_field_m | missing(middle) and n=3 | D:split_elements_and_output_ids_into_each_row.sas |
| 510 | qscan_retains_embedded_comma | item='a,b' | D:split_elements_and_output_ids_into_each_row.sas |
| 511 | infile_column_pointer_reposition | total=46 | E:evaluate_single_and_double_at_in_data_step.sas |
| 512 | input_absolute_pointer_character | prefix='ABC' and value=127 | E:Tell_sas_to_read_var_in_variable_length.sas |
| 513 | countw_quoted_delimiters | n=3 | D:split_elements_and_output_ids_into_each_row.sas |
| 514 | scan_backward_last_token | value=16 | D:use_scan_countc_to_get_min_value_with_loop.sas |
| 515 | trimmed_sql_key_preparation | clean='A12' and n=3 | E:strip left for equal condition in proc sql.sas |
| 516 | array_two_dimensional_trace | trace=9 | E:make data step matrix with array.sas |
| 517 | array_temporary_lower_bound_zero | value=20 and lower=0 | D:Datastep Array function to make multiple new variables and assign initial value to it.sas |
| 518 | array_character_initial_values | value='red/green/blue' | D:Datastep Array function to make multiple new variables and assign initial value to it.sas |
| 519 | array_parallel_scale_columns | total=7 | E:make data step matrix with array.sas |
| 520 | do_until_executes_once | value=12 | D:Do until Demo.sas |
| 521 | do_while_zero_iterations | value=12 and n=0 | D:Do until Demo.sas |
| 522 | do_until_fibonacci_threshold | a=13 and b=21 and n=7 | D:Do until Demo.sas |
| 523 | retain_prefix_running_total | total=20 | D:Powerful Function retain in datasetp.sas |
| 524 | by_reset_group_running_total | value=12 and n=2 | D:Demo for data step retain, by, if condition to summarize data.sas |
| 525 | lag_unconditional_difference | total=9 and first_missing=1 | E:lag_generate_missing_values.sas |
| 526 | lag_conditional_queue_semantics | total=6 | E:lag_generate_missing_values.sas |
| 527 | ranperm_preserves_integer_multiset | total=15 and product=120 | E:ranperm_generate_random_matrix.sas |
| 528 | fisher_yates_permutation_unique | total=21 and product=720 | E:ranperm_generate_random_matrix.sas |
| 529 | binary_three_bit_decode | b1=1 and b2=0 and b3=1 and reconstructed=5 | E:use_binary_function_in_proc_iml_generate_SNP_haplotype.sas |
| 530 | binary_bitwise_operations | intersection=2 and union=7 and difference=5 | E:use_binary_function_in_proc_iml_generate_SNP_haplotype.sas |
| 531 | point_read_reverse_order | x=4 | D:Transform Plink Tped to long format for SAS with point function debugging.sas |
| 532 | point_repeat_selected_observation | n=3 and total=27 | D:Transform Plink Tped to long format for SAS with point function debugging.sas |
| 533 | set_in_flags_origin_counts | origins=4 and total=13 | D:Datastep Set demo.sas |
| 534 | set_dataset_keep_rename | value=7 and doubled=14 | D:Datastep Set demo.sas |
| 535 | set_obs_firstobs_window | n=3 and total=12 | D:Datastep Set demo.sas |
| 536 | sort_descending_first_row | x=4 | E:desending should put ahead of the variable used in proc sort.sas |
| 537 | sort_mixed_direction_by_groups | grp=1 and x=3 | E:desending should put ahead of the variable used in proc sort.sas |
| 538 | sort_dupout_count_and_value | n=2 and total=60 | E:OUTPUT duplicates into sas dataset.sas |
| 539 | sort_noduprecs_entire_row | n=2 and total=30 | E:OUTPUT duplicates into sas dataset.sas |
| 540 | sql_having_multi_column_minima | n=2 and ids=5 | E:Get_minimum_or_max_value_for_any_of_specific_columns_with_having.sas |
| 541 | sql_having_group_max_ties | n=3 and total=13 | E:Get_minimum_or_max_value_for_any_of_specific_columns_with_having.sas |
| 542 | sql_catx_chromosome_position | locus='3:127' | E:CAT CATX for Linking variables to create new one in PROC SQL.sas |
| 543 | sql_cats_padded_character_parts | value='202610' | D:Proc SQL with Cats and other Cat functions.sas |
| 544 | sql_cat_preserves_internal_blanks | value='A  B' | E:CAT CATX for Linking variables to create new one in PROC SQL.sas |
| 545 | sql_join_trimmed_keys | total=28 | E:strip left for equal condition in proc sql.sas |
| 546 | sql_full_join_coalesce_key | ids=3 and total=13 | D:Proc Import only import partial column variables and rename them steamlessly.sas |
| 547 | sql_left_join_missing_match | n=3 and unmatched=2 | D:Proc Import only import partial column variables and rename them steamlessly.sas |
| 548 | rank_ties_low_group | total=5 | D:Proc Rank Demo.sas |
| 549 | rank_ties_high_group | total=7 | D:Proc Rank Demo.sas |
| 550 | rank_descending_highest_first | r=1 | D:Proc Rank Demo.sas |
| 551 | sql_range_scaling_signed | low=-1 and high=1 and abs(total)<1e-12 | E:scale ssGSEA score in the range from -1 to 1.sas |
| 552 | stdize_range_then_signed_scale | low=-1 and high=1 | E:scale ssGSEA score in the range from -1 to 1.sas |
| 553 | sql_dictionary_specific_member | nobs=1 and nvar=1 | D:check tables with dictionary.tables by proc sql.sas |
| 554 | sql_dictionary_column_order | varnum=1 and length=8 | D:check tables with dictionary.tables by proc sql.sas |
| 555 | work_directory_exists | exists=1 and lengthn(path)>0 | D:get sas work dir with sysfunc pathname_work.sas |
| 556 | transpose_two_measures_one_subject | n=2 and total=11 | D:Proc transpose_transpose rowwide long data into columnwide long data.sas |
| 557 | transpose_prefix_and_delimiter | visit_1=4 and visit_2=9 | D:Proc transpose_transpose rowwide long data into columnwide long data.sas |
| 558 | transpose_copy_constant_attribute | total=16 and n=2 | D:Proc transpose_transpose rowwide long data into columnwide long data.sas |
| 559 | wide_array_to_long_sum | n=3 and total=48 | E:make data step matrix with array.sas |
| 560 | compare_identical_numeric_rows | status=0 | D:Proc compare with var and id as well as output parameters.sas |
| 561 | compare_numeric_difference_flag | changed=1 | D:Proc compare with var and id as well as output parameters.sas |
| 562 | compare_absolute_tolerance | status=0 | D:Proc compare with var and id as well as output parameters.sas |
| 563 | open_dataset_attribute_counts | n=19 and vars=5 and rc=0 | D:check tables with dictionary.tables by proc sql.sas |
| 564 | open_custom_dataset_varnum | position=2 and rc=0 | D:check tables with dictionary.tables by proc sql.sas |
| 565 | metadata_varname_by_position | name='score' | D:Transform Plink Tped to long format for SAS with point function debugging.sas |
| 566 | array_vvaluex_dynamic_column | text='0017' | D:Transform Plink Tped to long format for SAS with point function debugging.sas |
| 567 | macro_work_path_matches_data_function | equal=1 | D:get sas work dir with sysfunc pathname_work.sas |
| 568 | retained_gap_cluster_count | cluster=3 | D:Powerful Function retain in datasetp.sas |
| 569 | by_first_last_flags_counts | starts=3 and finishes=3 and n=6 | D:Demo for data step retain, by, if condition to summarize data.sas |
| 570 | scan_numeric_list_mean | average=7.5 and n=4 | D:use_scan_countc_to_get_min_value_with_loop.sas |
| 571 | gtl_scatter_overlay_computed | total=24 | D:GTL Demo very useful.sas |
| 572 | gtl_series_computed | total=30 | D:GTL Demo very useful.sas |
| 573 | gtl_heatmapparm_four_cells | total=12 and n=4 | D:Heatmap Demo.sas |
| 574 | sgplot_heatmapparm_preaggregated | total=18 | D:Heatmap Demo.sas |
| 575 | sgplot_vbar_mean_response | average=5.5 | D:sgplot  vbar with mean by using response stat group functions.sas |
| 576 | sgplot_vbar_sum_response | total=15 | D:sgplot  vbar with mean by using response stat group functions.sas |
| 577 | sgplot_hbar_grouped_response | total=21 | D:sgplot  vbar with mean by using response stat group functions.sas |
| 578 | sgplot_tmplout_owned_tempfile | exists=1 and deleted=0 and cleared=0 | D:Get template code with proc sgplot function tmplout.sas |
| 579 | gtl_layout_lattice_two_panels | total=30 | D:GTL Demo very useful.sas |
| 580 | gtl_bar_chart_summary | total=24 | D:Proc sgrender with proc template Demo.sas |
| 581 | sgplot_vbar_weighted_frequency | total=10 | D:sgplot  vbar with mean by using response stat group functions.sas |
| 582 | sgplot_scatter_style_shapes | total=21 | D:GTL Demo very useful.sas |
| 583 | sgplot_series_grouped | total=30 | D:GTL Demo very useful.sas |
| 584 | sgplot_vbox_two_groups | low=2 and high=7 | D:Get template code with proc sgplot function tmplout.sas |
| 585 | sgplot_histogram_small_dataset | average=6.5 | D:Proc sgrender with proc template Demo.sas |
| 586 | sgplot_band_intervals | width=8 | D:GTL Demo very useful.sas |
| 587 | sgplot_reference_line_computed | high=25 | D:GTL Demo very useful.sas |
| 588 | sgplot_discrete_axis_long_labels | total=14 | D:sgplot  vbar with mean by using response stat group functions.sas |
| 589 | intentional_array_index_out_of_range | FAILED: Array subscript out of range | D:Datastep Array function to make multiple new variables and assign initial value to it.sas |
| 590 | intentional_sort_missing_by_variable | FAILED: E590ABSENT.*not found\|not found.*E590ABSENT | E:desending should put ahead of the variable used in proc sort.sas |

### Focused verification and offline checks

The first live run completed all 100 cases in `SAS_Output_real30_gnnAHX`
and passed 94 validations. Its six failures were 491, 492, 502, 517, 578
and 590, as described above; remote deletion of its four named include
fixtures passed. The focused rerun in `SAS_Output_real30_ODwIlm` passed
491, 492, 502, 517 and 578. Case 590 still demonstrated that DESENDING
was accepted, so that run passed 5/6. Its four remote fixtures were also
cleaned successfully. The corrected absent-BY-variable case then passed
1/1 validation in `SAS_Output_real30_526Yd0`, returning FAILED as required.

The new file-list regression initially failed five of ten assertions;
after the parser fix all ten passed. The complete offline suites passed
**300 assertions across 16 Perl files** for MCP4SAS and **162 assertions
across 13 Perl files** for the companion pipeline. The commands extend
the preceding section's full suite with `tests/test_include_file_lists.pl`:

```bash
prove tests/test_comment_quote_preflight.pl tests/test_inline_data_preflight.pl \
  tests/test_inline_macro_preflight.pl MCPDeps/test_sas_log_and_labels.pl \
  tests/test_mcp_job_reporting.pl tests/test_sas_log_diagnostics.pl \
  tests/test_macro_quoting_preflight.pl tests/test_format_name_advisory.pl \
  MCPDeps/test_sas_oda_include_lookup.pl tests/test_quoted_filename_upload.pl \
  tests/test_example_uniqueness.pl tests/test_deferred_macro_literals.pl \
  tests/test_printto_status_guard.pl tests/test_fileref_name_advisory.pl \
  tests/test_deferred_include_paths.pl tests/test_include_file_lists.pl
```

### Final live outcome for cases 491–590

The full rerun exited 0 and passed **100/100 validations** in
`SAS_Output_real30_biOUtX`: **98 COMPLETE jobs and two intentional FAILED
jobs** (589–590). All 40 original library hashes matched. The catalogue
passed normalized duplicate checks against the preceding 490 examples.
Computed markers, retained logs, nonempty HTML for successful jobs,
structured status/diagnostics, MCP error flags, worker exit codes and
completion-marker cleanup were verified. Successful jobs had no unexpected
warnings or data-quality diagnostics; case 502 explicitly requires its
expected input-flowover note.

Remote cleanup exited 0 and deleted only these four fixtures:

```text
~/include_491_1_SAS_Output_real30_biOUtX.sas
~/include_491_2_SAS_Output_real30_biOUtX.sas
~/include_492_1_SAS_Output_real30_biOUtX.sas
~/include_492_2_SAS_Output_real30_biOUtX.sas
```

Its evidence is retained in `fixture_cleanup.json` and `fixture_cleanup.log`
in the run directory. The companion public-wrapper live test passed all
**10 assertions** in `SAS_Output_include_lists_Tgn3QJ`, covering direct,
DOSUBL and CALL EXECUTE file lists, computed values, HTML and removal of its
two unique remote fixtures. That supplemental test is not counted among
the 100 numbered examples.

Terminal logs remain local in `SAS_Output_library100_run_logs/`:
`new_library100_batch8_initial.log`, `new_library100_batch8_repairs.log`,
`new_library100_batch8_failure_fixture.log`,
`new_library100_batch8_verified.log`,
`new_library100_batch8_regression_before.log`,
`new_library100_batch8_regression_after.log`,
`new_library100_batch8_baseline.log`, `new_library100_batch8_offline.log`,
`new_library100_batch8_companion_offline.log` and
`new_library100_batch8_companion_live.log`.
Programs, fixtures, responses, results JSON and HTML remain in their owned
run folders. Publication includes maintained code, the 100-case catalogue,
source hashes, Perl tests, README and this report. Generated outputs,
caches and unrelated configuration changes remain local.

## 15. Recursive remote directory cleanup with Del_Dir_Recursive

Validation date: October 31, 2026.

The user reported that `%Del_Dir_Recursive` worked after a manual include
but was not reliably available through MCP4SAS. The online source was
downloaded read-only and inspected. It defines both `recursiveDelete` and
`Del_Dir_Recursive(upper_dir,lower_dir)`, with positional parameters, and
renames each selected target to its parent's fixed `_DELETE_` staging name.
The macro itself was not changed or uploaded.

### Implementation

`MCPDeps/SAS_ODA_Directory_Cleanup.pm` builds the SAS cleanup program in Perl.
Both CLI scripts now accept repeatable `--delete-directory-rgx` patterns
and `--delete-directory-dry-run`, reusing `--delete-dir` as the remote parent
(default `~`). The MCP tool exposes `delete_directory_rgx` (string or array),
`delete_directory_dry_run` (boolean) and the existing `delete_dir` field.
Patterns match immediate child basenames using SAS PRX expressions; DOPEN
filters out regular files. Deleting a selected directory recursively removes
its contents through the existing online macro.

The cleanup operation explicitly includes `~/Macros/Del_Dir_Recursive.sas`.
Direct ordinary SAS calls also receive a targeted remote loader for that
macro, with canonical filename casing and preference for the Macros folder,
even when global macro autoload is enabled. This avoids relying entirely on
`importallmacros_ue` to have compiled both definitions. It does not overlay a
local macro copy. Built-in `%SYSMACEXIST`, `%SYSMACDELETE`, and `%SYMDEL`
are excluded from remote dependency lookup.

Before invoking the recursive macro, the generated program snapshots all
matches and rejects protected or macro-unsafe directory names. It acquires
an owned directory lock under the selected parent and refuses a preexisting
`_DELETE_` staging path. It releases its lock on normal completion and early
returns. After each call it verifies disappearance of the original path and
staging path; unverified removal is a failure. A stale lock is preserved
rather than treated as permission to continue deletion.

The dry run loads no deletion macro and deletes no files or directories.
Its logs list each selected path and a matched/deleted summary. Directory
cleanup runs separately from a user code/file submission. Existing file
cleanup flags retain their behavior.

### Live failures encountered and fixes

The first read-only download command accidentally allowed the local shell
to expand `~/Macros` to `/home/admin/Macros`. The corrected command escaped
remote `~` and downloaded the actual online macro successfully. Commands
below quote remote paths for use directly in Cygwin Bash; the Perl test
uses list-form exec arguments so no shell expands remote paths.

The first full live run passed 17/18 assertions in
`SAS_Output_remote_directory_cleanup_GZrk5Z`. The staging collision was
correctly blocked and all files were preserved, but its CLI exit status
was incorrectly zero. The generic explicit-include debug wrapper had
redirected the ERROR line out of the primary SAS log. Generated directory
cleanup submissions now keep their runtime log in the normal submission
path instead of using that wrapper, so a blocked cleanup reports a nonzero
exit and the MCP worker can report FAILED.

### Reproducible Cygwin commands

```bash
export PATH=/usr/bin:$PATH
# Preview only, matching immediate child directory names:
perl run_sas_codes_or_files_in_ODA.pl \
  --delete-dir '~' --delete-directory-rgx '^tmp_.*$' \
  --delete-directory-dry-run --persistent --session-id cleanup

# Delete the selected directories and their contents:
perl run_sas_codes_or_files_in_ODA.pl \
  --delete-dir '~' --delete-directory-rgx '^tmp_.*$' \
  --persistent --session-id cleanup

# Repeat patterns to combine them under a particular remote parent:
perl run_sas_codes_or_script_in_ODA.pl \
  --delete-dir '~/scratch' \
  --delete-directory-rgx '^old_run_[0-9]+$' \
  --delete-directory-rgx '^temporary_[0-9]+$' \
  --delete-directory-dry-run

prove tests/test_remote_directory_cleanup.pl tests/test_mcp_job_reporting.pl
perl tests/test_live_remote_directory_cleanup.pl --live
# A one-shot-session alternative is also available:
# perl tests/test_live_remote_directory_cleanup.pl --live --oneshot
```

The MCP tool takes the following arguments for preview; set the boolean to
false for deletion and poll the returned worker PID as usual:

```json
{
  "delete_directory_rgx": ["^tmp_.*$", "^old_run_[0-9]+$"],
  "delete_dir": "~",
  "delete_directory_dry_run": true,
  "persistent": "true",
  "session_id": "cleanup"
}
```

### Final live verification

The corrected live run passed **18/18 assertions**, exit 0, in
`SAS_Output_remote_directory_cleanup__x9sa4`. It created only a uniquely
named parent under remote HOME, with two matching directories (one containing
another nonempty directory), an unmatched directory containing a file, and
a regular file whose name also matched the pattern. It verified preview
preservation, rejection of an owned `_DELETE_` collision with nonzero exit,
retention of the collision sentinel and original files, successful deletion
of the two matching trees, preservation of the unmatched directory and
matching regular file, release of the cleanup lock, successful no-match
behavior, and deletion of all remaining owned test fixtures and their parent.

All programs and CLI/SAS logs remain in the owned run directory. The original
17/18 discovery run remains available separately. No existing user directory
was selected by the live tests.

The final offline regression suite passed **351 assertions across 18 Perl
test files**, including the new directory-cleanup checks and existing CLI,
MCP job reporting, include, macro quoting, diagnostic and cleanup tests.
Both CLI scripts, the MCP server and the two changed/new Perl modules
passed syntax checks. Download/probe logs, suite outputs, live-test terminal
logs and the read-only copy of the inspected online macro remain local in
`SAS_Output_directory_cleanup_validation/`, which is ignored by Git.

## 16. Case-insensitive targeted remote macro filenames

Targeted loading previously constructed an exact Linux source path from the
macro invocation spelling. It now preserves the old exact-match precedence,
then resolves case-only differences by scanning remote directories inside
SAS. It includes the actual directory entry, without renaming source files,
uploading substitutes or changing the filesystem's case sensitivity.

Resolution policy:

1. Check exact `macro_name.sas` paths in both search folders, in priority order.
2. If neither exact path exists, scan the primary folder and compare the whole
   filename, including `.sas`, using UPCASE. If it has no matches, scan the
   fallback folder.
3. Include the single matching file using its actual spelling. Directories
   whose names end in `.sas` are excluded. Multiple folded matches within
   the selected folder emit ERROR; no candidate from that lookup is included.

Ordinary macros retain `~` then `~/Macros` priority. The known deletion macro
retains `~/Macros` then `~` priority and its canonical source alias. Exact
matches in either folder precede all case-insensitive matches, preserving
existing behavior. Resolution state is local to the helper and directory
handles and filerefs are released. `MCP4SAS_TARGETED_MACRO` and
`MCP4SAS_MACRO_CANDIDATE` log messages remain visible with NONOTES enabled.

This handles case-only differences, not arbitrary typos or macros defined
in an unrelated source filename. It changes the targeted loader; the global
importer's own directory-loading rules are unchanged. Explicit `%include`
continues to work. Existing compiled macros in persistent sessions retain
normal SAS semantics; an ambiguity error does not roll back other SAS code.

### Real checks and observed test failures

`tests/test_live_case_insensitive_macro_lookup.pl` creates eight uniquely
named synthetic source files in remote HOME and Macros. It checks mixed-case
macro basenames and `.SaS`/`.SAS` extensions, exact preference despite two
case variants, a fallback-folder exact match beating a primary-folder folded
match, primary-folder preference when both folders have folded matches, and
an ambiguous pair with neither source loaded/executed. Computed values prove
which source was included. Cleanup deletes and verifies only its eight files.

The first fixture setup incorrectly checked existence in the same DATA step
as its FILE statement; SAS had already opened/created the output files.
Existence checks now run in a separate submission before any FILE statements.
The eight files from that failed setup were explicitly deleted and verified;
evidence remains in `SAS_Output_macro_case_hI9EKm/cleanup.cli.log`.

The next live run computed all expected macro results and correctly rejected
the ambiguous pair, but passed only 16/21 assertions: NONOTES suppressed five
resolution messages beginning with NOTE. The loader now uses explicit log
markers instead. That run (`SAS_Output_macro_case_BLMwf0`) and its successful
fixture cleanup remain available. The final MCP4SAS live run passed **21/21**,
exit 0, in `SAS_Output_macro_case_wGySmW`.

The full MCP4SAS offline suite passed **369 assertions across 19 Perl files**.
The companion public-wrapper live run passed **21/21**, exit 0, in
`SAS_Output_macro_case_uArZC1`. Its initial offline run found two stale
assertions expecting an old generated literal path; those assertions now
check the canonical requested filename rather than the previous layout.
The corrected companion suite passed **220 assertions across 15 Perl files**.
These supplemental checks do not add to the preceding numbered 100-case batches.

### Cygwin commands

```bash
export PATH=/usr/bin:$PATH
prove tests/test_case_insensitive_macro_lookup.pl tests/test_remote_directory_cleanup.pl
perl tests/test_live_case_insensitive_macro_lookup.pl --live
```

For example, an invocation `%my_macro` can now load remote `My_Macro.SAS`
when no exact-case source path exists. To inspect a standalone submission,
disable global autoload to exercise the targeted path explicitly:

```bash
SAS_ODA_AUTOLOAD_MACROS=0 perl run_sas_codes_or_files_in_ODA.pl \
  --file my_program.sas --persistent --session-id case_lookup
```

Programs, SAS/CLI logs and verified cleanup results remain in the ignored
owned run folders. Suite and terminal logs are retained locally in
`SAS_Output_macro_case_validation/`.

## 17. Another 500 runnable library-derived evaluations (2026-11-02)

### Scope and source provenance

Added `tests/library500/L001.sas` through `L500.sas`: **50 behavior families,
ten distinct boundary inputs per family**. These are 500 new executable cases,
not 500 unrelated algorithms or 500 independent ODA login sessions. The prior
590 examples and existing 500 source-analysis tasks remain intact. An ID-only
normalization rejects repeated executable bodies within this new batch.

The generator reads these directories under `H:/F_Queens/360yunpan/SASCodesLibrary`:

- `SAS-Useful-Codes/Easy-For-Error-Codes-SAS`
- `SAS-Useful-Codes/SAS_Code_Database`
- `SAS-Useful-Codes/Macros`

`tests/library500/manifest.json` identifies a real function-use site for each
family across 40 original source files, including relative filename, line number, complete-source SHA-256 and
evidence-line SHA-256. Original library files are read only. Generated programs
use small synthetic inputs; no original personal datasets, macro libraries or
directory-deletion operations are submitted. Expected answers are calculated
in Perl rather than copied from current analyzer output or a SAS result.

| New IDs | Coverage |
| --- | --- |
| L001–L100 | Numeric rounding, signs, roots, exponentials and logarithms |
| L101–L200 | Numeric aggregates, special missing values and coalescing |
| L201–L300 | Case, whitespace, reversal, substrings, word/character counting |
| L301–L400 | Replacement, translation, concatenation, searches and month intervals |
| L401–L500 | Dates, PRX match/replacement, missing values, input/output formats, repeat/trim |

See `tests/library500/README.md` for the exact family-to-ID map.

### Failures investigated and resulting changes

1. **Invalid PRX fixtures, not a confirmed MCP scanner bug.** The first offline
   draft failed seven case subtests. An attempted scanner change assumed an
   unescaped slash inside a PRX bracket class was valid. Live SAS rejected
   `/[a/]*/` with `Invalid characters "]*/" after end delimiter "/"`.
   That scanner change was removed; the final implementation retains the
   original PRX scanner. Slash delimiters are now escaped in the fixtures.
   A malformed comment-like expression stalled an early 20-case probe until
   its 180-second CLI timeout. The separate direct diagnostic process was
   explicitly identified and stopped; the shared session server was preserved.
   A later draft passed 400 cases but preflight blocked the last 100-case batch
   because one remaining fixture contained a comment opener. That fixture was
   replaced with a valid asterisk character-class pattern. These failed drafts
   are not counted as final successes or as seven product bugs.
2. **Include dependency order was a product defect.** Focused investigation
   found `include_targets()` collected all deferred executable-string includes
   before direct statements. For `first.sas`, a deferred `middle.sas`, then
   `last.sas`, the old result began with `middle.sas`. Discovery now merges
   direct and deferred targets by source offset, preserving repeated includes,
   multiple quoted operands, and recursive executable-string order. This is
   lexical dependency ordering; it does not claim to simulate CALL EXECUTE's
   runtime scheduling. The new four-check regression failed **2/4** against
   the original module and passes **4/4** after the fix.
3. **Successful calculations should not imply a rendering failure.** Every
   new script uses DATA _NULL_ and writes its assertion to the SAS log. Both
   equivalent CLI entry points now explain that successful calculations or
   log-only programs may produce no HTML. Failure status remains governed by
   actual execution and SAS diagnostics.
4. **Reviewable evaluation tooling.** The Perl builder, offline verifier and
   live harness are checked in. Each case has its own oracle and marker; the
   harness rejects missing/duplicate markers, echoed source, SAS ERROR lines,
   unexpected markers and nonzero CLI exits. A failed batch leaves its cases
   unverified; `--batch-size 1` isolates a case. The harness preserves artifacts
   and structured per-case results even when a submission fails.

### Final evidence

- Final live run: **500/500 passed**, five batches of 100, every CLI exit zero,
  no SAS ERROR lines, exactly one anchored marker for each ID.
- Live run directory: `SAS_Output_library500_live_fN6Zaz/`; each batch retains
  submitted code, CLI output, SAS log and status files.
- Portable results: `tests/library500/verified_results_2026-11-02.json`.
- Final independent PRX smoke rerun: **2/2 passed**, one case per submission,
  in `SAS_Output_library500_live_4etKas/`, after the CLI message change.
- Offline regression run: **25 files, 1,501 top-level checks passed**, including
  500 new case subtests with six checks each, the four include-order checks,
  and the existing adversarial/source-analysis suites.
- Diagnostic history: `SAS_Output_library500/` holds baseline and corrected
  TAP, terminal output and the old-module include-order reproduction.
  The initial 20-case timeout is in `SAS_Output_library500_live_fRzHmE/`;
  the isolated invalid-slash diagnosis is in `SAS_Output_library500_live_Aum6QE/`;
  the first 400/500 draft is in `SAS_Output_library500_live_o8ajqh/`.

These tests validate focused Base SAS behavior through the public CLI, lexical
preflight and dependency ordering. They do not validate every original library
macro, statistical procedure, plot, upload path or cleanup option.

### Reproduce in Cygwin using Perl/Bash

From the MCP4SAS checkout:

```bash
export PATH=/usr/bin:$PATH
perl tools/build_library500_evaluations.pl \
  /cygdrive/h/F_Queens/360yunpan/SASCodesLibrary
prove -v tests/test_library500_evaluations.pl tests/test_include_source_order.pl
perl tests/run_live_library500.pl --live
perl tests/run_live_library500.pl --live --only L431,L441 --batch-size 1
```

Full offline regression selection, including the two existing task corpora:

```bash
tests=()
for file in MCPDeps/test_*.pl tests/test_*.pl; do
  case "$file" in tests/test_live_*) continue;; esac
  if rg -q 'use Test::More|use Test2' "$file"; then tests+=("$file"); fi
done
prove "${tests[@]}" tests/new_validation_tasks_001_100.pl \
  tests/covid19_gwas_validation_tasks_001_500.pl
```

Submit any generated script individually without the harness:

```bash
OPEN_RESULT=0 SAS_ODA_AUTOLOAD_MACROS=0 \
  perl run_sas_codes_or_files_in_ODA.pl \
  --file tests/library500/L001.sas --run-timeout-seconds 180 \
  --output-prefix SAS_Output_library500_individual_L001
```

Its success evidence is the exact SAS log line `LIB500_PASS=L001`; HTML is
unnecessary. Generated source and runtime output are separate: the 500 scripts
are maintained fixtures; ignored `SAS_Output*` directories hold diagnostic runs.

## 18. Second different 500-script library round (2026-11-02)

### New coverage: relational data, macros and input/output

Added **500 new SAS scripts**, `tests/library500_round2/R501.sas` through
`R1000.sas`. These cover 50 operation families at ten synthetic input sizes
(N=2 through 11). They supplement the preceding function-focused L001–L500
batch; the earlier cases remain intact. The new manifest references **43 real
source files** from the same read-only SAS library directories.

Each case has an independently calculated Perl oracle, source filename/line,
original source and evidence-line SHA-256, and normalized executable-body
fingerprint. The offline verifier rejects ID-only duplicate bodies within this
batch and checks against the previous batch's fingerprints. This verifies
distinct generated programs, not semantic uniqueness of every SAS concept
across all historical tests.

| IDs | New coverage |
| --- | --- |
| R501–R600 | DISTINCT, HAVING, join cardinality, UNION/UNION ALL, EXCEPT, INTERSECT, CASE |
| R601–R700 | Correlated queries, CALCULATED, table updates/deletes/inserts, sort stability, BY-group summaries |
| R701–R800 | RETAIN, missing-aware sum statements, LAG/DIF queues, POINT/NOBS, arrays, TRANSPOSE, weighted summaries, tied ranks |
| R801–R900 | FREQ/COMPARE, hash lookup, RESOLVE macro expressions, MERGE/SET flags, DSD fields, TRUNCOVER, SCANOVER |
| R901–R1000 | INPUT modifiers, literal DATALINES4 source text, TEMP files, macro scope, CALL EXECUTE, DOSUBL, metadata, fileref INCLUDE |

Cases create only their own uniquely prefixed WORK tables in a newly named
test session. Each must produce exactly one result row before its value can
pass, then deletes only its own table prefix. TEMP files are cleared and local
test macros removed. A failed submission may retain its own WORK fixtures for
inspection. The tests do not change the original library or permanent user
datasets and do not delete user directories. These are 50 algorithms with ten
scenarios each, not 500 unrelated algorithms or separate login tests.

### Confirmed MCP4SAS defect: RESOLVE hid a real macro dependency

The library contains real patterns such as
`resolve('%AddSpaces4str(str='||aa||',add2end=1,nspaces=3,char4space=-)')`
in `Macros/AddSpaces4str.sas` and similar code in `Macros/leftalign4catstr.sas`.
The analyzer previously preserved macro calls in single-quoted arguments to
DOSUBL and CALL EXECUTE, but masked those passed to **RESOLVE** as ordinary
string data. Targeted loading therefore missed a macro called only through
`resolve('%macro_name()')`.

The baseline regression failed **3/16** checks. A live reproduction created
one uniquely named harmless source file in online `~/Macros`, returning 42.
With global autoload disabled, the old analyzer did not load it: the SAS log
reported `WARNING: Apparent invocation of macro ... not resolved`, followed
by the test's `ERROR: RESOLVE_LOADING_ASSERT`. Cleanup deleted and verified
the exact owned fixture. Baseline evidence is in
`SAS_Output_resolve_live__3pfca/` and
`SAS_Output_library500_round2/resolve_live_before.tap`.

`SAS_Source_Analysis.pm` now treats RESOLVE arguments as macro-evaluation
contexts for dependency discovery, including nested function calls and
case-insensitive function spelling. It retains the narrower distinction for
include discovery: RESOLVE alone is not DOSUBL/CALL EXECUTE submission of
arbitrary SAS statements, so quoted `%include` text is not invented as a
file dependency. Ordinary string data and NRSTR-protected calls stay masked.

An intermediate refactoring compiled a function-name regex without its own
case-insensitive flag. The uppercase nested RESOLVE check and two existing
uppercase deferred-include checks caught this regression. Adding `/i` to the
compiled patterns corrected it. Final regression: **16/16 passed**. Final live
targeted loading: **6/6 passed**, including uppercase `RESOLVE(strip(...))`,
the computed value 42, an EXACT loader marker, and verified fixture deletion.
Live evidence: `SAS_Output_resolve_live_TmkPbG/`. A final Cygwin `prove` run
also passed **6/6**, exit zero, with artifacts in
`SAS_Output_resolve_live_woDqX6/` and transcript
`SAS_Output_library500_round2/resolve_live_prove_final.log`.

Ten final corpus cases, R831–R840, now exercise locally defined macro return
values through lowercase/uppercase RESOLVE. They replaced a redundant draft
hash-replacement family; the separately counted remote-fixture test proves
that dependency loading works when the macro is not already compiled.

### Evaluation harness improvements

`tests/run_live_library500.pl` now accepts `--round 2` while preserving the
first round's default. Required script files cannot silently disappear: missing
or empty inputs stop submission. Both rounds use `SAS_Evaluation_Log.pm` to
count assertions only in the SAS runtime-log section. Numbered source echoes,
MPRINT traces, submitted source, and trailing report output cannot supply
ordinary assertion markers.

The evaluator fails closed on a missing runtime log, nonzero worker exit,
runtime ERROR (including indented numbered errors), missing/duplicate markers,
and unexpected or malformed marker IDs. Warnings retain their original SAS
severity. Its **13 regression checks passed**, including backward compatibility
with the L001–L500 marker format and CRLF logs. Structured results include
whether a runtime-log section was present; per-case markers and batch exit
codes remain reviewable. A failed batch marks its members unverified; use
`--batch-size 1` to isolate individual behavior.

### Verified results and artifacts

- Final corpus run: **500/500 live cases passed**, five 100-case submissions,
  each exit zero, exactly one marker per expected ID, no unexpected markers
  and no SAS ERROR lines. Artifacts: `SAS_Output_library500_live_LYsmuu/`.
- Dated per-case results:
  `tests/library500_round2/verified_results_2026-11-02.json`.
- Complete offline regression: **28 files, 2,034 top-level checks passed**,
  including the 500 new case subtests (six checks each), prior corpus tests,
  the RESOLVE checks and the evaluation-log checks.
- Supplemental remote macro loading: **6/6 passed**, with verified cleanup.
- Previous-round compatibility smoke: **2/2 passed** through the updated
  harness's default mode (`L001` and `L441`), in
  `SAS_Output_library500_live_lIkadp/`.
- Development TAP and terminal evidence remain in the ignored
  `SAS_Output_library500_round2/` directory. The initial draft batch also passed
  500 cases in `SAS_Output_library500_live_VLjUdv/`; the final evidence above
  covers the revised RESOLVE family and stricter harness.

These checks cover bounded synthetic data transformations and macro-loading
behavior. They do not validate all original library macros, statistical models,
plots, user datasets, network downloads or concurrent sessions.

### Cygwin commands (Perl/Bash)

From the MCP4SAS checkout:

```bash
export PATH=/usr/bin:$PATH
perl tools/build_library500_round2.pl \
  /cygdrive/h/F_Queens/360yunpan/SASCodesLibrary
prove -v tests/test_library500_round2.pl \
  tests/test_resolve_macro_dependencies.pl tests/test_evaluation_log.pl
perl tests/run_live_library500.pl --live --round 2
perl tests/test_live_resolve_macro_loading.pl --live
prove -v tests/test_live_resolve_macro_loading.pl :: --live
```

Isolate input, RESOLVE or INCLUDE cases:

```bash
perl tests/run_live_library500.pl --live --round 2 \
  --only R831,R832,R991,R1000 --batch-size 1
OPEN_RESULT=0 SAS_ODA_AUTOLOAD_MACROS=0 \
  perl run_sas_codes_or_files_in_ODA.pl --file tests/library500_round2/R831.sas \
  --run-timeout-seconds 180 --output-prefix SAS_Output_round2_R831
```

Run the full offline selection using the Bash loop in section 17. The old-failure
diagnostic command is `perl tests/test_live_resolve_macro_loading.pl --live
--expect-missing`; it is intended for the old analyzer and should fail against
the repaired implementation. Normal validation uses `--live` alone. Programs,
logs, fixtures, generators and harnesses use SAS, Perl and Bash; no Python
evaluation script was introduced.

## 19. Third different 500-script library round (2026-11-02)

### Coverage and provenance

Added **500 new runnable SAS evaluations**, `tests/library500_round3/T1001.sas`
through `T1500.sas`, based on operation-use sites in **39 original source
files**. The builder reads the same read-only `Easy-For-Error-Codes-SAS`,
`SAS_Code_Database` and `Macros` directories under the user's SAS library.
The preceding L001–L500 and R501–R1000 cases remain intact.

This round has **50 behavior families with ten scenarios each**, N=2 through
11. It tests bounded synthetic behavior; it is not 500 unrelated algorithms or
500 separate account logins. The manifest records source filenames/lines,
source and evidence-line SHA-256, independently calculated Perl answers and
normalized executable fingerprints. The verifier rejects repeated normalized
bodies within the batch and checks fingerprints against the preceding two
batches; it does not claim semantic uniqueness of every SAS concept.

| New IDs | Coverage |
| --- | --- |
| T1001–T1100 | PROC CONTENTS, variable attributes, dataset handles, dictionary indexes/tables |
| T1101–T1200 | Numeric/character formats, informats, CNTLIN/CNTLOUT, metadata attributes, APPEND FORCE, RENAME |
| T1201–T1300 | WHERE/IF iteration, FIRSTOBS/OBS, empty schema, missing classes, zero weights, tied ranks, TRANSPOSE LET, views |
| T1301–T1400 | SQL filtering/order/OUTOBS, leap dates, datetime components, weekend selection, UNQUOTE/NRSTR |
| T1401–T1500 | Macro indirection/quoting/scope, SYSFUNC handles, PRX lifetime, FREAD/FGET, FILEREF, owned TEMP deletion |

Every test must produce exactly one result row and exactly one matching runtime
assertion. Cleanup targets only its WORK table prefix, explicitly created view,
format/informat entry or owned TEMP file. Local macros and variables are
removed. Original library files, user datasets, permanent catalogs and user
directories are not cleanup targets. A failed case can retain its own session
resources for diagnosis. The new cases intentionally include warnings from
APPEND FORCE, TRANSPOSE LET and OUTOBS; warnings keep their SAS severity.

### Confirmed loading defect: UNQUOTE releases a hidden NRSTR call

The library uses `%UNQUOTE` to release quoted macro text, including an example
in `Macros/SAS-macros-master/distance.sas`. The dependency scanner previously
masked every `%NRSTR` body, so a macro called only through
`%UNQUOTE(%NRSTR(%macro_name()))` was absent from targeted loading.

The initial focused regression failed **4/12** checks. A live reproduction
created a uniquely named harmless source in `~/Macros` returning 42, with
global autoload disabled. SAS reported an unresolved macro invocation, and the
assertion failed. The baseline test's `--expect-missing` mode confirmed that
failure and deleted/verified its exact owned source file. Evidence:
`SAS_Output_unquote_live_1uY2LP/` and
`SAS_Output_library500_round3/unquote_live_before.log`.

`SAS_Source_Analysis::mask_macro_literals()` now recognizes direct UNQUOTE
release of an NRSTR expression, including double-quoted source and deferred
RESOLVE expressions. Independent inner NRSTR protection, enclosing protected
NRSTR text, ordinary single-quoted DATA strings and comments remain masked.
Source offsets stay unchanged. This is bounded static dependency discovery;
it does not expand arbitrary macro variables or simulate every possible macro
rescan/data-flow sequence.

Final focused regression: **15/15 passed**. The supplemental live loader test
now accepts `--mode unquote`, while keeping RESOLVE as its default. Both modes
create only one uniquely named source, require the computed value 42 and an
EXACT targeted-loader marker, then delete and verify that source. The final
UNQUOTE mode tests release inside a double-quoted DATA expression; the earlier
successful live check also covered a direct `%LET` expression.

### Fixture failures investigated instead of counted as product defects

The first full live run verified only **100/500 cases** under the strict batch
policy: four batches contained errors. Although 450 individual pass markers
appeared, an errored batch is not accepted as verified. The following were
mistakes in the new SAS fixtures, not confirmed MCP4SAS bugs:

1. SAS SQL rejected function calls inside the literal IN list used for two
   metadata table names. Replaced it with two equality predicates joined by OR.
2. PROC CATALOG rejected `NOLIST`. Removed that option and retained exact
   format/informat entry deletion. Numeric, character and informat entries use
   their corresponding FORMAT, FORMATC and INFMT types.
3. The WHERE-vs-IF test attempted a SELECT expression without a valid outer
   FROM source. Replaced it with separate scalar aggregate tables and a join.
4. PROC CONTENTS supplies informat width as `INFORML`, not `INFORMATL`.
   Corrected the metadata column; the original spelling produced a missing
   result and failed the case assertion.
5. CALL PRXFREE cannot modify a numeric constant. Using a variable corrected
   that compile error, but the macro-created handle was still invalid in the
   later DATA step in this run. The final fixture allocates, uses and frees its
   PRX handle together in one DATA step.
6. A TEMP fileref had not yet been materialized into a file when the assignment
   check expected the existing-file status. The fixture now writes its owned
   file first and checks for a nonzero status after clearing the fileref.

The intermediate corrected batch verified **400/500**; its final batch still
contained the PRX-handle and FILEREF assumptions. Those 20 cases then passed
in isolation before the final complete rerun.

### Final evidence

- Final live batch: **500/500 passed**, all five CLI exits zero, exactly one
  expected marker per case, no unexpected markers and no SAS ERROR lines.
  Artifacts: `SAS_Output_library500_live_M74lkr/`.
- Portable per-case evidence:
  `tests/library500_round3/verified_results_2026-11-02.json`.
- Complete offline selection: **30 test files, 2,553 top-level checks passed**,
  including 500 new subtests with six checks each and 15 UNQUOTE checks.
- UNQUOTE targeted-loading validation: **6/6 passed**, including source cleanup.
- RESOLVE compatibility validation: **6/6 passed**, including source cleanup.
- Their final owned artifacts are respectively
  `SAS_Output_unquote_live_6avUVD/` and `SAS_Output_resolve_live_Xc4spL/`.
- Isolated PRX/FILEREF cases: **20/20 passed**, in
  `SAS_Output_library500_live_wz7AMl/`.
- Initial and intermediate full-run evidence remains respectively in
  `SAS_Output_library500_live_3xgw8d/` and
  `SAS_Output_library500_live_ibqpZz/`.
- Cygwin live macro transcripts, focused TAP and terminal results remain in
  `SAS_Output_library500_round3/`. These ignored artifacts are kept separate
  from the maintained SAS fixtures and dated result JSON.

These checks do not validate every original library macro, plot, statistical
model, external dataset, network download or concurrent-session scenario.

### Cygwin reproduction commands

From the MCP4SAS checkout:

```bash
export PATH=/usr/bin:$PATH
perl tools/build_library500_round3.pl \
  /cygdrive/h/F_Queens/360yunpan/SASCodesLibrary
prove -v tests/test_library500_round3.pl tests/test_unquote_macro_dependencies.pl
perl tests/run_live_library500.pl --live --round 3
prove -v tests/test_live_resolve_macro_loading.pl :: --live --mode unquote
prove -v tests/test_live_resolve_macro_loading.pl :: --live
```

Isolate the format, metadata, quoting or handle cases:

```bash
perl tests/run_live_library500.pl --live --round 3 \
  --only T1121,T1201,T1391,T1461,T1481 --batch-size 1
OPEN_RESULT=0 SAS_ODA_AUTOLOAD_MACROS=0 \
  perl run_sas_codes_or_files_in_ODA.pl \
  --file tests/library500_round3/T1391.sas --run-timeout-seconds 180 \
  --output-prefix SAS_Output_round3_T1391
```

The full offline Bash selection from section 17 includes both new test files.
The old-failure command appends `--expect-missing` to the UNQUOTE live command;
use it only when intentionally reproducing the old analyzer. The repaired
implementation should not satisfy that expected-failure mode. No Python
evaluation scripts were introduced.

## 20. Fourth 500-script round: statistics and expected errors (2026-11-02)

### Coverage and independent oracles

Added `tests/library500_round4/F1501.sas` through `F2000.sas`: **500 new
executable scenarios** based on procedure/operation-use sites in **13 original
SAS library files**. The manifest records filenames, source lines, source and
evidence-line SHA-256, synthetic input size, expected result and normalized
executable fingerprint. Original libraries are read only. Families share
procedure examples while testing different statistical properties; the programs
are newly constructed synthetic evaluations rather than copies of private
original analyses.

There are **45 positive families and five intentional-error families**, each
at ten input sizes, N=2 through 11. This means **450 numerical analyses and 50
expected SAS errors**, not 500 successful SAS programs or separate logins.
Numerical oracles are computed in Perl from closed-form formulas or explicit
loops, independently of SAS output. Examples include sample/population variance,
replicated-frequency variance, standard errors, weighted means, covariance,
exact linear fits and online Welford variance. Expected-error cases require
specific runtime diagnostics rather than an arbitrary failure.

| IDs | New behavior |
| --- | --- |
| F1501–F1600 | Variance definitions, standard error/CV, weights/FREQ, grouped variance, range, missing counts |
| F1601–F1700 | Median/quartiles/IQR, skewness/kurtosis, CSS/USS, Pearson/Spearman correlation |
| F1701–F1800 | Covariance, listwise exclusion, regression parameters/predictions, GLM effects/residuals, frequency percentages |
| F1801–F1900 | Frequency percentages/sparse/cumulative cells, ranks, standardization, summary types, SQL moments |
| F1901–F1950 | Weighted missingness, double transpose, row expansion, online variance, array standardization |
| F1951–F1960 | REG must reject a missing response variable |
| F1961–F1970 | FREQ must reject a character WEIGHT variable |
| F1971–F1980 | APPEND without FORCE must reject incompatible variable types |
| F1981–F1990 | MEANS must reject a missing analysis variable |
| F1991–F2000 | SQL must reject an ambiguous column reference |

The successful cases must produce exactly one result row and one exact
`ROUND4_PASS=Fnnnn` runtime line after comparison with the oracle. The negative
cases deliberately emit no calculation-success marker. Every case creates and
cleans only its own WORK table prefix. No original library files, user datasets,
permanent libraries or user directories are cleanup targets.

### Improvements to evaluation and error-reporting verification

`SAS_Evaluation_Log.pm` now supports isolated expected-error evaluation. Such a
test passes only when the worker exits nonzero normally, the actual runtime
SAS log contains an ERROR matching the case's diagnostic, and no contradictory
success marker appears. Source listings, report text, warnings, signal exits,
missing logs and unrelated infrastructure errors cannot satisfy this rule.
Each expected-error case runs alone so a neighboring failure cannot validate it.

The harness also reads `output.run.status.json` and requires terminal metadata
to agree with the observed behavior: complete/completed/successful for positive
cases, complete/failed/unsuccessful for intentional errors. Missing, malformed,
incomplete or contradictory status invalidates the test. This checks process
status, executed SAS diagnostics and terminal job status together. Existing
positive evaluation remains supported; the new status requirement is enabled
by the live harness.

The expected-error evaluator's **15 focused regression checks passed**. They
include wrong diagnostic, zero exit, source echo, warning-only output, signal
termination, missing process status, unexpected success markers, missing logs,
non-isolated failures and contradictory terminal metadata. Per-case result JSON
now records body SHA-256, expected-failure flag, diagnostic match and status
validity, making an expected SAS error distinct from an unexpected test failure.

No additional SAS execution-engine defect was established by this batch. The
intentional errors were already reported correctly; the improvements make those
behaviors explicit, independently checked regressions instead of assuming any
nonzero return means the desired failure occurred.

### New fixture failure investigated

The first full run verified **450/500 expected outcomes**. The statistical
procedures and all 50 intentional errors behaved as expected. One 50-case
positive batch was invalidated because its ten double-transpose fixtures
assumed the second transpose produced a `COL1` column. SAS reported that COL1
was absent and the SUM argument was not numeric. This was a fixture mistake,
not an MCP4SAS execution failure; the other 40 cases in the batch were left
unverified under the strict batch policy.

The corrected fixture drops the first transpose's `_NAME_` metadata before
transposing back, supplies `PREFIX=back`, and sums the explicit `BACK1` column.
The independent sum-of-squares oracle was retained. The full corrected run
then verified all 500 outcomes. Initial evidence remains in
`SAS_Output_library500_live_tropLM/`.

### Persistent-session recovery and cleanup checks

`tests/test_live_sas_error_recovery.pl` deliberately creates one owned WORK
dataset, triggers a SQL missing-column error, then submits valid code using
that same dataset in the same persistent session. It checks the original failed
status, subsequent successful execution, computed value 42, completed status
and matching session identity, then cleans only the owned WORK prefix.
Using the prior WORK data verifies continuity beyond matching session labels.
The live test passed **6/6**, in `SAS_Output_error_recovery_oKO8Xg/`.

The helper-directory review found that the existing CLI already cleaned its
scratch after the expected errors; the final workspace check found **zero
`.mcp4sas_work_*` directories**. An attempted additional cleanup path was removed
as unnecessary. Existing explicit intermediate-retention preferences are honored;
SAS programs, logs and JSON evidence remain in the ignored run folders.

### Final verified results

- **500/500 expected outcomes verified**: **450 successful numerical analyses**
  and **50 correctly reported SAS errors**. Negative job status remains failed;
  only its evaluation outcome is a pass.
- Final run: `SAS_Output_library500_live_lJJYpU/`. The 450 positive scenarios
  used five batches and the 50 negatives used one job each: **55 submissions**.
- All cases had consistent terminal status. Positive jobs exited zero with one
  marker per case and no SAS ERROR lines. Each negative job exited nonzero with
  its required runtime diagnostic and no success marker.
- Portable evidence:
  `tests/library500_round4/verified_results_2026-11-02.json`.
- Complete offline suite: **32 files, 3,073 top-level checks passed**, including
  500 new case subtests with seven checks each and 15 error-evaluation checks.
- Persistent-session error recovery: **6/6 passed**.
- A positive/negative smoke rerun, including the corrected transpose case,
  verified **2/2 outcomes** in `SAS_Output_library500_live_xUpBoq/`.
- Focused TAP and terminal transcripts remain in
  `SAS_Output_library500_round4/`.

These are bounded synthetic procedure checks, not validation of every original
statistical model, inferential result, plot, external dataset or concurrency
scenario. There are 50 families with ten scenarios each, not 500 unrelated
algorithms. The preceding three 500-case batches remain intact.

### Cygwin commands

From the MCP4SAS checkout:

```bash
export PATH=/usr/bin:$PATH
perl tools/build_library500_round4.pl \
  /cygdrive/h/F_Queens/360yunpan/SASCodesLibrary
prove -v tests/test_library500_round4.pl tests/test_expected_failure_evaluation.pl
perl tests/run_live_library500.pl --live --round 4
prove -v tests/test_live_sas_error_recovery.pl :: --live
```

Isolate a numerical, transpose or intentional-error case:

```bash
perl tests/run_live_library500.pl --live --round 4 \
  --only F1521,F1731,F1911,F1991 --batch-size 1
OPEN_RESULT=0 SAS_ODA_AUTOLOAD_MACROS=0 \
  perl run_sas_codes_or_files_in_ODA.pl --file tests/library500_round4/F1991.sas \
  --run-timeout-seconds 180 --output-prefix SAS_Output_round4_F1991
```

The standalone F1991 command must exit nonzero with an ambiguous-column ERROR.
The evaluation harness must report that as a verified expected failure, while
requiring exit zero and a numeric assertion from the other selected programs.
Use section 17's Bash loop for the complete offline suite. No Python evaluation
scripts were introduced.

## 21. Fifth different 500-script round: dataset access and macro compatibility (2026-11-02)

### New scenarios and source evidence

Added **500 runnable SAS scenarios**, `tests/library500_round5/G2001.sas` through
`G2500.sas`, with operation-use evidence from **30 original library files**.
The source directories are the same read-only `Easy-For-Error-Codes-SAS`,
`SAS_Code_Database` and `Macros` folders beneath the user's SAS library root.
The preceding four 500-case corpora remain intact.

The new manifest records source paths, source line numbers, original-file and
line SHA-256, synthetic input N, independent Perl oracles and normalized body
fingerprints. There are **50 behavior families with ten input sizes each**,
N=2 through 11: **450 expected successes and 50 intentional SAS errors**. This
does not mean 500 unrelated algorithms or independent account logins. Generated
body fingerprints are checked for duplicates within the batch and against
earlier manifests; this is not a proof of semantic uniqueness across every
historical SAS concept.

| IDs | New coverage |
| --- | --- |
| G2001–G2100 | FETCH/FETCHOBS, GETVAR functions, existence and labels, REWIND, CALL SET, OPEN WHERE, physical/logical observations, PDV truncation |
| G2101–G2200 | MODIFY/REPLACE/REMOVE, UPDATE modes, interleaved SET, indexed KEY lookup, sorting variants, high tied ranks |
| G2201–G2300 | Special missings, temporary arrays, implicit DO OVER, CMISS, numeric variable lists, structured delimiters, INPUT pointers/named input |
| G2301–G2400 | Conditional input holding, record length/buffers, DATALINES4 apostrophes, MISSOVER, macro quoting and evaluation |
| G2401–G2450 | Macro loops/defaults/lifecycle and abbreviated single/multiple-fileref includes |
| G2451–G2460 | Expected duplicate-key rejection for a UNIQUE index |
| G2461–G2470 | Expected character/numeric SET conflict |
| G2471–G2480 | Expected aggregate-in-WHERE rejection |
| G2481–G2490 | Expected INSERT arity mismatch |
| G2491–G2500 | Expected overlapping-format-interior rejection |

Every positive scenario must create exactly one result row, match its Perl
oracle and emit one exact `ROUND5_PASS=Gnnnn` runtime marker. Each negative
scenario runs separately and must return a normal nonzero exit, an actual SAS
ERROR matching its diagnostic, no contradictory marker and complete failed
terminal metadata. A negative evaluation pass remains a failed SAS job.

The cases create only their own WORK tables, views, macros, format entries and
owned TEMP filerefs. Those resources are cleaned by the cases; a failed SAS step
can retain its own session state for diagnosis. Original source libraries,
permanent user datasets and user directories are not modified or deleted.

### Confirmed defect: abbreviated %INC did not discover local dependencies

The library uses `%INC`, for example in
`Macros/base4sas_developer/mp_abort.sas`, `mp_ds2squeeze.sas`,
`mp_applyformats.sas` and `mp_include.sas`. MCP4SAS previously recognized only
`%INCLUDE` in include extraction, submission detection and statement wrapping.
The CLI/runner classifiers also treated INC as an external macro name.

The initial focused alias regression failed **9/15** checks. A live reproduction
created one uniquely named local SAS payload, checked that its prospective
remote upload name did not already exist, and submitted `%inc 'LOCAL_PATH';`.
The old runner did not discover/upload that dependency. SAS could not execute
the local payload, the CLI returned nonzero and the payload assertion was
absent. The expected-failure baseline passed its four checks, including cleanup
or confirmation that the owned remote name was absent. Evidence:
`SAS_Output_inc_alias_TLU8zB/` and
`SAS_Output_library500_round5/inc_live_before.log`.

Include extraction now accepts `%INC` and `%INCLUDE`, case-insensitively, with
keyword boundaries. It preserves multiple quoted operands, doubled apostrophes,
deferred DOSUBL/CALL EXECUTE includes and source ordering. Inert comments,
single-quoted DATA strings and NRSTR examples remain excluded. Fileref operands
remain runtime operands; they are not invented as external local file paths.
Both CLI entry points recognize the abbreviation and handle its existing
include-wrapper statement completion consistently.

The final local-file live check passed **6/6**: the payload uploaded, executed
and returned 42; dependency upload was reported; INC was not requested as an
external macro; and cleanup deleted/verified the exact uniquely named upload.
Evidence: `SAS_Output_inc_alias_sT_Zjk/` and
`SAS_Output_library500_round5/inc_live_after.log`.

The corpus's TEMP-fileref `%INC` scenarios alone would not detect a missing
local-file upload, because they construct their files inside SAS. The separate
real local-payload check closes that coverage gap.

### Improvement: one builtin classifier for CLI and runner

The new macro scenarios also exposed inconsistent builtin-name lists: quoting
functions such as QSCAN, QSUBSTR, QUPCASE, QLOWCASE and NRQUOTE were missing,
while SYMDEL/SYSMACDELETE were recognized by the runner but not both CLIs.
INDEX and INC are now included as reserved operations too. With default
autoload selection, missing classifications could route builtin-only programs
through unnecessary external/global macro loading decisions.

`SAS_Source_Analysis::is_builtin_macro_name()` is now the shared classifier.
Both CLI wrappers and `SAS_ODA_Runner` delegate to it, reducing list drift while
leaving user-defined macro names eligible for targeted discovery. The expanded
alias/classification regression passed **43/43** checks.

An additional live test clears the autoload override for its child process and
runs QSUBSTR/STR/SYMDEL using default submission selection. It passed **4/4**:
the value was correct, global importallmacros bootstrap was skipped, and no
external macro source was requested. Evidence:
`SAS_Output_builtin_macros_piEM1D/` and
`SAS_Output_library500_round5/builtin_live.log`. This verifies the loading
decision; it is not a timing benchmark.

Targeted user-macro loading was rechecked through UNQUOTE/NRSTR and passed
**6/6**, including the computed value, EXACT loader marker and verified fixture
deletion. Evidence: `SAS_Output_unquote_live_uix2rm/` and
`SAS_Output_library500_round5/unquote_compatibility.log`.

### Fixture assumption corrected

The initial complete corpus verified **490/500 outcomes**. All 450 expected
successes and the first 40 intended failures behaved as expected. The last ten
format fixtures expected a fatal overlap error from ranges that merely touched
at an endpoint, but SAS accepted those definitions with exit zero. The harness
correctly rejected them as unverified expected failures; their zero exit was
not reclassified as a successful error test.

The fixtures now have overlapping interiors, for example `1–4` and `2–4`,
rather than just a shared endpoint. Those ten cases passed an isolated rerun
before the complete final run. This was a fixture correction, not a confirmed
SAS execution defect. Initial evidence: `SAS_Output_library500_live_j0pcF2/`;
isolated correction: `SAS_Output_library500_live_JGq2yM/`.

### Final results and maintained tools

- **500/500 expected outcomes verified**: 450 successful operations and 50
  correctly reported SAS errors; all terminal statuses agreed with their
  intended outcomes.
- Final corpus run: `SAS_Output_library500_live_9M8WmP/`, comprising five positive
  batches plus 50 isolated error jobs: **55 submissions**.
- Dated per-case evidence:
  `tests/library500_round5/verified_results_2026-11-02.json`.
- Complete offline suite: **34 test files, 3,621 top-level checks passed**,
  including 500 new subtests with seven checks each and 43 include/classifier
  assertions.
- Supplemental live checks: **6/6** local %INC upload, **4/4** builtin default
  loading, **6/6** targeted user-macro compatibility.
- Standalone SAS macro-bootstrap sentinel diagnostic: **PASS**.
- Workspace helper check: no `.mcp4sas_work_*` directories remained.

`tools/lib/Library_Evaluation_Corpus.pm` factors the repeated provenance,
fingerprinting and fixture-writing work for the new builder. Earlier corpus
generators are preserved. The harness supports `--round 5`; expected-error
isolation, strict runtime assertions, process status checks and terminal JSON
validation continue to apply. Raw development evidence remains under the ignored
`SAS_Output_library500_round5/` folder and its referenced run directories.

These are bounded synthetic tests, not validation of every original macro,
statistical model, plot, external dataset, platform option or concurrent session.

### Cygwin commands

From the MCP4SAS checkout:

```bash
export PATH=/usr/bin:$PATH
perl tools/build_library500_round5.pl \
  /cygdrive/h/F_Queens/360yunpan/SASCodesLibrary
prove -v tests/test_library500_round5.pl tests/test_include_abbreviation.pl
perl tests/run_live_library500.pl --live --round 5
prove -v tests/test_live_include_abbreviation.pl :: --live
prove -v tests/test_live_builtin_macro_bootstrap.pl :: --live
prove -v tests/test_live_resolve_macro_loading.pl :: --live --mode unquote
perl MCPDeps/test_sas_oda_debug_macro_guard.pl
```

Isolate a dataset, macro, include or expected-error case:

```bash
perl tests/run_live_library500.pl --live --round 5 \
  --only G2001,G2361,G2441,G2491 --batch-size 1
OPEN_RESULT=0 SAS_ODA_AUTOLOAD_MACROS=0 \
  perl run_sas_codes_or_files_in_ODA.pl --file tests/library500_round5/G2441.sas \
  --run-timeout-seconds 180 --output-prefix SAS_Output_round5_G2441
```

Use the offline Bash selection in section 17 for all non-live checks. For the
old alias defect only, add `--expect-missing` to the live include test; that
expected-failure mode should not pass against the fixed implementation. The
evaluation programs, harnesses and generators use SAS, Perl and Bash; no Python
evaluation script was introduced.

## 22. Sixth different 500-script round: hash, temporal and deferred-code coverage (2026-11-02)

### New scenarios and provenance

Added `tests/library500_round6/H2501.sas` through `H3000.sas`: **500 runnable
SAS scenarios**, comprising **450 expected successes and 50 intentional errors**.
There are 50 behavior families at ten synthetic input sizes, N=2 through 11;
these are not 500 unrelated algorithms or independent logins. All preceding
corpora remain intact.

The manifest references operation-use evidence in **19 original library files**
from the same read-only `Easy-For-Error-Codes-SAS`, `SAS_Code_Database` and
`Macros` folders. It records source filenames/lines, source/line SHA-256,
independent Perl oracles and normalized executable fingerprints. The programs
are newly constructed synthetic checks, not copies of private original analyses.
Fingerprint comparison guards generated-body duplication, not semantic uniqueness
of every SAS concept across historical tests.

| IDs | Coverage |
| --- | --- |
| H2501–H2600 | Hash misses, MULTIDATA, iterators, replace/remove/clear, output, duplicate policy and explicit-key lookup |
| H2601–H2700 | PRX captures, positions/spans/iteration, backreferences, lookahead, replacement limits and word counting |
| H2701–H2800 | Empty-token scanning, COMPRESS modifiers, character classes, calendar alignment and continuous intervals |
| H2801–H2900 | Julian/calendar/time conversion, rewind/file lifecycle/copy, CSV export/import and quoted delimiters |
| H2901–H2950 | Double-quoted deferred includes, SYSCALL binding, macro scope queries and SYSFUNC DOSUBL |
| H2951–H2960 | Expected duplicate-key hash error |
| H2961–H2970 | Expected formatted-ID collision in TRANSPOSE |
| H2971–H2980 | Expected character-variable rejection by CORR |
| H2981–H2990 | Expected missing CALCULATED variable error |
| H2991–H3000 | Expected unsorted-BY error |

Positive cases require one result row, an independent numerical oracle and one
exact `ROUND6_PASS=Hnnnn` runtime assertion. Negative cases run separately and
require the expected actual SAS diagnostic and consistent failed terminal
metadata. Cleanup targets only each case's WORK prefix, owned views/macros,
catalog entries and TEMP files. Original libraries, user datasets and user
directories are not modified or deleted. A failed step may retain its own test
session state for inspection.

### Confirmed defect: double-quoted deferred include dependencies were hidden

The library uses double-quoted executable strings, including
`rc=dosubl("&MacroFullCommand")` in `Macros/RunMacrosRepeatedly.sas`, and
double-quoted CALL EXECUTE code in the stock macro collections. The source
analyzer tracked only single-quoted strings for deferred include extraction.
Consequently, literal local-file includes inside
`dosubl("%include 'LOCAL_PATH';")` or CALL EXECUTE were not discovered/uploaded.

The initial focused regression failed **7/11** checks. A live reproduction
created one uniquely named local SAS payload, protected its remote filename
with an existence check and submitted it through a double-quoted DOSUBL string.
The old runner did not upload it; the program failed and no payload-success
marker appeared. Its four expected-failure baseline checks passed, including
cleanup or confirmation that the unique upload name was absent. Evidence:
`SAS_Output_inc_alias_vhhhB8/` and
`SAS_Output_library500_round6/deferred_live_before.log`.

`SAS_Source_Analysis.pm` now records double-quoted spans as well as single-quoted
ones. Include extraction recursively decodes the applicable doubled quote
delimiter for strings inside DOSUBL/CALL EXECUTE contexts, preserving source
ordering and quote escapes. Ordinary quoted DATA text, strings after a closed
execution call, RESOLVE-only text and comments remain excluded. Runtime fileref
operands are not invented as local paths. This remains bounded static literal
discovery; it does not evaluate arbitrary macro-variable contents or all possible
dynamic string constructions.

Final focused regression: **11/11 passed**. Live local-payload checks each
passed **6/6** for DOSUBL and CALL EXECUTE, including actual upload, computed
value 42 and verified deletion of the exact unique upload. Their artifacts are
`SAS_Output_inc_alias_EBYkLS/` and `SAS_Output_inc_alias_6H3nxL/`; transcripts
are `deferred_dosubl_after.log` and `deferred_execute_after.log` under the new
ignored round folder.

### Builtin classification and corpus-generation improvements

The library also uses `%SYSCALL SET(dsid)` and `%SYSCALL PRXFREE(...)`.
The shared builtin classifier now includes SYSCALL, SYMLOCAL and SYMGLOBL,
avoiding unnecessary external/global macro loading decisions for those reserved
operations. The existing live builtin probe now exercises dataset binding with
SYSCALL as well as quoting functions and SYMDEL, with the autoload override
unset. It passed **4/4**, verifying the result and that global bootstrap and
external macro lookup were skipped. Evidence:
`SAS_Output_builtin_macros_0tvIDS/` and
`SAS_Output_library500_round6/builtin_after.log`. The expanded shared-classifier
regression passed **52/52** checks. This is loading-decision verification, not
a timing benchmark.

During generation, my month-end calendar oracle used an incorrect month offset
and eventually passed an out-of-range month to Perl's Time::Local. It was
corrected to calculate the first day of the following month minus one for the
intended interval. The original shared writer could already have written some
new fixtures before such a late oracle exception.

The shared builder now computes and validates all 500 oracles and fingerprints
before replacing program files or the manifest. A six-check regression proves
that a late oracle failure preserves prior fixture/manifest contents, writes no
partial new program, and that a valid generation writes the complete corpus.
This protects against generation/validation failures; it does not make filesystem
writes atomic if an I/O error occurs during writing. The first version of that
unit check used glob on a literal path; it was corrected to test file existence
directly. Final generator prevalidation regression: **6/6 passed**.

### Fixture failure: fixed-length padding and an anchored PRX pattern

The first full live corpus verified **400/500 outcomes** under strict batching.
The capture fixture stored text in a `$60` variable, then matched a pattern
ending in `$` against the padded value. The pattern did not match, capture
conversion produced missing values and ten case assertions failed. The other
90 members of that 100-case batch were left unverified because the batch had
errors; the remaining 350 positive cases and all 50 intended errors verified.

The fixture now uses `STRIP(text)` consistently for the anchored match and both
capture extractions. Its independent sum-of-two-captures oracle was unchanged.
Those ten cases passed in isolation in `SAS_Output_library500_live_FodXjC/`.
The old fixture run is retained in `SAS_Output_library500_live_QmVYSO/`.
This was a fixture mistake, not an established MCP4SAS execution defect.

### Infrastructure termination preserved and isolated

The corrected complete run verified **499/500**. H2984 ended with CLI exit
**74**, `failure_class=sas_oda_remote_session_termination`, and no definitive
runtime SAS diagnostic. The existing CLI marked it non-retryable and preserved
its status, log and marker file. The evaluation correctly refused to count this
as the expected missing-CALCULATED-variable error.

The server-side cause is **unconfirmed**; the evidence does not establish memory
or WORK/quota exhaustion. H2984 uses one tiny WORK input table. It was manually
isolated in a fresh session, reducing the footprint to that one case, and then
returned ordinary exit **1** with the expected CALCULATED-variable ERROR. That
isolated check passed. No automatic retry loop or remote-cause assumption was
introduced.

Main run: `SAS_Output_library500_live_fmsvBl/`. Isolated H2984 run:
`SAS_Output_library500_live_MeHTWQ/`. The original exit-74 attempt and its
non-retryable marker remain available; it was not rewritten as a success.

This event prompted stricter evaluation: an expected program error must use
the CLI's ordinary SAS error exit **1**. Reserved infrastructure exits 73/74,
timeouts/signals and classified space/session failures cannot pass even when
a partial log contains a matching program-error string. Four new regression
checks cover these cases; the expected-failure evaluator now passes **19/19**.
The real exit-74 event already failed under the old rule because its SAS error
was absent; the new checks additionally guard matching partial logs and
overridden exit codes.

### Auditable collection without double-counting reruns

`tools/collect_library_evaluation_results.pl` combines preserved run evidence.
It checks each attempted body's current manifest hash, re-evaluates the actual
SAS report, process exit and terminal JSON using the current rules, selects only
verified attempts, and retains unsuccessful attempts separately. A failed rerun
cannot replace a verified result; multiple attempts do not increase the count of
distinct cases.

The dated audit record therefore contains **500/500 distinct verified outcomes
across two runs**: 499 from the corrected main run plus the isolated H2984
verification. It preserves one unsuccessful infrastructure attempt. This is not
a claim that the main full run passed 500/500.

The collector was also given the old PRX-fixture run deliberately. It rejected
H2601's mismatched body hash and preserved the previous output sentinel, proving
that outdated program evidence cannot silently be substituted. The transcript
is `SAS_Output_library500_round6/collector_mismatch.log`.

### Final evidence and limitations

- **500/500 distinct outcomes verified across the main and isolated runs**:
  450 successful operations and 50 correctly reported SAS errors.
- Full corrected run: 499 verified out of 500, including one exit-74 termination
  preserved as unsuccessful. Fresh isolated H2984: **1/1 verified**.
- The main run made 55 submissions; the final isolation added one submission.
- Per-case audit, run provenance and failed-attempt history:
  `tests/library500_round6/verified_results_2026-11-02.json` (schema 2).
- Complete offline suite: **37 test files, 4,156 top-level checks passed**,
  including 500 new subtests with seven checks each, 11 deferred-quote checks,
  six generator checks and the strengthened error-evaluation checks.
- Supplemental live checks: **6/6** DOSUBL local include, **6/6** CALL EXECUTE
  local include, **4/4** default builtin/SYSCALL loading.
- Standalone SAS macro-bootstrap sentinel diagnostic: **PASS**.
- Development TAP and transcripts remain in ignored
  `SAS_Output_library500_round6/` and its referenced run directories.

These bounded synthetic checks do not validate every original library macro,
plot, statistical inference, external dataset, platform option or concurrent
session. The remote termination's underlying cause remains unresolved.

### Cygwin commands

From the MCP4SAS checkout:

```bash
export PATH=/usr/bin:$PATH
perl tools/build_library500_round6.pl \
  /cygdrive/h/F_Queens/360yunpan/SASCodesLibrary
prove -v tests/test_library500_round6.pl \
  tests/test_double_quoted_deferred_includes.pl tests/test_corpus_prevalidation.pl \
  tests/test_expected_failure_evaluation.pl
perl tests/run_live_library500.pl --live --round 6
prove -v tests/test_live_include_abbreviation.pl :: --live --style dosubl
prove -v tests/test_live_include_abbreviation.pl :: --live --style execute
prove -v tests/test_live_builtin_macro_bootstrap.pl :: --live
```

Isolate a case and collect current, matching evidence:

```bash
perl tests/run_live_library500.pl --live --round 6 --only H2984 --batch-size 1
perl tools/collect_library_evaluation_results.pl --round 6 \
  --run SAS_Output_library500_live_fmsvBl \
  --run SAS_Output_library500_live_MeHTWQ \
  --output tests/library500_round6/verified_results_2026-11-02.json
```

The named directories are the preserved runs from this session; substitute new
run directories when intentionally advancing the evidence. The collector does
not resubmit SAS code or modify source-run files. `--expect-missing` on the live
include test is only for reproducing the old defect. Use section 17's Bash loop
for the complete offline suite. No Python evaluation scripts were introduced.

## 23. Seventh 500-case round from SAS book samples (2026-11-02)

### Source, scope and novelty

This round reads the requested folder:

```text
H:\F_Queens\360yunpan\SASCodesLibrary\SAS PDF\sas online samples
```

It contains 121 TXT files and one ZIP. The builder uses actual matching SAS code
lines in TXT files; it does not execute URL-only files, download linked books or
extract the ZIP. The original library remains unchanged. All generated data are
synthetic; the submitted programs do not copy original book datasets or private
analyses.

The new corpus is `tests/library500_round7/B3001.sas` through `B3500.sas`:
**500 runnable scenarios, 50 behavior families with ten input sizes each**,
N=2 through 11. There are **450 expected successes and 50 intentional program
errors**. These are parameterized scenarios, not 500 unrelated algorithms or
independent account logins.

The manifest records actual book title, filename, matching line, complete-source
and evidence-line SHA-256, generated-body hash, independent Perl numerical oracle
and tolerance. Eight book titles supplied matching code:

| Book sample | Scenarios |
| --- | ---: |
| A Handbook of Statistical Analyses Using SAS, Second Edition | 100 |
| Applied Statistics and the SAS Programming Language, Fourth Edition | 170 |
| Categorical Data Analysis Using the SAS System | 40 |
| Cody's Data Cleaning Techniques Using SAS Software | 50 |
| Combining and Modifying SAS Data Sets Examples, Version 6, First Edition | 70 |
| Getting Started with the SQL Procedure, Version 6, First Edition | 40 |
| SAS Macro Programming Made Easy, Second Edition | 10 |
| SAS System for Mixed Models | 20 |

The corpus README contains the ID-to-topic mapping. Coverage includes DATA step
control flow, MERGE/UPDATE retention, SUMMARY/MEANS/FREQ, LOGISTIC, GENMOD, MIXED,
TTEST ODS capture, correlations, ranks, TRANSPOSE metadata, DATASETS and SQL.
The intentional failures exercise UNION type conflicts, missing UPDATE columns,
character length limits, character-variable RANK and missing PRINT IDs.

The offline novelty check compares these programs with all 3,000 earlier
programs after normalizing generated case IDs and round-marker labels. All 500
new normalized bodies differ. This prevents relabeling old programs from counting
as new tests; it does not prove that differently written programs cannot be
semantically equivalent. The six earlier corpora remain intact.

### Failures investigated and corrections

The initial live run in `SAS_Output_library500_live_WpwpUg` reported **290/500
passed**. Its failures exposed three fixture problems:

1. **B3211–B3220, binary LOGISTIC:** default convergence produced a probability
   near 0.6666413814, while the analytically determined probability is 2/3.
   The fixture now requests `GCONV=1e-12`; its 1e-6 numerical tolerance remains
   unchanged. This corrects the estimation setup rather than fitting the oracle
   to the observed approximation. See the official
   [LOGISTIC MODEL options](https://support.sas.com/documentation/cdl/en/statug/63033/HTML/default/statug_logistic_sect010.htm).
2. **B3311–B3320, two-group TTEST:** filtering only on the difference label kept
   both pooled and Satterthwaite rows, violating the one-row assertion. The fixture
   now explicitly selects `upcase(method)='POOLED'`. The numerical difference
   remains -10. SAS documents the two methods in
   [Comparing Group Means](https://support.sas.com/documentation/cdl/en/statug/63962/HTML/default/statug_ttest_a0000000116.htm).
3. **B3461–B3470, expected SQL UPDATE errors:** the initial diagnostic matcher
   expected “not found”, “does not exist” or “not located”, while the actual SAS
   ERROR says `Variable ... is not on file ...`. The final matcher specifically
   recognizes that wording. The negative programs themselves are unchanged.

The first two faulty families contaminated their respective 100-case positive
batches: the evaluator requires a clean batch log and consistent successful
terminal status, so it did not count neighboring markers as passes. Thus the
initial 210 failed evaluations do not mean 210 independent SAS defects.
The corrected B3211 and B3311 passed a focused two-case live probe in
`SAS_Output_library500_live_zcwfmy` before the full positive rerun.

These were test-fixture issues, and MCP4SAS correctly returned failed job status.
No additional SAS execution defect was established by those three failures.

### MCP4SAS evaluation improvements

- Added the shared `MCPDeps/SAS_Evaluation_Corpus.pm` validator. Duplicate,
  unknown or empty selected IDs, inconsistent manifest counts, invalid filenames,
  missing oracles/diagnostics and stale generated-body hashes fail locally.
- The live runner verifies every selected program before any submission and
  uses that verified in-memory source snapshot. LF/CRLF inputs are accepted
  without rewriting the bytes submitted to SAS.
- The evidence collector checks current program hashes, the preserved submitted
  batch source, actual SAS logs, process exits and terminal JSON. Changed source
  cannot inherit an old pass solely from metadata containing the expected hash.
- Novelty fingerprints ignore generated case and round labels across corpora.
- Extended the Perl corpus builder to read book TXT sources, prefer relevant
  book titles, record book provenance and support explicit numerical tolerances.
  Existing SAS-source builders retain their defaults. All oracles and generated
  fingerprints are prevalidated before replacing fixtures.

Numerical modeling checks use relative tolerance 1e-6 for LOGISTIC/GENMOD/MIXED;
other checks use 1e-9. Positive cases still require exactly one row and one
expected runtime marker, no actual SAS ERROR, exit zero and completed successful
metadata. Negatives require the matching actual SAS ERROR, ordinary exit 1,
no success marker and completed failed metadata. Connection failures, timeout,
session termination and disk-space classifications cannot stand in for expected
program errors.

Programs only use their own WORK prefixes and clean those tables. Expected SAS
errors may leave their own WORK state for inspection. Existing helper cleanup
and explicit retention options remain in force. No original datasets, book files
or user directories are deleted.

### Cygwin commands and evidence

From the MCP4SAS checkout:

```bash
export PATH=/usr/bin:$PATH
perl tools/build_library500_round7.pl \
  '/cygdrive/h/F_Queens/360yunpan/SASCodesLibrary/SAS PDF/sas online samples'
prove -v tests/test_library500_round7.pl tests/test_evaluation_corpus_integrity.pl
perl tests/run_live_library500.pl --live --round 7
perl tests/run_live_library500.pl --live --round 7 --only B3211,B3311
```

The default runner uses five positive batches and 50 isolated negative jobs,
with a 180-second timeout per submission. The complete offline suite passed
**4,686 top-level checks across 39 files**, including 500 new corpus subtests
with seven checks each and 25 integrity checks. Its ignored transcript is
`SAS_Output_library500/regressions.log`. Use section 17's Bash loop to reproduce
the complete offline suite. Development transcripts for this round are under
`SAS_Output_library500_round7/`.

The full rerun `SAS_Output_library500_live_bFfUyW` reported **490/500** with
all 450 positive cases and 40 negative cases passing. That process had loaded
the old UPDATE diagnostic matcher before it was corrected. A fresh run of all
ten affected negative cases in `SAS_Output_library500_live_Qh8jnO` then passed
**10/10** with the corrected matcher. These results supply all 500 distinct
outcomes; this is evidence from two runs, not a clean 500/500 single invocation.

Independent collection verified **500/500 distinct cases** against current
source hashes and submitted batch sources: **450 successful programs and 50
expected program failures**. The dated JSON contains 500 unique IDs; all ten
UPDATE cases select the fresh rerun. No infrastructure failure was substituted
for an expected program error.

Collect and independently revalidate the preserved evidence:

```bash
perl tests/run_live_library500.pl --live --round 7 \
  --only B3461,B3462,B3463,B3464,B3465,B3466,B3467,B3468,B3469,B3470
perl tools/collect_library_evaluation_results.pl --round 7 \
  --run SAS_Output_library500_live_bFfUyW \
  --run SAS_Output_library500_live_Qh8jnO \
  --output tests/library500_round7/verified_results_2026-11-02.json
```

The collector applies the current reviewed manifest diagnostics to the original
logs. Its `recorded_passed` and `recorded_failures` fields preserve the original
runner verdicts separately from revalidation; the ten UPDATE cases use the fresh
run as their selected evidence. It does not overwrite either source run or count
repeated attempts as additional distinct cases. Initial development runs with
different executable-body hashes are not combined with final fixtures.

Additional local failure probes confirmed that `--only B3001,B3001` is rejected
before submission, and that a deliberately edited copy of a preserved batch is
rejected with `Submitted source mismatch` before an evidence file is written.
Their transcripts are `duplicate_selection.log` and `submission_integrity.log`
in the ignored round-seven development folder. Normal default cleanup left no
`.mcp4sas_work_*` directories after the live jobs finished.

These bounded synthetic checks do not validate every original book analysis,
macro library, statistical inference, external dataset or concurrent session.
No Python evaluation scripts were introduced.

## 24. Eighth 500-case round: further SAS book operations (2026-11-02)

### Scope, sources and novelty

This adds `tests/library500_round8/J3501.sas` through `J4000.sas`, generated by
`tools/build_library500_round8.pl` from the same requested book sample directory:

```text
H:\F_Queens\360yunpan\SASCodesLibrary\SAS PDF\sas online samples
```

There are **500 runnable scenarios across 50 new behavior families**, ten input
sizes each (N=2 through 11): **450 positive cases and 50 intentional SAS program
errors**. These are parameterized scenarios, not 500 unrelated algorithms or
fresh logins. All data are synthetic. No original book datasets or private
analyses are submitted; the TXT sources remain unchanged, and book download
links and the ZIP are not required.

The manifest records actual book title, filename/line, source and evidence-line
SHA-256, generated-body SHA-256, independent Perl numerical oracle and tolerance.
Its ten actual source titles and counts are listed in the corpus README. They
include *Applied Multivariate Statistics with SAS Software*, *PROC TABULATE by
Example*, *The Power of PROC FORMAT*, and programming/statistics/SQL books.

The new coverage includes:

- PRINCOMP covariance trace, eigenvalues, eigenvector normalization and score
  energy; TABULATE output; STANDARD missing values and selected variables.
- ANOVA model/error sums of squares; quadratic and no-intercept regression,
  R-square, GLM interactions, and one-/two-way FREQ chi-square.
- Nonunit multidimensional array bounds, temporary shift registers, VNAME and
  WHICHN; empty/bottom-tested loops and dependent nested bounds.
- Name literals with option restoration, NOTSORTED/descending BY behavior,
  INDSNAME, dataset KEEP/RENAME/WHERE ordering and labels containing semicolons.
- SQL INTO, three-way joins, UNION CORR, INTERSECT/EXCEPT ALL, scalar subqueries,
  HAVING, preloaded formatted classes and multilabel membership.
- BLOM/TUKEY/van der Waerden normal scores and COMPARE difference output.
- Intentional multiple-row scalar subqueries, missing SORT keys, character
  analysis variables in SUMMARY/PRINCOMP and reversed FORMAT ranges.

The offline novelty check compares all 500 normalized executable bodies against
all **3,500 earlier programs**, ignoring generated case IDs and round-marker
labels. All new bodies differ. This prevents simple renaming from counting as
novelty, without claiming to decide every possible semantic equivalence. Earlier
corpora and their dated verified evidence remain unchanged.

### Failures encountered and fixture corrections

The initial pilot submitted one case per family: 45 positive cases in one batch
and five isolated expected failures. In
`SAS_Output_library500_live_bgFzgf`, the five negative checks passed, while two
positive fixture issues invalidated the complete positive batch:

1. **J3881–J3890, preloaded formatted groups:** the fixture deleted its owned
   format catalog entry before the generated assertion opened its result table.
   The result table still attached that format to `grp`, so SAS reported that
   the format could not be loaded. The fixture now clears the inherited `grp`
   format on its result table before removing the owned catalog entry. Its
   expected empty-group frequency remains zero; cleanup stays enabled.
2. **J3901–J3910, one-way chi-square:** the fixture filtered ODS `Name1='PCHI'`,
   producing zero rows. The actual identifier is `_PCHI_`. The filter now uses
   that identifier and retains the independently expected chi-square value zero.
   SAS identifies the output table in its
   [FREQ ODS documentation](https://support.sas.com/documentation/onlinedoc/stat/132/freq.pdf),
   and the `_PCHI_` field is illustrated in this
   [SAS proceedings example](https://support.sas.com/resources/papers/proceedings13/181-2013.pdf).

The other 43 positive pilot programs emitted their expected markers, but the
evaluator correctly declined to count a positive batch containing actual SAS
errors and failed terminal status. Therefore **5/50** in that pilot does not
mean 45 separate defects. Both corrected representative cases then passed a
focused **2/2** run in `SAS_Output_library500_live_xtKCD2`.

These were fixture errors; no SAS execution-engine defect was established by
them. The final run uses corrected executable bodies, so the initial pilot is
preserved for diagnosis rather than mixed into final passing evidence.

The principal-component expectations follow covariance/eigenvalue identities
and sign-independent squared scores. See the official
[PRINCOMP output datasets](https://support.sas.com/documentation/cdl/en/statug/68162/HTML/default/statug_princomp_details02.htm).
The three normal-score checks use symmetry of the documented
[BLOM, TUKEY and VW transformations](https://support.sas.com/documentation/cdl/en/proc/65145/HTML/default/p16s2o8e4bnqrin1phywxdaxqba7.htm).
These tests check numerical transport and bounded behavior rather than asserting
the validity of statistical inference for the synthetic datasets.

### MCP4SAS evaluation improvements

The previous round exposed a provenance gap: a manifest diagnostic could change
while the executable SAS body stayed unchanged. Revalidating an old log with the
new matcher was disclosed in that round's report, but a body hash alone could
not establish which evaluation rules the running process had loaded.

This round adds an **evaluation-contract SHA-256** covering the numerical oracle,
tolerance, expected-error diagnostic and positive/negative classification.
The live runner records the fingerprint from its in-memory case metadata in
each result. The collector requires it for round eight and later and rejects
mismatches before accepting evidence. Changing an oracle, widening a matcher or
changing the tolerance requires a fresh run even if the SAS body is identical.
Round-one through round-seven evidence remains compatible and is explicitly
marked as lacking contract verification when collected with the new code.

The collector also groups cases once and caches validated terminal status and
log evaluations for each batch/evaluation rule. This avoids rereading and
reparsing the same positive batch for every individual case while preserving
source, source-hash, contract, exit, marker and status checks.

Regression coverage added:

- `tests/test_evaluation_contract.pl`: **18 checks** for unchanged contracts,
  modified oracles/tolerances/diagnostics/classifications, legacy evidence,
  malformed hashes and widened negative matchers.
- `tests/test_evaluation_collection.pl`: **12 checks** using explicitly synthetic
  logs to test partial same-batch collection and rejection of changed/missing
  contracts and edited submitted source. These synthetic logs are test fixtures,
  not live SAS evidence and do not enter the dated verified-results file.
- `tests/test_library500_round8.pl`: **500 subtests with seven checks each**,
  plus corpus/family/source totals and normalized novelty against earlier rounds.
- Corpus integrity compatibility now includes all eight generated round formats.

Positive checks require exactly one result row, the independent numerical answer,
one runtime marker, no actual SAS ERROR, exit zero and successful complete
terminal JSON. Negative checks require ordinary program-error exit 1, the actual
expected SAS ERROR, no success marker and consistent failed terminal JSON.
Infrastructure errors, timeout and session termination cannot pass as intended
program failures. Tolerances are recorded per case: 1e-6 for modeling and normal
scores, 1e-9 otherwise.

### Reproducible Cygwin commands

From the MCP4SAS checkout:

```bash
export PATH=/usr/bin:$PATH
perl tools/build_library500_round8.pl \
  '/cygdrive/h/F_Queens/360yunpan/SASCodesLibrary/SAS PDF/sas online samples'
prove -v tests/test_library500_round8.pl tests/test_evaluation_contract.pl \
  tests/test_evaluation_collection.pl tests/test_evaluation_corpus_integrity.pl
perl tests/run_live_library500.pl --live --round 8
```

The pilot and focused reproductions can be repeated with:

```bash
probe_ids=$(perl -e 'print join q{,}, map {q{J}.(3501+10*$_)} 0..49')
perl tests/run_live_library500.pl --live --round 8 --only "$probe_ids"
perl tests/run_live_library500.pl --live --round 8 --only J3881,J3901
```

Those commands now use the corrected fixtures; the preserved initial pilot
contains the original failure. A normal full run uses five positive batches and
50 isolated negative submissions (55 jobs), with a 180-second CLI timeout per
job. Runs use a persistent session and uniquely prefixed WORK resources rather
than opening 500 account logins.

### Final evidence

The full corrected live run in `SAS_Output_library500_live_oymzPc` finished
**500/500 passed in one invocation**: **450 successful SAS programs and 50
correctly identified intentional SAS program failures**. Each negative SAS job
still failed by design; a passing evaluation does not relabel it as SAS success.

Collect the preserved run without resubmitting SAS code:

```bash
perl tools/collect_library_evaluation_results.pl --round 8 \
  --run SAS_Output_library500_live_oymzPc \
  --output tests/library500_round8/verified_results_2026-11-02.json
```

The collector independently checks source files, submitted batch source,
evaluation contracts, SAS runtime logs, process exits and terminal JSON. Raw
programs, logs and statuses remain in the ignored live directory; development
transcripts are under `SAS_Output_library500_round8/`. Use section 17's Bash loop
to reproduce the complete offline regression suite.

Final independent collection verified **500 unique IDs and 500 evaluation
contracts**, with zero failed or contradicted final-run attempts. A separate
read-only audit verified all **500 source/line provenance records against the
ten original book files**; its transcript is `provenance.log` in the development
folder.

The complete final offline suite passed **5,222 top-level checks across 42
files**, including the new collector regression test. Its transcript is
`SAS_Output_library500/regressions.log`. `git diff --check` found no whitespace
errors; Git only reported the checkout's existing LF-to-CRLF normalization notice
for this report. Changes and verified evidence are saved locally.

Cases remove their own WORK tables, format entries and macro variables. Options
changed by successful name-literal cases are restored. Existing explicit helper
retention settings remain honored; default cleanup left no `.mcp4sas_work_*`
directories after live jobs finished. Original book files and user datasets are
unchanged. No Python evaluation scripts were introduced.

## 25. Fifty distinct open-code macro evaluations (2026-11-02)

### Sources and scope

The requested focused round adds **50 distinct examples**, `M4001.sas` through
`M4050.sas`, under `tests/macro_open_code50/`. They are individually designed
macro-boundary tests, rather than repeated input sizes. Their normalized bodies
differ from all **4,000 earlier programs**.

The builder reads the requested source directory without modifying it:

```text
H:\F_Queens\360yunpan\SASCodesLibrary\SAS PDF\sas online samples
```

Forty-nine source anchors are in *Carpenter's Complete Guide to the SAS Macro
Language, Second Edition* and one in *SAS Macro Programming Made Easy, Second
Edition*. Titles, paths, line numbers and source/evidence SHA-256 are recorded.
Three `derived_extension` entries explicitly anchor modern boundary experiments
to actual macro definitions instead of claiming the exact newer statement occurs
in the older book. All submitted datasets and names are synthetic.

The corpus README maps every ID range to its examples. The mix is:

- 25 clean examples of supported conditional groups, correctly wrapped loops,
  scope/RETURN/GOTO, quoting/comments, raw data, EVAL/SYSEVALF, delimiters,
  indirect references and SYMPUTX timing.
- 20 intentional SAS errors covering invalid open-code statements, recursion,
  integer-expression errors, missing functions and parameter/argument problems.
- Five actual macro-warning cases. Four complete successfully; unresolved macro
  invocation intentionally fails the MCP wrapper under its existing strict policy.

Thus final wrapper outcomes are **29 successes, 20 SAS-error failures and one
policy failure**. A passed evaluation verifies the expected behavior; it does
not relabel an intentionally failed job as a successful SAS program.

### Detection gaps and MCP4SAS changes

The preserved old preflight scanner flagged only **3/50 examples**: open-code
GOTO, RETURN and orphan MEND. It did not flag the other structural cases.
The new shared `SAS_Source_Analysis::open_code_macro_issues` now identifies
**14/50 structural problems**, adding 11 protected cases:

| Cases | New protection |
| --- | --- |
| M4026 | LOCAL outside a macro definition |
| M4027–M4030 | Indexed, WHILE, UNTIL and standalone DO outside a macro |
| M4031–M4033 | Orphan END, ELSE and THEN |
| M4034 | Nested IF in open code |
| M4035 | Open IF without the required DO action |
| M4036 | Missing LET terminator before another macro statement, causing recursion |

Both public helper aliases use the same analyzer. It preserves source line
numbers and respects comments, quoted text, macro quoting, inline data and macro
definition scope. All **30 positive/warning examples remain statically unblocked**.
Six expression/parameter failures still require actual SAS evaluation; the
analyzer is not a full macro interpreter.

Supported top-level IF/THEN/ELSE DO groups are retained, rather than rejecting
every open-code IF. They require SAS 9.4M5 or later; nested open-code IF and macro
loops need macro definitions. These restrictions are described in the official
[SAS macro reference](https://documentation.sas.com/api/docsets/mcrolref/9.4/content/mcrolref.pdf)
and SAS's [open-code conditional explanation](https://blogs.sas.com/content/sasdummy/2018/07/05/if-then-else-sas-programs/).

`SAS_Log_Diagnostics` now returns structured macro categories, original severity
and practical hints, which the existing MCP job reporting path displays. It
distinguishes open-code control/recursion, unresolved variables/invocations,
recursive references, missing symbols and expression/argument problems. Runtime
ERROR/WARNING lines are required; source echoes and submitted text cannot create
diagnostics. Missing-semicolon recursion is documented in
[Troubleshooting Your Macros](https://support.sas.com/documentation/cdl/en/mcrolref/62978/HTML/default/n1rvuiao0okk6cn1afs9ckt2unh9.htm).

The new tests also exposed an evaluation gap: the real wrapper reports some
timeouts with **exit 1** and a failed terminal message, rather than a distinct
timeout exit. The evaluator now rejects terminal timeout states, classes or
“timed out” messages even when a partial log contains a matching expected ERROR.
It also requires actual WARNING lines for warning-specific oracles. Warning and
policy requirements are included in the evaluation contract; earlier round-eight
contract fingerprints remain compatible.

### Actual failures and reviewed corrections

The initial diagnostic run, `SAS_Output_library500_live_929bKH`, reported
**46/50 passed**. The four unsuccessful evaluations were investigated:

1. **M4017, literal macro-looking records:** the original fixture used DATALINES
   for text containing semicolons. SAS ended the data context and reported the
   embedded LOCAL/GOTO/RETURN statements as open code. Switching to DATALINES4
   with a `;;;;` terminator preserved the intended literal record; the fresh
   run `SAS_Output_library500_live_SLzFMj` passed **1/1**. The static raw-data
   masking was retained; the fixture's delimiter choice was corrected.
2. **M4035, IF without DO:** the original raw submit waited until its configured
   **120-second timeout**, and the wrapper terminated that submit process tree.
   This timeout did not count as an expected SAS-error pass. The new normal
   preflight rejects the case before submission. For a bounded diagnostic fixture,
   an explicit closing END was added; SAS then returned `Expected %DO not found`
   and `Skipping to next %END statement`. After reviewing the exact diagnostic,
   the fresh run `SAS_Output_library500_live_lENbeZ` passed **1/1**. An earlier
   bounded reproduction with an overly narrow matcher remains preserved in
   `SAS_Output_library500_live__jDg2j`.
3. **M4043, duplicate parameters:** SAS says `Attempt to define more than one
   parameter with same name`. The original expected-message regex did not match
   that ordering. The reviewed matcher now uses that specific phrase; the SAS
   program and expected failure remain unchanged.
4. **M4047, unresolved invocation inside PUT:** SAS logged a WARNING, no ERROR,
   and emitted the expected numeric assertion marker. MCP4SAS already treats
   unresolved macro invocations as fatal to the job, even when embedded in PUT.
   This existing protection was preserved. The evaluation now explicitly checks
   a **policy failure**: actual warning, no SAS ERROR, the numeric marker, wrapper
   exit 1 and complete failed metadata. It is not described as a SAS fatal error.

The last two cases passed **2/2** in fresh isolated connections in
`SAS_Output_library500_live_URkMwa`. Fresh evidence was required whenever source
or evaluation rules changed.

Each raw diagnostic case uses a **fresh one-shot connection**, a 120-second
timeout and owned WORK resources. No invalid macro parser state is reused in a
subsequent test or a user's persistent session. The test runner's explicit
`--raw` option disables static preflight solely to measure SAS diagnostics;
ordinary user commands keep preflight enabled.

### Commands, acceptance checks and evidence

From the MCP4SAS checkout in Cygwin:

```bash
export PATH=/usr/bin:$PATH
perl tools/build_macro_open_code50.pl \
  '/cygdrive/h/F_Queens/360yunpan/SASCodesLibrary/SAS PDF/sas online samples'
prove -v tests/test_macro_open_code50.pl tests/test_open_code_macro_diagnostics.pl
perl tests/run_live_macro_open_code50.pl --live --raw
perl tests/test_live_open_code_preflight.pl --live
```

Focused reproductions:

```bash
perl tests/run_live_macro_open_code50.pl --live --raw --only M4017
perl tests/run_live_macro_open_code50.pl --live --raw --only M4035
perl tests/run_live_macro_open_code50.pl --live --raw --only M4043,M4047
```

With normal preflight enabled, `test_live_open_code_preflight.pl` passed **30/30
checks** across both helper aliases for LOCAL, indexed DO, nested IF, missing DO
and missing-semicolon recursion. It verified exit 1, a message stating that SAS
submission was skipped, and complete failed terminal JSON. These are preflight
acceptance checks, separate from the 50 raw diagnostic evaluations.

Independent collection verified **50/50 distinct final outcomes**, including
all 50 evaluation contracts and all five required actual warnings, across four
runs. This is not a clean 50/50 single invocation:

```bash
perl tools/collect_library_evaluation_results.pl --round 9 --skip-stale \
  --run SAS_Output_library500_live_929bKH \
  --run SAS_Output_library500_live_SLzFMj \
  --run SAS_Output_library500_live_lENbeZ \
  --run SAS_Output_library500_live_URkMwa \
  --output tests/macro_open_code50/verified_results_2026-11-02.json
```

The collector's explicit `--skip-stale` option excludes the entire batch when
source or contract changes. Four original attempts, including the timeout, are
preserved in `stale_attempts` with their original verdicts, exit/status messages
and old/current hashes. They contribute no passing evidence. Without this
option, mismatches still fail collection. Regressions verify that excluding a
stale batch cannot promote either case in that batch to a pass.

Accepted evidence still requires matching current source and submitted source,
contract, actual runtime log, exit and terminal status. Development transcripts,
the old preflight snapshot and focused TAP logs are in ignored
`SAS_Output_macro_open_code50/`; full SAS logs remain in the named run folders.
Use section 17's Bash loop for the complete offline suite.

The complete final offline suite passed **5,307 top-level checks across 44
files**; its transcript is `SAS_Output_library500/regressions.log`. A separate
read-only audit matched all **50 source/line provenance records** to the two
original book files (`SAS_Output_macro_open_code50/provenance.log`).

Default cleanup left no `.mcp4sas_work_*` directories after the live checks.
Existing explicit retention preferences remain honored. Original books, user
datasets and persistent SAS sessions were not changed. No Python evaluation
scripts were introduced.

## 26. Resumed Windows installation, GTEx recovery and 500 new book cases (2026-11-03)

### Windows workflow: confirmed fix

The original failure was not a SAS macro failure. The Windows installation job
could not fetch CPAN's index to install `Mojolicious`. The first explicit HTTPS
mirror change still failed on that image. Selecting cpanm's curl downloader
explicitly on Cygwin resolved the Windows failure. The follow-up run exposed
macOS Bash 3's nounset behavior for an empty options array; a nonempty argument
array fixes that compatibility issue.

The [verification workflow for 14e1adc](https://github.com/chengzhongshan/MCP4SAS/actions/runs/41607017139)
passed **all five installation jobs**: Windows/Cygwin, Ubuntu, both macOS
architectures and Conda. The fixes are published on `main`. Thirty installer
regression assertions cover backend selection, defaults/overrides, quoting,
platform behavior and failure propagation. Detailed history is in
`docs/WINDOWS_CI_CPAN_FIX.md`.

### Another 500 distinct book-derived scenarios

`tools/build_library500_round10.pl` creates `K4051.sas` through `K4550.sas` under
`tests/library500_round10/`, using the requested read-only directory:

```text
H:\F_Queens\360yunpan\SASCodesLibrary\SAS PDF\sas online samples
```

There are **50 behavior families with ten input sizes each**, N=2 through 11:
**450 positive cases and 50 intentional SAS program errors**. This is 500
parameterized scenarios, not 500 unrelated algorithms. Their normalized bodies
differ from all **4,050 earlier programs**, ignoring case IDs and round markers.
The earlier corpora and their verified evidence remain unchanged.

Eight actual book titles supply source/line evidence. The corpus README lists
their names/counts; the manifest records filenames, line numbers, source/line
SHA-256, executable hashes, independent Perl oracles and numerical tolerances.
The 200 distribution checks are explicitly marked `derived_extension`: documented
CDF/PDF/QUANTILE APIs extend the source books' PROBNORM/PROBIT examples. They are
not represented as literal calls copied from those older source lines.

| IDs | New coverage |
| --- | --- |
| K4051–K4250 | Normal, exponential, uniform, binomial, Poisson, geometric, gamma, chi-square, logistic, Weibull and t identities; log-gamma and beta |
| K4251–K4350 | Filter-before-transpose matrices, selected-gene checksums, prefix arrays, log-expression, gene medians, missing/zero, identifiers, phenotype filters and cache gates |
| K4351–K4450 | MIN IDGROUP, ASCII case order, CLASSDATA, transpose ID delimiters, SQL ALL/ANY, metadata and missing-value behavior |
| K4451–K4500 | Macro PRX delimiters, stepped loops, formatted integers and quoted punctuation |
| K4501–K4550 | Intended SQL type mismatch, incompatible CLASSDATA, unassigned libref, invalid SYSEVALF conversion and array-bound errors |

The pilot in `SAS_Output_library500_live_HhO0wJ` passed **49/50**. The CLASSDATA
fixture produced its intended ERROR, but the matcher omitted the actual word
“incompatible.” Its reviewed matcher was corrected before the full run.
`SAS_Output_library500_live_DAcgD4` then passed **500/500** under the initial
tolerances, with 450 successful programs and 50 correctly reported program errors.

Distribution tolerances were subsequently tightened from 1e-6 to
`1e-10*max(1,abs(expected))`, so small nonzero beta/probability values cannot pass
as zero. Other checks use `1e-9*max(1,abs(expected))`. The 200 tightened programs
were resubmitted in `SAS_Output_library500_live_VB0uLD`; the final collector uses
that fresh evidence and the 300 unchanged cases. Old distribution batches are
retained as stale, never promoted to passes. Final evidence is from two runs,
not a clean single invocation of the final stricter corpus.

From the MCP4SAS checkout in Cygwin:

```bash
export PATH=/usr/bin:$PATH
perl tools/build_library500_round10.pl \
  '/cygdrive/h/F_Queens/360yunpan/SASCodesLibrary/SAS PDF/sas online samples'
prove tests/test_library500_round10.pl tests/test_evaluation_corpus_integrity.pl
perl tests/run_live_library500.pl --live --round 10
```

The stricter-block rerun and collection used:

```bash
strict_ids=$(perl -e 'print join q{,}, map {q{K}.$_} 4051..4250')
perl tests/run_live_library500.pl --live --round 10 --only "$strict_ids"
perl tools/collect_library_evaluation_results.pl --round 10 --skip-stale \
  --run SAS_Output_library500_live_DAcgD4 \
  --run SAS_Output_library500_live_VB0uLD \
  --output tests/library500_round10/verified_results_2026-11-03.json
```

The collector rechecks current programs, submitted batches, evaluation contracts,
actual runtime logs, process exits and complete terminal metadata. A normal full
run has five positive batches plus 50 isolated negative jobs, with a 180-second
timeout per job. All input data are synthetic, and only owned WORK resources
are cleaned. No full GTEx matrix is downloaded by these tests.

### Previously unfinished GTEx failure

`SAS_Output_RandID979354` contains the exact MAP3K19/R3HDM1 request. Bootstrap
completed, followed by abrupt remote-session termination with no definitive SAS
runtime log and exit **74**. That proves termination; it does not prove a specific
quota/memory cause. The original heavy request was not retried.

Inspection of the original user macro shows that `UseGeneratedDsd=0` selects the
build/import path. If `GTEx.exp_all` does not exist, it downloads and imports the
whole UCSC expression matrix before filtering the requested genes. Specifying
`PreviousDsd=tgt` does not override that flag. A GTEx LIBNAME from an unrelated
SAS Studio session also need not exist in the CLI's new SASPy connection.

Two local, reviewable repairs were added without overwriting the user's macro
library or online macro:

- `examples/sas_macros/Boxplots4GenesInGTExV8_Cached.sas`: a cache-only alternative
  requiring `UseGeneratedDsd=1`, validated long input and explicit output handling.
  It filters the genes into a separate dataset, preserves expression scale,
  verifies every requested gene and draws the panels. It has no HTTP/full-matrix
  path and leaves the source cache unchanged.
- `tools/subset_gtex_expression.pl`: streams a local TSV/gzip matrix into a small
  requested-gene subset, preserving header and values. It refuses existing output
  and fails atomically for missing genes, ragged selected rows or corrupt gzip.
  It does not invent phenotype annotations or create a complete long GTEx cache.

Twelve offline subset assertions passed. Three isolated SAS ODA tests passed:
a 24-row synthetic cache produced the correct 16-row two-gene result while
retaining the source's 24 rows; missing-cache and rebuild requests failed promptly
without downloading a matrix. The passing artifact directory is
`SAS_Output_gtex_cache_ZWKdPR`.

Development uncovered a FINDW delimiter trap: its `T` modifier trims the chars
argument too, turning a space-only delimiter into an empty list. The final macro
strips just the gene token and uses `I` for case-insensitivity. Earlier failed
prototypes are preserved separately. See the official
[FINDW reference](https://support.sas.com/documentation/cdl/en/lefunctionsref/63354/HTML/default/p16rdsa30vmm43n1ej4936nwa01t.htm).

```bash
prove tests/test_gtex_expression_subset.pl
prove -v tests/test_live_gtex_cache_only.pl :: --live
perl tools/subset_gtex_expression.pl --input /path/to/exprMatrix.tsv.gz \
  --genes 'MAP3K19 R3HDM1' --output gtex_two_genes.tsv
```

`docs/GTEX_LARGE_DOWNLOAD_RECOVERY.md` contains the corrected cache-only invocation,
the need for an explicit LIBNAME assignment, source-schema requirements and
minimal changes to the original macro. It also explains why a longer timeout
alone does not solve a full-matrix resource failure.

Development logs are preserved in ignored `SAS_Output_resume_20261103/` and the
named raw run directories. No Python evaluation scripts were introduced.

Final independent collection verified **500/500 distinct cases and all 500
evaluation contracts** across two runs: 450 successful programs and 50 expected
program failures. The 200 old probability attempts are explicitly excluded as
stale. A read-only audit verified all 500 source/line provenance records against
the eight original book files. The complete final offline suite passed **5,826
top-level checks across 46 files**; the installer regression passed 30 checks,
and the cache-only GTEx live suite passed 3/3. Default cleanup left no
`.mcp4sas_work_*` directories. The CI fixes are published; this new corpus and
the GTEx repair are saved locally for review and use.

## 27. Local Windows SAS through the Cygwin Perl runner (2026-11-04)

The original native Windows SASPy `winlocal` connection passed after correcting
the reverse-loopback SPN issue described in
[the Windows IOM investigation](docs/WINDOWS_LOCAL_IOM_SSPI.md). The next test
used `run_sas_codes_or_files_in_ODA.pl` from Cygwin, with native Windows Python.

The initial submission failed before reaching SAS because Windows Python was
given a Cygwin `/mnt/e/.../sas_inline_runner_*.py` path. The interpreter tried
to open it below `E:/mnt/e/...`, which does not exist. The runner now identifies
the selected Python's `os.name`, caches that result and converts Cygwin paths
with `cygpath -am` when that interpreter requires Windows paths. Conversion
covers inline helper/source/result paths, file-action paths and the temporary
connection-check script. Existing POSIX Python path behavior is retained.

The eight-assertion `tests/test_python_path_boundary.pl` regression passed with
native Windows Python, including real file reads/writes with spaces, action
path conversion, preservation of remote paths, and a real Cygwin Python control.

From the MCP4SAS directory in Cygwin, the verified environment and commands are:

```bash
export PIPELINE_PYTHON_BIN="$(cygpath -m "$USERPROFILE/anaconda3/python.exe")"
export SASPY_CFGFILE="$(cygpath -m "$USERPROFILE/sascfg_winlocal_sasjava.py")"
export SASPY_CFGNAME=winlocal
export SAS_ODA_AUTOLOAD_MACROS=0

perl run_sas_codes_or_files_in_ODA.pl --check-saspy-connection-only

perl run_sas_codes_or_files_in_ODA.pl \
  --code 'proc print data=sashelp.class(obs=5); run; %put MCP4SAS_WINDOWS_PASS;' \
  --output-prefix "SAS_Output_RandID_winlocal_$(date +%Y%m%d_%H%M%S)" \
  --run-timeout-seconds 120
```

The live submission passed with zero SAS ERROR/WARNING lines, five SASHELP.CLASS
observations, the runtime marker `MCP4SAS_WINDOWS_PASS`, completed successful
terminal metadata and a downloaded HTML file. The fixed-run artifacts are in
`SAS_Output_RandID_winlocal_smoke_20261104/sas_res_IYqy2.html` and its adjacent
SAS log/status files. The connection-only command also passed with the exact
environment above. These examples are included directly in the canonical
runner's `--help`; no new filename alias was introduced.

Raw development transcripts are in the parent workspace's
`SAS_Output_windows_iom_sspi_20261104/mcp_cygwin.txt` (initial failure),
`mcp_cygwin_fixed.txt` (successful submission), and `mcp_help_and_probe.txt`
(eight path checks, rendered CLI help and successful local connection probe).

The broad offline run passed 5,189 of 5,190 top-level checks across 42 files.
Its single failure was the helper-entrypoint parity check: the new help block
had initially been added only to the canonical runner, while a pre-existing
four-line configuration-name deduplication differed in the compatibility copy.
The deduplication and help were preserved in both entrypoints. The repaired
parity check passed on rerun; the final native-Windows path/parity rerun is
recorded in `mcp_final_paths.txt`. The raw initial suite transcript is preserved
as `mcp_offline_paths.txt`, including that original failure.

### Persistent Windows sessions: Cygwin helper path (2026-11-04)

The reported persistent command failed before SAS started: native Windows Python
received `/mnt/e/.../sas_oda_session_server.py` and interpreted it relative to
`E:` as `E:\mnt\e\...`. The persistent launcher had missed the path conversion
already used by one-shot submission. The launcher now converts its helper path
and explicitly configured session temporary directory for the selected Python.
Persistent upload/download request paths use the same conversion; remote SAS
paths remain unchanged. Persistent submit fallback remains disabled.

Using the Cygwin environment shown above, the following live test succeeded:

```bash
perl run_sas_codes_or_files_in_ODA.pl \
  --code 'data persistent_path_test; set sashelp.class(obs=5); run; %put PERSIST_CREATE_PID=&sysjobid;' \
  --output-prefix SAS_Output_RandID_persistent_path_create_20261104 \
  --persistent --session-id pathfix_20261104 --run-timeout-seconds 120
perl run_sas_codes_or_files_in_ODA.pl \
  --code 'proc print data=persistent_path_test; run; data _null_; if 0 then set persistent_path_test nobs=n; if n ne 5 then abort cancel; put "PERSIST_REUSE_PASS rows=" n; stop; run; %put PERSIST_REUSE_PID=&sysjobid;' \
  --output-prefix SAS_Output_RandID_persistent_path_reuse_20261104 \
  --persistent --session-id pathfix_20261104 --run-timeout-seconds 120
```

The first command reported SAS PID 37624; the second reported the same PID and
`PERSIST_REUSE_PASS rows=5`. Its HTML is
`SAS_Output_RandID_persistent_path_reuse_20261104/sas_res_zsX66.html`.
No one-shot fallback was enabled. The create-only command correctly produced no
HTML because it contained no output procedure. CLI help also includes a shorter
`mc1` example that prints the dataset on both submissions.

The complete offline publication checks subsequently passed all 5,190 checks
across 42 files. The earlier single parity failure described above is retained
as historical debugging evidence.
