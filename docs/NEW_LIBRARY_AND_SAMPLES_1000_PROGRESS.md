# New library and online-sample tests — in progress

Requested 15 November 2026: 500 new cases from the author's SAS library and
another 500 from `SAS PDF/sas online samples`. Original source directories are
read-only. Existing unrelated `MCPDeps/sas_oda_session_server.py` changes and
`debug.log` must remain outside commits.

Baseline: `d1c271fcb85a4075fda5077b7e9f7f49fe9a396f`. Existing numerical
collections contain 4,550 cases, plus separate MCP and PoC catalogs.

The new collections will exercise actual library macros and sample-derived
workflows, rather than repeat the earlier elementary scalar-function cases.
Each case gets a source reference/hash, generated-input record, executable
program and independently calculated numerical oracle. Identity/source checks
will reject duplicates. Library macro names will be namespaced in the test
copies to avoid replacing the author's existing SAS ODA macros. No original
macro or sample file is edited.

Planned execution: both Perl and Python runners, independent test-only sessions,
retained submitted code/logs/status, collected numerical CSVs, numerical and
runtime checks kept separate. Cases may share a submission batch; report case
counts separately from batch/submission counts. Do not claim 500 connections
from 500 assertions. Intended program failures and source-library quirks must
not be confused with runner/infrastructure defects.

Current state: both 500-case corpora generated, with 25 workflow families each.
The source audit verifies 1,000 distinct normalized programs against the prior
4,550 cases, the original source hashes, all snapshot hashes, and input hashes.
Python online samples: 500/500 passed. Other full runs are still being completed;
consult their live `results.json` rather than extrapolating from pilot results.

Reproduced defects and changes so far:

- Python uploaded unquoted `zip=...` inputs but failed to rewrite them at equals
  and comma boundaries. Corrected and covered by focused offline regressions.
- Both reserved-macro classifiers now recognize SYSEXEC as a SAS statement.
- Perl selected an unrelated PATH cygpath when launched from Windows. It now
  prefers the converter beside the executing Perl; a poisoned-PATH test passes.
- Perl did not follow helper macros inside local macro definitions. Added
  transitive macro invocation discovery with duplicate suppression.
- CLI dependency uploads were performed separately, despite archive batching.
  Both compatibility entry points now pass the batching option to all workers.
  Destinations come from actual transfer results, including local SAS targets.
- Archive upload checked every not-yet-existing input with a separate remote
  metadata call. Both helpers now batch that probe, retaining the original full
  timestamp check for files that already exist.
- Three corrections to namespaced ZIP test copies are explicitly recorded in
  `manifest.json`: root-member directory, root-member reader, regex emptiness.
  No original H: file is edited. Anchored metadata regexes allow padded names.

Retain the failed first runs. Final evaluation must use fresh passing reruns,
not remove failed cases. Current final candidates:
`SAS_Output_new1000_online_python`,
`SAS_Output_new1000_library_python_fixed`,
`SAS_Output_new1000_online_perl_fixed`,
`SAS_Output_new1000_library_perl_final`.
The Perl library run is chained after a seven-case focused batch regression.
Full offline suite: `SAS_Output_new1000_all_offline`; package unit tests:
`SAS_Output_new1000_final_unit.log`. Finish and audit every final run, document
remaining warnings/platform limits, commit only intended files, push, check CI.


Completed execution and re-audit: all four full runs passed (500 cases each),
27,000 metrics checked with 1e-8 relative / 1e-12 absolute tolerance. Main SAS
submissions: 50. Numerical CSVs: 2,000; SVG outputs: 40. Local Windows SAS and
fresh ODA post-fix checks passed three cases per runner/target. Final offline
suite 124/124, native package 64/64, numerical evaluator 7/7. Cleanup and session
closure succeeded for all four full runs. Preserve 80 original self-referencing
SQL warnings per library run; the original H: sources remain unchanged.

Local-SAS HOME and matching-Cygwin-ps cleanup fixes were discovered and
verified; see NEW_LIBRARY_AND_SAMPLE_TEST_REPORT.md and the extra evidence
manifests. Remaining action: stage intended changes only (exclude pre-existing
four blank lines and debug.log), commit, push main, check CI. Do not claim
a clean user working tree while their edits remain.

All 1,152 frozen assets also match the staged Git bytes. Publishing and CI
checks follow this validated checkpoint; the original source library and book
remain unchanged. Final run/report files above are authoritative.
