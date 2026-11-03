# Sixth evaluation round: H2501–H3000

This adds **500 runnable SAS scenarios** across 50 families at ten input sizes
(N=2 through 11): **450 expected successes and 50 intentional errors**. A passed
negative evaluation still represents a failed SAS job. These are 50 behavior
families with ten scenarios each, not 500 unrelated algorithms or fresh logins.

`manifest.json` references operation-use sites in 19 original SAS library files,
with source filenames/lines, source/line SHA-256, independent Perl oracles and
normalized executable fingerprints. The generator reads the original library's
`Easy-For-Error-Codes-SAS`, `SAS_Code_Database` and `Macros` directories without
changing them. All earlier corpora are preserved. The new programs are synthetic
evaluations derived from operation examples, not copies of private analyses.

| IDs | Coverage |
| --- | --- |
| H2501–H2600 | Hash misses, MULTIDATA, ascending/descending iterators, replace/remove/clear, output, duplicate policy, explicit keys |
| H2601–H2700 | PRX captures/spans/iteration/backreferences/lookahead/replacement limits, FINDW, empty COUNTW tokens |
| H2701–H2800 | Empty SCAN tokens, COMPRESS modifiers, character classes, calendar alignment and continuous intervals |
| H2801–H2900 | Julian/calendar/time conversion, file rewind/lifecycle/copy, CSV export/import and quoted fields |
| H2901–H2950 | Double-quoted deferred includes, SYSCALL dataset binding, scope queries, SYSFUNC DOSUBL |
| H2951–H2960 | Expected hash duplicate-key error |
| H2961–H2970 | Expected formatted-ID collisions in TRANSPOSE |
| H2971–H2980 | Expected character-variable rejection in CORR |
| H2981–H2990 | Expected missing CALCULATED variable error |
| H2991–H3000 | Expected unsorted-BY error |

Positive cases require one result row, the independent numeric answer and one
exact `ROUND6_PASS=Hnnnn` runtime marker. Negative cases require normal nonzero
exit, a matching actual SAS ERROR, no contradictory marker and consistent failed
terminal metadata. Source echoes, unrelated connection failures and warnings
cannot supply the expected error. All outcomes must have complete, consistent
terminal JSON.

Expected-error validation requires the CLI's ordinary SAS program-error exit
**1**. Infrastructure exits 73/74, timeout exits and classified remote-session
or space failures cannot count as the expected program error, even if a partial
log happens to contain a matching message.

Only synthetic data, owned WORK tables/views/macros/catalog entries and TEMP
filerefs are used. Cases clean their own resources; failed SAS steps can retain
their own session state for inspection. No user datasets, source libraries or
user directories are deleted. Existing explicit helper-retention preferences
are honored.

From the MCP4SAS checkout in Cygwin:

```bash
export PATH=/usr/bin:$PATH
perl tools/build_library500_round6.pl /cygdrive/h/F_Queens/360yunpan/SASCodesLibrary
prove tests/test_library500_round6.pl tests/test_double_quoted_deferred_includes.pl \
  tests/test_corpus_prevalidation.pl
perl tests/run_live_library500.pl --live --round 6
```

The default is five positive batches and 50 isolated negative jobs: 55 SAS
submissions, each with a 180-second CLI timeout. Isolate cases with:

```bash
perl tests/run_live_library500.pl --live --round 6 \
  --only H2501,H2601,H2901,H2951 --batch-size 1
```

Supplemental live checks use one uniquely named local payload per run, protect
its remote filename with an existence check, verify upload/execution and delete
that exact upload:

```bash
prove -v tests/test_live_include_abbreviation.pl :: --live --style dosubl
prove -v tests/test_live_include_abbreviation.pl :: --live --style execute
prove -v tests/test_live_builtin_macro_bootstrap.pl :: --live
```

The include test's default `--style inc` remains supported. Its
`--expect-missing` mode is only for intentionally reproducing the old failure.
The builtin probe includes `%SYSCALL SET` with default autoload selection and
verifies that global macro-library bootstrap is skipped.

The shared corpus builder now validates all 500 oracles/fingerprints in memory
before replacing fixture files. A late generation error preserves the previous
programs and manifest. This is prevalidation, not an atomic filesystem transaction
if an I/O error happens during writing.

Programs, CLI/SAS logs, status and result JSON remain in ignored run folders.
The dated verified-results file and section 22 of
`../../RealExamples4ImprovingMCP4SAS.md` record final evidence and investigated
failures. These bounded checks do not validate every original macro, plot,
external dataset, statistical inference or concurrency scenario.

On **2026-11-02**, **500/500 distinct outcomes were verified across two runs**:
the main run verified 499 cases, and H2984 passed in a fresh, isolated session
after a remote termination without a definitive SAS log. The audit JSON keeps
that failed attempt and identifies the run supplying each verified result;
this was not a clean 500/500 single run. The complete offline suite passed
**4,156 top-level checks across 37 files**. Supplemental live checks passed
**6/6** for each deferred include form and **4/4** for default builtin loading.

Collect preserved evidence without rerunning or overwriting the source runs:

```bash
perl tools/collect_library_evaluation_results.pl --round 6 \
  --run SAS_Output_library500_live_fmsvBl \
  --run SAS_Output_library500_live_MeHTWQ \
  --output tests/library500_round6/verified_results_2026-11-02.json
```

The collector rechecks current body hashes, SAS logs, process exits and terminal
statuses, chooses only verified case attempts, and preserves unsuccessful
attempts separately. Duplicate attempts do not increase the distinct-case count.
