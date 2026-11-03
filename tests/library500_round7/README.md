# Seventh evaluation round: B3001–B3500

These **500 runnable SAS scenarios** use 50 behavior families with ten input
sizes each (N=2 through 11): **450 expected successes and 50 intentional SAS
errors**. They are synthetic programs derived from operations found in the
requested SAS book sample folder, rather than copies of book datasets or analyses.
Earlier evaluation corpora remain unchanged. These are 50 families with ten
scenarios each, rather than 500 unrelated algorithms.

The source folder contains 121 TXT files and one ZIP. Only TXT files containing
actual matching SAS code were used; URL-only files and the ZIP were not executed
or downloaded. `manifest.json` records the book title, filename, line, source and
line SHA-256, independent Perl oracle, tolerance and executable-body hash.

Eight actual book sources supplied the operation examples:

- A Handbook of Statistical Analyses Using SAS, Second Edition
- Applied Statistics and the SAS Programming Language, Fourth Edition
- Categorical Data Analysis Using the SAS System
- Cody's Data Cleaning Techniques Using SAS Software
- Combining and Modifying SAS Data Sets Examples, Version 6, First Edition
- Getting Started with the SQL Procedure, Version 6, First Edition
- SAS Macro Programming Made Easy, Second Edition
- SAS System for Mixed Models

| IDs | Coverage |
| --- | --- |
| B3001–B3100 | SELECT, LINK/RETURN, GOTO, LEAVE/CONTINUE, DO lists, OUTPUT/DELETE, multiple SET streams |
| B3101–B3190 | MERGE/UPDATE retention, IN flags, SUMMARY WAYS, MEANS IDGROUP/AUTONAME, FREQ ordering/missing |
| B3191–B3230 | LOGISTIC intercepts, binary predictor and aggregated FREQ input |
| B3231–B3270 | GENMOD Poisson, groups, binomial trials and exposure offsets |
| B3271–B3290 | MIXED intercept and symmetric slope |
| B3291–B3320 | One-sample, paired and two-group TTEST ODS statistics |
| B3321–B3350 | Kendall/partial correlations and population covariance |
| B3351–B3380 | RANK FRACTION/NPLUS1/PERCENT |
| B3381–B3400 | TRANSPOSE names and noncontiguous BY groups |
| B3401–B3430 | DATASETS member/column rename, format removal |
| B3431–B3450 | SQL calculated ordering and ungrouped HAVING remerge |
| B3451–B3460 | Expected UNION column type conflict |
| B3461–B3470 | Expected UPDATE missing-column error |
| B3471–B3480 | Expected character length limit error |
| B3481–B3490 | Expected RANK character-variable rejection |
| B3491–B3500 | Expected PRINT missing ID error |

Positive checks require exactly one result row, the numerical oracle, one exact
runtime marker, exit zero, no SAS ERROR and consistent completed terminal JSON.
LOGISTIC/GENMOD/MIXED use relative tolerance 1e-6; other checks use 1e-9.
The binary LOGISTIC fixture explicitly sets GCONV=1e-12 rather than relaxing its
oracle to accept the default convergence approximation. Two-group TTEST selects
the pooled difference row explicitly.

Negative checks require ordinary program-error exit 1, the expected actual SAS
ERROR, no success marker and consistent failed terminal JSON. Transport failures,
timeouts, source echoes and warnings cannot pass these checks. A passing negative
evaluation still means the SAS program intentionally failed.

The runner validates selected IDs and every selected source hash before remote
submission, then submits the verified source snapshot. Duplicate or unknown IDs,
empty selections and edited fixtures with stale manifest hashes fail locally.
The offline test compares against all earlier 3,000 programs after normalizing
generated case IDs and round labels, so renaming an old case is not novelty.
This detects equivalent generated bodies, not all possible semantic equivalences.

From the checkout in Cygwin:

```bash
export PATH=/usr/bin:$PATH
perl tools/build_library500_round7.pl \
  '/cygdrive/h/F_Queens/360yunpan/SASCodesLibrary/SAS PDF/sas online samples'
prove tests/test_library500_round7.pl tests/test_evaluation_corpus_integrity.pl
perl tests/run_live_library500.pl --live --round 7
perl tests/run_live_library500.pl --live --round 7 \
  --only B3211,B3311 --batch-size 1
```

The default uses five positive batches and 50 isolated negative submissions,
with a 180-second timeout per submission. All generated datasets use owned WORK
prefixes; cases clean their own tables. Failed steps can leave their own WORK
state for inspection. Original book files and user datasets are not modified.
Existing explicit helper-retention preferences remain in effect.

Logs and terminal JSON remain in ignored `SAS_Output_library500_live_*` folders.
The dated verified-results JSON and section 23 of
`../../RealExamples4ImprovingMCP4SAS.md` record the verified outcomes and failures
investigated. No Python evaluation scripts are required. These bounded checks do
not establish correctness of all original book analyses or statistical inference.

On **2026-11-02**, **500/500 distinct outcomes were verified across two runs**:
450 successful programs and 50 correctly detected intentional program errors.
The full rerun initially reported 490/500 because it had loaded an outdated
UPDATE diagnostic matcher; all ten affected cases then passed a fresh isolated
rerun. The audit preserves those original ten failed evaluation verdicts in
`recorded_failures` separately from current revalidation. This is not a clean
500/500 single invocation. The final offline suite passed **4,686 top-level
checks across 39 files**.

```bash
perl tools/collect_library_evaluation_results.pl --round 7 \
  --run SAS_Output_library500_live_bFfUyW \
  --run SAS_Output_library500_live_Qh8jnO \
  --output tests/library500_round7/verified_results_2026-11-02.json
```

The collector rechecks the preserved submitted batch against current verified
fixtures before accepting log evidence. The named run directories are this
session's preserved artifacts; substitute new directories for future runs.
