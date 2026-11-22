# Persistent SAS and PoC performance investigation — 22 November 2026

The reported `PROC PRINT` did complete: it read 19 observations from `WORK.A`
and saved an HTML result. The preceding DATA step correctly produced no HTML.
The delay was real, but absence of HTML from a DATA step was not a failed job.

## What was corrected

1. **Repeated local HOME setup.** Each Perl invocation previously selected its
   new random output folder as SAS HOME. Even a reused session therefore ran
   setup again. Persistent local sessions now keep a project directory under
   `local/sas-home/`, keyed by session, profile and configuration path. Explicit
   HOME options retain precedence; one-shot defaults are unchanged.
2. **HTML for internal housekeeping.** HOME setup, file metadata, archive
   preparation, cleanup and liveness probes use text results. User programs
   retain their normal HTML output. A measured HOME setup fell to 0.10 seconds;
   subsequent unchanged settings submitted no SAS code.
3. **Five submissions for one metadata query.** File information now returns
   existence, size and timestamps in one text response, replacing a query plus
   four separate `symget` calls. Missing fields or SAS errors cause failure;
   stale macro-variable values are not accepted.
4. **Unwritable local template catalogs.** Local PoC execution exposed an error
   compiling `Styles.BookPublication` into SASUSER. Local sessions now prepend
   `WORK.TEMPLAT(UPDATE)` and retain existing template read paths. This uses the
   documented [ODS PATH PREPEND behavior](https://support.sas.com/documentation/cdl/en/odsug/61723/HTML/default/a002233323.htm).
   ODA template paths are unchanged.
5. **Large interactive source submissions.** Programs of at least 32 KiB now
   execute from an exact UTF-8 source file through a short `%INCLUDE` command,
   in the same SAS session. Local SAS reads a local temporary file; ODA receives
   a SASPy upload into its WORK directory. SAS checks the staged byte count
   before executing it. Normal completion removes the remote staged file;
   WORK cleanup removes any remainder when a session ends. User SAS is never
   automatically replayed. The log records the source size and SHA-256.
6. **Detected HOME in the native Python runner.** Local uploads succeeded, but
   a quoted `~/...` oncoprint template path was not expanded unless an explicit
   HOME option was supplied. The backend now identifies a local target, and the
   runner configures and uses its detected HOME automatically. ODA and older
   responses retain their previous behavior.

Both runners preserve the prepared program as `submitted.sas`. New files use
UTF-8 with LF endings so their hash agrees with the source sent to SAS.
Normal `%INCLUDE` execution avoids echoing an entire macro library unless SAS
source-display options request it; the saved source remains available for
debugging. This investigation did not measure AI tokens or monetary savings.

## Measurements and evidence

The comparison uses the same frozen PoC programs and input datasets. It
includes preparation, submission, result collection and the example's checks.
Graphics jobs reuse a warm session after the CLASS and listing checks. The
older baseline is commit `1db5cc2`, dated 16 November: it is the latest committed
revision before 19 November; there is no 19 November commit to test.

| Task | Nov 16 Perl/ODA | Updated Perl/ODA | Updated Python/ODA | Updated Perl/local | Updated Python/local |
|---|---:|---:|---:|---:|---:|
| class_cold | 16.35 s | 15.20 s | 16.62 s | 26.56 s | 22.25 s |
| class_warm | 2.96 s | 2.14 s | 1.41 s | 2.28 s | 1.22 s |
| list_warm | 2.66 s | 1.83 s | 0.94 s | 2.01 s | 0.64 s |
| forest | 58.77 s | 39.92 s | 24.44 s | 43.60 s | 41.80 s |
| oncoprint | 35.01 s | 19.44 s | 14.71 s | 14.57 s | 10.95 s |
| clustergram | 42.18 s | 29.59 s | 22.37 s | 51.45 s | 59.54 s |
| multi_gwas_gtf | 459.74 s | 143.65 s | 94.89 s | 302.55 s | 247.49 s |

All 16 figure-family executions passed: four families through Perl and Python, on ODA and local Windows SAS. Their validators passed 47,468 file, row-count and numerical checks in total. Across 96 exported CSV comparisons, 90 match the older ODA baseline exactly. The remaining six local clustergram tables differ only in a root-height value by 1e-14, with unchanged labels and ordering. No P values, effect estimates or confidence intervals changed.

The [machine-readable evidence manifest](PERSISTENT_PERFORMANCE_20261122.json) records timings, program/input hashes, per-trial runtime hashes, output hashes, source transport and the exact cluster-height differences.

These are observational single-run timings with variable machine and SAS
load, including overlapping trials. They do not establish a universal speedup
percentage or guarantee that local SAS is faster than ODA. Direct SASPy on this
computer also measured a 96.59-second cold local connection and a 38.55-second
HTML print, compared with 2.32 seconds for text PRINT. Those delays cannot all
be attributed to MCP4SAS.

Local WORK remained on `H:\TMP4SAS`, and SASUSER remained in OneDrive. Their
locations and the global SAS startup configuration were preserved. A local
multi-GWAS run still spent substantial time inside SGRENDER itself; wrapper
optimizations do not eliminate SAS rendering or storage costs.

The tests execute saved visualization programs, not complete GWAS pipelines
and not AI writing/debugging trials. Each target/runner combination checks the
forest, oncoprint, clustergram and multi-GWAS figures using the existing
file, row-count and numerical validators. Scientific source programs and
input datasets were not modified. Numerical agreement and graphical
appearance remain separate questions; successful execution is not a claim
of publication validation.

Existing PoC warnings about large ODS image dimensions, self-referencing
CREATE TABLE statements and a closed output destination remain in the logs
and manifest. They were not suppressed, and the frozen plotting macros were
not rewritten merely to silence warnings.

Full local evidence is retained in the ignored directory
`SAS_Output_RandID_persistent_home_20261122/`: submitted programs, console and
SAS logs, outputs, timings, earlier failures, backups and comparisons. Runtime
logs can contain account paths, so the raw directory is not published.

## Regression coverage

- Persistent HOME stability across output prefixes, separation of session and
  configuration keys, and unchanged one-shot defaults.
- Text-only setup, cached HOME, explicit override precedence, remote rejection
  and failed-setup handling, exercised using the actual backend functions.
- Single-response metadata, empty files, missing files and incomplete/error
  responses, including the embedded one-shot implementation.
- Archive batching, integrity validation, corruption handling and cleanup.
- Staged-source byte preservation, local versus remote transport, upload
  failure, small-source behavior and explicit disabling.
- Native Python's detected local HOME and remote compatibility.
- Actual create → implicit PRINT → explicit PRINT → large saved-file PRINT,
  checking the same SAS PID, 19 WORK.A rows and saved HTML through both runners.

The first live PRINT test incorrectly depended on NOTE messages that this ODA
account suppressed. The test now explicitly enables NOTES. Its large-source
case uses `--file` to respect Windows command-line length limits. An initial
experimental metadata patch also omitted a local `re` import; the live PoC
caught it, the import and test namespace were corrected, and that failed
experiment is excluded from the successful comparison. Logs remain retained.

GitHub's full root-suite run also found an older HOME fixture that accepted
only `submit(code)`. It now checks the real `submit(code, results='text')`
interface and verifies that a second HOME resolution makes no additional SAS
query. This was a fixture correction; production behavior was not rolled back
to satisfy the test.

To repeat the persistent-session check after configuring SASPy:

```bash
python tests/run_live_persistent_print.py --language perl --out SAS_Output_RandID_print_perl
python tests/run_live_persistent_print.py --language python --out SAS_Output_RandID_print_python
```

For Perl, supply `--perl /path/to/perl` if necessary. The test uses its own
session and helper port and closes only those test resources.

## Existing sessions and rollback

Updating source files does not hot-patch an already running Perl helper.
The user's existing helper on port 65055 and session `mc` were preserved,
including WORK.A. The API version was not bumped to force their destruction.

Use a newly started helper for the complete server-side improvements. In
Cygwin, an unused loopback port can isolate a fresh helper while keeping the
old session available:

```bash
# Choose an unused port. This creates a separate SAS session, not mc's WORK.
SAS_ODA_SESSION_PORT=65056 perl run_sas_codes_or_files_in_ODA.pl \
  --persistent --session-id fastcheck --code 'proc print data=sashelp.class;run;'
```

Save any needed WORK tables before deliberately ending their original session.
Do not kill all SAS processes to apply an update. The native Python backend
versions its own helper state by source hash, so changing that backend also
requires treating its new process as a fresh SAS session.

For transport diagnosis, set `MCP4SAS_STAGE_SOURCE_BYTES=0` in the helper startup environment to disable source staging; a positive integer changes its byte threshold. Existing persistent helpers retain their startup environment. This does not disable preflight,
dependency checks, SAS error detection or transfer integrity checks.
