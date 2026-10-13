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
