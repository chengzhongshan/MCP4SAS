# Tenth evaluation round: K4051–K4550

This adds **500 runnable scenarios across 50 behavior families**, ten input sizes
each (N=2 through 11): **450 expected successes and 50 intended SAS errors**.
They are parameterized scenarios, not 500 unrelated algorithms. All data are
synthetic. All 500 normalized bodies differ from the earlier 4,050 programs;
generated case and round labels do not establish novelty.

The requested SAS book TXT folder is read-only input. The manifest records book
title, filename/line, source/line SHA-256, body SHA-256, independent Perl oracle
and tolerance. The 200 distribution-identity cases are explicitly marked
`derived_extension`: they extend the books' PROBNORM/PROBIT probability examples
to documented CDF/PDF/QUANTILE APIs rather than claiming those exact calls occur
in the older source lines. Other cases use actual matching book operations.

| Actual source title | Scenarios |
| --- | ---: |
| Analysis of Clinical Trials Using SAS A Practical Guide | 210 |
| Combining and Modifying SAS Data Sets Examples, Version 6, First Edition | 30 |
| Applied Statistics and the SAS Programming Language, Fourth Edition | 120 |
| A Handbook of Statistical Analyses Using SAS, Second Edition | 20 |
| Carpenter's Complete Guide to the SAS Macro Language, Second Edition | 70 |
| PROC TABULATE by Example | 10 |
| Getting Started with the SQL Procedure, Version 6, First Edition | 30 |
| SAS Guide to Report Writing Examples, Version 6, First Edition | 10 |

| IDs | Coverage |
| --- | --- |
| K4051–K4250 | Distribution probability/density/quantile identities, gamma and beta functions |
| K4251–K4350 | Filter-before-transpose gene matrices, prefix arrays, expression transforms, cache gates and phenotype filters |
| K4351–K4450 | MIN IDGROUP, ASCII ordering, CLASSDATA, multiple transpose IDs, SQL ANY/ALL, metadata and missing values |
| K4451–K4500 | Unquoted macro PRX, stepped loops, formatted integers and QSYSFUNC punctuation |
| K4501–K4510 | Intended SQL IN type mismatch |
| K4511–K4520 | Intended incompatible CLASSDATA type |
| K4521–K4530 | Intended unassigned output library |
| K4531–K4540 | Intended invalid SYSEVALF conversion |
| K4541–K4550 | Intended out-of-range array subscript |

Numerical oracles use analytic identities or independent Perl arithmetic.
Distribution checks use `1e-10*max(1,abs(expected))`; other checks use
`1e-9*max(1,abs(expected))`. Positive
cases require one result row, one exact runtime marker, exit zero, no actual SAS
ERROR and completed successful terminal JSON. Negative cases require their actual
SAS ERROR, ordinary exit 1, no success marker and completed failed metadata.
Timeouts and remote terminations cannot pass as intended program errors.

From the checkout in Cygwin:

```bash
export PATH=/usr/bin:$PATH
perl tools/build_library500_round10.pl \
  '/cygdrive/h/F_Queens/360yunpan/SASCodesLibrary/SAS PDF/sas online samples'
prove tests/test_library500_round10.pl tests/test_evaluation_corpus_integrity.pl
perl tests/run_live_library500.pl --live --round 10
```

On **2026-11-03**, the initial corrected full run passed **500/500**
in `SAS_Output_library500_live_DAcgD4`. The pilot passed 49/50: the CLASSDATA case
produced its intended error, but its matcher omitted the actual word
“incompatible.” That diagnostic was reviewed and corrected before the full run.
The pilot is preserved separately and does not supply final evidence. The initial
full run used tolerance 1e-6 for distribution cases. Those 200 cases were then
tightened to 1e-10 and rerun separately, so small nonzero probabilities cannot
pass as zero. The current audit combines unchanged cases with that fresh block
and excludes the old distribution batches as stale. Final evidence therefore
comes from two runs rather than one invocation of the final corpus.

```bash
perl tools/collect_library_evaluation_results.pl --round 10 --skip-stale \
  --run SAS_Output_library500_live_DAcgD4 \
  --run SAS_Output_library500_live_VB0uLD \
  --output tests/library500_round10/verified_results_2026-11-03.json
```

Independent collection rechecks all 500 current programs, submitted batches,
evaluation contracts, SAS logs, exits and terminal statuses. The default is 55
submissions: five positive batches and 50 isolated negative jobs, with a
180-second timeout per job. Only owned WORK resources are used and cleaned.
No original book data, private datasets or user directories are uploaded/deleted.
Raw logs remain in ignored run folders. See section 26 of
`../../RealExamples4ImprovingMCP4SAS.md`. No Python evaluation scripts are required.

The final audit verified **500/500 cases and 500 evaluation contracts** across
two runs, with 200 older probability attempts explicitly excluded as stale and
no unsuccessful current attempts. All 500 source/line provenance records matched
the eight original book files. The complete offline suite passed **5,826
top-level checks across 46 files**.
