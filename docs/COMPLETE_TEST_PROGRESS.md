# Complete runner regression work

Requested scope: execute all remaining root `tests/` scripts; add native Python
counterparts based on the Perl tests; fix reproduced defects and improve repeatable
execution. Work branch: `test/complete-runner-suite`, based on `b6157ef`.

## Completed verification

- Final combined offline suite: 116/116 scripts passed (54 Perl, 59 Python,
  3 Bash), plus the existing 64-test Python package suite.
- Every one of the 80 root Perl test/catalog scripts has a native Python
  counterpart. Source hashes and semantic coverage types are mapped in
  `docs/TEST_COUNTERPART_MAP.csv`.
- All 4,550 original numerical cases passed through the Python CLI, including
  50 raw macro-boundary cases. Independent saved-evidence audits reverified all
  4,550 source/oracle contracts. All 4,550 original Perl cases also passed.
- All eight MCP catalogs have 590/590 verified outcomes for each runtime after
  explicit reruns. Original rejected attempts remain in the audit; their
  orchestrator exits were not rewritten.
- Added native evaluation-contract, source-integrity and runtime-log evaluation
  functions. Captured hash-pinned public source-analysis calls from 17 original
  Perl tests for differential replay by Python without invoking Perl.
- Fixed single-file apostrophe uploads, nested quoted dependency rewriting,
  structural preflight terminal status, and late catalog prevalidation failures.
  Live quoted-include reruns and the existing 64 Python unit tests passed.
- Added strict runtime-only expected-error checks after finding an old false
  positive; fixed dead-session exception classification and owned-bridge cleanup.
- Final Python CI: six platforms/version combinations passed in run 43685346908.
  Targeted Perl CI: three OS jobs passed in run 43683422685.
- Author's pre-existing four blank lines in `MCPDeps/sas_oda_session_server.py` and
  untracked `debug.log` are outside this work.

## Evidence locations (ignored local execution outputs)

- `MCP4SAS_Use_Python/test-results/complete-suite/coverage.json`
- `MCP4SAS_Use_Python/test-results/remaining-live/execution.json`
- `MCP4SAS_Use_Python/test-results/python-counterparts-initial/coverage.json`
- `MCP4SAS_Use_Python/test-results/remaining-parity/`

The detailed result is `docs/COMPLETE_TEST_REPORT.md`; the machine-readable audit
is `docs/COMPLETE_TEST_EXECUTION_MANIFEST.json`. These are regression execution
records, not full publication/scientific validation. Live ODA work was performed
on Windows; other-platform CI and fake-SAS checks are identified separately.
