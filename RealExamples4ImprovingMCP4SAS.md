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
