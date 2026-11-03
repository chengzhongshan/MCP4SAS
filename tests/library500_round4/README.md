# Fourth round: F1501–F2000

These **500 new executable SAS scenarios** cover 50 families at ten input sizes
(N=2 through 11). They comprise **450 successful numerical analyses and 50
intentional SAS failures**. A verified negative case is a successful test of
error reporting; its SAS program must still fail and its job status stay failed.

The manifest references operation-use sites in 13 original SAS library files,
with source filenames/lines, source/line SHA-256, independent Perl oracles and
normalized executable fingerprints. Families share procedure examples while
checking different statistical properties. These are 50 algorithms/scenarios
with ten input sizes each, not 500 unrelated algorithms or fresh logins.

| IDs | Coverage |
| --- | --- |
| F1501–F1600 | Sample/population variance, standard error, CV, weights/FREQ, grouped variance, range, missing counts |
| F1601–F1700 | Median/quartiles/IQR, skewness/kurtosis, CSS/USS, Pearson and Spearman correlation |
| F1701–F1800 | Covariance, listwise exclusion, regression coefficients/predictions, GLM group effects/residuals, uniform frequency percentages |
| F1801–F1900 | Row percentages, sparse/cumulative frequency tables, rank groups, standardization, dense ties, summary types, SQL moments |
| F1901–F1950 | Missing-aware weighted denominator, double-transpose checksum, row expansion, online Welford variance, array standardization |
| F1951–F1960 | Expected REG error: missing response variable |
| F1961–F1970 | Expected FREQ error: character weight |
| F1971–F1980 | Expected APPEND error: incompatible variable types |
| F1981–F1990 | Expected MEANS error: missing analysis variable |
| F1991–F2000 | Expected SQL error: ambiguous column |

Successful analyses must produce one result row, the expected numeric answer
and one exact `ROUND4_PASS=Fnnnn` runtime marker. Negative cases never emit a
success marker: they require an explicit nonzero normal process exit, an actual
SAS ERROR matching the manifest's expected diagnostic, and no contradictory
marker. Network errors, warnings, source echoes and process signals cannot
satisfy that rule. Every outcome also requires complete, consistent terminal
JSON: completed/successful for a positive test, failed/unsuccessful for a negative.

From the MCP4SAS checkout in Cygwin:

```bash
export PATH=/usr/bin:$PATH
perl tools/build_library500_round4.pl /cygdrive/h/F_Queens/360yunpan/SASCodesLibrary
prove tests/test_library500_round4.pl tests/test_expected_failure_evaluation.pl
perl tests/run_live_library500.pl --live --round 4
prove -v tests/test_live_sas_error_recovery.pl :: --live
```

The default batches the 450 successful cases into five jobs and isolates each
negative case in its own job: **55 SAS submissions** for the 500-case corpus.
The per-job CLI timeout is 180 seconds. Example isolated rerun:

```bash
perl tests/run_live_library500.pl --live --round 4 \
  --only F1521,F1731,F1911,F1991 --batch-size 1
```

Input data are synthetic. Each case creates/deletes only its own WORK prefix;
it does not change original source libraries or permanent user datasets. The
CLI's existing helper cleanup is retained, including its explicit option to
keep intermediates. SAS programs, logs, terminal status and structured results
remain under ignored `SAS_Output_library500_live_*` directories. Each result
now records the tested body fingerprint and whether an intentional error was
expected, rather than conflating expected errors with unexpected failures.

The recovery test separately creates one owned WORK dataset, triggers a SAS SQL
error, and then reads that same dataset successfully in the persistent session.
It verifies failed/completed job statuses and cleans only its owned table prefix.

See section 20 of `../../RealExamples4ImprovingMCP4SAS.md` for fixture failures,
improvements and final evidence. This batch validates bounded synthetic procedure
behavior and error reporting, not every original statistical model, inference,
plot, external dataset or concurrent-session scenario.

Final verification on **2026-11-02**: **500/500 expected outcomes verified**
(450 successful analyses, 50 correctly reported SAS failures). The full offline
suite passed **3,073 top-level checks across 32 files**. Persistent-session
error recovery passed **6/6**. See `verified_results_2026-11-02.json` for per-case
outcomes, fingerprints, diagnostics, terminal status and exit codes.
