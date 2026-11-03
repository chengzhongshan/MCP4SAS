# MCP4SAS Validation Tasks

Run these tasks in order. Stop at the first unexplained failure, preserve its
artifacts, reduce it to a focused reproduction, and rerun the affected tier
after the fix. Live tests require a configured SAS ODA account. They do not
require Conda.

## 1. Repository And Runtime Gate

Confirm that the checkout is synchronized and free of unrelated edits:

```bash
git fetch origin
git status -sb
git diff --check
```

Install declared Perl dependencies into the repository-local library when
`local/perl5` is absent:

```bash
. install/common.sh
install_perl_deps
export PERL5LIB="$PWD/local/perl5/lib/perl5${PERL5LIB:+:$PERL5LIB}"
```

Expected evidence: all tracked Perl, shell, and Python files pass their syntax
checks. A missing declared module in an uninstalled checkout is an environment
failure, not automatically a source defect.

## 2. Complete Offline Behavior

Run every non-live `Test::More` file plus the two standalone diagnostics:

```bash
mapfile -t tests < <(
  for file in MCPDeps/test_*.pl tests/test_*.pl; do
    case "$file" in tests/test_live_*) continue;; esac
    rg -q 'use Test::More|use Test2' "$file" && printf '%s\n' "$file"
  done
)
prove "${tests[@]}"
perl MCPDeps/test_sas_oda_debug_macro_guard.pl
perl MCPDeps/test_sas_oda_connection_lifecycle.pl
python3 tests/test_github_sync.py
```

This tier covers parsing, dependency discovery, upload decisions, status and
error reporting, cleanup ownership, macro loading, and Git synchronization.

Run the independent 100-task adversarial batch separately so its stable task
IDs remain visible:

```bash
prove -v tests/new_validation_tasks_001_100.pl
```

`T001`-`T025` cover include discovery, `T026`-`T050` cover format and fileref
advisories, `T051`-`T075` cover SAS-log classification, and `T076`-`T100`
cover temporary-directory ownership and removal safety. These cases are
distinct from the earlier offline assertions.

Run the independently numbered COVID19_GWAS_Analyzer corpus batch:

```bash
prove -v tests/covid19_gwas_validation_tasks_001_500.pl
```

`C001`-`C200` validate real macro declarations, `C201`-`C400` validate their
invocation dependency tokens, `C401`-`C486` cover real `%include` sites,
`C487`-`C493` protect unquoted PRX boundaries containing `*/`, and
`C494`-`C500` analyze all seven top-level demo programs. The manifest records
the upstream repository commit and source path for every task. Rebuild it only
when intentionally advancing that source revision:

```bash
perl tools/build_covid19_validation_corpus.pl \
  /path/to/COVID19_GWAS_Analyzer
```

## 3. Minimal ODA Gate

An additional library-derived executable batch is available independently of
the source-analysis corpus:

```bash
prove tests/test_library500_evaluations.pl tests/test_include_source_order.pl
perl tests/run_live_library500.pl --live
```

This adds 500 runnable SAS cases across 50 behavior families with ten inputs
each. See `tests/library500/README.md` and section 17 of
`RealExamples4ImprovingMCP4SAS.md` for provenance, oracles, failure history and
the verified live results. The live command needs configured ODA credentials.

A second, different batch covers dataset operations, SQL, input/output and
macro execution:

```bash
prove tests/test_library500_round2.pl tests/test_resolve_macro_dependencies.pl \
  tests/test_evaluation_log.pl
perl tests/run_live_library500.pl --live --round 2
perl tests/test_live_resolve_macro_loading.pl --live
```

Its 500 scripts are `tests/library500_round2/R501.sas` through `R1000.sas`.
See the README in that directory and section 18 of the real-example report.

A third batch covers metadata, formats/catalogs, views, dates, macro quoting
and file handles:

```bash
prove tests/test_library500_round3.pl tests/test_unquote_macro_dependencies.pl
perl tests/run_live_library500.pl --live --round 3
prove -v tests/test_live_resolve_macro_loading.pl :: --live --mode unquote
```

Its 500 scripts are `tests/library500_round3/T1001.sas` through `T1500.sas`.
See that directory's README and section 19 of the real-example report.

The fourth round adds 450 numerical/statistical calculations and 50 intentional
SAS failures, each requiring its specific error and a failed terminal status:

```bash
prove tests/test_library500_round4.pl tests/test_expected_failure_evaluation.pl
perl tests/run_live_library500.pl --live --round 4
prove -v tests/test_live_sas_error_recovery.pl :: --live
```

Its scripts are `tests/library500_round4/F1501.sas` through `F2000.sas`.
Negative cases run individually; a verified expected failure remains a failed
SAS job. See section 20 of the real-example report for the distinction and results.

The fifth round adds dataset-handle, in-place update, structured-input and
macro-processing coverage, including abbreviated include discovery:

```bash
prove tests/test_library500_round5.pl tests/test_include_abbreviation.pl
perl tests/run_live_library500.pl --live --round 5
prove -v tests/test_live_include_abbreviation.pl :: --live
prove -v tests/test_live_builtin_macro_bootstrap.pl :: --live
```

Its 500 scripts are `tests/library500_round5/G2001.sas` through `G2500.sas`.
See section 21 of the real-example report for the %INC fix and final evidence.

The sixth round adds hash objects, PRX captures, calendar intervals, CSV/file
lifecycle and double-quoted deferred includes:

```bash
prove tests/test_library500_round6.pl tests/test_double_quoted_deferred_includes.pl \
  tests/test_corpus_prevalidation.pl tests/test_expected_failure_evaluation.pl
perl tests/run_live_library500.pl --live --round 6
prove -v tests/test_live_include_abbreviation.pl :: --live --style dosubl
prove -v tests/test_live_include_abbreviation.pl :: --live --style execute
```

See `tests/library500_round6/README.md` and section 22 of the real-example report.
Intentional errors require ordinary SAS exit 1; infrastructure/termination or
timeout exits never substitute for the expected program diagnostic. A collector
can combine verified rerun evidence while retaining failed attempts and counting
each case only once.

The seventh round uses the requested SAS book TXT samples, with provenance from
eight actual book titles and 50 new families (450 positives and 50 intentional
errors). It also validates actual source hashes before submission and rejects
duplicate selected IDs. Novelty checks ignore generated case and round labels.

```bash
perl tools/build_library500_round7.pl \
  '/cygdrive/h/F_Queens/360yunpan/SASCodesLibrary/SAS PDF/sas online samples'
prove tests/test_library500_round7.pl tests/test_evaluation_corpus_integrity.pl
perl tests/run_live_library500.pl --live --round 7
```

See `tests/library500_round7/README.md` and section 23 of the real-example report
for fixtures, corrections, commands and verified evidence.

The eighth round adds PRINCOMP/ANOVA/TABULATE, normal-score ranks, array/PDV
boundaries, SQL multisets and formatted class coverage from ten book samples.
It binds evidence to the numerical oracle, tolerance and error matcher as well
as the executable source; changed evaluation contracts require a fresh run.

```bash
perl tools/build_library500_round8.pl \
  '/cygdrive/h/F_Queens/360yunpan/SASCodesLibrary/SAS PDF/sas online samples'
prove tests/test_library500_round8.pl tests/test_evaluation_contract.pl \
  tests/test_evaluation_collection.pl tests/test_evaluation_corpus_integrity.pl
perl tests/run_live_library500.pl --live --round 8
```

See `tests/library500_round8/README.md` and section 24 of the real-example report.

The ninth round is a focused **50-example** suite for open-code macro problems:

```bash
perl tools/build_macro_open_code50.pl \
  '/cygdrive/h/F_Queens/360yunpan/SASCodesLibrary/SAS PDF/sas online samples'
prove tests/test_macro_open_code50.pl tests/test_open_code_macro_diagnostics.pl
perl tests/run_live_macro_open_code50.pl --live --raw
perl tests/test_live_open_code_preflight.pl --live
```

The diagnostic runner explicitly bypasses static preflight and isolates every
case in a fresh connection. Ordinary helpers retain preflight. It verifies SAS
errors, successful warning cases, and the existing strict unresolved-invocation
policy separately. See `tests/macro_open_code50/README.md` and section 25 of the
real-example report for the full audit and bounded reproductions.

Use a bounded login probe before expensive live tests:

```bash
SAS_ODA_RUN_TIMEOUT_SECONDS=120 \
  ./run_sas_codes_or_files_in_ODA.pl --check-sas-oda-login-only
```

Expected evidence: `proc setinit;run;` succeeds and the one-shot connection is
closed. A credential or network failure stops the live tier but does not
invalidate offline results.

## 4. Persistent Macro Freshness

```bash
perl tests/test_live_case_insensitive_macro_lookup.pl --live
```

Required behaviors:

- exact and case-insensitive source resolution;
- HOME and `~/Macros` precedence;
- an explicit higher-priority source refreshes a macro already compiled in the
  persistent session;
- ambiguous folded names fail without executing either source; and
- every uniquely named remote fixture is deleted and verified.

## 5. Deferred Includes And Redirected Logs

```bash
perl tests/test_live_deferred_and_printto.pl --live
perl tests/test_live_deferred_includes.pl --live
perl tests/test_live_include_file_lists.pl --live
```

Verify direct `%include`, `DOSUBL`, and `CALL EXECUTE`, including quoted paths
and multi-file include lists. A redirected SAS error must still produce a
nonzero wrapper result. For slow runs, inspect `output.run.status.json` and let
the configured timeout terminate the process tree.

## 6. Owned Remote Cleanup

```bash
perl tests/test_live_remote_directory_cleanup.pl --live
```

Only uniquely named test directories may be removed. Preview must be
non-mutating, regular files must be excluded, `_DELETE_` collisions must stop
the operation, no-match results must be explicit, and final cleanup must verify
that all owned fixtures are gone.

## 7. Acceptance And Release Evidence

Before committing:

```bash
prove tests/test_helper_entrypoint_parity.pl
cmp -s run_sas_codes_or_files_in_ODA.pl \
  run_sas_codes_or_script_in_ODA.pl
bash install/check_mcp4sas_install.sh
git diff --check
git diff --cached
git status -sb
```

Accept a change only when the focused reproduction, full offline suite, and
relevant live tier pass. Record assertion counts, live artifact directories,
timeout values, cleanup verification, and any intentionally skipped tier.
