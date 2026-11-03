# Second 500-script evaluation round: R501–R1000

This batch contains **500 new runnable SAS scripts**, covering 50 dataset,
relational, macro and input/output families at ten input sizes (N=2 through 11).
It supplements the earlier L001–L500 function tests. These are 50 algorithms
with ten scenarios each, not 500 unrelated algorithms or independent logins.

The generator reads real operation-use sites under these folders in your SAS
library: `Easy-For-Error-Codes-SAS`, `SAS_Code_Database`, and `Macros` beneath
`SAS-Useful-Codes`. The manifest records source paths, line numbers, original
source/line SHA-256 fingerprints, synthetic input size, independent Perl oracle,
and normalized executable fingerprint. The final manifest references 43 source
files. Original library files are unchanged.

| IDs | Ten-case families in order |
| --- | --- |
| R501–R600 | SQL distinct, HAVING, inner/left/full joins, UNION, UNION ALL, EXCEPT, INTERSECT, CASE |
| R601–R700 | EXISTS, NOT EXISTS, correlated MAX, CALCULATED, UPDATE, DELETE, INSERT, NODUPKEY, descending sort, BY groups |
| R701–R800 | Retained product, missing-aware sum statement, LAG, DIF, POINT, NOBS, array shift, transpose, weighted summary, tied ranks |
| R801–R900 | FREQ, COMPARE, hash lookup, RESOLVE macros, merge IN flags, SET END flag, empty/quoted DSD fields, TRUNCOVER, SCANOVER |
| R901–R1000 | INPUT @@, colon modifier, ampersand modifier, DATALINES4 literal code, TEMP roundtrip, macro scope, CALL EXECUTE, DOSUBL, dictionary columns, fileref INCLUDE |

Each case must create exactly one result row, compare its value with the Perl
oracle and write exactly one `ROUND2_PASS=Rnnn` line. The result-row check avoids
vacuous success from an empty table. Cleanup uses only that case's `rNNN:` WORK
table prefix. TEMP filerefs are cleared and locally defined test macros removed.
The harness uses a newly named persistent session, whose WORK library is test
state. Cases do not read user data, alter permanent libraries or delete user
directories. A failed submission may leave its own WORK fixtures for diagnosis.

From the MCP4SAS directory in Cygwin:

```bash
export PATH=/usr/bin:$PATH
perl tools/build_library500_round2.pl /cygdrive/h/F_Queens/360yunpan/SASCodesLibrary
prove tests/test_library500_round2.pl tests/test_resolve_macro_dependencies.pl \
  tests/test_evaluation_log.pl
perl tests/run_live_library500.pl --live --round 2
```

To isolate individual new cases:

```bash
perl tests/run_live_library500.pl --live --round 2 \
  --only R831,R832,R991,R1000 --batch-size 1
```

The default is five submissions of 100 cases, with a 180-second CLI timeout
per submission. A nonzero exit, missing runtime-log section, SAS ERROR, missing
or duplicate marker, or unexpected marker invalidates the batch. Source listings
and report text cannot supply assertion markers. Warnings retain their SAS
severity. Log-only cases need no HTML.

`tests/test_live_resolve_macro_loading.pl --live` separately checks targeted
loading for an uppercase, nested RESOLVE expression. It creates one uniquely
named harmless online macro source, verifies loading and the returned value,
then deletes and verifies only its owned file. It needs configured SAS ODA
credentials. The `--expect-missing` mode exists to reproduce the old failure;
it should not pass against the fixed analyzer.

The live harness writes submitted programs, terminal/SAS logs, statuses and
per-case JSON into ignored `SAS_Output_library500_live_*` folders. The dated
verified result file and section 18 of `RealExamples4ImprovingMCP4SAS.md` record
the final run. These tests do not validate every original macro, ODS plot,
statistical model or concurrent-session behavior.

On **2026-11-02**, the final batch passed **500/500 live SAS evaluations**.
The supplemental targeted RESOLVE loading check passed **6/6**, including
fixture cleanup. The complete offline suite passed **2,034 top-level checks
across 28 test files**, including 500 new case subtests with six checks each.
`verified_results_2026-11-02.json` records each new case's verified result.
