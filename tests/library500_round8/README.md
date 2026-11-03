# Eighth evaluation round: J3501–J4000

This corpus adds **500 runnable SAS scenarios** from the requested SAS book TXT
collection: **50 new behavior families, ten inputs each** (N=2 through 11), with
450 expected successes and 50 intentional SAS program errors. These are
parameterized scenarios rather than 500 unrelated algorithms or account logins.
All data are synthetic; no original book datasets or private analyses are uploaded.

`manifest.json` records book title, filename and evidence line, source/line
SHA-256, executable-body hash, independent Perl oracle and numerical tolerance.
The generator reads the original TXT files without modifying them or following
book download links. ZIP contents are not required.

Ten actual source titles supplied matching SAS operations:

| Source title | Scenarios |
| --- | ---: |
| A Handbook of Statistical Analyses Using SAS, Second Edition | 160 |
| Applied Multivariate Statistics with SAS Software, Second Edition | 30 |
| Applied Statistics and the SAS Programming Language, Fourth Edition | 140 |
| Carpenter's Complete Guide to the SAS Macro Language, Second Edition | 20 |
| Cody's Data Cleaning Techniques Using SAS Software | 20 |
| Getting Started with the SQL Procedure, Version 6, First Edition | 80 |
| PROC TABULATE by Example | 20 |
| SAS System for Mixed Models | 10 |
| Step-by-Step Programming with Base SAS Software | 10 |
| The Power of PROC FORMAT | 10 |

| IDs | Coverage |
| --- | --- |
| J3501–J3540 | PRINCOMP covariance trace, correlation eigenvalue, eigenvector norm and score energy |
| J3541–J3550 | TABULATE sum output |
| J3551–J3580 | STANDARD missing replacement/preservation and selected variables |
| J3581–J3600 | ANOVA model/error sums of squares |
| J3601–J3630 | REG quadratic coefficient, no-intercept slope and perfect-fit R-square |
| J3631–J3640 | GLM interaction coefficient |
| J3641–J3650 | Two-way FREQ chi-square under independence |
| J3651–J3690 | Nonunit multidimensional bounds, temporary shift registers, VNAME and WHICHN arrays |
| J3691–J3720 | Empty DO WHILE, bottom-tested DO UNTIL and dependent nested bounds |
| J3721–J3740 | DATA/SQL name literals with option restoration |
| J3741–J3770 | NOTSORTED runs, descending BY boundaries and INDSNAME origins |
| J3771–J3800 | Dataset KEEP/RENAME/WHERE ordering and semicolon-containing labels |
| J3801–J3820 | SQL INTO delimited and numbered macro variables |
| J3821–J3880 | Three-way cross join, UNION CORR, INTERSECT/EXCEPT ALL, scalar subqueries and HAVING |
| J3881–J3900 | Preloaded empty formatted classes and multilabel membership |
| J3901–J3910 | One-way FREQ chi-square |
| J3911–J3940 | BLOM, TUKEY and van der Waerden normal-score symmetry |
| J3941–J3950 | COMPARE difference output |
| J3951–J3960 | Expected scalar-subquery multiple-row error |
| J3961–J3970 | Expected missing SORT key error |
| J3971–J3980 | Expected character analysis-variable rejection in SUMMARY |
| J3981–J3990 | Expected character analysis-variable rejection in PRINCOMP |
| J3991–J4000 | Expected reversed FORMAT range error |

All 500 normalized executable bodies differ from the earlier 3,500 programs.
The check ignores generated case IDs and round markers, preventing renaming from
counting as novelty. It does not establish all possible semantic equivalences.

Positive cases require exactly one result row, the independent numerical oracle,
one exact `ROUND8_PASS=Jnnnn` runtime marker, no actual SAS ERROR, exit zero and
consistent successful terminal JSON. Each manifest entry specifies tolerance
(1e-6 for the modeling/normal-score checks, 1e-9 otherwise). A passing negative
evaluation requires a matching actual SAS ERROR, ordinary exit 1, no marker and
consistent failed terminal JSON. Infrastructure errors/timeouts cannot pass as
expected program errors.

This round records an additional evaluation-contract SHA-256 covering the oracle,
tolerance, diagnostic and expected-failure classification. The collector requires
it for round eight and later. A changed matcher or oracle cannot silently reuse
an old result, even when the SAS executable-body hash is unchanged. Older runs
remain readable and are explicitly identified as lacking this contract evidence.
Submitted sources, source hashes, logs, exits and terminal status are also checked.

From the checkout in Cygwin:

```bash
export PATH=/usr/bin:$PATH
perl tools/build_library500_round8.pl \
  '/cygdrive/h/F_Queens/360yunpan/SASCodesLibrary/SAS PDF/sas online samples'
prove tests/test_library500_round8.pl tests/test_evaluation_contract.pl \
  tests/test_evaluation_collection.pl tests/test_evaluation_corpus_integrity.pl
perl tests/run_live_library500.pl --live --round 8
perl tests/run_live_library500.pl --live --round 8 \
  --only J3881,J3901 --batch-size 1
```

The default is five positive batches and 50 isolated negative submissions, with
a 180-second CLI timeout per submission. Only owned WORK tables, owned format
entries and owned macro variables are used. Options changed by successful cases
are restored. Cases remove their own resources; failed SAS steps may retain
their own WORK state for inspection. Source libraries and user data are unchanged.

See section 24 of `../../RealExamples4ImprovingMCP4SAS.md` for live results,
failure investigations and the collection command. Logs and terminal JSON are
preserved in ignored run directories. No Python evaluation scripts are required.
These checks do not establish correctness of all original book analyses or
statistical inference.

On **2026-11-02**, the corrected full live run
`SAS_Output_library500_live_oymzPc` passed **500/500 in one invocation**: 450
successful SAS programs and 50 correctly detected intentional errors. Independent
collection verified all 500 executable/source snapshots and evaluation contracts,
with no unsuccessful final-run attempts. The initial pilot and focused repair
run remain separate from this final evidence.

The complete offline suite passed **5,222 top-level checks across 42 files**.
A separate read-only audit matched all 500 source/line provenance records to the
ten original book files. Default helper cleanup left no `.mcp4sas_work_*`
directories after the live jobs finished.

```bash
perl tools/collect_library_evaluation_results.pl --round 8 \
  --run SAS_Output_library500_live_oymzPc \
  --output tests/library500_round8/verified_results_2026-11-02.json
```
