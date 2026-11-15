# Additional SAS library and sample-book test report

15 November 2026. Baseline: `d1c271fcb85a4075fda5077b7e9f7f49fe9a396f`.

## Result and scope

**1,000 new cases passed through both runners on SAS OnDemand for Academics:
2,000 successful case executions and 27,000 metric checks.** The two collections
contain 25 workflow families each, with 20 varied deterministic fixtures per
family. They are not 1,000 distinct research pipelines, 1,000 source files, or
1,000 connections. No published scientific findings are inferred from these
invented test datasets.

| Collection | Python | Perl | Metrics per runner | Main SAS submissions (Python / Perl) |
|---|---:|---:|---:|---:|
| Author-library workflows | 500/500 | 500/500 | 7,834 | 10 / 10 |
| Local online-book samples | 500/500 | 500/500 | 5,666 | 20 / 10 |

The 50 main submissions are separate from CSV/SVG download, cleanup, connection,
pilot and debugging operations. Each program exports the measured columns of its actual result as a keyed numerical table.
The results auditor rereads every CSV, checks the complete metric-key set,
missingness and values, rejects duplicate/unexpected keys, verifies actual SAS
completion markers and terminal status, and hashes the code/log/data evidence.
Final numeric tolerances are **1e-8 relative and 1e-12 absolute**; a small nonzero
probability cannot pass merely because SAS returned zero at a 1e-8 absolute
threshold. All saved results pass the tighter re-audit.

There are 2,000 checked numerical CSVs and 40 actual SAS-generated SVGs (20
sample graphics cases per runner). SVG checks establish well-formed, nonempty
rendering; they are not a publication-quality appearance review.

Additional post-fix checks passed for three macro/import cases through each
runner on licensed local Windows SAS, and three through each runner on fresh
SAS ODA sessions. Local Windows checks cover nested helper macros, grouped
aggregation, and plain-file transfer/import. They do not validate the Windows
7-Zip/GZIP branch. No licensed Linux SAS execution was available; Linux HOME and
STDIO-related logic has offline coverage only.

## Source coverage and distinctness

The source audit verifies 1,000 distinct normalized programs, with no identical
normalized program among the preceding 4,550 SAS corpus files. This is a source
identity check, not a claim that every program teaches an unrelated algorithm.
Inputs, shapes, missingness, settings and numerical oracles vary within families.

The original 25 macro files and four sample-book files still match their recorded
SHA256 hashes. All 30 extracted macro-definition snapshots and 120 input assets
are hash recorded. The source directories on H: were read without being edited.
The book samples were read from:
`H:/F_Queens/360yunpan/SASCodesLibrary/SAS PDF/sas online samples`.

Sample-book coverage includes `Integrading Results through Meta analytic review
using sas software.txt` (the actual local filename), `Multiple Comparisons and
Multiple Tests Using SAS.txt`, `Reading External Data Files Using SAS Examples
Handbook.txt`, and `Quick Results with SAS_GRAPH Software.txt`. This run does not
claim to execute every program in that directory or every macro in the library.

The meta-analysis listing credits Morgan C. Wang and Brad J. Bushman. The
multiple-testing listing credits Westfall, Tobias, Rom, Wolfinger and Hochberg;
the external-data examples credit Michele M. Burlew. Exact local source hashes,
definition lines and sample anchors are in the collection manifests. Full book
text is not copied into the repository.

## Defects reproduced and corrected

| Defect | Root cause and correction | Evidence |
|---|---|---|
| Python imports uploaded but SAS could not find them | Unquoted `zip=localpath,` was discovered but not rewritten because `=` and `,` were excluded as path boundaries. Added appropriate boundaries without rewriting filename substrings. | Failed library pilot 1; `test_unquoted_macro_input_paths.py`; final plain/GZIP/ZIP cases |
| Reserved SYSEXEC treated as a custom macro | Added the SAS macro statement to both built-in classifiers, avoiding unnecessary remote macro searches. | `test_sysexec_builtin.pl/.py`, transitive graph tests |
| Windows-launched Perl used an unrelated cygpath | PATH selected a different Cygwin installation. Prefer the converter beside the executing Perl. | Poisoned-PATH case in `test_python_path_boundary.pl`; live Perl reruns |
| Helper macros missing despite loading their caller | Perl scanned the submitted program without following calls inside local macro definitions. Added transitive discovery and name deduplication. | Failed isolated library run; NUMARGS-dependent cases; `test_transitive_dependency_batch.pl/.py`; final 500-case Perl run |
| Many small input transfers exceeded the 240-second test cap | CLI dependency discovery uploaded files individually even when archive transfers were enabled. All four worker/runner constructor paths in both compatibility CLIs now pass dependency batching. Actual transfer destinations replace temporary placeholders, including local SAS targets. | Failed import batches; batched-dependency log entries; final compressed-file runs |
| Archive upload still probed every new file separately | Both archive helpers now prime missing-file metadata in one SAS submission. Existing files retain the original full timestamp validation. | `test_persistent_archive.py`; final import batches |
| Local Windows SAS received `/home/oda.account` destinations | Home detection reused client ODA credentials regardless of target. Restrict the ODA shortcut to ODA hosts/profiles; other targets query accessible directories in SAS, with Windows USERPROFILE and WORK fallbacks. | Failed Windows transfer run; `test_target_home.pl/.py`; six successful Windows case executions |
| Timeout cleanup left a descendant alive | Process enumeration could use another Cygwin's `ps`. Prefer the sibling executable and accept the optional status column before PID. | Failed first full offline `test_cli_cleanup.pl`; successful descendant late-write regression after correction |

Dependency batching is the CLI default when archive transfers are enabled.
`--no-archive-transfers` retains individual transfers. Direct users of the Perl
module can opt in with `batch_dependencies => 1`. Failed transfers and duplicate
remote basenames stop submission. User SAS code is not silently replayed.

## Original-library corrections and remaining warnings

Three explicit corrections are made only in the **namespaced test copies**:
`GetZIPContents` uses a dot sentinel for an archive-root member;
`ImportFileHeadersFromZIP` reads that member without a nonexistent folder
prefix; its regex emptiness test uses LENGTH/SUPERQ rather than arithmetic
comparison. Each exact before/after replacement is recorded in the library
manifest. Root and nested members are both covered. These corrections have not
been applied to the original H: macro files.

Anchored column/member patterns allow trailing spaces because the original
macros match padded SAS metadata names. Selection tests verify both values and
the complete retained-column schema. This adaptation is not a silent change to
the original macro definitions.

**80 SAS warnings remain in each library run**: original macros use
self-referencing `CREATE TABLE` statements. Final values are independently
checked, but these warnings are retained and reported rather than suppressed.
The online-sample runs have no native SAS warnings. CLI messages announcing
uploads are distinct from warnings in the actual SAS runtime log.

Compatibility limits found during source inspection remain explicit:

- `calculate_binomial_P` computes a lower-tail CDF at the smaller count, not a
  generic two-sided binomial test. Its nondefault ratio/log-P limits include
  hardcoded behavior; only the documented tested defaults are covered here.
- `additive_geno2alleles` uses an `id` column internally; the tested fixtures
  supply it. Generalizing its sample-ID parameter remains library work.
- Multiple missing rows per group can multiply joins in `AddMissingTag4Grps`;
  these fixtures contain one such missing row per group.
- Legacy `compeff` conventions differ from some current standardized-effect
  definitions; the tests reproduce the listing's formula, using positive mean
  differences. They do not establish correct signed point-biserial results for
  negative effects. `mhodds` tests the pooled point estimate, not its legacy
  confidence-interval construction.
- Successful execution does not establish the independence assumptions of
  Fisher's combined-P method or the suitability of a fixed-effect model for a
  particular research dataset. Derived examples are labeled in the manifest.

## Workflow families

### library_workflows500

`pivot_complete`, `pivot_zero_fill`, `pivot_sentinel_fill`, `zscore_columns`, `zscore_rows`, `column_type_inventory`, `keep_regex_columns`, `exclude_regex_columns`, `rename_regex_columns`, `rank_rows_within_group`, `encode_group_keep_rows`, `encode_group_unique_descending`, `encode_compound_group`, `binomial_tail_and_ratio`, `dosage_to_alleles`, `convert_one_character_column`, `convert_three_character_columns`, `aggregate_columns_mean`, `aggregate_columns_sum`, `propagate_group_missing`, `layout_even_positions`, `import_plain_tsv`, `import_gzip_tsv`, `import_zip_member`, `import_gzip_row_window`.

### online_samples500

`meta_odds_four_scales`, `meta_zero_cell_correction`, `meta_fixed_odds`, `meta_fixed_odds_confidence`, `meta_weighted_effect_groups`, `meta_effect_size_scales`, `meta_fisher_correlation_pool`, `meta_fisher_correlation_intervals`, `meta_weighted_heterogeneity`, `meta_mantel_haenszel_point`, `adjust_data_bonferroni_sidak`, `adjust_proc_bonferroni`, `adjust_proc_sidak`, `adjust_proc_holm`, `adjust_proc_step_sidak`, `adjust_proc_hochberg`, `adjust_proc_bh_fdr`, `adjust_proc_by_fdr`, `adjust_fixed_sequence`, `combine_fisher_pvalues`, `meta_leave_one_out`, `external_quoted_csv`, `external_short_records`, `summary_grouped_plot_values`, `graphics_scatter_and_values`.

## Reproduction and retained evidence

See [tests/NEW_WORKFLOWS.md](../tests/NEW_WORKFLOWS.md). The source audit is
[NEW_WORKFLOW_SOURCE_AUDIT.json](NEW_WORKFLOW_SOURCE_AUDIT.json); numerical,
source, log and rendered-asset hashes are in
[NEW_WORKFLOW_EXECUTION_MANIFEST.json](NEW_WORKFLOW_EXECUTION_MANIFEST.json).
Post-fix Windows/ODA checks are in
[NEW_WORKFLOW_EXTRA_EVIDENCE.json](NEW_WORKFLOW_EXTRA_EVIDENCE.json).

Full local evidence directories:

- `SAS_Output_new1000_online_python`
- `SAS_Output_new1000_library_python_fixed`
- `SAS_Output_new1000_online_perl_fixed`
- `SAS_Output_new1000_library_perl_final`

Initial failed pilots and full attempts remain in the other
`SAS_Output_new1000_*` directories; no failed case was removed from the final
500-case selections. Final runs used test-only sessions and owned filenames.
All four final run cleanup/close operations succeeded. Source versions span
working revisions during debugging: the exact SAS programs are hash checked,
while the full runs should not all be attributed retrospectively to one final
Git revision. New runs preserve selected runtime source snapshots as well.

The final complete offline suite passed **124/124 scripts**, and the native
Python package passed **64/64 unit tests**. The numerical evidence validator
also passed seven targeted rejection/acceptance tests. The complete
regression-suite results and hashes are recorded separately in
`NEW_WORKFLOW_REGRESSION_RESULTS.json`. Large raw logs and generated outputs
remain local under ignored artifact directories; the frozen programs, inputs,
oracles, test tools, and compact evidence manifests are tracked.
