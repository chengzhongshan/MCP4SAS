# Third evaluation round: T1001–T1500

This adds **500 runnable SAS scripts**: 50 behavior families, ten synthetic
scenarios each (N=2 through 11). It supplements the two earlier 500-case batches.
The new focus is metadata, catalogs, formats, views, dates, macro quoting and
file handles. These are 50 algorithms with ten scenarios each, not 500 unrelated
algorithms or separate logins.

`manifest.json` records independent Perl oracles, source-use sites from 39
original library files, line numbers, source/line SHA-256 fingerprints and
normalized executable fingerprints. The builder reads the original
`Easy-For-Error-Codes-SAS`, `SAS_Code_Database`, and `Macros` folders beneath
`SASCodesLibrary/SAS-Useful-Codes`; it never writes to them. Running the
checked-in scripts does not require access to the original library.

| IDs | Families in groups of ten |
| --- | --- |
| T1001–T1100 | CONTENTS counts/lengths/labels; VARNUM, VARTYPE, VARLEN, VARLABEL, ATTRN; dictionary indexes/tables |
| T1101–T1200 | Numeric/character formats, INVALUE, CNTLIN/CNTLOUT, comma roundtrip, format/informat attributes, APPEND FORCE, RENAME |
| T1201–T1300 | WHERE vs IF, FIRSTOBS/OBS, empty schema, missing CLASS, zero weights, descending ranks, TRANSPOSE LET, OUTER UNION CORR, SQL/DATA views |
| T1301–T1400 | Date BETWEEN, LIKE ESCAPE, NOT IN with missing, column order, OUTOBS, leap dates, datetime components, leap intervals, weekend filtering, UNQUOTE/NRSTR |
| T1401–T1500 | Indirect macro arrays, QSCAN, SYMPUTX scope, SYMEXIST, descending macro loops, SYSFUNC handles, PRXPARSE, FREAD/FGET, FILEREF, owned TEMP deletion |

Every case creates a single result row and writes its own `ROUND3_PASS=Tnnnn`
marker only after comparison with the oracle. Empty results cannot pass. Cases
delete only their own WORK table prefix. Views are explicitly dropped; catalog
cases delete only their own numeric/character format or informat entry. File
tests use owned TEMP filerefs; FDELETE removes only the file created in that
same test. Local test macros and macro variables are removed. No original
library files, user datasets, permanent catalogs or user directories are deleted.
A failed case may retain its own session resources for inspection.

From the MCP4SAS directory in Cygwin:

```bash
export PATH=/usr/bin:$PATH
perl tools/build_library500_round3.pl /cygdrive/h/F_Queens/360yunpan/SASCodesLibrary
prove tests/test_library500_round3.pl tests/test_unquote_macro_dependencies.pl
perl tests/run_live_library500.pl --live --round 3
prove -v tests/test_live_resolve_macro_loading.pl :: --live --mode unquote
```

An isolated rerun can target any subset:

```bash
perl tests/run_live_library500.pl --live --round 3 \
  --only T1121,T1201,T1391,T1461 --batch-size 1
```

The harness preserves SAS source, CLI and SAS logs, status and per-case JSON
in ignored `SAS_Output_library500_live_*` folders. Default batching is five
100-case jobs with a 180-second CLI timeout each. Nonzero exits, SAS errors,
missing runtime logs, missing/duplicate assertions or unexpected marker IDs
invalidate the batch. Numbered source and MPRINT echoes cannot establish
success. SAS warnings retain their severity; several intentional scenarios
such as APPEND FORCE, TRANSPOSE LET and OUTOBS can issue warnings.

The supplemental live UNQUOTE check creates one uniquely named harmless online
macro returning 42, verifies targeted loading through `%UNQUOTE(%NRSTR(...))`,
and deletes/verifies that exact fixture. `--expect-missing` reproduces the old
failure and is not the normal command for the fixed analyzer.

See section 19 of `../../RealExamples4ImprovingMCP4SAS.md` for the initial
fixture errors, the confirmed dependency-loading bug, fixes and final evidence.
The dated verified-results file records the final per-case outcome. These tests
cover bounded synthetic behavior, not every original macro, plot, statistical
model, external dataset or concurrent-session scenario.

Final verification on **2026-11-02**: **500/500 live cases passed**; **2,553
top-level offline checks passed across 30 files**; the supplemental UNQUOTE
loading and RESOLVE compatibility checks each passed **6/6**, including fixture
cleanup. `verified_results_2026-11-02.json` records the per-case outcomes.
