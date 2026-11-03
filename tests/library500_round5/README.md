# Fifth library-derived evaluation batch: G2001–G2500

This batch adds **500 runnable SAS scenarios** across 50 families, ten synthetic
input sizes each (N=2 through 11): **450 expected successes and 50 intentional
SAS errors**. A verified negative test still has a failed SAS job status. These
are 50 behavior families with ten scenarios each, not 500 unrelated algorithms
or independent logins.

The manifest references operation-use sites in 30 original library files,
including paths, line numbers, source/line SHA-256, independent Perl oracles and
normalized executable-body fingerprints. Source libraries remain read only.
The preceding four batches are preserved. Rebuilding requires the original
`Easy-For-Error-Codes-SAS`, `SAS_Code_Database` and `Macros` folders under
`SASCodesLibrary/SAS-Useful-Codes`; executing the checked-in scripts does not.

| IDs | Coverage |
| --- | --- |
| G2001–G2100 | FETCH/FETCHOBS, GETVARN/GETVARC, DATA/VIEW existence, labels, REWIND, CALL SET, OPEN WHERE, deleted observations, PDV lengths |
| G2101–G2200 | MODIFY/REPLACE/REMOVE, UPDATE modes, interleaved SET, indexed KEY lookup, DUPOUT/NODUPRECS/TAGSORT, high tied ranks |
| G2201–G2300 | Special-missing sorting, retained temporary arrays, implicit DO OVER, character CMISS, numeric lists, tabs/pipes, INPUT pointers and named input |
| G2301–G2400 | Conditional INPUT holding, record lengths/buffers, DATALINES4 apostrophes, MISSOVER, QSUBSTR/QUPCASE/NRBQUOTE, SYSEVALF/EVAL |
| G2401–G2450 | Macro Euclid loop, quoted default arguments, SYSMACEXIST deletion, single/multiple-fileref %INC |
| G2451–G2460 | Expected unique-index duplicate-key rejection |
| G2461–G2470 | Expected numeric/character SET conflict |
| G2471–G2480 | Expected aggregate-in-WHERE rejection |
| G2481–G2490 | Expected INSERT value-count mismatch |
| G2491–G2500 | Expected overlapping-format-interior rejection |

Positive cases require one result row, the independent numerical answer and
one exact `ROUND5_PASS=Gnnnn` runtime marker. Negative cases run separately and
require normal nonzero process status, an actual SAS ERROR matching their
diagnostic, no positive marker and consistent failed terminal JSON. Every case
also checks final completed/failed status consistency. Echoed source, warnings,
signals and unrelated connection errors cannot establish the expected failure.

Cases use synthetic data in their own WORK table prefixes and owned TEMP
filerefs. Views, macros, variables and format entries created by tests are
cleaned by those tests; failed SAS steps can leave their own session state for
diagnosis. No user datasets, permanent libraries or user directories are deleted.
Existing explicit intermediate-retention preferences remain supported.

From the MCP4SAS checkout in Cygwin:

```bash
export PATH=/usr/bin:$PATH
perl tools/build_library500_round5.pl /cygdrive/h/F_Queens/360yunpan/SASCodesLibrary
prove tests/test_library500_round5.pl tests/test_include_abbreviation.pl
perl tests/run_live_library500.pl --live --round 5
prove -v tests/test_live_include_abbreviation.pl :: --live
prove -v tests/test_live_builtin_macro_bootstrap.pl :: --live
```

The default is five positive batches plus 50 isolated negative jobs: 55 SAS
submissions, each with a 180-second CLI timeout. To isolate cases:

```bash
perl tests/run_live_library500.pl --live --round 5 \
  --only G2001,G2361,G2441,G2491 --batch-size 1
```

The live include test separately verifies local `%INC` dependency discovery,
upload, execution and deletion of one uniquely named uploaded payload. It
protects the upload filename with a remote existence check first. The builtin
test verifies quoting functions do not trigger global macro bootstrap with
default autoload selection. Both need configured SAS ODA credentials.

The build logic lives in `tools/lib/Library_Evaluation_Corpus.pm`, shared by this
builder without changing previous corpus generators. Source/CLI/SAS logs,
terminal JSON and results stay in ignored `SAS_Output_library500_live_*` folders.
See section 21 of `../../RealExamples4ImprovingMCP4SAS.md` for the %INC defect,
fixture correction and final evidence. These are bounded synthetic checks, not
validation of every original macro, plot, dataset or concurrency scenario.

On **2026-11-02**, the final corpus verified **500/500 expected outcomes**
(450 successful operations and 50 correctly reported SAS errors). The complete
offline suite passed **3,621 top-level checks across 34 files**. Supplemental
live checks passed: local %INC upload **6/6**, default builtin-only selection
**4/4**, and user-macro loading compatibility **6/6**. The dated verified-results
JSON records per-case outcomes, body hashes, diagnostics and terminal statuses.
